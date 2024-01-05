/**
 * Created by frans fourie on 2022/10/27.
 */

@IsTest
public with sharing class SRVIdvControllerTest {

    @TestSetup
    public static void testData() {

        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Person Account'];


        Account acc = new Account(FirstName = 'test', LastName = '69');
        insert acc;

        ResidentialLoanApplication rla = new ResidentialLoanApplication(Name = 'test69', AccountId = acc.Id);
        insert rla;

        BLG_Campaign__c blg = new BLG_Campaign__c(Name='test69',Type_of_Campaign__c = 'Create lead/manual');
        insert blg;

        Opportunity opp = new Opportunity(BLG_Campaign__c = blg.Id,Name='test69', StageName = 'New',CloseDate=Date.newInstance(2023,01,01));
        insert opp;

        LoanApplicant la = new LoanApplicant(Is_Main_Applicant__c = true,
                ContactId=[SELECT Id,PersonContactId FROM Account WHERE FirstName LIKE '%test%' LIMIT 1].PersonContactId,
                SourceOpportunity__c = opp.Id,Name = 'test69', Are_you_buying_your_first_home__c = 'No', Marital_agreement__c = 'Not married', LoanApplicationId = rla.Id);
        insert la;

    }
    @IsTest
    public static void getIdvQuestionsTest() {


        Test.setMock(HttpCalloutMock.class, new SRVIDVHttpMockGetQuestions());
        Test.startTest();

        SRVCRDIdvController.getIdvQuestions([SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id, '0000000000000', 'SID');

        Test.stopTest();
    }

    @IsTest
    public static void checkIdvAnswersTest() {

        List<SRVCRDIdvCheckRequestAnswerData> answerData = new List<SRVCRDIdvCheckRequestAnswerData>();
        for (Integer i = 0; i < 5; i++) {
            SRVCRDIdvCheckRequestAnswerData answer = new SRVCRDIdvCheckRequestAnswerData();
            answer.answerNumber = String.valueOf(i);
            answer.questionNumber = String.valueOf(i);
            answerData.add(answer);
        }

        SRVCRDIdvCheckRequest answers = new SRVCRDIdvCheckRequest();
        answers.verificationRequestNumber = '18342443255092788484';
        answers.sourceSystem = 'Salesforce';
        answers.answers = answerData;


        Test.setMock(HttpCalloutMock.class, new SRVIDVHttpMockCheckAnswers());
        Test.startTest();

        Assert.isNotNull(SRVCRDIdvController.checkIdvAnswers(answers, [SELECT Id FROM LoanApplicant WHERE Name = 'Test69' LIMIT 1].Id));
        Assert.isFalse(SRVCRDIdvController.manualConsentPending([SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id));
        SRVCRDIdvController.setManualConsentParamsForMC([SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id);
        SRVCRDIdvController.setOpportunityStatus([SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id, 'Attempting Contact', 'Working', 'Automated');
        Assert.isNotNull(SRVCRDIdvController.getLoanApplicant([SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id));
        Assert.isNotNull(SRVCRDIdvController.updateLoanApplicant([SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id, '89010101010101','SID',null));
        Assert.isNotNull(SRVCRDIdvController.updateLoanApplicant([SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id, null,'Passport','P1234567890'));
        Assert.isNotNull(SRVCRDIdvController.biometricUpdates([SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id, '543'));
        SRVCRDIdvController.redoConsent([SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id);
        SRVCRDIdvController.accountEmailPopulated([SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id);
        SRVCRDIdvController.updateEmailAddress('test@test.com' , [SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id);
        SRVCRDIdvController.setLoanApplicantStatus([SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id , 'test@test.com');
        SRVCRDIdvController.documentCheck([SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id);

        Test.stopTest();
    }


}