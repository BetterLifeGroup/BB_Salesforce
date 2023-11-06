public without sharing class lwcLookupController {

    @AuraEnabled
    public static List<SObject> getSobjectRecords(String searchKey, String objectName, String queryFilter, String searchField) {
        String searchAcc = '\'%' + String.escapeSingleQuotes(searchKey) + '%\'';
        searchAcc = searchAcc.replaceAll(' ', '%');

        if (queryFilter == null) {
            queryFilter = '';
        }

        String query = 'SELECT Id, Name FROM ' + objectName + ' WHERE ' + searchField + ' LIKE ' + searchAcc + ' ' + queryFilter + ' LIMIT 20';
        System.debug(Database.query(query));
        return Database.query(query);
    }

    @AuraEnabled
    public static List<SObject> getSobjectRecordsAgents(String searchKey, String objectName, String queryFilter, String searchField) {
        String searchAcc = '\'%' + String.escapeSingleQuotes(searchKey) + '%\'';

        if (queryFilter == null) {
            queryFilter = '';
        }
        searchAcc = searchAcc.replaceAll(' ', '%');

        System.debug(searchKey.length());
        String query = 'SELECT Id, Name, Account.Name FROM ' + objectName + ' WHERE ' + searchField + ' LIKE ' + searchAcc + ' ' + queryFilter + ' LIMIT 5';
        System.debug(Database.query(query));
        return Database.query(query);
    }

    @AuraEnabled
    public static List<SObject> getAgents(String searchKey, String objectName, String queryFilter, String searchField, String userId) {
        String searchAcc = '%' + String.escapeSingleQuotes(searchKey) + '%';

        if (queryFilter == null) {
            queryFilter = '';
        }
        searchAcc = searchAcc.replaceAll(' ', '%');

        List<Contact> contactList = new List<Contact>();
        try {
            Contact userContact = [SELECT Id FROM Contact WHERE Consultant__c = :userId AND Consultant__r.IsActive = TRUE LIMIT 1];

            List<String> ccr = new List<String>();
            List<FinServ__ContactContactRelation__c> ccrs = [SELECT Id, FinServ__RelatedContact__c FROM FinServ__ContactContactRelation__c WHERE FinServ__Contact__c = :userContact.Id];

            for (FinServ__ContactContactRelation__c con : ccrs) {
                String str = con.FinServ__RelatedContact__c;
                ccr.add(str);
            }
//            contactList = [SELECT Id, Name FROM Contact WHERE Id IN :ccr AND Name LIKE :searchAcc];
            contactList = [SELECT Id, Name FROM Contact WHERE Name LIKE :searchAcc AND RecordType.Name = 'Real Estate Agent' AND Visibility__c != 'Hidden' LIMIT 10];
        } catch (Exception e) {
            contactList = [SELECT Id, Name FROM Contact WHERE Name LIKE :searchAcc AND RecordType.Name = 'Real Estate Agent' AND Visibility__c != 'Hidden' LIMIT 10]; // TODO - temp fix to show all and not related
            return contactList;
        }
        return contactList;
    }

    @AuraEnabled
    public static List<SObject> getCampaigns(String searchKey, String objectName, String queryFilter, String searchField, String userId) {
        String searchAcc = '%' + String.escapeSingleQuotes(searchKey) + '%';

        String userRoleName = [SELECT Id, Name FROM UserRole WHERE Id = :UserInfo.getUserRoleId()].Name;
        String userType = userRoleName == 'BetterDirect' || userRoleName == 'BetterDirect Consultant' ? 'Direct' : 'Regional';

        if (queryFilter == null) {
            queryFilter = '';
        }
        searchAcc = searchAcc.replaceAll(' ', '%');

        List<Contact> contactList = new List<Contact>();
        System.debug(userId);
        List<BLG_Campaign__c> blgList = new List<BLG_Campaign__c>();
        try {
            Contact userContact = [SELECT Id, AccountId, Account.ParentId FROM Contact WHERE Id = :userId LIMIT 1];
            Set<String> stringSet = new Set<String>();
            stringSet.add(userContact.AccountId);
            stringSet.add(userContact.Account.ParentId);

//            blgList = [SELECT Id, Name FROM BLG_Campaign__c WHERE (Agency__c IN :stringSet OR Branch__c IN :stringSet) AND Active__c = TRUE AND Campaign_Owner__c = :userType AND Name LIKE :searchAcc];
            blgList = [SELECT Id, Name FROM BLG_Campaign__c WHERE (Agency__c IN :stringSet OR Branch__c IN :stringSet) AND Active__c = TRUE AND Name LIKE :searchAcc];
            if(blgList.size() == 0) {
                blgList = [SELECT Id, Name FROM BLG_Campaign__c WHERE Active__c = TRUE AND Name LIKE :searchAcc LIMIT 10];
            }
//            blgList = [SELECT Id, Name FROM BLG_Campaign__c WHERE Name LIKE :searchAcc AND Active__c = TRUE LIMIT 10];

        } catch (Exception e) {
            System.debug(searchAcc);
//          return [SELECT Id, Name FROM BLG_Campaign__c WHERE Active__c = TRUE AND Campaign_Owner__c = :userType AND Name LIKE :searchAcc];
            return [SELECT Id, Name FROM BLG_Campaign__c WHERE Name LIKE :searchAcc AND Active__c = TRUE LIMIT 10];
        }
        return blgList;
    }

    @AuraEnabled
    public static List<SObject> getCustomers(String searchKey, String objectName, String queryFilter, String searchField, String userId) {
        String searchAcc = '%' + String.escapeSingleQuotes(searchKey) + '%';
        searchAcc = searchAcc.replaceAll(' ', '%');


        return [
                SELECT Id, Name, PersonEmail, Phone
                FROM Account
                WHERE IsPersonAccount = TRUE AND (Name LIKE :searchAcc OR PersonMobilePhone = :searchKey OR Identification_Number__c = :searchKey
                OR PersonEmail LIKE :searchAcc OR Phone = :searchKey)
                LIMIT 5
        ];
    }

    @AuraEnabled
    public static List<User> getUsers(String searchKey, Boolean includeInactive) {
        String searchAcc = '%' + String.escapeSingleQuotes(searchKey) + '%';
        searchAcc = searchAcc.replaceAll(' ', '%');
        if (includeInactive) {
            return [SELECT Id, Name, Profile.Name FROM User WHERE Name LIKE :searchAcc AND ((NOT Name LIKE '%Exah%') AND (NOT Name LIKE 'Automated Process') AND (NOT Name LIKE '%System%')) ORDER BY Name LIMIT 6];
        } else {
            return [SELECT Id, Name, Profile.Name FROM User WHERE IsActive = TRUE AND Name LIKE :searchAcc AND ((NOT Name LIKE '%Exah%') AND (NOT Name LIKE 'Automated Process') AND (NOT Name LIKE '%System%')) ORDER BY Name LIMIT 6];
        }
    }

    @AuraEnabled
    public static List<SObject> getAccountsForUserManagement(String accountScope, String searchKey, String parentId) {

        String searchAcc = '%' + String.escapeSingleQuotes(searchKey) + '%';

        System.debug(accountScope + ' ' + parentId + ' ' + searchAcc);
        searchAcc = searchAcc.replaceAll(' ', '%');

        switch on accountScope {
            when 'Region' {
                return [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Region' AND Name LIKE :searchAcc];
            }
            when 'Branch' {
                return [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Branch' AND Name LIKE :searchAcc AND ParentId = :parentId];
            }
            when 'Sub-Branch' {
                return [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Sub-Branch' AND Name LIKE :searchAcc AND ParentId = :parentId];
            }
            when 'Network' {
                return [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Real Estate Network' AND Name LIKE :searchAcc];
            }
            when 'Agency' {
                return [SELECT Id, Name FROM Account WHERE (RecordType.Name = 'Real Estate Agency' OR RecordType.Name = 'Developer Agency') AND Name LIKE :searchAcc AND ParentId = :parentId];
            }
            when 'Estate Branch' {
                return [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Real Estate Branch' AND Name LIKE :searchAcc AND ParentId = :parentId];
            }
            when 'reAll' {
                return [SELECT Id, Name FROM Account WHERE (RecordType.Name = 'Real Estate Branch' OR RecordType.Name = 'Real Estate Agency' OR RecordType.Name = 'Real Estate Network') AND Name LIKE :searchAcc];
            }
            when 'agents' {
                return [SELECT Id, Name FROM Contact WHERE RecordType.Name = 'Real Estate Agent' AND Name LIKE :searchAcc];
            }
        }
        return new List<Account>();
    }

    @AuraEnabled
    public static List<Region_Suburb__c> getAllRegionSuburbs(String searchKey) {
        String searchAcc = '%' + String.escapeSingleQuotes(searchKey) + '%';
        searchAcc = searchAcc.replaceAll(' ', '%');

        return [SELECT Id, Name, Province__c, City__c, Suburb__c, Region__c FROM Region_Suburb__c WHERE Suburb__c LIKE :searchAcc LIMIT 10];
    }


}