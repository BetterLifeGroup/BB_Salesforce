@IsTest
public class Invocable_AllocateOpportunityTest {

    @TestSetup
    public static void createTestData() {

        CollaborationGroup collabGroup = new CollaborationGroup();
        collabGroup.Name = 'Opportunity Team';
        collabGroup.CollaborationType = 'Public';
        insert collabGroup;

        System.debug('collabGroup' + collabGroup);

        Profile prof = [SELECT Id FROM Profile WHERE Name LIKE '%System%' LIMIT 1];

        List<User> us = [SELECT Id FROM User WHERE Username = 'ser@testorg6.com'];

        User u = new User();
        if (us.size() == 0) {
            u = new User(Alias = 'sd', Email = 'ser@testorg6.com', IsActive = true,
                    EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US', ProfileId = prof.Id, AvailableforRouting__c = true,
                    TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ser@testorg6.com');
            insert u;
        } else {
            u = [SELECT Id,Alias,Email,IsActive,EmailEncodingKey,LastName,LanguageLocaleKey,LocaleSidKey,ProfileId,AvailableforRouting__c,TimeZoneSidKey FROM User WHERE Username = 'ser@testorg6.com' LIMIT 1];
        }

        CollaborationGroupMember cgm = new CollaborationGroupMember();
        cgm.CollaborationGroupId = collabGroup.Id;
        cgm.MemberId = u.Id;
        cgm.CollaborationRole = 'Standard';
        cgm.NotificationFrequency = 'P';
        insert cgm;

        User u2 = new User(Alias = 'sd2', Email = 'ser2@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing2', AvailableforRouting__c = true, LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = prof.Id, IsActive = true,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ser2@testorg.com');
        insert u2;

        CollaborationGroupMember cgm2 = new CollaborationGroupMember();
        cgm2.CollaborationGroupId = collabGroup.Id;
        cgm2.MemberId = u2.Id;
        cgm2.CollaborationRole = 'Standard';
        cgm2.NotificationFrequency = 'P';
        insert cgm2;

        BLG_Campaign__c blg = new BLG_Campaign__c();
        blg.Type_of_Campaign__c = 'Create lead/manual';
        blg.Name = 'test69';

        insert blg;


        List<Opportunity> oppsToAssign = new List<Opportunity>{
                new Opportunity(OwnerId = u.Id, BLG_Campaign__c = blg.Id, Name = 'Opp1', StageName = 'Working', CloseDate = Date.today()),
                new Opportunity(Name = 'Opp2', BLG_Campaign__c = blg.Id, StageName = 'Working', CloseDate = Date.today())
        };
        insert oppsToAssign;
    }

    @IsTest
    public static void allocateOpportunityTestNegative() {

        CollaborationGroup collGroup = [SELECT Id, Name FROM CollaborationGroup LIMIT 1];
        System.debug('collGroup' + collGroup);

        Invocable_AllocateOpportunity.Request req = new Invocable_AllocateOpportunity.Request();
        req.opportunityGroup = collGroup.Name;
        req.oppDefaultType = 'Opportunity Team';

        List<Invocable_AllocateOpportunity.Request> reqList = new List<Invocable_AllocateOpportunity.Request>();
        reqList.add(req);

        Test.startTest();
        List<Invocable_AllocateOpportunity.Result> result = Invocable_AllocateOpportunity.allocateOpportunity(reqList);
        Test.stopTest();

        System.debug('collGroup' + collGroup);
        System.debug('req' + req);
        System.debug('reqList' + reqList);
        // System.debug('result' + result);

    }
    @IsTest
    public static void allocateOpportunityTestPositive() {

        CollaborationGroup collGroup = [SELECT Id, Name FROM CollaborationGroup WHERE Name = 'Opportunity Team' LIMIT 1];
        System.debug('collGroup' + collGroup);

        Invocable_AllocateOpportunity.Request req = new Invocable_AllocateOpportunity.Request();
        req.opportunityGroup = collGroup.Name;

        List<Invocable_AllocateOpportunity.Request> reqList = new List<Invocable_AllocateOpportunity.Request>();
        reqList.add(req);

        Test.startTest();
        List<Invocable_AllocateOpportunity.Result> result = Invocable_AllocateOpportunity.allocateOpportunity(reqList);
        Test.stopTest();

        System.debug('collGroup' + collGroup);
        System.debug('req' + req);
        System.debug('reqList' + reqList);
        // System.debug('result' + result);

    }

    @IsTest
    public static void allocateOpportunityTestPositiveWithOpps() {

        CollaborationGroup collGroup = [SELECT Id, Name FROM CollaborationGroup WHERE Name = 'Opportunity Team' LIMIT 1];

        User u = [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];

        Opportunity opp = new Opportunity(Name='Test',OwnerId=u.Id,CloseDate=Date.newInstance(2020,02,02),StageName = 'New');
        insert opp;

        User u2 = [SELECT Id FROM User WHERE LastName = 'Testing2' LIMIT 1];

        Opportunity opp2 = new Opportunity(Name='Test2',OwnerId=u2.Id,CloseDate=Date.newInstance(2020,02,02),StageName = 'New');
        insert opp2;

//        Opportunity opp3 = new Opportunity(Name='Test3',CloseDate=Date.newInstance(2020,02,02),StageName = 'New');
//        insert opp3;
        System.debug('collGroup' + collGroup);

        Invocable_AllocateOpportunity.Request req = new Invocable_AllocateOpportunity.Request();
        req.opportunityGroup = collGroup.Name;

        List<Invocable_AllocateOpportunity.Request> reqList = new List<Invocable_AllocateOpportunity.Request>();
        reqList.add(req);

        Test.startTest();
        List<Invocable_AllocateOpportunity.Result> result = Invocable_AllocateOpportunity.allocateOpportunity(reqList);
        Test.stopTest();

        System.debug('collGroup' + collGroup);
        System.debug('req' + req);
        System.debug('reqList' + reqList);
        // System.debug('result' + result);

    }

}