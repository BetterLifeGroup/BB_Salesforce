/**
 * Created by frans fourie on 2023/02/15.
 */
@IsTest
public with sharing class NotificationSLABatchable75Test {

    @TestSetup
    public static void createData() {
        try {
            Invocable_AllocateOpportunityTest.createTestData();
        } catch (Exception e) {
            try {
                Invocable_AllocateOpportunityTest.createTestData();
            } catch (Exception f) {
            }
        }

        Profile prof = [SELECT Id FROM Profile WHERE Name LIKE '%System%' LIMIT 1];

        User u = new User();
            u = new User(Alias = 'sd', Email = 'ser@testorg7.com', IsActive = true,
                    EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US', ProfileId = prof.Id, AvailableforRouting__c = true,
                    TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ser@testorg7.com');
            insert u;

        BLG_Campaign__c blg = new BLG_Campaign__c();
        blg.Type_of_Campaign__c = 'Create lead/manual';
        blg.SLA__c = 12;

        insert blg;

        Account acc = new Account();
        acc.Name = 'test';

        insert acc;

        Opportunity opp = new Opportunity();
        opp.SLA_Notification_Processed_Flag__c = 0;
        opp.SLA_Deadline__c = Datetime.now().addDays(-1);
        opp.AccountId = acc.Id;
        opp.StageName = 'Working';
        opp.CloseDate = Date.newInstance(2022, 2, 2);
        opp.OwnerId = [SELECT Id FROM User WHERE Username = 'ser@testorg7.com'].Id;
        opp.Name = 'test';
        opp.BLG_Campaign__c = blg.Id;

        insert opp;

        Opportunity opp2 = new Opportunity();
        opp2.SLA_Notification_Processed_Flag__c = 1;
        opp2.SLA_Deadline__c = Datetime.now().addDays(-1);
        opp2.AccountId = acc.Id;
        opp2.StageName = 'Working';
        opp2.CloseDate = Date.newInstance(2022, 2, 2);
        opp2.OwnerId = [SELECT Id FROM User WHERE Username = 'ser@testorg7.com'].Id;
        opp2.Name = 'test';
        opp2.BLG_Campaign__c = blg.Id;

        insert opp2;

    }

    @IsTest
    public static void test() {
        NotificationSLABatchable75 batch = new NotificationSLABatchable75();
        Database.executeBatch(batch);

    }

}