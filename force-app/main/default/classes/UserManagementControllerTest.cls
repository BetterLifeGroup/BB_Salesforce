/**
 * Created by frans fourie on 2023/04/26.
 */
@IsTest
public with sharing class UserManagementControllerTest {

    @TestSetup
    public static void createData() {

        RecordType subBranchRT = [SELECT Id FROM RecordType WHERE Name = 'Sub-Branch' LIMIT 1];
        RecordType branchRT = [SELECT Id FROM RecordType WHERE Name = 'Branch' LIMIT 1];
        RecordType regionRT = [SELECT Id FROM RecordType WHERE Name = 'Region' LIMIT 1];

        Account region = new Account(RecordTypeId = regionRT.Id, Name = 'Region');
        insert region;
        Account branch = new Account(RecordTypeId = branchRT.Id, Name = 'Branch', ParentId = region.Id);
        insert branch;
        Account subBranch = new Account(RecordTypeId = subBranchRT.Id, Name = 'Sub Branch', ParentId = branch.Id);
        insert subBranch;
        Account region2 = new Account(RecordTypeId = regionRT.Id, Name = 'Region2');
        insert region2;
        Account branch2 = new Account(RecordTypeId = branchRT.Id, Name = 'Branch2', ParentId = region.Id);
        insert branch2;
        Account subBranch2 = new Account(RecordTypeId = subBranchRT.Id, Name = 'Sub Branch2', ParentId = branch.Id);
        insert subBranch2;
        Account region3 = new Account(RecordTypeId = regionRT.Id, Name = 'Region3');
        insert region3;
        Account branch3 = new Account(RecordTypeId = branchRT.Id, Name = 'Branch3', ParentId = region.Id);
        insert branch3;
        Account subBranch3 = new Account(RecordTypeId = subBranchRT.Id, Name = 'Sub Branch3', ParentId = branch.Id);
        insert subBranch3;

        Profile prof = [SELECT Id FROM Profile WHERE Name LIKE '%System%' LIMIT 1];

        BLG_Campaign__c blg = new BLG_Campaign__c();
        blg.Type_of_Campaign__c = 'Create lead/manual';
        blg.SLA__c = 12;

        insert blg;

        Opportunity opp = new Opportunity();
        opp.CloseDate = Date.newInstance(2022, 2, 2);
        opp.StageName = 'Prospecting';
        opp.Name = 'test67';
        opp.BLG_Campaign__c = blg.Id;

        insert opp;

        Opportunity opp1 = new Opportunity();
        opp1.CloseDate = Date.newInstance(2022, 2, 2);
        opp1.StageName = 'Prospecting';
        opp1.Name = 'test67';
        opp1.BLG_Campaign__c = blg.Id;

        insert opp1;

        Opportunity opp2 = new Opportunity();
        opp2.CloseDate = Date.newInstance(2022, 2, 2);
        opp2.StageName = 'Prospecting';
        opp2.Name = 'test68';
        opp2.BLG_Campaign__c = blg.Id;

        insert opp2;

        Opportunity opp3 = new Opportunity();
        opp3.CloseDate = Date.newInstance(2022, 2, 2);
        opp3.StageName = 'Prospecting';
//        opp.AccountId = acc.Id;
        opp3.Name = 'test69';
        opp3.BLG_Campaign__c = blg.Id;
        opp3.PreApprovalOpportunity__c = opp2.Id;
        opp3.General_Opportunity__c = opp.Id;
        opp3.Bond_Opportunity__c = opp1.Id;

        insert opp3;

        User newUser = new User();
        newUser.Email = 'test69LetsMakeSureThisIsUnique@test69.com';
        newUser.FirstName = 'testClassUser69';
        newUser.LastName = 'test69';
        newUser.Username = newUser.Email;
        newUser.TimeZoneSidKey = 'Africa/Johannesburg';
        newUser.LocaleSidKey = 'en_ZA';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.ProfileId = prof.Id;
        newUser.Alias = newUser.FirstName.substring(0, 1) + newUser.LastName.substring(0, 4);
        insert newUser;

        User newUser2 = new User();
        newUser2.Email = 'ThisOneMustAlsoBeUnique2@test.com';
        newUser2.FirstName = 'testClassUser70';
        newUser2.LastName = 'test69';
        newUser2.Username = newUser2.Email;
        newUser2.TimeZoneSidKey = 'Africa/Johannesburg';
        newUser2.LocaleSidKey = 'en_ZA';
        newUser2.EmailEncodingKey = 'UTF-8';
        newUser2.LanguageLocaleKey = 'en_US';
        newUser2.ProfileId = prof.Id;
        newUser2.Alias = newUser2.FirstName.substring(0, 1) + newUser2.LastName.substring(0, 4);
        insert newUser2;

        Contact ct = new Contact();
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'BetterBond Contact' LIMIT 1];
        ct.RecordTypeId = rt.Id;
        ct.FirstName = newUser.FirstName;
        ct.LastName = newUser.LastName;
        ct.Email = newUser.Email;
        ct.MobilePhone = newUser.MobilePhone;
        ct.Consultant__c = newUser.Id;
        ct.AccountId = subBranch.Id;
        insert ct;

        Contact ct2 = new Contact();
        ct2.RecordTypeId = rt.Id;
        ct2.FirstName = 'test40';
        ct2.LastName = 'test40';
        ct2.Email = 'test40@test.com';
        ct2.AccountId = subBranch.Id;
        insert ct2;


        AccountContactRelation acr = new AccountContactRelation();
        acr.ContactId = ct.Id;
        acr.AccountId = region.Id;

        insert acr;

        FinServ__ReciprocalRole__c role = new FinServ__ReciprocalRole__c();
        role.Name = 'Consultant';
        role.FinServ__InverseRole__c = 'Agent';
        role.FinServ__CreateInverseRole__c = true;
        role.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Contact Role' AND SobjectType = 'FinServ__ReciprocalRole__c' LIMIT 1].Id;

        insert role;

    }
    @IsTest
    public static void testSetupMethods() {

        User us = [SELECT Id, FirstName, LastName, MobilePhone, ProfileId, Email, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey FROM User WHERE FirstName = 'testClassUser69' LIMIT 1];
        Account subBranch = [SELECT Id FROM Account WHERE Name = 'Sub Branch'];
        Account Branch = [SELECT Id FROM Account WHERE Name = 'Branch'];
        Account Region = [SELECT Id FROM Account WHERE Name = 'Region'];

        Test.startTest();
        us.Id = null;
        us.Email = 'ThisOneMustAlsoBeUnique@test.com';
        User newUser = UserManagementController.insertUser(us, subBranch.Id, 'fakeid');
        try {
            Assert.isNotNull(UserManagementController.insertUser(us, 'fakeId', 'fakeid2'));
        } catch (Exception e) {
        }

        UserManagementController.assignPermissionAssignment(us.Id);
        try {
            Assert.isNotNull(UserManagementController.assignPermissionAssignment('fakeId'));
        } catch (Exception e) {
        }
        Assert.isNotNull(UserManagementController.removePermissionAssignment(us.Id));
        try {
            UserManagementController.updateUserDetails(newUser);
        } catch (Exception e) {
        }
        try {
            Assert.isNotNull(UserManagementController.deactivateUser(us.Id));
        } catch (Exception e) {
        }
        try {
            Assert.isNotNull(UserManagementController.deactivateUser('fakeId'));
        } catch (Exception e) {
        }
        Test.stopTest();

    }

    @IsTest
    public static void testStandardMethods() {

        User us = [SELECT Id, FirstName, LastName, MobilePhone, ProfileId, Email, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey FROM User WHERE FirstName = 'testClassUser69' LIMIT 1];
        User newUser = [SELECT Id, FirstName, LastName, MobilePhone, ProfileId, Email, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey FROM User WHERE Email = 'ThisOneMustAlsoBeUnique2@test.com' LIMIT 1];
        Account subBranch = [SELECT Id FROM Account WHERE Name = 'Sub Branch'];
        Account Branch = [SELECT Id FROM Account WHERE Name = 'Branch'];
        Account Region = [SELECT Id FROM Account WHERE Name = 'Region'];
        Account subBranch2 = [SELECT Id FROM Account WHERE Name = 'Sub Branch2'];
        Account Branch2 = [SELECT Id FROM Account WHERE Name = 'Branch2'];
        Account Region2 = [SELECT Id FROM Account WHERE Name = 'Region2'];
        Account subBranch3 = [SELECT Id FROM Account WHERE Name = 'Sub Branch3'];
        Account Branch3 = [SELECT Id FROM Account WHERE Name = 'Branch3'];
        Account Region3 = [SELECT Id FROM Account WHERE Name = 'Region3'];
        Contact contact1 = [SELECT Id FROM Contact WHERE LastName = 'test69' LIMIT 1];
        Contact contact2 = [SELECT Id FROM Contact WHERE LastName = 'test40' LIMIT 1];
        User user1 = [SELECT Id FROM User WHERE LastName = 'test69' LIMIT 1];
        Test.startTest();

        try {
            us.FirstName = 'abc';
            UserManagementController.insertUserPartTwo(us, subBranch.Id, 'fake ID', new List<String>());
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        UserManagementController.getAdmins(us.Id);
        try {
            UserManagementController.getAdmins('fakeId');
        } catch (Exception e) {
        }
        UserManagementController.getAllSubBranches();
        UserManagementController.getMortgagePermission(us.Id);
        try {
            UserManagementController.getMortgagePermission('fakeId');
        } catch (Exception e) {
        }
        Assert.isNotNull(UserManagementController.getOrgBaseUrl());
        Assert.isNotNull(UserManagementController.getProfiles());
        Assert.isNotNull(UserManagementController.getRoles());
        Assert.isNotNull(UserManagementController.getSelectedSubBranchDetails(subBranch.Id));
        Assert.isNotNull(UserManagementController.getUserAssignedSubBranches(us.Id));
//        Assert.isNotNull(UserManagementController.getUserDetails(us.Id));
        try {
            UserManagementController.removePermissionAssignment('fakeId');
        } catch (Exception e) {
        }
        UserManagementController.subBranchChange(us.Id, subBranch.Id, subBranch2.Id);
        try {
            UserManagementController.subBranchChange('fakeid', subBranch2.Id, subBranch.Id);
        } catch (Exception e) {
        }
        UserManagementController.getRegions();
        UserManagementController.getBranchesOfParent(Region.Id);
        UserManagementController.getSubBranchesOfRegion(Region.Id);
        try {
            UserManagementController.addAdditionalSubBranch(us.Id, subBranch3.Id, subBranch2.Id, false, '');
        } catch (Exception e) {
        }
        try {
            UserManagementController.addAdditionalSubBranch(us.Id, subBranch3.Id, subBranch2.Id, true, '');
        } catch (Exception e) {
        }
        try {
            UserManagementController.deleteAdditionalSubBranch(us.Id, subBranch3.Id);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        try {
            UserManagementController.deleteAdditionalSubBranch(us.Id, 'fakeId');
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        try {
            UserManagementController.reassignBulkOpps(new List<String>{
                    [SELECT Id FROM Opportunity WHERE Name LIKE '%test69%' LIMIT 1].Id
            }, new List<String>{
                    us.Id
            });
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        try {
            UserManagementController.consultantsAvailable(us.Id);
        } catch (Exception e) {
        }
        try {
            UserManagementController.getUserOpenOpps(us.Id);
        } catch (Exception e) {
        }
        try {
            UserManagementController.updateCommissionEntityId('abc', subBranch.Id, us.Id);
        } catch (Exception e) {
        }
        try {
            UserManagementController.getPicklistValues();
        } catch (Exception e) {
        }
        try {
            UserManagementController.updateSkills(us.Id, new List<String>(), subBranch.Id);
        } catch (Exception e) {
        }
        Assert.isNotNull(UserManagementController.getAllLinkedConsultants(contact1.Id));
        Assert.isNotNull(UserManagementController.getAllLinkedAgents(user1.Id));
        Assert.isNotNull(UserManagementController.createCCRByAgent(contact1.Id, contact2.Id));
        Assert.isNotNull(UserManagementController.createCCRByConsultant(contact1.Id, contact2.Id));
        Assert.isNotNull(UserManagementController.CreateNetwork('Network'));
        Assert.isNotNull(UserManagementController.CreateAgency('Agency', [SELECT Id FROM Account WHERE Name = 'Network' LIMIT 1].Id));
        Assert.isNotNull(UserManagementController.CreateBranch('Branch', [SELECT Id FROM Account WHERE Name = 'Agency' LIMIT 1].Id));
        Assert.isNotNull(UserManagementController.CreateRegion('Region'));
        Assert.isNotNull(UserManagementController.CreateReBranch('Branch', [SELECT Id FROM Account WHERE Name = 'Region' LIMIT 1].Id));
        Assert.isNotNull(UserManagementController.CreateSubBranch('subBranch', [SELECT Id FROM Account WHERE Name = 'Branch' LIMIT 1].Id));
        Assert.isNotNull(UserManagementController.userManagementNetworks('', false));
        Assert.isNotNull(UserManagementController.userManagementNetworks('', true));
        Assert.isNotNull(UserManagementController.deleteCCRById([SELECT Id FROM FinServ__ContactContactRelation__c LIMIT 1].Id));
        Assert.isNotNull(UserManagementController.getAllConsultantsNotLinkedToRunningAgent(contact1.Id));
        Assert.isNotNull(UserManagementController.getAllConsultants());
        Assert.isNotNull(UserManagementController.updateAgent(contact1));
        try {
            Assert.isNotNull(UserManagementController.getAgentDetails(contact1.Id));
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        contact1.Id = null;
        try {
            Assert.isNotNull(UserManagementController.updateAgent(contact1));
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        contact1.LastName = 'test';
        try {
            Assert.isNotNull(UserManagementController.updateAgent(contact1));
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Assert.isNotNull(UserManagementController.getAccountsForUserManagement('Region', '', ''));
        Assert.isNotNull(UserManagementController.getAccountsForUserManagement('Real Estate Network', '', ''));
        Assert.isNotNull(UserManagementController.getAccountsForUserManagement('Network', '', ''));
        Test.stopTest();


    }
    @IsTest
    public static void testStandardMethodsPartTwo() {
        User us = [SELECT Id, FirstName, LastName, MobilePhone, ProfileId, Email, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey FROM User WHERE FirstName = 'testClassUser69' LIMIT 1];
        us.DigiApp_Link__c = 'testLink';
        update us;

        Assert.isNotNull(UserManagementController.getUserDetails(us.Id));
        try {
            Assert.isNotNull(UserManagementController.reactivateUser(us.Id));
        } catch (Exception e) {
        }
        try {
            Assert.isNotNull(UserManagementController.getUserDigiAppLink(us.Id));
        } catch (Exception e) {
        }
        try {
            Assert.isNotNull(UserManagementController.officeAdminCanBeDeleted(us.Id));
        } catch (Exception e) {
        }
    }
}