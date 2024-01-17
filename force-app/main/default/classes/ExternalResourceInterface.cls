/**
 * Created by frans fourie on 2022/10/11.
 */

public with sharing class ExternalResourceInterface {

//    @AuraEnabled
//    public static void CreateExternalResourceRecord(String fileName, Integer fileSize, String fileType, String container, Id recordId) {
//        System.debug(recordId);
//        String objectType = String.valueOf(recordId.getSobjectType());
//        System.debug(objectType);
//        File_Manager__mdt mdtParams = [
//                SELECT Id, fileNames__c, ExpiryTime__c, Object__c
//                FROM File_Manager__mdt
//                WHERE
//                        FileNames__c = :fileName AND Object__c = :objectType
//                LIMIT 1
//        ];
//        System.debug(mdtParams);
//        ExternalResources__c er = new ExternalResources__c();
//        try {
//            er = [
//                    SELECT Id, FileName__c, FileType__c, Container__c
//                    FROM ExternalResources__c
//                    WHERE FileName__c = :fileName AND Container__c = :container
//                    LIMIT 1
//            ];
//        } catch (Exception e) {
//        }
//
//        if (er.Id != null) {
//            delete er;
//        }
//
//        ExternalResources__c newEr = new ExternalResources__c();
//        newEr.FileName__c = fileName;
//        newEr.ParentId__c = recordId;
//        if (mdtParams.ExpiryTime__c != null) {
//            newEr.ExpiryDate__c = Date.today().addDays((Integer) mdtParams.ExpiryTime__c);
//        }
//        insert newEr;
//
//    }
//    @AuraEnabled
//    public static ExternalResources__c GetExternalResource(String fileName, String containerInLowerCase) {
//        System.debug(fileName + '    ' + containerInLowerCase);
//
//        return [
//                SELECT Id, FileName__c, FileType__c, Container__c
//                FROM ExternalResources__c
//                WHERE FileName__c = :fileName AND Container__c = :containerInLowerCase
//                LIMIT 1
//        ];
//
//
//    }

//    @AuraEnabled
//    public static Boolean DeleteExternalResource(String fileName, String containerInLowerCase, Id recordId) {
//
//        ExternalResourceInterface.deleteContainer(recordId, containerInLowerCase);
//
//        System.debug(fileName + '    ' + containerInLowerCase + '    ' + recordId);
//
//        Boolean result = true; //TODO
//
//        ExternalResources__c er = [
//                SELECT Id, FileName__c, FileType__c, Container__c
//                FROM ExternalResources__c
//                WHERE FileName__c = :fileName AND Container__c = :containerInLowerCase
//                LIMIT 1
//        ];
//
//        delete er;
//
//        return result;
//
//    }

//    public static void deleteContainer(Id recordId, String containerInLowerCase) {
//
//        List<ExternalResources__c> erList = new List <ExternalResources__c>();
//        try {
//            erList = [
//                    SELECT Id, Container__c
//                    FROM ExternalResources__c
//                    WHERE Container__c = :containerInLowerCase
//            ];
//        } catch (Exception e) {
//        }
//        System.debug(erList.size());
//        if (erList.size() == 1) {
//
//        }
//
//    }

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