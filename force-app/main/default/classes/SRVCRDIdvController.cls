/**
 * Created by frans fourie on 2022/10/20.
 */

public class SRVCRDIdvController {
    @AuraEnabled
    public static SRVCRDCreditCheckVerification getIdvQuestions(String loanApplicantId, String idNumber, String idType) {

        LoanApplicant la = [SELECT Id, Contact.AccountId, Personal_ID_Number__c, idvVerificationRequestNumber__c FROM LoanApplicant WHERE Id = :loanApplicantId LIMIT 1 FOR UPDATE];
        Account acc = [SELECT Id, Identification_Type__c FROM Account WHERE Id = :la.Contact.AccountId LIMIT 1 FOR UPDATE];


        System.debug(idNumber + ' - ' + idType);
        SRVCRDIdvGetRequest param = new SRVCRDIdvGetRequest();
        param.appName = 'Smart Service';
        param.appVersion = 'v1';
        param.clientConsent = 'Y';
        param.idType = idType;
        param.noOfQuestions = 5;
        param.idNumber = idNumber;

        Map<String, Object> params = new Map<String, Object>{
                'srVCRDIdvGetRequest' => param
        };

        SRVCRDClient client;

        client = new SRVCRDClient();
        Integration_Parameter__mdt integrationParam = Integration_Parameter__mdt.getInstance('Subscription_Key');
        ((OAS.ApiKeyAuth) client.getAuthentication('apiKeyHeader')).setApiKey(integrationParam.Parameter_Value__c);

        SRVCRDIdvApiDeligate crd = new SRVCRDIdvApiDeligate(client);
        SRVCRDCreditCheckVerification obj = new SRVCRDCreditCheckVerification();
        try {
            obj = crd.postIdvGetquestionsDeligate(params);
        } catch (OAS.ApiException e) {
            throw new AuraHandledException(e.getBody());

        }
        if (obj.questions == null) {
            throw new AuraHandledException('Unable to load questions, too many queries');
        }
        if (obj.questions.size() < 5) {

            throw new AuraHandledException('Unable to load questions, too many queries');
        }

        la.idvVerificationRequestNumber__c = obj.verificationRequestNumber;
        if (idType == 'SID') {
            acc.Identification_Type__c = 'Smart ID';
            acc.Identification_Number__c = idNumber;
        } else {
            acc.Identification_Type__c = 'Passport';
            acc.Passport_Number__c = idNumber;
        }

        update la;
        update acc;
        return obj;
    }

    @AuraEnabled
    public static SRVCRDCreditCheckAppVerificationResu checkIdvAnswers(SRVCRDIdvCheckRequest answers, String loanApplicantId) {

        LoanApplicant la = [SELECT Id, idvVerificationRequestNumber__c FROM LoanApplicant WHERE Id = :loanApplicantId LIMIT 1];

        SRVCRDIdvCheckRequest param = new SRVCRDIdvCheckRequest();
        param.answers = answers.answers;
        param.sourceSystem = answers.sourceSystem;
        param.verificationRequestNumber = answers.verificationRequestNumber;
        Map<String, Object> params = new Map<String, Object>{
                'SRVCRDIdvCheckRequest' => param
        };


        SRVCRDClient client;

        client = new SRVCRDClient();
        Integration_Parameter__mdt integrationParam = Integration_Parameter__mdt.getInstance('Subscription_Key');
        ((OAS.ApiKeyAuth) client.getAuthentication('apiKeyHeader')).setApiKey(integrationParam.Parameter_Value__c);

        SRVCRDIdvApiDeligate crd = new SRVCRDIdvApiDeligate(client);
        SRVCRDCreditCheckAppVerificationResu obj = new SRVCRDCreditCheckAppVerificationResu();
        try {
            obj = crd.postIdvCheckanswersDeligate(params);
        } catch (OAS.ApiException e) {
            System.debug(e);
            throw new AuraHandledException(e.getBody());


        }
        System.debug(obj);
        try {
            la.idvFinalScore__c = Integer.valueOf(obj.finalScore);
            la.idvResponseStatus__c = obj.responseStatus;
        } catch (Exception e) {
            throw new AuraHandledException('Invalid response from domain, please try again later');
        }

        update la;

        return obj;
    }

    @AuraEnabled
    public static void setManualConsentParamsForMC(String loanApplicantId) {

        try {

            Account acc = [SELECT Id, ConsentRequirementsMet__c FROM Account WHERE Id = :[SELECT Id, Contact.AccountId from LoanApplicant where Id = :loanApplicantId].Contact.AccountId LIMIT 1];
            acc.ConsentRequirementsMet__c = false;
            update acc;

            LoanApplicant la = [SELECT Id FROM LoanApplicant WHERE Id = :loanApplicantId LIMIT 1];
            la.Status__c = 'Awaiting Consent';

            update la;

            Opportunity opp = [
                    SELECT Id, emailSendTrigger__c, Status__c, Template_Selection__c
                    FROM Opportunity
                    WHERE Id = :[SELECT SourceOpportunity__c from LoanApplicant where Id = :loanApplicantId AND Is_Main_Applicant__c = true].SourceOpportunity__c
            ];
            opp.ConsentRequirementsMet__c = false;
            opp.emailSendTrigger__c = true;
            opp.Template_Selection__c = 'PA - sending consent form (spoke to client)';
            opp.Status__c = 'PA requested - IDV failed - awaiting consent';
            opp.Wrap_Up_Reason__c = 'Automated';
            update opp;

        } catch (Exception e) {
        }

    }

    @AuraEnabled
    public static void setOpportunityStatus(String loanApplicantId, String status, String stageName, String wrapUpReason) {

        try {
            Opportunity opp = [SELECT Id, emailSendTrigger__c, Status__c, Template_Selection__c FROM Opportunity WHERE Id = :[SELECT SourceOpportunity__c from LoanApplicant where Id = :loanApplicantId AND Is_Main_Applicant__c = true].SourceOpportunity__c FOR UPDATE];
            opp.Status__c = status;
            opp.StageName = stageName;
            opp.Wrap_Up_Reason__c = wrapUpReason;
            update opp;
        } catch (Exception e) {
        }
    }

    @AuraEnabled
    public static void setLoanApplicantStatus(String loanApplicantId, String status) {

        try {
            LoanApplicant la = [SELECT Id, Status__c FROM LoanApplicant WHERE Id = :loanApplicantId LIMIT 1 FOR UPDATE];
            la.Status__c = status;
            update la;
        } catch (Exception e) {
        }

    }

    @AuraEnabled
    public static LoanApplicant getLoanApplicant(String loanApplicantId) {

        LoanApplicant la = [
                SELECT Id, Personal_ID_Number__c, Is_Main_Applicant__c, idvFinalScore__c, Contact.Account.Identification_Number__c
                FROM LoanApplicant
                WHERE Id = :loanApplicantId
                LIMIT 1
        ];

        return la;
    }

    @AuraEnabled
    public static Boolean updateLoanApplicant(String loanApplicantId, String idNumber, String idType, String passportNumber) {

        System.debug(idType);
        Boolean success = false;

        try {
            Account acc = [SELECT Id, Identification_Number__c FROM Account WHERE Id = :[SELECT Id, Contact.AccountId from LoanApplicant where Id = :loanApplicantId].Contact.AccountId];
            if (idType == 'SID') {
                acc.Identification_Type__c = 'Smart ID';
                acc.Identification_Number__c = idNumber;
            } else {
                acc.Identification_Type__c = 'Passport';
                acc.Passport_Number__c = passportNumber;
            }
            update acc;
            success = true;
        } catch (Exception e) {
            return success;
        }
        return success;
    }

    @AuraEnabled
    public static Boolean biometricUpdates(String loanApplicantId, String xdsScore) {
        try {
            LoanApplicant la = [SELECT Id, creditCheckScore__c,LoanApplication.OpportunityId FROM LoanApplicant WHERE Id = :loanApplicantId];
            la.creditCheckScore__c = Decimal.valueOf(xdsScore);

            update la;

            Opportunity opp = new Opportunity(Id=la.LoanApplication.OpportunityId,Status__c='PA Requested - awaiting documents',Wrap_Up_Reason__c='Automated');
            update opp;

            return true;
        } catch (Exception e) {
            System.debug('Unable to update Biometric requirements - ' + e.getMessage());
            return false;
        }

    }

    @AuraEnabled
    public static Boolean closeOppBiometricLowXdsScore(String applicantId, String xdsScore) {

        try {
            LoanApplicant la = [SELECT Id, Is_Main_Applicant__c, LoanApplication.OpportunityId FROM LoanApplicant WHERE Id = :applicantId];
            la.creditCheckScore__c = Decimal.valueOf(xdsScore);
            la.Status__c = 'Poor Credit';
            update la;
            if (la.Is_Main_Applicant__c) {
                Opportunity opp = new Opportunity(Id = la.LoanApplication.OpportunityId, StageName = 'Closed Lost',Status__c = 'Poor credit', Wrap_Up_Reason__c = 'Automated');
                update opp;
                return true;
            }
            return true;
        } catch (Exception e) {
            System.debug('Unable to close opportunity - ' + e.getMessage());
            return false;
        }
    }

    @AuraEnabled
    public static Boolean redoConsent(String loanApplicantId) {

        Boolean success = false;

        try {
            LoanApplicant la = [
                    SELECT Contact.AccountId
                    FROM LoanApplicant
                    WHERE Id = :loanApplicantId

            ];

            Account acc = [SELECT Id, ConsentRequirementsMet__c FROM Account WHERE Id = :la.Contact.AccountId LIMIT 1];

            acc.ConsentRequirementsMet__c = false;
            update acc;
            success = true;
        } catch (Exception e) {
            return success;
        }
        return success;
    }


    @AuraEnabled
    public static Boolean manualConsentPending(String loanApplicantId) {

        try {
            Opportunity opp = [SELECT Id, emailSendTrigger__c, Status__c, Template_Selection__c FROM Opportunity WHERE Id = :[SELECT SourceOpportunity__c from LoanApplicant where Id = :loanApplicantId].SourceOpportunity__c FOR UPDATE];

            if (opp.Status__c == 'PA requested - IDV failed - awaiting consent') {
                return true;
            }
        } catch (Exception e) {
        }
        return false;
    }

    @AuraEnabled
    public static Boolean accountEmailPopulated(Id loanApplicantId) {

        try {
            String email = ' ';
            email = [SELECT Id, Account_Email__c FROM LoanApplicant WHERE Id = :loanApplicantId].Account_Email__c;
            if (email.length() > 2) {
                return true;
            }

        } catch (Exception e) {
            return false;
        }

        return false;
    }

    @AuraEnabled
    public static void updateEmailAddress(String emailAddress, Id loanApplicantId) {

        try {
            Account acc = new Account();
            LoanApplicant la = [SELECT Id, ContactId FROM LoanApplicant WHERE Id = :loanApplicantId];
            Contact con = [SELECT Id, AccountId FROM Contact WHERE Id = :la.ContactId];
            acc.PersonEmail = emailAddress;
            acc.Id = con.AccountId;

            update acc;

        } catch (Exception e) {
            System.debug(e);
        }
    }

    @AuraEnabled
    public static List<String> documentCheck(String loanApplicantId){

        List<String> result = new List<String>();
        List<String> cvIds = [SELECT relatedFilesIds__c FROM LoanApplicant WHERE Id = :loanApplicantId].relatedFilesIds__c.split(';');
        List<ContentVersion> cvList = [SELECT Id,Title FROM ContentVersion WHERE Id IN :cvIds];
        for(ContentVersion cv : cvList){
            result.add(cv.Title);
        }
        return result;
    }

}