/**
 * Created by frans fourie on 2023/05/24.
 */

@IsTest
public with sharing class OpportunityReassignTest {

    @TestSetup
    public static void createTestData() {


        Account region = new Account();
        region.Name = 'Region Account';
        region.RecordTypeId = [SELECT Id FROM RecordType WHERE Name LIKE '%region%'].Id;

        insert region;

        Account branch = new Account();
        branch.Name = 'Branch Account';
        branch.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'branch'].Id;
        branch.ParentId = region.Id;

        insert branch;

        Account subBranch = new Account();
        subBranch.Name = 'Suburb Account';
        subBranch.RecordTypeId = [SELECT Id FROM RecordType WHERE Name LIKE '%Sub-Branch%'].Id;
        subBranch.ParentId = branch.Id;

        insert subBranch;


        Region_Suburb__c rs = new Region_Suburb__c();
        rs.Region__c = 'Region Account';
        rs.Suburb__c = 'suburb';
        rs.City__c = 'city';
        rs.Province__c = 'province';

        insert rs;

        Contact agent = new Contact (FirstName = 'Agent', LastName = 'Test');
        Contact notLinkedAgent = new Contact (FirstName = 'notLinkedAgent', LastName = 'Test');
        Contact consultant = new Contact (FirstName = 'Consultant', LastName = 'Test',AccountId = subBranch.Id,RecordTypeId=[SELECT Id FROM RecordType WHERE Name LIKE '%BetterBond Contact%' LIMIT 1].Id);
        List<Contact> newContacts = new List<Contact>{
                agent, consultant, notLinkedAgent
        };
        insert newContacts;

        FinServ__ReciprocalRole__c role = new  FinServ__ReciprocalRole__c();
//        role.FinServ__CreateInverseRole__c = true;
        role.FinServ__InverseRole__c = 'Role New';
        role.Name = 'New Role';
        role.RecordTypeId = [SELECT Id,SobjectType FROM RecordType WHERE Name = 'Contact Role' AND SobjectType = 'FinServ__ReciprocalRole__c'].Id;

        insert role;

        FinServ__ContactContactRelation__c ccr = new FinServ__ContactContactRelation__c();
        ccr.FinServ__Contact__c = consultant.Id;
        ccr.FinServ__RelatedContact__c = agent.Id;
        ccr.FinServ__Role__c = role.Id;
//        todo create account contact between consultant contact and region account
        insert ccr;

        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = region.Id;
        acr.ContactId = consultant.Id;

        insert acr;
    }

    @IsTest
    public static void runTest() {

        OpportunityReassign.ReassignRequest req = new OpportunityReassign.ReassignRequest();
        req.method = 'Reassign';
//        req.agentContactId = [SELECT Id FROM Contact WHERE FirstName = 'Agent'].Id;
        req.applicationType = 'Normal';
        req.regionId = [SELECT Id FROM Account WHERE Name = 'Region Account'].Id;
        List<OpportunityReassign.ReassignRequest> reqList = new List<OpportunityReassign.ReassignRequest>{req};

//        System.assert(OpportunityReassign.methods(reqList)[0].newOwnerId != null);

        OpportunityReassign.ReassignRequest req2 = new OpportunityReassign.ReassignRequest();
        req2.method = 'Reassign';
//        req2.agentContactId = [SELECT Id FROM Contact WHERE FirstName = 'notLinkedAgent'].Id;
        req2.applicationType = 'Normal';
        req2.selfEmployed = true;
        req2.regionId = [SELECT Id FROM Account WHERE Name = 'Region Account'].Id;
        List<OpportunityReassign.ReassignRequest> reqList2 = new List<OpportunityReassign.ReassignRequest>{req2};

//        System.assert(OpportunityReassign.methods(reqList2)[0].newOwnerId != null);
        System.debug(OpportunityReassign.methods(reqList2));

        OpportunityReassign.ReassignRequest req3 = new OpportunityReassign.ReassignRequest();
        req3.method = 'Invalid';
//        req3.agentContactId = [SELECT Id FROM Contact WHERE FirstName = 'notLinkedAgent'].Id;
        req3.applicationType = 'Normal';
        req3.regionId = [SELECT Id FROM Account WHERE Name = 'Region Account'].Id;
        List<OpportunityReassign.ReassignRequest> reqList3 = new List<OpportunityReassign.ReassignRequest>{req3};
        System.debug(OpportunityReassign.methods(reqList3));
//        System.assert(OpportunityReassign.methods(reqList3)[0].hasError == true);
    }
}