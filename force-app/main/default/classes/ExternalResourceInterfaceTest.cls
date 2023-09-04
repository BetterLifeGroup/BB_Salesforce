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



        Blob b;
        b = Blob.valueOf('testdata');
        ContentVersion cv = new ContentVersion();
        cv.VersionData = b;
        cv.Title = 'Preapproval';
        cv.PathOnClient = 'testPath.pdf';
        cv.FirstPublishLocationId = [SELECT Id FROM Opportunity WHERE Name LIKE '%test69%'].Id;

        insert cv;

        Account acc = new Account();

        acc.Name = 'testAccount';

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

        insert la;

    }


    @IsTest
    public static void testExternalResources() {
        ExternalResourceInterface.CreateExternalResourceRecord('fileName',350,'pdf','0012z00000-c-b7r-i-a-a-t','0012z00000CB7rIAAT');
        Assert.isNotNull(ExternalResourceInterface.GetExternalResource('testFile0','0012z00000-c-b7r-i-a-a-t'));
        Assert.isNotNull(ExternalResourceInterface.DeleteExternalResource('testFile0','0012z00000-c-b7r-i-a-a-t','0012z00000CB7rIAAT'));
        Assert.isNotNull(ExternalResourceInterface.getAllFiles([SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id ));
        Assert.isNotNull(ExternalResourceInterface.getAllFiles([SELECT Id FROM Opportunity WHERE Name = 'test69' LIMIT 1].Id ));
        Assert.isNotNull(ExternalResourceInterface.deleteFile([SELECT Id FROM ContentDocument LIMIT 1].Id));


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
