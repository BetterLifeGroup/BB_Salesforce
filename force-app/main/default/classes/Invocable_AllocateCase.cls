global class Invocable_AllocateCase {

    global class Request {
        @InvocableVariable
        global String caseGroup;
        global String caseDefaultType = 'Verification Team';
    }

    global class Result {
        @InvocableVariable
        global String ownerId;
        @InvocableVariable
        global Boolean failed;
        @InvocableVariable
        global String errorMessage;
    }

    @InvocableMethod(Label='Assign Case Owner'
            Description='Assigns the Case to a Group Member in the specified Group, in Round Robin fashion')
    public static List<Result> allocateCase(List<Request> varsList) {
        /* assignment rules:
         - get all group members and sort each of their leads by createddate (DESC)
         - if any of these group members have never had an case - assign to them
         - else, assign lead to the group member who's newest lead is the oldest lead out of the group.
         */
        List<Result> results = new List<Result>();

        Boolean failed = true;

        //get all active and available users as activeGroupMembers for our Group
        List<String> groups = new List<String>();
        List<String> defaultType = new List<String>();
        Set<Id> activeGroupMembers = new Set<Id>();
        Map<String, Set<Id>> groupUserMap = new Map<String, Set<Id>>();

        for (Request vars : varsList) {
            groups.add(vars.caseGroup);
            defaultType.add(vars.caseDefaultType);
        }
        System.debug('Groups: ' + groups);

        List<CollaborationGroupMember> noLeadResults = [
                SELECT MemberId , Member.Name
                FROM CollaborationGroupMember
                WHERE CollaborationGroup.Name IN :groups
                AND Member.AvailableforRouting__c = TRUE
                AND Member.IsActive = TRUE
                AND MemberId NOT IN (SELECT OwnerId FROM Case)
                AND CollaborationRole != 'Admin'
        ];

        if (noLeadResults.size() > 0) {
            failed = false;
            Integer maxGroupMembers = noLeadResults.size();
            Integer currentGroupMember = 0;
            for (Request vars : varsList) {
                Result thisResult = new Result();
                thisResult.ownerId = (Id) noLeadResults[currentGroupMember].get('MemberId');
                results.add(thisResult);
                currentGroupMember++;
                if (currentGroupMember >= maxGroupMembers) {
                    currentGroupMember = 0;
                }
            }
        } else {

            List<AggregateResult> resultList = [
                    SELECT COUNT(Id) caseCount, OwnerId, MAX(CreatedDate) newestCase
                    FROM Case
                    WHERE OwnerId IN (
                            SELECT MemberId
                            FROM CollaborationGroupMember
                            WHERE CollaborationGroup.Name IN :groups
                            AND Member.AvailableforRouting__c = TRUE AND Member.IsActive = TRUE
                            AND CollaborationRole != 'Admin'
                    )
                    GROUP BY OwnerId
                    ORDER BY MAX(CreatedDate), COUNT(Id) ASC
            ];

            Integer maxGroupMembers = resultList.size();
            if (resultList.size() > 0) {
                failed = false;
            }
            Integer currentGroupMember = 0;
            System.debug('Query AR Results: ' + resultList);
            if (resultList.size() > 0) {
                for (Request vars : varsList) {
                    Result thisResult = new Result();
                    thisResult.ownerId = (Id) resultList[currentGroupMember].get('OwnerId');
                    results.add(thisResult);
                    currentGroupMember++;
                    if (currentGroupMember >= maxGroupMembers) {
                        currentGroupMember = 0;
                    }
                }
            }
        }
        System.debug('Results: ' + results);
        if (failed) {
            Result thisResult = new Result();
            thisResult.failed = true;
            results.add(thisResult);
        }
        return results;
    }

}