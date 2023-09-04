/**
 * Created by frans fourie on 2023/05/23.
 */

public with sharing class OpportunityReassign {

    public static String skill;
    public static String regionName;
    public static Boolean isSelfEmployed;

    @InvocableMethod
    public static List<ReassignResponse> methods(List<ReassignRequest> req) {
        List<ReassignResponse> responseList = new List<OpportunityReassign.ReassignResponse>();
        OpportunityReassign.ReassignResponse resp = new OpportunityReassign.ReassignResponse();

        if (req[0].method == 'Reassign') {
            System.debug(req[0]);
            responseList.add(checkForRelatedConsultant(req[0]));
            return responseList;
        } else {

            resp.hasError = true;
            resp.errorMessage = 'No/Incorrect Method Specified';

            responseList.add(resp);
            return responseList;
        }

    }

    public static ReassignResponse checkForRelatedConsultant(ReassignRequest req) {
        return getNewOppOwner(req);

    }

    public static ReassignResponse getNewOppOwner(ReassignRequest req) {


        return getApplicableConsultants(req.applicationType, req.regionId, req.selfEmployed);
    }

    public static ReassignResponse getApplicableConsultants(String skills, String RegionAccountId, Boolean selfEmployed) {

        skill = skills;
        isSelfEmployed = selfEmployed;
        regionName = [SELECT Id,Name FROM Account WHERE Id = :RegionAccountId LIMIT 1].Name;

        ReassignResponse resp = new ReassignResponse();
        try {
            List<AccountContactRelation> acrList = new List<AccountContactRelation>();
            if (selfEmployed) {
                acrList = [
                        SELECT Id, SkillGroup__c, ContactId
                        FROM AccountContactRelation
                        WHERE AccountId = :RegionAccountId AND SkillGroup__c INCLUDES ('Self-Employed')
                ];
            } else {
                 acrList = [
                        SELECT Id, SkillGroup__c, ContactId
                        FROM AccountContactRelation
                        WHERE AccountId = :RegionAccountId AND SkillGroup__c INCLUDES (:skills)
                ];
            }
            List<String> contactIds = new List<String>();
            for (AccountContactRelation acr : acrList) {
                contactIds.add(acr.ContactId);
            }

            Contact assignee = [SELECT Id, Consultant__c, Consultant__r.IsActive
            FROM Contact
            WHERE Id IN :contactIds AND Consultant__r.IsActive = TRUE AND RecordType.Name = 'Betterbond Contact' AND RecordType.SobjectType = 'Contact'
            ORDER BY LastOppAssignDateTime__c ASC NULLS FIRST LIMIT 1];

            resp.hasError = false;
            resp.newOwnerId = assignee.Consultant__c;
            return resp;
        } catch (Exception e) {
            resp.hasError = true;
            resp.errorMessage = 'No User found for the following criteria:\nSkillgroup: '
                    + skill + ' \nSelf Employed: ' + (isSelfEmployed == true ?'Yes ' :'No ' + '\nRegion: ' + regionName);
            return resp;
        }
    }
//    Comment

    public class ReassignRequest {
        @InvocableVariable public String method;
        @InvocableVariable public String regionId;
        @InvocableVariable public String applicationType;
        @InvocableVariable public Boolean selfEmployed;

    }

    public class ReassignResponse {
        @InvocableVariable public String newOwnerId;
        @InvocableVariable public String errorMessage;
        @InvocableVariable public Boolean hasError;
    }
}