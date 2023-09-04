/**
 * Created by frans fourie on 2023/01/20.
 */

@IsTest
public with sharing class workFlowManagerTest {

    @TestSetup
    public static void createTestData() {

        Account acc = new Account();
        acc.Name = 'test69';

        insert acc;

        BLG_Campaign__c blg = new BLG_Campaign__c();
        blg.SLA__c = 20;
        blg.Name = 'test69';
        blg.Type_of_Campaign__c = 'Create lead/manual';

        insert blg;


        Opportunity opp = new Opportunity();
        opp.Name = 'test69';
        opp.StageName = 'New';
        opp.CloseDate =  Date.newInstance(2023, 01, 01);
        opp.BLG_Campaign__c = blg.Id;

        insert opp;


        ResidentialLoanApplication rla = new ResidentialLoanApplication();
        rla.Name = 'test69';
        rla.AccountId = acc.Id;

        insert rla;


        List<LoanApplicant> laList = new List<LoanApplicant>();
        for (Integer i = 0; i < 2; i++) {
            LoanApplicant la = new LoanApplicant();
            la.IsActive__c = true;
            la.Name = 'test69';
            la.SourceOpportunity__c = opp.Id;
            la.Are_you_buying_your_first_home__c = 'No';
            la.Marital_agreement__c = 'Not married';
            la.LoanApplicationId = rla.Id;
            laList.add(la);
        }

        insert laList;

    }

    @IsTest
    public static void testClass() {

        Assert.isNotNull(workFlowManager.getLoanApplicants([SELECT Id FROM Opportunity WHERE Name = 'test69' LIMIT 1].Id));
        Assert.isNotNull(workFlowManager.getLoanApplicants([SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id));
    }

}