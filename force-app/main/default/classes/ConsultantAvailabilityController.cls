/**
 * Created by frans fourie on 2023/10/03.
 */

public with sharing class ConsultantAvailabilityController {

    @AuraEnabled
    public static ConsultantsAvailable GetNumberOfConsultantsAvailable() {
        Datetime now = Datetime.now().addHours(-2);
        List<User> directConsultants = [SELECT Id FROM User WHERE UserRole.Name LIKE '%Direct%' AND Profile.Name = 'Consultant' AND IsActive = TRUE];
        List<User> availableDirectConsultants = [SELECT Id FROM User WHERE UserRole.Name LIKE '%Direct%' AND Profile.Name = 'Consultant' AND IsActive = TRUE AND AvailableforRouting__c = TRUE];
        List<User> unavailableDirectConsultants = [SELECT Id, Name FROM User WHERE UserRole.Name LIKE '%Direct%' AND Profile.Name = 'Consultant' AND IsActive = TRUE AND AvailableforRouting__c = FALSE];
        List<Consultant_Availability__c> consultantAvailabilities = [SELECT Id, Unavailable_Reason__c FROM Consultant_Availability__c WHERE Consultant__c IN :unavailableDirectConsultants AND Unavailable_To__c = NULL AND Unavailable_From__c < :now];
        ConsultantsAvailable ca = new ConsultantsAvailable();
        ca.availableConsultants = availableDirectConsultants.size();
        ca.totalConsultants = directConsultants.size();
        ca.lunch = 0;
        ca.meeting = 0;
        ca.sickLeave = 0;
        ca.annualLeave = 0;
        ca.adminTime = 0;
        ca.travelling = 0;

        for (Consultant_Availability__c cal : consultantAvailabilities) {
            switch on cal.Unavailable_Reason__c {
                when 'Lunch' {
                    ca.lunch = ca.lunch + 1;
                }
                when 'Meeting/Training' {
                    ca.meeting = ca.meeting + 1;
                }
                when 'Annual Leave' {
                    ca.annualLeave = ca.annualLeave + 1;
                }
                when 'Sick Leave' {
                    ca.sickLeave = ca.sickLeave + 1;
                }
                when 'Admin Time' {
                    ca.adminTime = ca.adminTime + 1;
                }
                when 'Travelling' {
                    ca.travelling = ca.travelling + 1;
                }
            }
        }

        return ca;
    }

    @AuraEnabled
    public static List<Consultant_Availability__c> getUnavailableUsers(String unavailableReason) {

        List<String> unavailableUserIds = new List<String>();
        Datetime now = Datetime.now();
        List<Consultant_Availability__c> unavailableUsers = [
                SELECT Id, Consultant__r.FirstName, Consultant__r.LastName, Unavailable_From__c, Unavailable_Reason__c
                FROM Consultant_Availability__c
                WHERE Consultant__r.AvailableforRouting__c = FALSE AND Unavailable_To__c = NULL AND Unavailable_From__c < :now
        ];
        for (Consultant_Availability__c ca : unavailableUsers) {
            ca.Unavailable_From__c = ca.Unavailable_From__c.addHours(2);
            unavailableUserIds.add(ca.Consultant__c);
        }
        List<User> availableUsers = [SELECT Id, FirstName, LastName FROM User WHERE UserRole.Name LIKE '%Direct%' AND AvailableforRouting__c = TRUE AND Profile.Name = 'Consultant' AND IsActive = TRUE AND Id NOT IN :unavailableUserIds];

        for (User u : availableUsers) {
            Consultant_Availability__c ca = new Consultant_Availability__c();
            ca.Consultant__c = u.Id;
            ca.Unavailable_Reason__c = 'Available';
            ca.Consultant__r = new User();
            ca.Consultant__r.FirstName = u.FirstName;
            ca.Consultant__r.LastName = u.LastName;
            unavailableUsers.add(ca);
        }

        List<User> initialUsers = [SELECT Id, FirstName, LastName FROM User WHERE UserRole.Name LIKE '%Direct%' AND AvailableforRouting__c = FALSE AND Profile.Name = 'Consultant' AND IsActive = TRUE AND Id NOT IN :unavailableUserIds];

        for (User u : initialUsers) {
            Consultant_Availability__c ca = new Consultant_Availability__c();
            ca.Consultant__c = u.Id;
            ca.Unavailable_Reason__c = 'Not Available';
            ca.Consultant__r = new User();
            ca.Consultant__r.FirstName = u.FirstName;
            ca.Consultant__r.LastName = u.LastName;
            unavailableUsers.add(ca);
        }
        unavailableUsers.sort();

        return unavailableUsers;
    }

    @AuraEnabled
    public static Boolean userAvailable(String userId) {
        try {
            return [SELECT AvailableforRouting__c FROM User WHERE Id = :userId].AvailableforRouting__c == true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static String futureUnavailabilities(String userId) {
        try {
            Datetime now = Datetime.now().addHours(-2);
            Consultant_Availability__c ca = [SELECT Id, Unavailable_From__c FROM Consultant_Availability__c WHERE Consultant__c = :userId AND Unavailable_To__c = NULL AND Unavailable_From__c > :now LIMIT 1];
            System.debug(ca.Id);
            ca.Unavailable_From__c = ca.Unavailable_From__c.addHours(2);
            return String.valueOf(ca.Unavailable_From__c).replaceAll('T', ' ').replaceAll('Z', '');
        } catch (Exception e) {
            return 'No Record Found';
        }
    }

    @AuraEnabled
    public static Boolean DeleteFutureAvailabilityRecord(String userId) {
        try {
            Datetime now = Datetime.now();
            delete [SELECT Id FROM Consultant_Availability__c WHERE Consultant__c = :userId AND Unavailable_From__c > :now];
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static Boolean MarkUserAvailable(String userId) {
        Datetime now = Datetime.now();
        try {
            update new User(Id = userId, AvailableforRouting__c = true);
            List<Consultant_Availability__c> caList = [SELECT Id FROM Consultant_Availability__c WHERE Unavailable_From__c < :now AND Consultant__c = :userId AND Unavailable_To__c = NULL];
            for (Consultant_Availability__c ca : caList) {
                ca.Unavailable_To__c = Datetime.now();
            }

            update caList;
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static Boolean CreateConsultantAvailability(String userId, String reason, Boolean futureEntry, Datetime futureDate) {
        try {
            Consultant_Availability__c ca = new Consultant_Availability__c();
            ca.Consultant__c = userId;
            if (!futureEntry) {
                ca.Unavailable_From__c = Datetime.now().addHours(-2);
            } else {
                ca.Unavailable_From__c = futureDate.addHours(-2);
            }
            ca.Unavailable_Reason__c = reason;
            insert ca;
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static Boolean MarkUserUnavailable(String userId) {
        try {
            update new User(Id = userId, AvailableforRouting__c = false);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static List<Contact> DirectOnlyAvailableConsultants(String userId) {

        List<Contact> sameSubBranchConsultants = [
                SELECT Id, Name, Consultant__c, Account.Parent.Parent.Name
                FROM Contact
                WHERE Consultant__r.IsActive = TRUE AND Consultant__r.Profile.Name = 'Consultant'
                AND Consultant__r.AvailableforRouting__c = TRUE AND Consultant__c != :userId AND Consultant__r.UserRole.Name LIKE '%Direct%'
                ORDER BY Name
        ];
        return sameSubBranchConsultants;

    }

    public class ConsultantsAvailable {
        @AuraEnabled public Integer totalConsultants;
        @AuraEnabled public Integer availableConsultants;
        @AuraEnabled public Integer sickLeave;
        @AuraEnabled public Integer annualLeave;
        @AuraEnabled public Integer lunch;
        @AuraEnabled public Integer meeting;
        @AuraEnabled public Integer adminTime;
        @AuraEnabled public Integer travelling;

    }

}