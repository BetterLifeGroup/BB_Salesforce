/**
 * Created by frans fourie on 2023/08/24.
 */

@IsTest
public with sharing class getBranchAndSubBranchFromRegionACRTest {

    @TestSetup

    public static void createTestData(){

        Account acc = new Account();
        acc.Name = 'TestLastName';
        acc.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE Name LIKE '%sub-branch%' AND SobjectType = 'Account'].Id;
        System.debug(acc);

        insert acc;

        Account acc2 = new Account();
        acc2.Name = 'TestLastName2';
        acc2.RecordTypeId = [SELECT Id,Name FROM RecordType WHERE Name LIKE '%sub-branch%' AND SobjectType = 'Account'].Id;
        acc2.ParentId = acc.Id;
        System.debug(acc2);

        insert acc2;

        Contact ct = new Contact();
        ct.LastName = 'TestContactLastName';
        ct.RecordTypeId = [SELECT Id FROM RecordType WHERE Name LIKE '%betterbond%' AND SobjectType = 'Contact'].Id;
        ct.AccountId = acc.Id;

        insert ct;

        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = acc2.Id;
        acr.ContactId = ct.Id;

        insert acr;
    }

    @IsTest
    public static void testMethods(){

        getBranchAndSubBranchFromRegionACR.Request req = new getBranchAndSubBranchFromRegionACR.Request();
        req.contactId = [SELECT Id FROM Contact WHERE LastName = 'TestContactLastName' LIMIT 1].Id;
        req.regionId = [SELECT Id FROM Account WHERE Name = 'TestLastName' LIMIT 1].Id;
        List<getBranchAndSubBranchFromRegionACR.Request> reqList = new List<getBranchAndSubBranchFromRegionACR.Request>{req};

        Assert.isNotNull(getBranchAndSubBranchFromRegionACR.accounts(reqList));
    }

}
