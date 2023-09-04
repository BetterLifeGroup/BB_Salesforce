/**
 * Created by frans fourie on 2023/06/30.
 */

@IsTest
public with sharing class BranchManagementControllerTest {

    @TestSetup
    public static void createTestData(){
        List<Account> accList = new List<Account>();
        Account subBranch = new Account(Name='subBranch');
        accList.add(subBranch);
        Account branch = new Account(Name='branch',ParentId = subBranch.Id);
        accList.add(branch);
        Account region = new Account(Name='region',ParentId = branch.Id);
        accList.add(region);

        insert accList;
    }

    @IsTest
    public static void testGetRelatedAccounts(){
        Assert.isNotNull(BranchManagementController.getRelatedAccounts([SELECT Id FROM Account WHERE Name = 'subBranch' LIMIT 1].Id));
    }
}