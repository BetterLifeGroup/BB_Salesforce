/**
 * Created by frans fourie on 2023/11/27.
 */

@IsTest
private class OpportunityMergeControllerTest {

    @TestSetup
    static void createTestData(){

        Account mainAcc = new Account();
        mainAcc.FirstName = 'John';
        mainAcc.LastName = 'Main';

        insert mainAcc;

        Opportunity mainOpp = new Opportunity();
        mainOpp.Name = 'Main Opp';
        mainOpp.CloseDate = Date.newInstance(2020,01,01);
        mainOpp.StageName = 'Working';
        mainOpp.Status__c = 'Pa Requested - awaiting documents';
        mainOpp.AccountId = mainAcc.Id;

        insert mainOpp;

        ResidentialLoanApplication rlaMain = new ResidentialLoanApplication();
        rlaMain.Name = 'mainRLA';
        rlaMain.OpportunityId = mainOpp.Id;
        rlaMain.AccountId = mainAcc.Id;

        insert rlaMain;

        LoanApplicant laMain = new LoanApplicant();
        laMain.Name = 'MasterMain App';
        laMain.LoanApplicationId = rlaMain.Id;
        laMain.Is_Main_Applicant__c = true;
        laMain.IsActive__c = true;

        insert laMain;

        Account slaveAcc = new Account();
        slaveAcc.FirstName = 'John';
        slaveAcc.LastName = 'slave';

        insert slaveAcc;

        Opportunity slaveOpp = new Opportunity();
        slaveOpp.Name = 'slave Opp';
        slaveOpp.CloseDate = Date.newInstance(2020,01,01);
        slaveOpp.StageName = 'Working';
        slaveOpp.Status__c = 'Pa Requested - awaiting documents';
        slaveOpp.AccountId = slaveAcc.Id;

        insert slaveOpp;

        ResidentialLoanApplication rlaslave = new ResidentialLoanApplication();
        rlaslave.Name = 'slaveRLA';
        rlaslave.OpportunityId = slaveOpp.Id;
        rlaslave.AccountId = slaveAcc.Id;

        insert rlaslave;

        LoanApplicant laslave = new LoanApplicant();
        laslave.Name = 'Masterslave App';
        laslave.LoanApplicationId = rlaslave.Id;
        laslave.Is_Main_Applicant__c = true;
        laslave.IsActive__c = true;

        insert laslave;

        Task ta = new Task();
        ta.WhatId = slaveOpp.Id;
        ta.Status = 'Open';
        ta.Subject = 'Test';
        ta.locked__c = false;
        insert ta;

        LoanApplicantIncome lai = new LoanApplicantIncome();
        lai.LoanApplicationId = rlaslave.Id;
        lai.LoanApplicantId = laslave.Id;
        lai.Amount__c = 12;
        lai.Name = 'Test';

        insert lai;

        LoanApplicationLiability lal = new LoanApplicationLiability();
        lal.LoanApplicationId = rlaslave.Id;
        lal.MonthlyPaymentAmount = 12;
        lal.Name = 'test';

        insert lal;

        LoanApplicantLiability al =new LoanApplicantLiability();
        al.Amount__c = 12;
        al.LoanApplicationLiabilityId = lal.Id;
        al.LoanApplicantId = laslave.Id;

        insert al;

    }

    @IsTest
    static void getOpportunityTest() {
        Assert.isNotNull(OpportunityMergeController.getOpportunity([SELECT Id FROM Opportunity WHERE Name = 'Main Opp'][0].Id));
    }

    @IsTest
    static void searchOpportunitiesTest() {
        Assert.isNotNull(OpportunityMergeController.searchOpportunities('slave Opp',[SELECT Id FROM Opportunity WHERE Name = 'Main Opp'][0].Id));
    }

    @IsTest
    static void mergeOppsTest() {
        Assert.isNotNull(OpportunityMergeController.mergeOpps([SELECT Id FROM Opportunity WHERE Name = 'Main Opp'][0].Id,[SELECT Id FROM Opportunity WHERE Name = 'slave Opp'][0].Id));
        Assert.areEqual(OpportunityMergeController.mergeOpps('fakeId',[SELECT Id FROM Opportunity WHERE Name = 'slave Opp'][0].Id),false);
    }

}