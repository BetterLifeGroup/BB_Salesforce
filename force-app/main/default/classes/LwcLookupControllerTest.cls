@IsTest
public with sharing class LwcLookupControllerTest {

    @TestSetup
    public static void createTestData() {

        insert new Account (Name = 'test69');

        Profile prof = [select id from profile where name LIKE '%System%' LIMIT 1];

        User u = new User(Alias = 'sd', Email = 'ser@testorg4.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = prof.Id,
                TimeZoneSidKey = 'America/Los_Angeles', IsActive = true, AvailableforRouting__c = true,
                UserName = 'ser@testorg4.com');
        insert u;

        Contact c = new Contact();
        c.FirstName = 'test69';
        c.LastName = 'test69';
        c.Consultant__c = u.Id;
        insert c;

        Account acc = new Account();
        acc.FirstName = 'test69';
        acc.LastName = 'test69';

        Account region = new Account();
        region.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Region'];
        region.Name = 'Region';

        Account branch = new Account();
        branch.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Branch'];
        branch.Name = 'Branch';

        Account subBranch = new Account();
        subBranch.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Sub-Branch'];
        subBranch.Name = 'Region';

        insert region;
        insert branch;
        insert subBranch;


    }

    @IsTest
    public static void testLookupController() {

        Assert.isNotNull(lwcLookupController.getSobjectRecords('test69', 'Account', '', 'Name'));
        Assert.isNotNull(lwcLookupController.getSobjectRecords('test69', 'Account', null, 'Name'));
        Assert.isNotNull(lwcLookupController.getAgents('test69', 'Account', '', 'Name', [SELECT Id FROM User WHERE Username = 'ser@testorg4.com'].Id));
        Assert.isNotNull(lwcLookupController.getAgents('test69', 'Account', null, 'Name', [SELECT Id FROM User WHERE Username = 'ser@testorg4.com'].Id));
        Assert.isNotNull(lwcLookupController.getCampaigns('test69', 'Account', '', 'Name', [SELECT Id FROM Contact WHERE FirstName = 'test69'].Id));
        Assert.isNotNull(lwcLookupController.getCustomers('test69', 'Account', '', 'null', null));
        Assert.isNotNull(lwcLookupController.getUsers('',true));
        Assert.isNotNull(lwcLookupController.getAccountsForUserManagement('Region','',''));
        Assert.isNotNull(lwcLookupController.getAccountsForUserManagement('Real Estate Network','',''));
        Assert.isNotNull(lwcLookupController.getAccountsForUserManagement('Network','',''));
        Assert.isNotNull(lwcLookupController.getSobjectRecordsAgents('','Opportunity','','Name'));
        Assert.isNotNull(lwcLookupController.getSobjectRecordsAgents('','Opportunity',null,'Name'));
    }
}