/**
 * Created by frans fourie on 2022/12/08.
 */

trigger trgContentVersion on ContentVersion (after insert, after update, before delete) {


    System.debug('in trigger');
    for (ContentVersion cv : Trigger.new) {
        if (Trigger.isDelete) {
            System.debug('in delete');

            LoanApplicant la = [SELECT Id, relatedFilesIds__c, Received_Documents__c FROM LoanApplicant WHERE Id = :cv.FirstPublishLocationId];

            la.relatedFilesIds__c = la.relatedFilesIds__c.replace(cv.Id + ';', '');
            la.relatedFilesIds__c = la.relatedFilesIds__c.replace(cv.Id, '');

            List<String> cvIds = la.relatedFilesIds__c.split(';');

            List<ContentVersion> cvList = [SELECT Id, Title FROM ContentVersion WHERE Id IN :cvIds];

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
        } else {

            System.debug(cv.Title);
            if (cv.VersionNumber != '1') {
                cv.addError('Your organization does not support the uploading of new document versions. Please upload documents from the file upload screen');
            }
            String parentObjectType;
            try {
                parentObjectType = String.valueOf(cv.FirstPublishLocationId.getSobjectType()).removeEnd('__c');
            } catch (Exception e) {
                System.debug('');
            }
            List<FileManagerGetMDT.MetaData> md = FileManagerGetMDT.getGlobalPickList('ContentVersion', 'Category__c', 'FileClassification__c');
            String fileNames = '';
            for (Integer i = 0; i < md.size(); i++) {
                fileNames = fileNames + md[i].fileName + ' ';

            }


//        if (parentObjectType == 'LoanApplicant' && cv.Category__c != 'NotSpecified' && fileNames.contains(cv.Title) && Trigger.isInsert && (cv.Title.contains('Consent Document') || cv.Title.contains('Credit Report') || cv.Title.contains('Offer To Purchase') || cv.Title.contains('Preapproval'))) {
            if (parentObjectType == 'LoanApplicant' && cv.Category__c != 'NotSpecified' && fileNames.contains(cv.Title) && Trigger.isInsert) {
                LoanApplicant la = [SELECT Id, Name, Requested_Documents__c, Received_Documents__c, relatedFilesIds__c FROM LoanApplicant WHERE Id = :cv.FirstPublishLocationId LIMIT 1];

                Set<String> fileIdsSet = new Set<String>();
                if (la.relatedFilesIds__c != null) {
                    List<String> idList = new List<String>();
                    idList = la.relatedFilesIds__c.split(';');
                    fileIdsSet.addAll(idList);
                }

                fileIdsSet.add(cv.Id);

                if (!fileIdsSet.isEmpty()) {
                    String fileIdsString = '';
                    for (String str : fileIdsSet) {
                        fileIdsString = fileIdsString + str + ';';
                    }
                    la.relatedFilesIds__c = fileIdsString.removeEnd(';');
                }

                Set<String> receivedDocsSet = new Set<String>();

                if (la.Received_Documents__c != null) {
                    List<String> receivedDocs = la.Received_Documents__c.split(';');
                    receivedDocsSet.addAll(receivedDocs);
                }
                receivedDocsSet.add(cv.Title);

                String uploadedDocuments = '';
                if (!receivedDocsSet.isEmpty()) {
                    for (String element : receivedDocsSet) {
                        uploadedDocuments = uploadedDocuments + element + ';';
                    }
                    la.Received_Documents__c = uploadedDocuments.removeEnd(';');
                    la.uploadedDocumentsVerification__c = uploadedDocuments.removeEnd(';');
                    update la;
                }
            }
            if (parentObjectType == 'LoanApplicant' && cv.Category__c != 'NotSpecified' && fileNames.contains(cv.Title) && Trigger.isUpdate) {
                LoanApplicant la = [SELECT Id, Name, Requested_Documents__c, Received_Documents__c, relatedFilesIds__c FROM LoanApplicant WHERE Id = :cv.FirstPublishLocationId LIMIT 1];

                Set<String> fileIdsSet = new Set<String>();
                if (la.relatedFilesIds__c != null) {
                    List<String> idList = new List<String>();
                    idList = la.relatedFilesIds__c.split(';');
                    fileIdsSet.addAll(idList);
                }

                fileIdsSet.add(cv.Id);

                if (!fileIdsSet.isEmpty()) {
                    String fileIdsString = '';
                    for (String str : fileIdsSet) {
                        fileIdsString = fileIdsString + str + ';';
                    }
                    la.relatedFilesIds__c = fileIdsString.removeEnd(';');
                }

                Set<String> receivedDocsSet = new Set<String>();

                if (la.Received_Documents__c != null) {
                    List<String> receivedDocs = la.Received_Documents__c.split(';');
                    receivedDocsSet.addAll(receivedDocs);
                }
                receivedDocsSet.add(cv.Title);

                String uploadedDocuments = '';
                if (!receivedDocsSet.isEmpty()) {
                    for (String element : receivedDocsSet) {
                        uploadedDocuments = uploadedDocuments + element + ';';
                    }
                    la.Received_Documents__c = uploadedDocuments.removeEnd(';');
                    la.uploadedDocumentsVerification__c = uploadedDocuments.removeEnd(';');
                    update la;
                }
            }


            ContentDistribution cd = new ContentDistribution();
            if ((parentObjectType == 'LoanApplicant' && cv.Title.contains('Credit Report')) || (parentObjectType == 'Opportunity' && (cv.Title.contains('Preapproval') || cv.Title.contains('Offer To Purchase')))) {

                try {
                    if (cv.Title.contains('Preapproval') || cv.Title.contains('Credit Report')) {
                        cd.ContentVersionId = cv.Id;
                        cd.Name = cv.Title;
                        cd.PreferencesPasswordRequired = false;
                        cd.PreferencesNotifyOnVisit = false;
                        cd.PreferencesNotifyRndtnComplete = false;

                        insert cd;


                        cd = [
                                SELECT Id, ContentDownloadUrl, DistributionPublicUrl
                                FROM ContentDistribution
                                WHERE Id = :cd.Id
                                LIMIT 1
                        ];
                    }
                } catch (Exception e) {
                }
                if (parentObjectType == 'Opportunity' && (cv.Title.contains('Preapproval') || cv.Title.contains('Offer To Purchase'))) {

                    Opportunity opp = [SELECT Id, PACertPublicDownloadLink__c, PACertPublicViewLink__c, relatedFilesIds__c FROM Opportunity WHERE Id = :cv.FirstPublishLocationId LIMIT 1];

                    if (cv.Title.contains('Preapproval')) {
                        opp.PACertPublicDownloadLink__c = cd.ContentDownloadUrl;
                        opp.PACertPublicViewLink__c = cd.DistributionPublicUrl;
                        opp.Wrap_Up_Reason__c = 'Automated';
                    }

                    Set<String> fileIdsSet = new Set<String>();
                    if (opp.relatedFilesIds__c != null) {
                        List<String> idList = new List<String>();
                        idList = opp.relatedFilesIds__c.split(';');
                        fileIdsSet.addAll(idList);
                    }

                    fileIdsSet.add(cv.Id);

                    if (!fileIdsSet.isEmpty()) {
                        String fileIdsString = '';
                        for (String str : fileIdsSet) {
                            fileIdsString = fileIdsString + str + ';';
                        }
                        opp.relatedFilesIds__c = fileIdsString.removeEnd(';');
                    }
                    opp.Wrap_Up_Reason__c = 'Automated';
                    update opp;
                }

            } if (parentObjectType == 'LoanApplicant' && cv.Title.contains('Credit Report')) {

                LoanApplicant loanApp = [SELECT Id, CreditReportPublicDownloadLink__c, CreditReportPublicViewLink__c FROM LoanApplicant WHERE Id = :cv.FirstPublishLocationId LIMIT 1];
                loanApp.CreditReportPublicDownloadLink__c = cd.ContentDownloadUrl;
                loanApp.CreditReportPublicViewLink__c = cd.DistributionPublicUrl;

                update loanApp;

            }
        }
    }

}