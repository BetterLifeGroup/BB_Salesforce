global class Invocable_AllocateOpportunity {

    global class Request {
        @InvocableVariable
        global String opportunityGroup;
        global string oppDefaultType = 'Bond';
    }

    global class Result {
        @InvocableVariable
        global String ownerId;
        @InvocableVariable
        global Boolean failed;
        @InvocableVariable
        global String errorMessage;
    }

    @InvocableMethod(label='Assign Opportunity Owner'
            description='Assigns the Opportunity to a Group Member in the specified Group, in Round Robin fashion')
    public static List<Result> allocateOpportunity(List<Request> varsList) {
        /* assignment rules:
         - get all group members and sort each of their leads by createddate (DESC)
         - if any of these group members have never had an opportunity - assign to them
         - else, assign lead to the group member who's newest lead is the oldest lead out of the group.
         */
        List<Result> results = new List<Result>();

        //get all active and available users as activeGroupMembers for our Group
        List<String> groups = new List<String>();
        List<String> defaultType = new List<String>();

        Set<Id> activeGroupMembers = new Set<Id>();
        Map<String, Set<Id>> groupUserMap = new Map<String, Set<Id>>();

        for (Request vars : varsList) {
            List<String> groupNames = vars.opportunityGroup.split(';');
            for (String groupName : groupNames) {
                groups.add(groupName);
                defaultType.add(vars.oppDefaultType);

            }
        }

        List<CollaborationGroupMember> noLeadResults = [
                SELECT MemberId
                FROM CollaborationGroupMember
                WHERE CollaborationGroup.Name IN :groups
                AND Member.AvailableforRouting__c = TRUE
                AND Member.isActive = true
                AND MemberId NOT IN (SELECT OwnerId FROM Opportunity)
                AND CollaborationRole != 'Admin'
        ];

        if (noLeadResults.size() > 0) {
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
                    SELECT Count(Id) leadCount, OwnerId, Max(CreatedDate) newestLead
                    FROM Opportunity
                    WHERE OwnerId IN (
                            SELECT MemberId
                            FROM CollaborationGroupMember
                            WHERE CollaborationGroup.Name IN :groups
                            AND Member.AvailableforRouting__c = TRUE
                            AND Member.isActive = true
                            AND CollaborationRole != 'Admin'
                    )
                    GROUP BY OwnerId
                    ORDER BY Max(CreatedDate), Count(Id) ASC
            ];

            Integer maxGroupMembers = resultList.size();
            Integer currentGroupMember = 0;
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
        System.debug('Results: ' + results);
        return results;
    }
}