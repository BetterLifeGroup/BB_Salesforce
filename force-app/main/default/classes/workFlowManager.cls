/**
 * Created by frans fourie on 2023/01/13.
 */

public with sharing class workFlowManager {
    @AuraEnabled
    public static List<LoanApp> getLoanApplicants(Id recordId) {

        System.debug(recordId);

        List<LoanApp> loanAppList = new List<LoanApp>();

        String objectType = String.valueOf(recordId.getSobjectType()).removeEnd('__c');

        List<LoanApplicant> loanApplicants = new List<LoanApplicant>();

        if (objectType == 'Opportunity') {
            loanApplicants = [
                    SELECT Id, Name, Name_Title__c, Status__c, SourceOpportunity__c
                    FROM LoanApplicant
                    WHERE SourceOpportunity__c = :recordId AND IsActive__c = TRUE
                    ORDER BY Is_Main_Applicant__c DESC
                    LIMIT 65
            ];
        } else if (objectType == 'LoanApplicant') {
            loanApplicants = [
                    SELECT Id, Name, Name_Title__c, Status__c, SourceOpportunity__c
                    FROM LoanApplicant
                    WHERE Id = :recordId AND IsActive__c = TRUE
                    ORDER BY Is_Main_Applicant__c DESC
                    LIMIT 2
            ];
        }
        List<String> listOfPicklistOptions = new List<String>();

        List<Schema.PicklistEntry> picklistEntry = LoanApplicant.Status__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry ple : picklistEntry) {
            listOfPicklistOptions.add(ple.label);
        }

        for (LoanApplicant la : loanApplicants) {
            LoanApp loanApp = new LoanApp();
            loanApp.loanApplicant = la;
            loanApp.pickListValues = listOfPicklistOptions;

            loanAppList.add(loanApp);

        }

        return loanAppList;

    }

    public class LoanAppList {
        @AuraEnabled public List<LoanApp> applicants;
    }

    public class LoanApp {
        @AuraEnabled public LoanApplicant loanApplicant;
        @AuraEnabled public List<String> pickListValues;
    }

}