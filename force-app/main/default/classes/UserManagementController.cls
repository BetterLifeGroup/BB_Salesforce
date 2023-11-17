/**
 * Created by frans fourie on 2023/04/24.
 */

public with sharing class UserManagementController {


    @AuraEnabled
    public static List<User> getUserDetails(String userId) {
        List<User> userDetails = [SELECT Id, Name, FirstName, LastName, Profile.Name, UserRole.Name, Email, IsActive, MobilePhone FROM User WHERE Id = :userId LIMIT 1];
        try {
            Contact userContact = [SELECT Id FROM Contact WHERE Consultant__c = :userId AND RecordType.Name = 'Betterbond Contact' LIMIT 1];
        } catch (Exception e) {
            insert new Contact(Consultant__c = userId,
                    FirstName = userDetails[0].FirstName,
                    LastName = userDetails[0].LastName,
                    Email = userDetails[0].Email,
                    MobilePhone = userDetails[0].MobilePhone,
                    RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Betterbond Contact' AND SobjectType = 'Contact' LIMIT 1].Id);
        }
        return userDetails;
    }

    @AuraEnabled
    public static List<SObject> getAccountsForUserManagement(String accountScope, String searchKey, String parentId) {

        String searchAcc = '%' + String.escapeSingleQuotes(searchKey) + '%';
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
            when 'inactiveAgents' {
                return [
                        SELECT Id, Name, Email, MobilePhone, FinServ__PreferredName__c
                        FROM Contact
                        WHERE RecordType.Name = 'Real Estate Agent' AND
                        (Name LIKE :searchAcc OR Email LIKE :searchAcc OR MobilePhone LIKE :searchAcc OR FinServ__PreferredName__c LIKE :searchAcc)
                        LIMIT 40
                ];
            }
            when 'agents' {
                return [
                        SELECT Id, Name, Email, MobilePhone, FinServ__PreferredName__c
                        FROM Contact
                        WHERE RecordType.Name = 'Real Estate Agent' AND Active__c = TRUE AND
                        (Name LIKE :searchAcc OR Email LIKE :searchAcc OR MobilePhone LIKE :searchAcc OR FinServ__PreferredName__c LIKE :searchAcc)
                        LIMIT 40
                ];
            }
        }
        return new List<Account>();
    }

    @AuraEnabled
    public static List<Admin> getAdmins(String userId) {

        List<UserTeamMember> teamMembers = [SELECT Id, OwnerId, UserId, OpportunityAccessLevel, TeamMemberRole FROM UserTeamMember WHERE OwnerId = :userId];
        Map<Id, UserTeamMember> teamMembersMap = new Map<Id, UserTeamMember>();
        for (UserTeamMember ust : teamMembers) {
            teamMembersMap.put(ust.UserId, ust);
        }
        List<Admin> adminList = new List<Admin>();
        try {
            List<User> admins = [SELECT Id, Name FROM User WHERE Id IN (SELECT UserId FROM UserTeamMember WHERE OwnerId = :userId) ORDER BY Name];
            for (User us : admins) {
                Admin ad = new Admin();
                ad.user = us;
                ad.accessLevel = teamMembersMap.get(us.Id).OpportunityAccessLevel;
                ad.role = teamMembersMap.get(us.Id).TeamMemberRole;
                adminList.add(ad);
            }
            return adminList;
        } catch (Exception e) {
            System.debug('Exception' + e);
        }
        return new List<Admin>();
    }

    @AuraEnabled
    public static String getOrgBaseUrl() {

        String baseUrl = String.valueOf(Url.getSalesforceBaseUrl());

        return baseUrl.substring(22).removeEnd(']');
    }

    @AuraEnabled
    public static List<UserRole> getRoles() {
        return [SELECT Id, Name FROM UserRole ORDER BY Name];
    }

    @AuraEnabled
    public static String getUserDigiAppLink(String userId) {
        try {
            return [SELECT Id, DigiApp_Link__c FROM User WHERE Id = :userId LIMIT 1].DigiApp_Link__c;
        } catch (Exception e) {
            return '';
        }
    }

    @AuraEnabled
    public static String reactivateUser(String userId) {

        try {
            update new User(Id = userId, IsActive = true);
            return 'true';
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static Boolean updateUserDetails(User updatedUser) {
        try {

            Contact ct = [SELECT Id FROM Contact WHERE Consultant__c = :updatedUser.Id LIMIT 1];

            ct.FirstName = updatedUser.FirstName;
            ct.LastName = updatedUser.LastName;
            ct.Email = updatedUser.Email;
            ct.MobilePhone = updatedUser.MobilePhone;
            ct.Consultant__c = updatedUser.Id;

            update ct;
            return true;
        } catch (Exception e) {
            try {

                Contact ct = new Contact();
                ct.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND Name = 'BetterBond Contact'].Id;
                ct.FirstName = updatedUser.FirstName;
                ct.LastName = updatedUser.LastName;
                ct.Email = updatedUser.Email;
                ct.MobilePhone = updatedUser.MobilePhone;
                ct.Consultant__c = updatedUser.Id;

                insert ct;
                return true;
            } catch (Exception f) {
                System.debug(f);
                AuraHandledException auraEx = new AuraHandledException(e.getMessage());
                auraEx.setMessage(e.getMessage());
                throw auraEx;
            }
        }
    }
    @AuraEnabled
    public static Boolean updateUserDetailsPartTwo(User updatedUser, String digiAppLink) {
        try {
            updatedUser.DigiApp_Link__c = digiAppLink;
            update updatedUser;
            return true;
        } catch (Exception e) {
            System.debug(e);
            AuraHandledException auraEx = new AuraHandledException(e.getMessage());
            auraEx.setMessage(e.getMessage());
            throw auraEx;
        }
    }

    @AuraEnabled
    public static User insertUser(User newUser, String subBranch, String digiAppLink) {
        try {
            newUser.Username = newUser.Email;
            newUser.TimeZoneSidKey = 'Africa/Johannesburg';
            newUser.LocaleSidKey = 'en_ZA';
            newUser.EmailEncodingKey = 'UTF-8';
            newUser.LanguageLocaleKey = 'en_US';
            newUser.Alias = newUser.FirstName.substring(0, 1) + (newUser.LastName.length() > 3 ? newUser.LastName.substring(0, 3) : newUser.LastName);
            newUser.DigiApp_Link__c = digiAppLink;
            insert newUser;

            return newUser;
        } catch (Exception e) {
            System.debug(e);
            AuraHandledException auraEx = new AuraHandledException(e.getMessage());
            auraEx.setMessage(e.getMessage());
            throw auraEx;
        }
    }

    @AuraEnabled
    public static String insertUserPartTwo(User newUser, String subBranch, String commissionEntityId, List<String> assignedSkills) {
        try {

            Contact ct = new Contact();
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'BetterBond Contact' LIMIT 1];
            ct.RecordTypeId = rt.Id;
            ct.FirstName = newUser.FirstName;
            ct.LastName = newUser.LastName;
            ct.Email = newUser.Email;
            ct.MobilePhone = newUser.MobilePhone;
            ct.Consultant__c = newUser.Id;
            ct.AccountId = subBranch;
            insert ct;

            Contact insertedContact = [SELECT Id, Account.ParentId, Account.Parent.ParentId FROM Contact WHERE Id = :ct.Id LIMIT 1];

            List<AccountContactRelation> newAcrs = new List<AccountContactRelation>();

            AccountContactRelation branchAcr = new AccountContactRelation(ContactId = ct.Id, AccountId = insertedContact.Account.ParentId);
            AccountContactRelation regionAcr = new AccountContactRelation(ContactId = ct.Id, AccountId = insertedContact.Account.Parent.ParentId, CommissionEntityId__c = commissionEntityId, SkillGroup__c = String.join(assignedSkills, ';'));
            newAcrs.add(branchAcr);
            newAcrs.add(regionAcr);

            insert newAcrs;

            return newUser.Id;
        } catch (Exception e) {
            System.debug(e);
            AuraHandledException auraEx = new AuraHandledException(e.getMessage());
            auraEx.setMessage(e.getMessage());
            throw auraEx;
        }
    }

    @AuraEnabled
    public static List<Profile> getProfiles() {
        return [
                SELECT Id, Name
                FROM Profile
                WHERE Name = 'System Administrator' OR Name = 'Consultant' OR Name = 'Office Administrator' OR Name = 'Team Lead' OR Name = 'Senior Manager'
                ORDER BY Name
        ];
    }

    @AuraEnabled
    public static Boolean getMortgagePermission(String userId) {
        try {
            PermissionSetAssignment perAssign = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name = 'Mortgage')];
            PermissionSetAssignment perAssign2 = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name = 'FinancialServicesCloudStandard')];
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static Boolean removePermissionAssignment(String userId) {

        List<SObject> deleteList = new List<SObject>();
        try {
            PermissionSetAssignment perAssign = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name = 'Mortgage')];
            PermissionSetLicenseAssign perAssignLicense = [SELECT Id FROM PermissionSetLicenseAssign WHERE AssigneeId = :userId AND PermissionSetLicenseId IN (SELECT Id FROM PermissionSetLicense WHERE MasterLabel = 'Mortgage')];

            PermissionSetAssignment perAssign2 = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name = 'FinancialServicesCloudStandard')];

            deleteList.add(perAssign);
            deleteList.add(perAssign2);
            deleteList.add(perAssignLicense);

            Database.delete(deleteList, false);
            return true;
        } catch (Exception e) {
            AuraHandledException auraEx = new AuraHandledException(e.getMessage());
            auraEx.setMessage(e.getMessage());
            throw auraEx;
        }
    }

    @AuraEnabled
    public static Boolean assignPermissionAssignment(String userId) {

        try {
            List<PermissionSetAssignment> perAssignList = new List<PermissionSetAssignment>();
            PermissionSetAssignment perAssign = new PermissionSetAssignment();
            perAssign.PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Mortgage' LIMIT 1].Id;
            perAssign.AssigneeId = userId;
            perAssignList.add(perAssign);

            PermissionSetAssignment perAssign2 = new PermissionSetAssignment();
            perAssign2.PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'FinancialServicesCloudStandard' LIMIT 1].Id;
            perAssign2.AssigneeId = userId;
            perAssignList.add(perAssign2);

            Database.insert(perAssignList, false);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static List<Account> getAllSubBranches() {

        return [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Sub-Branch' ORDER BY Name];
    }

    @AuraEnabled
    public static List<SubBranch> getUserAssignedSubBranches(String userId) {

        List<SubBranch> subBranchList = new List<SubBranch>();
        List<AccountContactRelation> acrs = [SELECT Id, Account.Name, Contact.Name, AccountId, Account.Parent.Name, Account.Parent.Parent.Name, Account.Parent.ParentId FROM AccountContactRelation WHERE Account.RecordType.Name = 'Sub-Branch' AND ContactId IN (SELECT Id FROM Contact WHERE Consultant__c = :userId) ORDER BY IsDirect DESC];

        for (AccountContactRelation acr : acrs) {
            AccountContactRelation regionAcr = new AccountContactRelation();
            try {
                regionAcr = [SELECT Id, CommissionEntityId__c, SkillGroup__c FROM AccountContactRelation WHERE Account.RecordType.Name = 'Region' AND AccountId = :acr.Account.Parent.ParentId AND ContactId IN (SELECT Id FROM Contact WHERE Consultant__c = :userId AND RecordType.Name = 'Betterbond Contact') ORDER BY CreatedDate LIMIT 1];
            } catch (Exception e) {
            }
            SubBranch sb = new SubBranch();
            sb.subBranchId = acr.AccountId;
            sb.branchName = acr.Account.Parent.Name;
            sb.regionName = acr.Account.Parent.Parent.Name;
            sb.commissionEntityId = regionAcr.CommissionEntityId__c;
            if (regionAcr?.SkillGroup__c != null) {
                sb.skills = new List<String>(regionAcr?.SkillGroup__c?.split(';'));
            } else {
                sb.skills = new List<String>();
            }

            subBranchList.add(sb);
        }
        try {
            subBranchList.sort();
        } catch (Exception e) {
        }
        System.debug(subBranchList);
        return subBranchList;
    }

    @AuraEnabled
    public static List<SubBranch> getSelectedSubBranchDetails(String selectedSubBranch) {

        List<SubBranch> subBranchList = new List<SubBranch>();
        Account acc = [SELECT Id, Parent.Name, Parent.Parent.Name FROM Account WHERE Id = :selectedSubBranch LIMIT 1];
        SubBranch sb = new SubBranch();
        sb.subBranchId = acc.Id;
        sb.branchName = acc.Parent.Name;
        sb.regionName = acc.Parent.Parent.Name;

        subBranchList.add(sb);

        return subBranchList;
    }

    @AuraEnabled
    public static Boolean subBranchChange(String userId, String newSubBranch, String oldSubBranch) {
        try {

            Contact userContact = [SELECT Id FROM Contact WHERE Consultant__c = :userId LIMIT 1];

            userContact.AccountId = newSubBranch;

            Account oldSubBranchAccount = [SELECT Id, ParentId, Parent.ParentId FROM Account WHERE Id = :oldSubBranch LIMIT 1];

            List<AccountContactRelation> oldAcrs = [
                    SELECT Id
                    FROM AccountContactRelation
                    WHERE (AccountId = :oldSubBranchAccount.Id OR AccountId = :oldSubBranchAccount.ParentId OR AccountId = :oldSubBranchAccount.Parent.ParentId) AND
                    ContactId IN (SELECT Id FROM Contact WHERE Consultant__c = :userId)
            ];
            update userContact;
            delete oldAcrs;

            Contact updatedContact = [SELECT Id, Account.ParentId, Account.Parent.ParentId FROM Contact WHERE Consultant__c = :userId LIMIT 1];

            List<AccountContactRelation> newAcrs = new List<AccountContactRelation>();

            AccountContactRelation branchAcr = new AccountContactRelation(ContactId = updatedContact.Id, AccountId = updatedContact.Account.ParentId);
            AccountContactRelation regionAcr = new AccountContactRelation(ContactId = updatedContact.Id, AccountId = updatedContact.Account.Parent.ParentId);
            newAcrs.add(branchAcr);
            newAcrs.add(regionAcr);

            Database.insert(newAcrs, false);
            return true;
        } catch (Exception e) {
            AuraHandledException auraEx = new AuraHandledException(e.getMessage());
            auraEx.setMessage(e.getMessage());
            throw auraEx;
        }


    }
    @AuraEnabled
    public static List<Opportunity> getUserOpenOpps(String userId) {

        Set<Opportunity> returnSet = new Set<Opportunity>();

        List<Opportunity> openOpps = [
                SELECT Id, Name, StageName, Affordability_Amount__c, PreApprovalOpportunity__c, RecordType.Name, Consultant_Region_Name__c, Bond_Opportunity__c, Status__c, Campaign_Type__c, BLG_Campaign__r.Name, SLA_Deadline__c, PreApprovalOpportunity__r.OwnerId, Bond_Opportunity__r.OwnerId
                FROM Opportunity
                WHERE StageName != 'Closed Won' AND StageName != 'Closed Lost' AND OwnerId = :userId
                ORDER BY Name
        ];
        for (Opportunity opp : openOpps) {

            if ((opp.RecordType.Name == 'General Opportunity' && opp.PreApprovalOpportunity__c == null && opp.Bond_Opportunity__c == null) || (opp.PreApprovalOpportunity__c != null && opp.PreApprovalOpportunity__r?.OwnerId != userId) || (opp.Bond_Opportunity__c != null && opp.Bond_Opportunity__r.OwnerId != userId)) {
                returnSet.add(opp);
            }
            if ((opp.RecordType.Name == 'Pre-Approval Opportunity' && opp.Bond_Opportunity__c == null) || (opp.Bond_Opportunity__c != null && opp.Bond_Opportunity__r.OwnerId != userId)) {
                returnSet.add(opp);
            } else if (opp.RecordType.Name == 'Bond Opportunity') {
                returnSet.add(opp);
            }

        }
        List<Opportunity> returnList = new List<Opportunity>();
        returnList.addAll(returnSet);
        returnList.sort();
        return returnList;
    }

    @AuraEnabled
    public static List<Contact> consultantsAvailable(String userId) {

        List<String> consultantIdsList = new List<String>();
        Contact currentUserContact = [SELECT Id, AccountId, Account.ParentId, Account.Parent.ParentId FROM Contact WHERE Consultant__c = :userId LIMIT 1];

        List<AccountContactRelation> userToBeDeactivatedAcrs = [SELECT Id, AccountId FROM AccountContactRelation WHERE ContactId = :currentUserContact.Id AND Account.RecordType.Name = 'Region'];

        List<String> accountIds = new List<String>();

        for (AccountContactRelation acr : userToBeDeactivatedAcrs) {
            accountIds.add(acr.AccountId);
        }

        List<AccountContactRelation> sameAccountAcrs = [SELECT Id, ContactId FROM AccountContactRelation WHERE AccountId IN :accountIds AND Contact.Consultant__r.IsActive = TRUE];

        List<String> contactIds = new List<String>();

        for (AccountContactRelation acr : sameAccountAcrs) {
            contactIds.add(acr.ContactId);
        }

        List<Contact> sameSubBranchConsultantsContacts = [SELECT Id, Name, Consultant__c FROM Contact WHERE Consultant__r.IsActive = TRUE AND Consultant__c != :userId AND Id IN :contactIds ORDER BY Name];

        for (Contact ct : sameSubBranchConsultantsContacts) {
            String str = ct.Consultant__c;
            consultantIdsList.add(str);
        }
        List<Contact> sameSubBranchConsultants = [SELECT Id, Name, Consultant__c, Account.Parent.Parent.Name FROM Contact WHERE Consultant__r.IsActive = TRUE AND Consultant__r.Profile.Name = 'Consultant' AND Consultant__c IN :consultantIdsList ORDER BY Name];
        if (sameSubBranchConsultants.size() == 0) {
            return [SELECT Id, Name, Consultant__c, Account.Parent.Parent.Name FROM Contact WHERE Consultant__r.IsActive = TRUE AND Consultant__r.Profile.Name = 'Consultant' ORDER BY Name];
        }
        return sameSubBranchConsultants;

    }

    @AuraEnabled
    public static Boolean reassignBulkOpps(List<String> oppIds, List<String> newUserIdList) {
        try {
            // Fetch Contact records based on newUserIdList
            List<Contact> newUserContacts = [SELECT Id, AccountId, Account.ParentId, Account.Parent.ParentId FROM Contact WHERE Consultant__c IN :newUserIdList];

            // Fetch Opportunities to update
            List<Opportunity> userOpenopps = [SELECT Id, PreApprovalOpportunity__c, Bond_Opportunity__c, RecordType.Name, General_Opportunity__c FROM Opportunity WHERE Id IN :oppIds];
            Set<Opportunity> oppsToUpdate = new Set<Opportunity>();

            // Round-robin assignment of opportunities to consultants
            Integer newIndex = 0; // Index to track the current consultant to assign
            for (Opportunity opp : userOpenopps) {

                Contact newUserContact = newUserContacts[newIndex];
                opp.OwnerId = newUserIdList[newIndex];
                opp.ConsultantSubBranch__c = newUserContact.AccountId;
                opp.ConsultantBranch__c = newUserContact.Account.ParentId;
                opp.ConsultantRegion__c = newUserContact.Account.Parent.ParentId;
                opp.Wrap_Up_Reason__c = 'Automated';

                oppsToUpdate.add(opp);

                if (opp.PreApprovalOpportunity__c != null) {
                    Opportunity paOpp = new Opportunity(Id = opp.PreApprovalOpportunity__c,
                            OwnerId = newUserIdList[newIndex],
                            ConsultantSubBranch__c = newUserContact.AccountId,
                            ConsultantBranch__c = newUserContact.Account.ParentId,
                            ConsultantRegion__c = newUserContact.Account.Parent.ParentId,
                            Wrap_Up_Reason__c = 'Automated'
                    );
                    oppsToUpdate.add(paOpp);

                }
                if (opp.Bond_Opportunity__c != null) {
                    Opportunity bondOpp = new Opportunity(Id = opp.Bond_Opportunity__c,
                            OwnerId = newUserIdList[newIndex],
                            ConsultantSubBranch__c = newUserContact.AccountId,
                            ConsultantBranch__c = newUserContact.Account.ParentId,
                            ConsultantRegion__c = newUserContact.Account.Parent.ParentId,
                            Wrap_Up_Reason__c = 'Automated'
                    );
                    oppsToUpdate.add(bondOpp);

                }
                if (opp.General_Opportunity__c != null) {
                    Opportunity genOpp = new Opportunity(Id = opp.General_Opportunity__c,
                            OwnerId = newUserIdList[newIndex],
                            ConsultantSubBranch__c = newUserContact.AccountId,
                            ConsultantBranch__c = newUserContact.Account.ParentId,
                            ConsultantRegion__c = newUserContact.Account.Parent.ParentId,
                            Wrap_Up_Reason__c = 'Automated'
                    );
                    oppsToUpdate.add(genOpp);

                }
                newIndex = Math.mod(newIndex + 1, newUserIdList.size()); // Increment the index in a round-robin manner
            }

            for (Integer i = 0; i < oppsToUpdate.size(); i++) {

            }
            System.debug(new List<Opportunity>(oppsToUpdate));
            update new List<Opportunity>(oppsToUpdate);
            return true;

        } catch (Exception e) {
            AuraHandledException auraEx = new AuraHandledException(e.getMessage());
            auraEx.setMessage(e.getMessage());
            throw auraEx;
        }
    }


    @AuraEnabled
    public static List<User> officeAdminCanBeDeleted(String userId) {


        User userRecord = [SELECT Id, Profile.Name FROM User WHERE Id = :userId];

        if (userRecord.Profile.Name == 'Office Administrator') {

            List<UserTeamMember> allTeamsAdminIsAPartOff = [SELECT Id, OwnerId FROM UserTeamMember WHERE UserId = :userId];

            Set<String> consultants = new Set<String>();

            for (UserTeamMember us : allTeamsAdminIsAPartOff) {
                consultants.add(us.OwnerId);
            }

            List<AggregateResult> consultantTeams = [SELECT Count(Id), OwnerId FROM UserTeamMember WHERE TeamMemberRole = 'Administrator' AND OwnerId IN :consultants GROUP BY OwnerId HAVING COUNT(Id) = 1];

            if (consultantTeams.size() == 0) {
                return new List<User>();
            } else {
                List<String> resultIds = new List<String>();
                for (AggregateResult ar : consultantTeams) {
                    resultIds.add((String) ar.get('OwnerId'));
                }

                return [SELECT Id, Name FROM User WHERE Id IN :resultIds];
            }
        } else {
            return new List<User>();
        }

    }


    @AuraEnabled
    public static Boolean deactivateUser(String userId) {
        try {
            User userRecord = [SELECT Id, Profile.Name FROM User WHERE Id = :userId];

            if (userRecord.Profile.Name == 'Office Administrator') {
                // Check if the user is the only admin on any Consultant's opportunity team

                Integer adminTeamCount = [
                        SELECT COUNT()
                        FROM UserTeamMember
                        WHERE UserId = :userId AND TeamMemberRole = 'Administrator'
                ];

                if (adminTeamCount > 0) {
                    throw new AuraHandledException('Cannot deactivate the user.They are the only admin on at least one Consultant\'s opportunity team.');
                }
            } else {
                // Continue with deactivation for non-Office Administrators
                User u = new User(Id = userId, IsActive = false);
                update u;
            }

            return true;
        } catch (Exception e) {
            if (e instanceof AuraHandledException) {
                throw e;
            } else {
                throw new AuraHandledException('An error occurred while deactivating the user.');
            }
        }
    }


    @AuraEnabled
    public static List<Account> getRegions() {
        return [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Region' ORDER BY Name];
    }

    @AuraEnabled
    public static List<Account> getBranchesOfParent(String regionId) {
        return [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Branch' AND ParentId = :regionId ORDER BY Name];
    }
    @AuraEnabled
    public static List<Account> getSubBranchesOfRegion(String regionId) {
        return [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Sub-Branch' AND Parent.ParentId = :regionId ORDER BY Name];
    }

    @AuraEnabled
    public static Boolean addAdditionalSubBranch(String userId, String subBranchId, String oldSubBranch, Boolean isNew, String commissionEntityId) {

        try {

            if (!isNew) {
                Account oldSubBranchAccount = [SELECT Id, ParentId, Parent.ParentId FROM Account WHERE Id = :oldSubBranch LIMIT 1];

                List<AccountContactRelation> oldAcrs = [
                        SELECT Id
                        FROM AccountContactRelation
                        WHERE (AccountId = :oldSubBranchAccount.Id OR AccountId = :oldSubBranchAccount.ParentId OR AccountId = :oldSubBranchAccount.Parent.ParentId) AND
                        ContactId IN (SELECT Id FROM Contact WHERE Consultant__c = :userId)
                ];
                delete oldAcrs;
            }

            Contact userContact = [SELECT Id, AccountId FROM Contact WHERE Consultant__c = :userId LIMIT 1];

            AccountContactRelation subBranchAcr = new AccountContactRelation();
            Account subBranch = [SELECT Id, ParentId, Parent.ParentId FROM Account WHERE Id = :subBranchId LIMIT 1];

            if (userContact.AccountId == null) {
                userContact.AccountId = subBranchId;
                update userContact;
            } else {
                subBranchAcr = new AccountContactRelation(ContactId = userContact.Id, AccountId = subBranch.Id);
            }


            List<AccountContactRelation> newAcrs = new List<AccountContactRelation>();


            AccountContactRelation branchAcr = new AccountContactRelation(ContactId = userContact.Id, AccountId = subBranch.ParentId);
            AccountContactRelation regionAcr = new AccountContactRelation(ContactId = userContact.Id, AccountId = subBranch.Parent.ParentId, commissionEntityId__c = commissionEntityId);
            newAcrs.add(subBranchAcr);
            newAcrs.add(branchAcr);
            newAcrs.add(regionAcr);

            Database.insert(newAcrs, false);
            return true;
        } catch (Exception e) {
            AuraHandledException auraEx = new AuraHandledException(e.getMessage());
            auraEx.setMessage(e.getMessage());
            throw auraEx;
        }
    }

    @AuraEnabled
    public static Boolean deleteAdditionalSubBranch(String userId, String subBranchId) {

        try {

            Account oldSubBranchAccount = [SELECT Id, ParentId, Parent.ParentId FROM Account WHERE Id = :subBranchId LIMIT 1];

            Contact userContact = [SELECT Id FROM Contact WHERE Consultant__c = :userId LIMIT 1];

            List<AccountContactRelation> oldAcrs = [
                    SELECT Id
                    FROM AccountContactRelation
                    WHERE (AccountId = :oldSubBranchAccount.Id OR AccountId = :oldSubBranchAccount.ParentId OR AccountId = :oldSubBranchAccount.Parent.ParentId) AND
                    ContactId = :userContact.Id
            ];
            delete oldAcrs;

            List<AccountContactRelation> upsertAcrs = new List<AccountContactRelation>();

            List<AccountContactRelation> currentAcrs = [SELECT Id, Account.ParentId, Account.Parent.ParentId FROM AccountContactRelation WHERE ContactId = :userContact.Id AND Account.RecordType.Name = 'Sub-Branch'] ;

            for (AccountContactRelation acr : currentAcrs) {
                AccountContactRelation newRegionAcr = new AccountContactRelation();
                newRegionAcr.AccountId = acr.Account.Parent.ParentId;
                newRegionAcr.ContactId = userContact.Id;
                upsertAcrs.add(newRegionAcr);

                AccountContactRelation newBranchAcr = new AccountContactRelation();
                newBranchAcr.AccountId = acr.Account.ParentId;
                newBranchAcr.ContactId = userContact.Id;
                upsertAcrs.add(newBranchAcr);
            }
            Database.upsert(upsertAcrs, false);

            return true;
        } catch (Exception e) {
            AuraHandledException auraEx = new AuraHandledException(e.getMessage());
            auraEx.setMessage(e.getMessage());
            throw auraEx;
        }
    }

    @AuraEnabled
    public static Boolean updateCommissionEntityId(String commissionEntityId, String subBranchId, String userId) {
        try {
            Account subBranch = [SELECT Id, Parent.ParentId FROM Account WHERE Id = :subBranchId LIMIT 1];
            Contact userContact = [SELECT Id FROM Contact WHERE Consultant__c = :userId LIMIT 1];
            AccountContactRelation acr = [SELECT Id FROM AccountContactRelation WHERE ContactId = :userContact.Id AND AccountId = :subBranch.Parent.ParentId LIMIT 1];
            acr.CommissionEntityId__c = commissionEntityId;

            update acr;
            return true;

        } catch (Exception e) {
            AuraHandledException auraEx = new AuraHandledException(e.getMessage());
            auraEx.setMessage(e.getMessage());
            throw auraEx;
        }

    }

    @AuraEnabled
    public static List<String> getPicklistValues() {
        Schema.DescribeSObjectResult objSchema = AccountContactRelation.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getMap();
        List<Schema.PicklistEntry>fld = fieldMap.get ('SkillGroup__c').getDescribe().getPicklistValues();
        List<String> pickListValues = new List<String>();

        for (Schema.PicklistEntry pl : fld) {
            pickListValues.add(pl.getValue());
        }

        return pickListValues;
    }

    @AuraEnabled
    public static Boolean updateSkills(String userId, List<String> selectedSkills, String subBranchId) {

        try {
            Account subBranch = [SELECT Id, Parent.ParentId FROM Account WHERE Id = :subBranchId LIMIT 1];
            Contact userContact = [SELECT Id FROM Contact WHERE Consultant__c = :userId LIMIT 1];
            AccountContactRelation acr = [SELECT Id FROM AccountContactRelation WHERE ContactId = :userContact.Id AND AccountId = :subBranch.Parent.ParentId LIMIT 1];
            acr.SkillGroup__c = String.join (selectedSkills, ';');

            update acr;
            return true;

        } catch (Exception e) {
            AuraHandledException auraEx = new AuraHandledException(e.getMessage());
            auraEx.setMessage(e.getMessage());
            throw auraEx;
        }

    }

    @AuraEnabled
    public static RelatedReAccounts getRelatedReAccounts(String searchId) {
        RelatedReAccounts result = new RelatedReAccounts();
        Account selectedAccount = [SELECT Id, Name, RecordType.Name, Parent.ParentId, ParentId FROM Account WHERE Id = :searchId];
        if (selectedAccount.RecordType.Name == 'Real Estate Network') {
            result.network = selectedAccount;
            result.agencies = [SELECT Id, Name FROM Account WHERE ParentId = :searchId];
            result.branches = [SELECT Id, Name FROM Account WHERE Parent.ParentId = :searchId];
        } else if (selectedAccount.RecordType.Name == 'Real Estate Agency') {
            result.network = [SELECT Id, Name FROM Account WHERE Id = :selectedAccount.ParentId LIMIT 1];
            result.agencies = new List<Account>{
                    selectedAccount
            };
            result.branches = [SELECT Id, Name FROM Account WHERE ParentId = :searchId];
        } else if (selectedAccount.RecordType.Name == 'Real Estate Branch') {
            result.network = [SELECT Id, Name FROM Account WHERE Id = :selectedAccount.Parent.ParentId];
            result.agencies = [SELECT Id, Name FROM Account WHERE Id = :selectedAccount.ParentId];
            result.branches = new List<Account>{
                    selectedAccount
            };
        }

        return result;
    }

    @AuraEnabled
    public static List<Contact> getRealEstateAgentsByAccountId(String accountId) {

        try {
            Account selectedAccount = [SELECT Id, Name, RecordType.Name, Parent.ParentId, ParentId FROM Account WHERE Id = :accountId];

            if (selectedAccount.RecordType.Name == 'Real Estate Network') {
                return [SELECT Id, Name FROM Contact WHERE Account.Parent.ParentId = :accountId];

            } else if (selectedAccount.RecordType.Name == 'Real Estate Agency') {
                return [SELECT Id, Name FROM Contact WHERE Account.ParentId = :accountId];

            } else {

                return [SELECT Id, Name FROM Contact LIMIT 50];
            }
        } catch (Exception e) {
            System.debug('No Agents Found');
            return new List<Contact>();
        }
    }


    @AuraEnabled
    public static AgentDetails getAgentDetails(String contactId) {

        AgentDetails ad = new AgentDetails();
        ad.agent = [SELECT Id, Active__c, Name, FirstName, AccountId, FinServ__PreferredName__c, LastName, Email, MobilePhone, Account.Name, Account.Parent.Name, Account.Parent.Parent.Name, P40_Indicator__c, X4DX_Indicator__c,Visibility__c FROM Contact WHERE Id = :contactId];
        try {
            ad.network = ad.agent.Account.Parent.Parent.Name;
        } catch (Exception e) {
        }
        try {
            ad.agency = ad.agent.Account.Parent.Name;
        } catch (Exception e) {
        }
        try {
            ad.branch = ad.agent.Account.Name;
            ad.commId = [SELECT Id, CommissionEntityId__c FROM AccountContactRelation WHERE ContactId = :ad.agent.Id AND AccountId = :ad.agent.AccountId LIMIT 1].CommissionEntityId__c;
        } catch (Exception e) {
        }
        try {
            ad.linkedConsultantName = [SELECT Id, FinServ__RelatedContact__r.Name FROM FinServ__ContactContactRelation__c WHERE FinServ__Contact__c = :contactId LIMIT 1].FinServ__RelatedContact__r.Name;
        } catch (Exception e) {

        }
        return ad;
    }

    @AuraEnabled
    public static Boolean updateAgent(Contact agent, String commId) {
        agent.et4ae5__HasOptedOutOfMobile__c = true;
        try {
            if (agent.Id != null) {
                update agent;
            } else {
                agent.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Real Estate Agent' AND SobjectType = 'Contact' LIMIT 1].Id;
                insert agent;
            }
            if (commId != null && agent.AccountId != null) {
                try {
                    AccountContactRelation acr = [SELECT Id,CommissionEntityId__c FROM AccountContactRelation WHERE ContactId = :agent.Id AND AccountId = :agent.AccountId LIMIT 1];
                    acr.CommissionEntityId__c = commId;
                    update acr;
                    return true;
                } catch (Exception e) {
                    return false;
                }
            }
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());

        }
    }

    @AuraEnabled
    public static List<Account> getRealEstateBranches() {
        return [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Real Estate Branch'];
    }

    @AuraEnabled
    public static LwcResult userManagementNetworks(String searchString, Boolean reState, Boolean searchByContact) {

        String searchKey = '%' + String.escapeSingleQuotes(searchString) + '%';
        searchKey = searchKey.replaceAll(' ', '%');

        LwcResult res = new LwcResult();
        res.contacts = new List<Contact>();
        List<String> contactParentIds = new List<String>();
        if (reState) {
            if (searchByContact) {
                res.contacts = [SELECT Id, Name, AccountId, Account.ParentId, Account.Parent.ParentId FROM Contact WHERE Name LIKE :searchKey AND RecordType.Name = 'Real Estate Agent' LIMIT 50];
            }
        } else {
            res.contacts = [SELECT Id, Name, AccountId, Account.ParentId, Account.Parent.ParentId FROM Contact WHERE Name LIKE :searchKey AND RecordType.Name = 'BetterBond Contact' LIMIT 50];
        }
        for (Contact con : res.contacts) {
            if (con.AccountId != null) {
                contactParentIds.add(con.AccountId);
            }
            if (con.Account.ParentId != null) {
                contactParentIds.add(con.Account.ParentId);
            }
            if (con.Account.Parent.ParentId != null) {
                contactParentIds.add(con.Account.Parent.ParentId);
            }
        }
        if (reState && !searchByContact) {
            res.accounts = [SELECT Id, Name, Parent.ParentId, RecordType.Name FROM Account WHERE (Name LIKE :searchKey AND (RecordType.Name = 'Real Estate Network' OR RecordType.Name = 'Real Estate Agency' OR RecordType.Name = 'Real Estate Branch')) OR (Id IN :contactParentIds) LIMIT 50];
        } else if (reState && searchByContact) {
            res.accounts = [SELECT Id, Name, Parent.ParentId, RecordType.Name FROM Account WHERE (RecordType.Name = 'Real Estate Network' OR RecordType.Name = 'Real Estate Agency' OR RecordType.Name = 'Real Estate Branch') AND (Id IN :contactParentIds) LIMIT 50];
        } else {
            res.accounts = [SELECT Id, Name, Parent.ParentId, RecordType.Name FROM Account WHERE (Name LIKE :searchKey AND (RecordType.Name = 'Region' OR RecordType.Name = 'Branch' OR RecordType.Name = 'Sub-Branch')) OR (Id IN :contactParentIds) LIMIT 50];
        }
        List<String> childAccountIds = new List<String>();
        List<String> parentAccountIds = new List<String>();
        Set <Account> accountSet = new Set <Account>();
        accountSet.addAll(res.accounts);
        for (Account acc : res.accounts) {
            childAccountIds.add(acc.Id);
        }

        for (Account acc : res.accounts) {
            if (acc.ParentId != null) {
                parentAccountIds.add(acc.ParentId);
            }
            if (acc.Parent.ParentId != null) {
                parentAccountIds.add(acc.Parent.ParentId);
            }
        }

        if (!searchByContact) {
            List<Account> accountList = [SELECT Id, Name, Parent.ParentId, RecordType.Name FROM Account WHERE ParentId IN :childAccountIds OR Parent.ParentId IN :childAccountIds OR Id IN :parentAccountIds LIMIT 50];
            accountSet.addAll(accountList);
            res.accounts.addAll(accountSet);
        }
        return res;
    }

    @AuraEnabled
    public static String CreateNetworkAgencyBranch(String networkName, String networkId, String agencyName, String agencyId, String branchName) {
        try {
            if (networkId == null) {
                Account acc = new Account(Name = networkName, RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Real Estate Network'].Id, Type = 'Other');
                insert acc;
                networkId = acc.Id;
            }

            if (agencyId == null) {
                Account acc = new Account(Name = agencyName, ParentId = networkId, RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Real Estate Agency'].Id, Type = 'Other');
                insert acc;
                agencyId = acc.Id;
                if(branchName == null){
                    return agencyId;
                }
            }

            if (branchName != null) {
                Account acc = new Account(Name = branchName, ParentId = agencyId, RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Real Estate Branch'].Id, Type = 'Other');
                insert acc;
                return acc.Id;
            }
            return 'success';
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static String CreateNetwork(String name) {
        try {
            insert new Account(Name = name, RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Real Estate Network'].Id, Type = 'Other');
        } catch (Exception e) {
            System.debug('Error occurred' + e.getMessage());
            return e.getMessage();
        }
        return 'success';
    }

    @AuraEnabled
    public static String CreateAgency(String name, String parentId) {
        try {
            insert new Account(Name = name, RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Real Estate Agency'].Id, Type = 'Other', ParentId = parentId);
        } catch (Exception e) {
            System.debug('Error occurred' + e.getMessage());
            return e.getMessage();
        }
        return 'success';
    }

    @AuraEnabled
    public static String CreateReBranch(String name, String parentId) {
        try {
            Account acc = new Account(Name = name, RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Real Estate Branch'].Id, Type = 'Other', ParentId = parentId);
            insert acc;
            return acc.Id;
        } catch (Exception e) {
            System.debug('Error occurred' + e.getMessage());
            return e.getMessage();
        }


    }

    @AuraEnabled
    public static Boolean CreateRegion(String name) {
        insert new Account(Name = name, RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Region'].Id, Type = 'Other');
        return true;
    }

    @AuraEnabled
    public static Boolean CreateBranch(String name, String parentId) {
        insert new Account(Name = name, RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Branch'].Id, Type = 'Other', ParentId = parentId);
        return true;
    }

    @AuraEnabled
    public static Boolean CreateSubBranch(String name, String parentId) {
        insert new Account(Name = name, RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Sub-Branch'].Id, Type = 'Other', ParentId = parentId);
        return true;
    }

    @AuraEnabled
    public static List<Contact> getAllConsultants() {
        return [SELECT Id, Name FROM Contact WHERE RecordType.Name = 'BetterBond Contact' AND Consultant__r.IsActive = TRUE AND Consultant__r.Profile.Name = 'Consultant'];
    }


    @AuraEnabled
    public static Boolean deleteCCRById(Id ccrId) {
        try {
            delete new FinServ__ContactContactRelation__c(Id = ccrId);
            return true;
        } catch (Exception e) {
            return false;
        }
    }


    @AuraEnabled
    public static Boolean createCCRByConsultant(String consultantUserId, String agentContactId) {

        try {
            FinServ__ContactContactRelation__c ccr = new FinServ__ContactContactRelation__c();
            FinServ__ReciprocalRole__c role = [SELECT Id FROM FinServ__ReciprocalRole__c WHERE Name = 'Consultant' LIMIT 1];

            ccr.FinServ__Role__c = role.Id;
            ccr.FinServ__Contact__c = [SELECT Id FROM Contact WHERE Consultant__c = :consultantUserId LIMIT 1].Id;
            ccr.FinServ__RelatedContact__c = agentContactId;
            ccr.FinServ__Active__c = true;
            ccr.FinServ__StartDate__c = Date.today();

            insert ccr;
            return true;
        } catch (Exception e) {
            return false;
        }

    }

    @AuraEnabled
    public static Boolean createCCRByAgent(String consultantContactId, String agentContactId) {

        try {
            FinServ__ContactContactRelation__c ccr = new FinServ__ContactContactRelation__c();
            FinServ__ReciprocalRole__c role = [SELECT Id FROM FinServ__ReciprocalRole__c WHERE Name = 'Consultant' LIMIT 1];

            ccr.FinServ__Role__c = role.Id;
            ccr.FinServ__Contact__c = consultantContactId;
            ccr.FinServ__RelatedContact__c = agentContactId;
            ccr.FinServ__Active__c = true;
            ccr.FinServ__StartDate__c = Date.today();

            insert ccr;
            return true;
        } catch (Exception e) {
            return false;
        }

    }

    @AuraEnabled
    public static List<Contact> getAllReAgentsNotLinkedToRunningConsultant(String consultantUserId) {
        List<FinServ__ContactContactRelation__c> ccrs = [SELECT Id, FinServ__RelatedContact__c FROM FinServ__ContactContactRelation__c WHERE FinServ__Contact__c = :[SELECT Id from Contact where Consultant__c = :consultantUserId limit 1].Id ORDER BY FinServ__RelatedContact__r.Name];
        List<String> usedAgentIds = new List<String>();
        for (FinServ__ContactContactRelation__c ccr : ccrs) {
            usedAgentIds.add(ccr.FinServ__RelatedContact__c);
        }
        return [SELECT Id, Name FROM Contact WHERE RecordType.Name = 'Real Estate Agent' AND Id NOT IN :usedAgentIds];
    }

    @AuraEnabled
    public static List<Contact> getAllConsultantsNotLinkedToRunningAgent(String agentContactId) {
        List<FinServ__ContactContactRelation__c> ccrs = [SELECT Id, FinServ__RelatedContact__c FROM FinServ__ContactContactRelation__c WHERE FinServ__Contact__c = :agentContactId ORDER BY FinServ__RelatedContact__r.Name];
        List<String> usedConsultantIds = new List<String>();
        for (FinServ__ContactContactRelation__c ccr : ccrs) {
            usedConsultantIds.add(ccr.FinServ__RelatedContact__c);
        }
        return [SELECT Id, Name FROM Contact WHERE RecordType.Name = 'Betterbond Contact' AND Consultant__r.Profile.Name = 'Consultant' AND Consultant__r.IsActive = TRUE AND Id NOT IN :usedConsultantIds];
    }

    @AuraEnabled
    public static List<FinServ__ContactContactRelation__c> getAllLinkedAgents(String consultantUserId) {
        List<FinServ__ContactContactRelation__c> results = new List<FinServ__ContactContactRelation__c>();
        results = [SELECT Id, Name, FinServ__RelatedContact__r.Name FROM FinServ__ContactContactRelation__c WHERE FinServ__Contact__c = :[SELECT Id from Contact where Consultant__c = :consultantUserId AND RecordType.Name = 'Betterbond Contact' limit 1].Id ORDER BY FinServ__RelatedContact__r.Name];
        return results;
    }

    @AuraEnabled
    public static List<FinServ__ContactContactRelation__c> getAllLinkedConsultants(String agentContactId) {
        List<FinServ__ContactContactRelation__c> results = new List<FinServ__ContactContactRelation__c>();
        results = [SELECT Id, Name, FinServ__RelatedContact__r.Name FROM FinServ__ContactContactRelation__c WHERE FinServ__Contact__c = :agentContactId ORDER BY FinServ__RelatedContact__r.Name];
        return results;
    }

    @AuraEnabled
    public static Account getAccount(String recordId) {
        try {
            return [SELECT Id, Name, RecordType.Name FROM Account WHERE Id = :recordId LIMIT 1];

        } catch (Exception e) {
            System.debug('Error' + e.getMessage());
            return new Account();
        }
    }

    @AuraEnabled
    public static String updateAccountName(Account acc) {
        try {
            update acc;
            return 'success';
        } catch (Exception e) {
            System.debug('Error Updating Account Name' + e.getMessage());
            return e.getMessage();
        }
    }


    @AuraEnabled
    public static String deleteAccount(String recordId) {

        try {
            List<Account> accounts = new List<Account>();
            Set<String> accountIds = new Set<String>();
            Set<SObject> recordsToDelete = new Set<SObject>();
            Account selectedAccount = [SELECT Id, Name, RecordType.Name, Parent.ParentId, ParentId FROM Account WHERE Id = :recordId];
            if (selectedAccount.RecordType.Name == 'Real Estate Network') {
                accounts.add(selectedAccount);
                accounts.addAll([SELECT Id, Name FROM Account WHERE ParentId = :recordId]);
                accounts.addAll([SELECT Id, Name FROM Account WHERE Parent.ParentId = :recordId]);
            } else if (selectedAccount.RecordType.Name == 'Real Estate Agency') {
                accounts.add(selectedAccount);
                accounts.addAll([SELECT Id, Name FROM Account WHERE ParentId = :recordId]);
                accountIds.add(selectedAccount.ParentId);
            } else if (selectedAccount.RecordType.Name == 'Real Estate Branch') {
                accounts.add(selectedAccount);
                accountIds.add(selectedAccount.ParentId);
                accountIds.add(selectedAccount.Parent.ParentId);
            }

            for (Account acc : accounts) {
                accountIds.add(acc.Id);
            }
            List<AccountContactRelation> acrList = [SELECT Id, ContactId FROM AccountContactRelation WHERE AccountId IN :accountIds AND IsDirect = FALSE];
            List<String> contactIds = new List<String>();

            for (AccountContactRelation acr : acrList) {
                contactIds.add(acr.ContactId);
                recordsToDelete.add(acr);

            }
            List<Contact> contactList = [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds];

            for (Contact ct : contactList) {
                ct.AccountId = null;
            }

            delete new List<AccountContactRelation>(acrList);
            update contactList;
            delete new List<Account>(accounts);

            return 'success';
        } catch (Exception e) {
            System.debug('Unable to delete records - ' + e.getMessage());
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static Boolean CreateCampaign(
            String name,
            Decimal sla,
            Date endDate,
            Date startDate,
            Boolean active,
            String branchId,
            String campaignList,
            String typeOfCampaign,
            String typeOfLead,
            String priority,
            String campaignOwner,
            String campaignGroup) {

        try {

            Account branch = [SELECT Id, Name, ParentId, Parent.ParentId FROM Account WHERE Id = :branchId LIMIT 1];

            BLG_Campaign__c camp = new BLG_Campaign__c();
            camp.End_Date__c = endDate;
            camp.Campaign_List__c = campaignList;
            camp.Type_of_Campaign__c = typeOfCampaign;
            camp.Type_of_Lead__c = typeOfLead;
            camp.Priority__c = priority;
            camp.Campaign_Owner__c = campaignOwner;
            camp.Group__c = campaignGroup;
            camp.Name = branch.Name;
            camp.Start_Date__c = startDate;
            camp.Active__c = active;
            camp.SLA__c = sla;
            camp.Branch__c = branchId;
            camp.Agency__c = branch.ParentId;
            camp.Network__c = branch.Parent.ParentId;

            insert camp;

            return true;
        } catch (Exception e) {
            System.debug('error');
            return false;
        }
    }

    @AuraEnabled
    public static String deactivateAgent(String contactId) {

        try {
            List<FinServ__ContactContactRelation__c> ccrList = [SELECT Id FROM FinServ__ContactContactRelation__c WHERE FinServ__Contact__c = :contactId];
            delete ccrList;

            List<AccountContactRelation> acrList = [SELECT Id FROM AccountContactRelation WHERE ContactId = :contactId AND IsDirect = FALSE];
            delete acrList;


            update new Contact(Id = contactId, AccountId = null, Active__c = false);
            return 'success';
        } catch (Exception e) {
            System.debug(e.getMessage());
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static String reactivateAgent(String contactId) {
        try {
            update new Contact(Id = contactId, Active__c = true);
            return 'success';
        } catch (Exception e) {
            System.debug(e.getMessage());
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static String getSobjectType(Id recordId) {
            return recordId.getSobjectType().getDescribe().getName();
        }

    public class LwcResult {
        @AuraEnabled public List<Account> accounts;
        @AuraEnabled public List<Contact> contacts;
    }


    public class AgentDetails {
        @AuraEnabled public Contact agent;
        @AuraEnabled public String network;
        @AuraEnabled public String agency;
        @AuraEnabled public String branch;
        @AuraEnabled public String linkedConsultantName;
        @AuraEnabled public String commId;
    }

    public class RelatedReAccounts {
        @AuraEnabled public Account network;
        @AuraEnabled public List<Account> agencies;
        @AuraEnabled public List<Account> branches;
    }

    public class Admin {
        @AuraEnabled public User user;
        @AuraEnabled public String role;
        @AuraEnabled public String accessLevel;
    }

    public class SubBranch {
        @AuraEnabled public String subBranchId;
        @AuraEnabled public String branchName;
        @AuraEnabled public String regionName;
        @AuraEnabled public String commissionEntityId;
        @AuraEnabled public List<String> skills;
    }

}