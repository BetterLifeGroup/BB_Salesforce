/**
 * Created by frans fourie on 2024/01/08.
 */

@IsTest
private class trgContentDocumentLinkTest {

    @TestSetup
    static void createTestData(){
        Account acc = new Account();
        acc.FirstName = 'test69';
        acc.LastName = 'test69';
        insert acc;

        ResidentialLoanApplication rla = new ResidentialLoanApplication();
        rla.AccountId = acc.Id;
        rla.Name = 'test69';

        insert rla;

        LoanApplicant la = new LoanApplicant();
        la.Name = 'test69';
        la.LoanApplicationId = rla.Id;
        la.relatedFilesIds__c = 'fakeIdGoesHere';
        la.Received_Documents__c = 'Copy of ID';
        insert la;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Consent Document';
        cv.PathOnClient = 'test.pdf';
        cv.VersionData = Blob.valueOf('abc');
        insert cv;

    }
    @IsTest
    static void testContentDocumentLinkTriggerAfterInsert() {

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = [SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id;
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Consent Document' LIMIT 1].ContentDocumentId;

        insert cdl;

        Assert.isNotNull(cdl.Id);
        LoanApplicant la = [SELECT Id,relatedFilesIds__c,Received_Documents__c FROM LoanApplicant WHERE Name = 'test69' LIMIT 1];
        Assert.isTrue(la.Received_Documents__c.contains('Consent Document'));
        Assert.isTrue(la.relatedFilesIds__c.contains([SELECT Id FROM ContentVersion WHERE ContentDocumentId = :cdl.ContentDocumentId LIMIT 1].Id));
    }
}