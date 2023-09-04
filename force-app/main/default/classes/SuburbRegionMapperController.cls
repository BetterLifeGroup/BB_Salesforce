/**
 * Created by frans fourie on 2023/05/23.
 */

public with sharing class SuburbRegionMapperController {

    @AuraEnabled
    public static List<String> getProvinces() {
        Set<String> provinces = new Set<String>();
        List<String> provincesList = new List<String>();
        List<Region_Suburb__c> regionSuburbsList = [SELECT Id, Province__c FROM Region_Suburb__c ORDER BY Province__c];

        for (Region_Suburb__c rs : regionSuburbsList) {
            provinces.add(rs.Province__c);
        }
        provincesList.addAll(provinces);
        return provincesList;
    }

    @AuraEnabled
    public static List<String> getCities(String province) {
        Set<String> cities = new Set<String>();
        List<String> citiesList = new List<String>();
        List<Region_Suburb__c> regionSuburbsList = [SELECT Id, City__c FROM Region_Suburb__c WHERE Province__c = :province ORDER BY City__c];

        for (Region_Suburb__c rs : regionSuburbsList) {
            cities.add(rs.City__c);
        }
        citiesList.addAll(cities);
        return citiesList;
    }

    @AuraEnabled
    public static List<String> getSuburbs(String province, String city) {
        Set<String> suburbs = new Set<String>();
        List<String> suburbsList = new List<String>();
        List<Region_Suburb__c> regionSuburbsList = [
                SELECT Id, Suburb__c
                FROM Region_Suburb__c
                WHERE Province__c = :province AND City__c = :city
                ORDER BY Suburb__c
        ];

        for (Region_Suburb__c rs : regionSuburbsList) {
            suburbs.add(rs.Suburb__c);
        }
        suburbsList.addAll(suburbs);
        return suburbsList;
    }

    @AuraEnabled
    public static String getRegionId(String province, String city, String suburb) {
        List<Region_Suburb__c> regionSuburbsList = [
                SELECT Id, Region__c
                FROM Region_Suburb__c
                WHERE Province__c = :province AND City__c = :city AND Suburb__c = :suburb
                LIMIT 1
        ];

        return regionSuburbsList[0].Region__c;
    }
    @AuraEnabled
    public static String getRegionAccountId(String regionName) {
        Account acc = [
                SELECT Id
                FROM Account
                WHERE Name = :regionName AND RecordType.Name = 'Region' AND RecordType.SobjectType = 'Account'
                LIMIT 1
        ];

        return acc.Id;

    }
    @AuraEnabled
    public static String getRegionId2(String suburb) {
        List<Region_Suburb__c> regionSuburbsList = [
                SELECT Id, Region__c
                FROM Region_Suburb__c
                WHERE Id = :suburb
                LIMIT 1
        ];

        return regionSuburbsList[0].Region__c;
    }

    @AuraEnabled
    public static Region_Suburb__c getSuburbDetails(String suburb) {
        System.debug(suburb);
        List<Region_Suburb__c> regionSuburbsList = [
                SELECT Id, Region__c, Province__c, City__c, Suburb__c
                FROM Region_Suburb__c
                WHERE Id = :suburb
                LIMIT 1
        ];

        return regionSuburbsList[0];
    }


    @AuraEnabled
    public static List<Region_Suburb__c> getRegionSuburb(String searchKey) {
        String searchAcc = '%' + String.escapeSingleQuotes(searchKey) + '%';

        return [SELECT Id, Name, Province__c, City__c, Suburb__c, Region__c FROM Region_Suburb__c WHERE Id = :searchAcc LIMIT 1];
    }


}