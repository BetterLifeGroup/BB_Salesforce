/**
 * Created by frans fourie on 2024/01/08.
 */

/**
 * Trigger to update loan applicant record when consent document is linked from account to Loan Applicant via a Content Document Link record.
 * The update is required to populate the received documents field used in validations, as well as the relatedFilesIds field so that the document will show in the file manager component.
 */

trigger trgContentDocumentLink on ContentDocumentLink (after insert) {


    for (ContentDocumentLink cdl : Trigger.new) {
        try {
            String parentObjectType = String.valueOf(cdl.LinkedEntityId.getSobjectType()).removeEnd('__c');

            ContentVersion cv = [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId = :cdl.ContentDocumentId ORDER BY CreatedDate DESC LIMIT 1];

            if (cv.Title == 'Consent Document' && parentObjectType == 'LoanApplicant') {
                LoanApplicant la = [SELECT Id, Name, Requested_Documents__c, Received_Documents__c, relatedFilesIds__c FROM LoanApplicant WHERE Id = :cdl.LinkedEntityId LIMIT 1];
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
        } catch (Exception e) {
            System.debug('Exception in Content Document Link Trigger - ' + e);
        }
    }
}