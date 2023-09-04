/**
 * Created by frans fourie on 2023/05/24.
 */

@IsTest
public with sharing class SuburbRegionMapperControllerTest {

    @TestSetup
    public static void createTestData(){
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
    }

    @IsTest
    public static void runTests(){
        String province = SuburbRegionMapperController.getProvinces()[0];
        String city = SuburbRegionMapperController.getCities(province)[0];
        String suburb = SuburbRegionMapperController.getSuburbs(province,city)[0];
        String regionId = SuburbRegionMapperController.getRegionId(province,city,suburb);
        String regionId2 = SuburbRegionMapperController.getRegionId2([SELECT Id FROM Region_Suburb__c WHERE Suburb__c = 'suburb'].Id);
        Region_Suburb__c rs = SuburbRegionMapperController.getSuburbDetails([SELECT Id FROM Region_Suburb__c WHERE Suburb__c = 'suburb'].Id);
        List<Region_Suburb__c> rsList = SuburbRegionMapperController.getRegionSuburb([SELECT Id FROM Region_Suburb__c WHERE Suburb__c = 'suburb'].Id);
        System.assert(regionId != null);
    }
}