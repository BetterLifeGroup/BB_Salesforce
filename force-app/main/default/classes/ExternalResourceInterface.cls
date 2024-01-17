/**
 * Created by frans fourie on 2022/10/11.
 */

public with sharing class ExternalResourceInterface {

    @AuraEnabled
    public static List<ContentVersion> getAllFiles(Id recordId) {
        System.debug(recordId);
        String objectType;
        try {
            objectType = String.valueOf(recordId.getSobjectType()).removeEnd('__c');
        } catch (Exception e) {
        }

//        List<OpportunityTeamMember> oppTeam = new List<OpportunityTeamMember>();
//        try {
//            oppTeam = [SELECT Id, UserId FROM OpportunityTeamMember WHERE OpportunityId = :[SELECT Id, SourcePAOpportunity__c from LoanApplicant where Id = :recordId limit 1].SourcePAOpportunity__c];
//        } catch (Exception e) {
//        }
//        Boolean proceed = false;
//        String oppOwner;
//        try {
//            oppOwner = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :[SELECT Id, SourcePAOpportunity__c from LoanApplicant where Id = :recordId limit 1].SourcePAOpportunity__c LIMIT 1].OwnerId;
//        } catch (Exception e) {
//            oppOwner = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :recordId].OwnerId;
//        }
//        User runningUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
//
//        if (oppOwner == UserInfo.getUserId() || runningUser.Profile.Name == 'System Administrator') {
//            proceed = true;
//        }
//        for (OpportunityTeamMember member : oppTeam) {
//            if (member.UserId == UserInfo.getUserId()) {
//                proceed = true;
//            }
//        }

        Boolean proceed = true; // TODO - Temporary fix to display all files to all users. Not deleting commented code in case we have to revert.
        if (proceed == true) {
            if (objectType == 'LoanApplicant') {
                List<String> idList = new List<String>();
                try {
                    LoanApplicant la = [SELECT Id, relatedFilesIds__c FROM LoanApplicant WHERE Id = :recordId];

                    idList = la.relatedFilesIds__c.split(';');
                } catch (Exception e) {
                    System.debug(e);
                }

                return [SELECT Id, Title, Category__c, ContentDocumentId, CreatedDate, FileExtension, ContentSize, VersionDataUrl FROM ContentVersion WHERE Id IN :idList ORDER BY Title];
            } else if (objectType == 'Opportunity') {


                List<String> idList = new List<String>();
                try {
                    Opportunity opp = [SELECT Id, relatedFilesIds__c FROM Opportunity WHERE Id = :recordId];

                    idList = opp.relatedFilesIds__c.split(';');
                } catch (Exception e) {
                    System.debug(e);
                    return new List<ContentVersion>();
                }

                return [SELECT Id, Title, Category__c, ContentDocumentId, CreatedDate, FileExtension, ContentSize, VersionDataUrl FROM ContentVersion WHERE Id IN :idList ORDER BY Title];


            }
        } else {
            return [SELECT Id, Title, Category__c, ContentDocumentId, CreatedDate, FileExtension, ContentSize, VersionDataUrl FROM ContentVersion WHERE FirstPublishLocationId = :recordId ORDER BY Title];
        }
        return new List<ContentVersion>();
    }

    @AuraEnabled
    public static void prepFileForDelete(String contentDocumentId) {
        ContentVersion cv = [SELECT Id, FirstPublishLocationId FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId];
        cv.ReasonForChange = 'delete';
        update cv;
    }

    @AuraEnabled
    public static Boolean deleteFile(String contentDocumentId, String applicantId) {

        System.debug(contentDocumentId);
        try {
            ContentVersion cv = [SELECT Id, Title, FirstPublishLocationId FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId];

            Boolean cdlToDelete = false;

            if (cv.Title == 'Consent Document') {
                List<ContentDocumentLink> cdl = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :contentDocumentId AND LinkedEntityId = :applicantId];
                cdlToDelete = true;
                delete cdl;
            }

            LoanApplicant la = [SELECT Id, relatedFilesIds__c, Received_Documents__c FROM LoanApplicant WHERE Id = :applicantId FOR UPDATE ];

            la.relatedFilesIds__c = la.relatedFilesIds__c.replace(cv.Id + ';', '');
            la.relatedFilesIds__c = la.relatedFilesIds__c.replace(cv.Id, '');

            List<String> cvIds = la.relatedFilesIds__c.split(';');

            List<ContentVersion> cvList = [SELECT Id, Title, FirstPublishLocationId FROM ContentVersion WHERE Id IN :cvIds];

            Set<String> uploadedDocNames = new Set<String>();

            for (ContentVersion cvLoopItem : cvList) {
                uploadedDocNames.add(cvLoopItem.Title);
            }

            String uploadedDocs = '';
            for (String str : uploadedDocNames) {
                uploadedDocs = uploadedDocs + str + ';';
            }
            la.Received_Documents__c = uploadedDocs.removeEnd(';');

            update la;

            if (!cdlToDelete) {
                ContentDocument cd = new ContentDocument(Id = contentDocumentId);
                delete cd;

                return true;
            }

            return true;


        } catch (Exception e) {
            System.debug('failed to delete - ' + e);
            return false;
        }
    }

}