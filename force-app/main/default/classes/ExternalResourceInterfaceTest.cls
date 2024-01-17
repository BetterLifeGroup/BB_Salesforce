/**
 * Created by frans fourie on 2022/10/12.
 */
@IsTest
public with sharing class ExternalResourceInterfaceTest {

    @TestSetup
    public static void createTestData() {
        LwcLookupControllerTest.createTestData();
        FileManagerContentVersionControllerTest.createData();

        List<ExternalResources__c> erList = new List<ExternalResources__c>();
        for (Integer i = 0; i < 2; i++) {


            ExternalResources__c er = new ExternalResources__c();
            er.FileType__c = 'pdf';
            er.FileName__c = 'testFile' + i;
            er.Container__c = '0012z00000-c-b7r-i-a-a-t';
            er.FileSize__c = 400;
            erList.add(er);
        }
        insert erList;

        Account acc = new Account();

        acc.Name = 'testAccount';
        acc.Phone = '+27739871234';

        insert acc;

        Opportunity opp = new Opportunity();
        opp.CloseDate = date.newInstance(2023,01,01);
        opp.StageName = 'Working';
        opp.AccountId = acc.Id;
        opp.Name = 'testOpportunity';

        insert opp;

        ResidentialLoanApplication rla = new ResidentialLoanApplication();

        rla.Name = 'test69';
        rla.OpportunityId = opp.Id;

        insert rla;

        LoanApplicant la = new LoanApplicant();
        la.Name = 'test69';
        la.LoanApplicationId = rla.Id;
        la.Received_Documents__c = 'Payslip;Bank Statement';

        insert la;



        Blob b;
        b = Blob.valueOf('testdata');
        ContentVersion cv = new ContentVersion();
        cv.VersionData = b;
        cv.Title = 'Preapproval';
        cv.PathOnClient = 'testPath.pdf';
        cv.FirstPublishLocationId = [SELECT Id FROM Opportunity WHERE Name LIKE '%test69%' LIMIT 1].Id;

        insert cv;

        Blob b2;
        b2 = Blob.valueOf('testdata');
        ContentVersion cv2 = new ContentVersion();
        cv2.VersionData = b2;
        cv2.Title = 'Consent Document';
        cv2.PathOnClient = 'testPath.pdf';
        cv2.FirstPublishLocationId = [SELECT Id FROM LoanApplicant WHERE Name LIKE '%test69%' LIMIT 1].Id;

        insert cv2;


    }


    @IsTest
    public static void testExternalResources() {
        Assert.isNotNull(ExternalResourceInterface.getAllFiles([SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id ));
        Assert.isNotNull(ExternalResourceInterface.getAllFiles([SELECT Id FROM Opportunity WHERE Name = 'test69' LIMIT 1].Id ));
        ExternalResourceInterface.prepFileForDelete([SELECT Id,ContentDocumentId FROM ContentVersion WHERE Title LIKE '%Preapproval%' LIMIT 1].ContentDocumentId);
        Assert.isNotNull(ExternalResourceInterface.deleteFile([SELECT Id,ContentDocumentId FROM ContentVersion WHERE Title LIKE '%Preapproval%' LIMIT 1].ContentDocumentId,[SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id));
//        trgContentVersion Coverage
        Blob b;
        b = Blob.valueOf('testdata');
        ContentVersion cv = new ContentVersion();
        cv.VersionData = b;
        cv.Title = 'Credit Report';
        cv.PathOnClient = 'testPath.pdf';
        cv.Category__c = 'Credit Report';
        cv.FirstPublishLocationId = [SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id;

        insert cv;

        ContentVersion cvToUpdate = [SELECT Id FROM ContentVersion WHERE Title LIKE '%Credit Report%' LIMIT 1];
        cvToUpdate.Title = 'Credit Report';

        update cvToUpdate;


    }
}