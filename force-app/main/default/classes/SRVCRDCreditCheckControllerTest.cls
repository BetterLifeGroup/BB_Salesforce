/**
 * Created by frans fourie on 2022/10/27.
 */
@IsTest
public with sharing class SRVCRDCreditCheckControllerTest {

    @TestSetup
    public static void testData() {

        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Person Account'];


        Account acc = new Account(FirstName = 'Test69Acc',LastName='test');
//        acc.RecordTypeId = rt.Id;
        insert acc;
//        Contact con = new Contact(FirstName='Joe',LastName='Smith',Phone='415.555.1212',AccountId=acc.Id);
//        insert con;


        ResidentialLoanApplication rla = new ResidentialLoanApplication();
        rla.Name = 'Test69RLA';
        rla.AccountId = acc.Id;

        insert rla;

        LoanApplicant la = new LoanApplicant();
        la.Name = 'Test69';
        la.LoanApplicationId = rla.Id;
        la.idvFinalScore__c = 80;
        la.ContactId = acc.PersonContactId;
        la.Are_you_buying_your_first_home__c = 'No';
        la.Marital_agreement__c = 'Not married';
        insert la;

        LoanApplicant la2 = new LoanApplicant();
        la2.Name = 'Test669';
        la2.LoanApplicationId = rla.Id;
        la2.idvFinalScore__c = 80;
        la2.creditCheckScore__c = 777;
        la2.ContactId = acc.PersonContactId;
        la2.Are_you_buying_your_first_home__c = 'No';
        la2.Marital_agreement__c = 'Not married';
        insert la2;

        LoanApplicant la3 = new LoanApplicant();
        la3.Name = 'Test6699';
        la3.LoanApplicationId = rla.Id;
        la3.idvFinalScore__c = 80;
        la3.creditCheckScore__c = 777;
        la3.ContactId = acc.PersonContactId;
        la3.CreditCheckGroupId__c = 'qwerty12345';
        la3.Are_you_buying_your_first_home__c = 'No';
        la3.Marital_agreement__c = 'Not married';
        insert la3;

    }
    
    @IsTest
    public static void simpleCreditCheckTest() {


        Test.setMock(HttpCalloutMock.class, new SRVCRDHttpMock());
        Test.startTest();

        Assert.isNotNull(SRVCRDCreditCheckController.creditCheckSimple([SELECT Id FROM LoanApplicant WHERE Name = 'Test69' LIMIT 1].Id));

        Test.stopTest();
    }
    
    @IsTest
    public static void fullCreditCheckTest() {


        Test.setMock(HttpCalloutMock.class, new SRVCRDHttpMock());
        Test.startTest();

        String str = [SELECT Id FROM LoanApplicant WHERE Name = 'Test69' LIMIT 1].Id;
        List<String> stringIds = new List<String>();
        stringIds.add(str);
        Assert.isNotNull(SRVCRDCreditCheckController.fullCreditCheck(stringIds));


        Test.stopTest();


    }

    @IsTest
    public static void fullCreditCheckAuraTest() {


        Test.setMock(HttpCalloutMock.class, new SRVCRDHttpMock());
        Test.startTest();

        String str = [SELECT Id FROM LoanApplicant WHERE Name = 'Test69' LIMIT 1].Id;
        List<String> stringIds = new List<String>();
        stringIds.add(str);
        Assert.isNotNull(SRVCRDCreditCheckController.fullCreditCheckAura(stringIds[0]));


        Test.stopTest();


    }

    @IsTest
    public static void getLoanApplicantTest(){

        Assert.isNotNull(SRVCRDCreditCheckController.getLoanApplicant([SELECT Id FROM LoanApplicant WHERE Name = 'Test669' LIMIT 1].Id));
    }

    @IsTest
    public static void getCreditCheckDocumentTest(){

        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));
        Test.startTest();

        Assert.isNotNull(SRVCRDCreditCheckController.getCreditCheckDocument([SELECT Id FROM LoanApplicant WHERE Name = 'Test6699' LIMIT 1].Id));

        Test.stopTest();
    }

}