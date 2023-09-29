@IsTest
public class Invocable_AllocateCaseTest {

    @TestSetup
    public static void createTestData() {

        CollaborationGroup collabGroup = new CollaborationGroup();
        collabGroup.Name = 'TestCase Team';
        collabGroup.CollaborationType = 'Public';
        insert collabGroup;

        System.debug('collabGroup' + collabGroup);

        Profile prof = [SELECT Id FROM Profile WHERE Name LIKE '%System%' LIMIT 1];

        User u = new User(Alias = 'sd', Email = 'ser@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = prof.Id,
                TimeZoneSidKey = 'America/Los_Angeles',IsActive = true, AvailableforRouting__c = true,
                Username = 'ser@testorg.com');
        insert u;


        CollaborationGroupMember cgm = new CollaborationGroupMember();
        cgm.CollaborationGroupId = collabGroup.Id;
        cgm.MemberId = u.Id;
        cgm.CollaborationRole = 'Standard';
        cgm.NotificationFrequency = 'P';
        // cgm.AvailableforRouting__c = 'true';
        insert cgm;

        User u2 = new User(Alias = 'sd2', Email = 'ser2@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing2', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = prof.Id,
                TimeZoneSidKey = 'America/Los_Angeles', Username = 'ser2@testorg.com');
        insert u2;

        CollaborationGroupMember cgm2 = new CollaborationGroupMember();
        cgm2.CollaborationGroupId = collabGroup.Id;
        cgm2.MemberId = u2.Id;
        cgm2.CollaborationRole = 'Standard';
        cgm2.NotificationFrequency = 'P';
        // cgm.AvailableforRouting__c = 'true';
        insert cgm2;

        System.debug('cgm' + cgm);

        System.debug(u.Id);

        List<Case> casesToAssign = new List<Case>{
                new Case(OwnerId = u.Id)
        };
        insert casesToAssign;
    }


    @IsTest
    public static void allocateCaseTestNegative() {


        CollaborationGroup collGroup = [SELECT Id, Name FROM CollaborationGroup LIMIT 1];
        System.debug('collGroup' + collGroup);

        Invocable_AllocateCase.Request req = new Invocable_AllocateCase.Request();
        req.caseGroup = collGroup.Name;
        req.caseDefaultType = 'TestCase Team';

        List<Invocable_AllocateCase.Request> reqList = new List<Invocable_AllocateCase.Request>();
        reqList.add(req);

        Test.startTest();
        List<Invocable_AllocateCase.Result> result = Invocable_AllocateCase.allocateCase(reqList);
        Test.stopTest();

        System.debug('collGroup' + collGroup);
        System.debug('req' + req);
        System.debug('reqList' + reqList);
        // System.debug('result' + result);

    }
    @IsTest
    public static void allocateCaseTestPositive() {

        CollaborationGroup collGroup = [SELECT Id, Name FROM CollaborationGroup WHERE Name = 'TestCase Team' LIMIT 1];
        System.debug('collGroup' + collGroup);

        Invocable_AllocateCase.Request req = new Invocable_AllocateCase.Request();
        req.caseGroup = collGroup.Name;

        List<Invocable_AllocateCase.Request> reqList = new List<Invocable_AllocateCase.Request>();
        reqList.add(req);

        Test.startTest();
        List<Invocable_AllocateCase.Result> result = Invocable_AllocateCase.allocateCase(reqList);
        Test.stopTest();

        System.debug('collGroup' + collGroup);
        System.debug('req' + req);
        System.debug('reqList' + reqList);
        // System.debug('result' + result);

    }

    @IsTest
    public static void allocateCaseTestPositiveAlreadyCaseOwner() {

        CollaborationGroup collGroup = [SELECT Id, Name FROM CollaborationGroup WHERE Name = 'TestCase Team' LIMIT 1];
        User u = [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];

        Case ca = new Case(Subject='Test',OwnerId=u.Id);
        insert ca;

        User u2 = [SELECT Id FROM User WHERE LastName = 'Testing2' LIMIT 1];

        Case ca2 = new Case(Subject='Test2',OwnerId=u2.Id);
        insert ca2;

        Case ca3 = new Case(Subject='Test3',OwnerId=System.UserInfo.getUserId());
        insert ca3;

        System.debug('collGroup' + collGroup);

        Invocable_AllocateCase.Request req = new Invocable_AllocateCase.Request();
        req.caseGroup = collGroup.Name;

        List<Invocable_AllocateCase.Request> reqList = new List<Invocable_AllocateCase.Request>();
        reqList.add(req);

        Test.startTest();
        List<Invocable_AllocateCase.Result> result = Invocable_AllocateCase.allocateCase(reqList);
        Test.stopTest();

        System.debug('collGroup' + collGroup);
        System.debug('req' + req);
        System.debug('reqList' + reqList);
        // System.debug('result' + result);

    }

}