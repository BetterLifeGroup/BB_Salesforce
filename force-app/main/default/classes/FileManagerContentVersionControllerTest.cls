/**
 * Created by frans fourie on 2023/02/15.
 */
@IsTest
public with sharing class FileManagerContentVersionControllerTest {

    @TestSetup

    public static void createData() {

        CollaborationGroup collabGroup = new CollaborationGroup();
        collabGroup.Name = 'Opportunity Team';
        collabGroup.CollaborationType = 'Public';
        insert collabGroup;

        System.debug('collabGroup' + collabGroup);

        Profile prof = [SELECT Id FROM Profile WHERE Name LIKE '%System%' LIMIT 1];

        User u = new User();
        u = new User(Alias = 'sd', Email = 'ser@testorg3.com', IsActive = true,
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = prof.Id, AvailableforRouting__c = true,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'ser@testorg3.com');
        insert u;

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


        Account acc = new Account(Name = 'test69');
        insert acc;

        ResidentialLoanApplication rla = new ResidentialLoanApplication(Name = 'test69', AccountId = acc.Id);
        insert rla;


        Opportunity opp = new Opportunity();
        opp.CloseDate = date.newInstance(2022, 01, 01);
        opp.StageName = 'Prospecting';
        opp.AccountId = acc.Id;
        opp.Name = 'test69';
        opp.BLG_Campaign__c = blg.Id;
        insert opp;
        LoanApplicant la = new LoanApplicant(SourceOpportunity__c = opp.Id, Received_Documents__c = '1 Months Payslip', Requested_Documents__c = '1 Months Payslip', Name = 'test69', Are_you_buying_your_first_home__c = 'No', Marital_agreement__c = 'Not married', LoanApplicationId = rla.Id);
        insert la;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'test69';
        cv.VersionData = EncodingUtil.base64Decode('hello world');
        cv.PathOnClient = 'the path';
        cv.FirstPublishLocationId = la.Id;
        insert cv;

        OpportunityTeamMember oppmember = new OpportunityTeamMember();
        oppmember.OpportunityId = opp.Id;
        oppmember.UserId = [SELECT Id FROM User WHERE UserName = 'ser@testorg3.com'].Id;

        ContentVersion cv2 = new ContentVersion();
        cv2.Title = 'test69';
        cv2.VersionData = EncodingUtil.base64Decode('hello world');
        cv2.PathOnClient = 'the path';
        insert cv2;


    }

    @IsTest
    public static void updateFileNameTest() {

        Assert.isNotNull(FileManagerContentVersionController.updateFileName([SELECT Id FROM ContentVersion WHERE Title = 'test69' LIMIT 1].Id, 'Payslips', 'name1'));
        Assert.isNotNull(FileManagerContentVersionController.documentController([SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id));
        FileManagerContentVersionController.createContentVersion([SELECT Id FROM LoanApplicant WHERE Name = 'test69' LIMIT 1].Id, 'abcd', 'Personal Documents', 'Copy of ID', 'pdf');
    }
}