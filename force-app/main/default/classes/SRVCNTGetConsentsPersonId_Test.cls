/**
 * Created by fkleynhans on 2022/09/06.
 */
@isTest
private class SRVCNTGetConsentsPersonId_Test {

    @isTest
    private static void getPersonConsentsTest() {

        String js = JSON.serialize(new List<SRVCNTGetConsentsResult>{
                SRVCNTGetConsentsResult.getExample()
        });
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        res.setStatusCode(200);
        res.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));

        List<String> scopes = new List<String>{
                'MOBBPrequal', 'MOBBBonds'
        };
        String personId = '1FCEC9F6-E54E-4A45-BCB0-C6692701BC3F';

        List<SRVCNTGetConsentsResult> response = SRVCNTGetConsentsPersonId_Controller.getPersonConsents(personId, scopes);

        System.assert(response != null);
    }

    @isTest
    private static void updateConsentsTest() {

        String js = JSON.serialize(new List<SRVCNTGetConsentsResult>{
                SRVCNTGetConsentsResult.getExample()
        });
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(js);
        res.setStatusCode(200);
        res.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));

        String personId = '1FA4F766-D878-4A75-A0C0-D7F0BA0CE969';

        List<SRVCNTGetConsentsResult> consentReqList = new List<SRVCNTGetConsentsResult>{
                SRVCNTGetConsentsResult.getExample()
        };

        String response = SRVCNTGetConsentsPersonId_Controller.updateConsents(personId, consentReqList);
        System.assert(response != null);
    }

    @isTest
    private static void updateConsentsFileTest() {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');

        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));

        Blob fileContents = Blob.valueOf('Test');

        String response = SRVCNTGetConsentsPersonId_Controller.uploadConsentsFile('testFileName', fileContents);
        System.assert(response != null);
    }

    @IsTest
    public static void testGetLoanApplicant() {


        BLG_Campaign__c blg = new BLG_Campaign__c();
        blg.Type_of_Campaign__c = 'Create lead/manual';
        blg.SLA__c = 12;

        insert blg;


        Contact cn = new Contact();
        cn.FirstName = 'test';
        cn.LastName = '69';
        insert cn;

        Profile prof = [SELECT Id FROM Profile WHERE Name LIKE '%System%' LIMIT 1];

        User u = new User(Alias = 'sd', Email = 'ser@testorg8.com', IsActive = true,
        EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US', ProfileId = prof.Id, AvailableforRouting__c = true,
        TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ser@testorg8.com');
        insert u;

        Account acc = new Account();
        acc.Name = 'test69';
        acc.DomainId__c = 'test69';

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


        SRVCNTGetConsentsPersonId_Controller.getLoanApplicant([SELECT Id FROM LoanApplicant WHERE Name = 'testLA' LIMIT 1].Id);
        SRVCNTGetConsentsPersonId_Controller.getOpportunity([SELECT Id FROM LoanApplicant WHERE Name = 'testLA' LIMIT 1].Id);
        SRVCNTGetConsentsPersonId_Controller.setConsentRequirementsMet('test69',true,[SELECT Id FROM LoanApplicant WHERE Name = 'testLA' LIMIT 1].Id);
    }

}