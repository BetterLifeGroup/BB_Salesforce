/**
 * Created by frans fourie on 2023/01/20.
 */
@IsTest
public with sharing class SRVAFFPreapprovalControllerTest {

    @TestSetup
    public static void createTestData() {
        BLG_Campaign__c blg = new BLG_Campaign__c();
        blg.Type_of_Campaign__c = 'Create lead/manual';
        blg.SLA__c = 12;

        insert blg;


        Contact cn = new Contact();
        cn.FirstName = 'test';
        cn.LastName = '69';
        insert cn;

        Profile prof = [SELECT Id FROM Profile WHERE Name LIKE '%System%' LIMIT 1];

        User u = new User(Alias = 'sd', Email = 'ser@testorg5.com', IsActive = true,
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = prof.Id, AvailableforRouting__c = true,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ser@testorg5.com');
        insert u;

        Account acc = new Account();
        acc.Name = 'test69';

        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'test69';
        opp.StageName = 'New';
        opp.CloseDate = Date.newInstance(2023, 01, 01);
        opp.BLG_Campaign__c = blg.Id;
        opp.AccountId = acc.Id;
        opp.OwnerId = u.Id;
        opp.Reference_Number_Text__c = 'testabc';

        insert opp;

        opp.StageName = 'Working';
        opp.Wrap_Up_Reason__c = 'Automated';
        update opp;

        ResidentialLoanApplication rla = new ResidentialLoanApplication();
        rla.OpportunityId = opp.Id;
        rla.Name = 'tes69';

        insert rla;

        LoanApplicant la = new LoanApplicant();
        la.Name = 'testLA';
        la.LoanApplicationId = rla.Id;
        la.Is_Main_Applicant__c = true;
        la.Opportunity__c = opp.Id;

        insert la;


        ContentVersion cv = new ContentVersion();
        cv.VersionData = Blob.valueOf('abc');
        cv.FirstPublishLocationId = opp.Id;
        cv.PathOnClient = 'abc.pdf';
        cv.Title = 'Preapproval';

        insert cv;

        String loanApplicantId = [SELECT Id FROM LoanApplicant WHERE Name = 'testLa' LIMIT 1].Id;

        List<Income_and_Expense_Types__c> types = new List<Income_and_Expense_Types__c>();

        Income_and_Expense_Types__c type = new Income_and_Expense_Types__c();
        type.Name = 'test';
        type.Type__c = 'Deduction';
        types.add(type);

        Income_and_Expense_Types__c type2 = new Income_and_Expense_Types__c();
        type2.Name = 'test';
        type2.Type__c = 'Living Expense';

        types.add(type2);

        Income_and_Expense_Types__c type3 = new Income_and_Expense_Types__c();
        type3.Name = 'test';
        type3.Type__c = 'Contractual Expense';

        types.add(type3);

        insert types;

        type2.Name = 'test1';
        update type2;

        LoanApplicationLiability loanAppLia2 = new LoanApplicationLiability();
        loanAppLia2.Expense_Category__c = 'Contractual Expense';
        loanAppLia2.LoanApplicationId = [SELECT Id FROM ResidentialLoanApplication WHERE Id IN (SELECT LoanApplicationId FROM LoanApplicant WHERE Id = :loanApplicantId)].Id;
        loanAppLia2.Name = 'test2';
        loanAppLia2.Monthly_Instalment_Amount__c = 12;
        loanAppLia2.MonthlyPaymentAmount = 12;

        insert loanAppLia2;

        LoanApplicantIncome laIncome = new LoanApplicantIncome();
        laIncome.LoanApplicantId = loanApplicantId;
        laIncome.IncomeSourceType = 'Commission';
        laIncome.MonthlyIncomeAmount = 12;
        laIncome.Name = 'test';

        insert laIncome;

        laIncome.Name = 'test1';

        update laIncome;

        LoanApplicationLiability loanAppLia = new LoanApplicationLiability();
        loanAppLia.Expense_Category__c = 'Deduction';
        loanAppLia.LoanApplicationId = [SELECT Id FROM ResidentialLoanApplication WHERE Id IN (SELECT LoanApplicationId FROM LoanApplicant WHERE Id = :loanApplicantId)].Id;
        loanAppLia.Name = 'test';
        loanAppLia.Monthly_Instalment_Amount__c = 12;
        loanAppLia.MonthlyPaymentAmount = 12;

        insert loanAppLia;


        LoanApplicantLiability laLia = new LoanApplicantLiability();
        laLia.LoanApplicantId = loanApplicantId;
        laLia.LoanApplicationLiabilityId = loanAppLia.Id;
        laLia.Amount__c = 12;
        laLia.LoanApplicationLiabilityId = loanAppLia2.Id;

        insert laLia;

        Case ca = new Case();
        ca.Opportunity__c = [SELECT Id FROM Opportunity WHERE Name = 'test69' LIMIT 1].Id;
        ca.Subject = 'test69';
        insert ca;


    }

    @IsTest
    public static void getPreApprovalDocumentTest() {

        Assert.isNotNull(SRVAFFPreapprovalController.getPreApprovalDocument([SELECT Id FROM Opportunity WHERE Name = 'test69' LIMIT 1].Id, false));
        Assert.isNotNull(SRVAFFPreapprovalController.getPreApprovalDocument([SELECT Id FROM Opportunity WHERE Name = 'test69' LIMIT 1].Id, true));
        Assert.isNotNull(SRVAFFPreapprovalController.PaCertExists([SELECT Id FROM Opportunity WHERE Name = 'test69' LIMIT 1].Id));
        Assert.isNotNull(SRVAFFPreapprovalController.PaCertExists('34324h23jh'));
        SRVCNTGetConsentsPersonId_Controller.setConsentRequirementsMet([SELECT Id, DomainId__c FROM Account WHERE Name = 'test69' LIMIT 1].DomainId__c, false, [SELECT Id FROM LoanApplicant WHERE Name = 'testLA' LIMIT 1].Id);

    }

    @IsTest
    public static void getPreApprovalDocumentTest2() {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        res.setBody('aBase64String');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PreApprovalMockResponse(res));
        Assert.isNotNull(SRVAFFPreapprovalController.getPreApprovalDocument([SELECT Id FROM Opportunity WHERE Name = 'test69' LIMIT 1].Id, true));
        Test.stopTest();
    }
    @IsTest
    public static void getPreApprovalDocumentTest3() {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(400);
        res.setStatus('gross income needs to be greater than 0');
        res.setBody('gross income needs to be greater than 0');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PreApprovalMockResponse(res));
        Assert.isNotNull(SRVAFFPreapprovalController.getPreApprovalDocument([SELECT Id FROM Opportunity WHERE Name = 'test69' LIMIT 1].Id, true));
        Test.stopTest();
    }

}