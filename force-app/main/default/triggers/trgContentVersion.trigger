/**
 * Created by frans fourie on 2022/12/08.
 */

trigger trgContentVersion on ContentVersion (after insert, after update) {


    for (ContentVersion cv : Trigger.new) {

        System.debug('intrigger');
        String parentObjectType = String.valueOf(cv.FirstPublishLocationId.getSobjectType()).removeEnd('__c');

        List<FileManagerGetMDT.MetaData> md = FileManagerGetMDT.getGlobalPickList('ContentVersion', 'Category__c', 'FileClassification__c');
        String fileNames = '';
        for (Integer i = 0; i < md.size(); i++) {
            fileNames = fileNames + md[i].fileName + ' ';

        }


        if (parentObjectType == 'LoanApplicant' && cv.Category__c != 'NotSpecified' && fileNames.contains(cv.Title) && Trigger.isInsert && (cv.Title.contains('Consent Document') || cv.Title.contains('Credit Report') || cv.Title.contains('Offer To Purchase') || cv.Title.contains('Preapproval'))) {
            System.debug('intrigger1' + cv.Category__c);
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
            System.debug('intrigger1' + cv.Category__c);
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
                    System.debug('intrigger2');
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

                System.debug('intrigger3');
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
                System.debug('intriggerOPP' + opp);
                update opp;
            }

        } if (parentObjectType == 'LoanApplicant' && cv.Title.contains('Credit Report')) {

            System.debug('intrigger4');
            LoanApplicant loanApp = [SELECT Id, CreditReportPublicDownloadLink__c, CreditReportPublicViewLink__c FROM LoanApplicant WHERE Id = :cv.FirstPublishLocationId LIMIT 1];
            loanApp.CreditReportPublicDownloadLink__c = cd.ContentDownloadUrl;
            loanApp.CreditReportPublicViewLink__c = cd.DistributionPublicUrl;

            update loanApp;

        }
    }

}
