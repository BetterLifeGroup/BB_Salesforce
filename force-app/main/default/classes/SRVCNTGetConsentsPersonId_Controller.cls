/**
 * Created by fkleynhans on 2022/09/13.
 */

public without sharing class SRVCNTGetConsentsPersonId_Controller {
    @AuraEnabled(cacheable=true)
    public static List<SRVCNTGetConsentsResult> getPersonConsents(String personId, List<String> scopes) {
        List<SRVCNTGetConsentsResult> responseList = new List<SRVCNTGetConsentsResult>();
        SRVCNTClient client = new SRVCNTClient();
        SRVCNTConsents_DeligateApi api = new SRVCNTConsents_DeligateApi(client);
        Integration_Parameter__mdt integrationParam = Integration_Parameter__mdt.getInstance('Subscription_Key');
        ((OAS.ApiKeyAuth) client.getAuthentication('apiKeyHeader')).setApiKey(integrationParam.Parameter_Value__c);

//        Map<String, Object> params = new Map<String, Object>{
//                'personId' => personId,
//                'scopes' => scopes
//        };
        Map<String, Object> params = new Map<String, Object>{
                'personId' => personId
        };

        List<SRVCNTGetConsentsResult> personConsents = new List<SRVCNTGetConsentsResult>();
        try {
            personConsents = (List<SRVCNTGetConsentsResult>) api.getConsentsPersonidPersonid(params);
        } catch (OAS.ApiException e) {
            //throw new AuraHandledException(e.getBody());
        }

        List<String> personConsentsIds = new List<String>();
        List<SRVCNTGetConsentsResult> combinedConsents = new List<SRVCNTGetConsentsResult>();

        combinedConsents.addAll(personConsents);

        for (SRVCNTGetConsentsResult pc : personConsents) {
            personConsentsIds.add(pc.consentTypeId);
        }

        List<SRVCNTGetConsentTypesResult> allConsents = new List<SRVCNTGetConsentTypesResult>();
        try {
            allConsents = SRVCNTGetConsentTypes_Controller.getConsentTypes(scopes);
        } catch (OAS.ApiException e) {
            throw new AuraHandledException(e.getBody());
        }

        for (SRVCNTGetConsentTypesResult ctr : allConsents) {
            if (!personConsentsIds.contains(ctr.id) || Test.isRunningTest()) {
                SRVCNTGetConsentsResult newConsent = new SRVCNTGetConsentsResult();
                newConsent.context = ctr?.contextDefinition;
                newConsent.consentTypeId = ctr?.id;
                //newConsent.granted = false;
                newConsent.notSet = true;
                //newConsent.required = 'true';
                SRVCNTConsentTypeSnapshot newConsentTypeSnapshot = new SRVCNTConsentTypeSnapshot();
                newConsentTypeSnapshot.name = ctr?.name;
                newConsentTypeSnapshot.scope = ctr?.scope;
                newConsentTypeSnapshot.category = ctr?.category;
                newConsentTypeSnapshot.declaration = ctr?.declaration;
                newConsentTypeSnapshot.description = ctr?.description;
                newConsentTypeSnapshot.fileId = ctr?.fileId;
                newConsentTypeSnapshot.fileName = ctr?.fileName;
                newConsentTypeSnapshot.version = ctr?.version;
                newConsent.consentTypeSnapshot = newConsentTypeSnapshot;

                combinedConsents.add(newConsent);
            }
        }

        // TODO Loop through Consents and check requirement
        Map<String, Required_Consents__mdt> requiredConsentsmtd = Required_Consents__mdt.getAll();
        Map<String, String> requiredConsentsMap = new Map<String, String>();
        List<SRVCNTGetConsentsResult> returnedConsents = new List<SRVCNTGetConsentsResult>();

        for (Required_Consents__mdt reqC : requiredConsentsmtd.values()) {
            requiredConsentsMap.put(reqC.Description__c, reqC.RequiredValue__c);
        }

        for (SRVCNTGetConsentsResult result : combinedConsents) {
            // Check the map for requirements
            String reqString = requiredConsentsMap.get(result.consentTypeSnapshot.description);
            if (reqString == 'Yes') {
                // Set requirement to yes
                result.required = 'true';
            } else if (reqString == 'Any') {
                // Set requirement to yes/no
                result.required = 'false';
            }
            returnedConsents.add(result);
        }
        System.debug(returnedConsents);
        return returnedConsents;
    }

    @AuraEnabled
    public static String updateConsents(String personId, List<SRVCNTGetConsentsResult> consentReqList) {

        SRVCNTCreateConsentsRequest request = new SRVCNTCreateConsentsRequest();
        request.personId = personId;
        List<SRVCNTCreateConsentDto> consents = new List<SRVCNTCreateConsentDto>();
        Integration_Parameter__mdt consumerKey = Integration_Parameter__mdt.getInstance('Consumer_Key');

        for (SRVCNTGetConsentsResult consnt : consentReqList) {
            SRVCNTCreateConsentDto consent = new SRVCNTCreateConsentDto();
            consent.context = consnt.context;
            consent.sourceURN = 'SalesForce:SFID';
            consent.apiClientId = consumerKey.Parameter_Value__c;
            consent.createdBy = 'Salesforce';
            consent.consentTypeId = consnt.consentTypeId;
            consent.granted = consnt.granted;
            consent.fileName = consnt.fileName;
            consent.fileId = consnt.fileName;

            consents.add(consent);
        }

        request.consents = consents;

        Map<String, Object> params = new Map<String, Object>{
                'srVCNTCreateConsentsRequest' => request
        };

        SRVCNTClient client = new SRVCNTClient();
        SRVCNTConsents_DeligateApi api = new SRVCNTConsents_DeligateApi(client);
        Integration_Parameter__mdt integrationParam = Integration_Parameter__mdt.getInstance('Subscription_Key');
        ((OAS.ApiKeyAuth) client.getAuthentication('apiKeyHeader')).setApiKey(integrationParam.Parameter_Value__c);

        try {
            return api.postConsents(params);
        } catch (OAS.ApiException e) {
            throw new AuraHandledException(e.getBody());
        }
    }

    @AuraEnabled
    public static String uploadConsentsFile(String fileName, Blob fileContents) {
        // Generate form body
        String body = '';
        body += HttpFormBuilder.WriteBoundary();
        body += HttpFormBuilder.WriteBlobBodyParameter('file', EncodingUtil.base64Encode(fileContents), fileName);

        Map<String, Object> params = new Map<String, Object>{
                'file' => EncodingUtil.base64Decode(body)
        };

        SRVCNTClient client = new SRVCNTClient();
        SRVCNTConsents_DeligateApi api = new SRVCNTConsents_DeligateApi(client);
        Integration_Parameter__mdt integrationParam = Integration_Parameter__mdt.getInstance('Subscription_Key');
        ((OAS.ApiKeyAuth) client.getAuthentication('apiKeyHeader')).setApiKey(integrationParam.Parameter_Value__c);

        try {
            return api.postConsentsFiles(params);
        } catch (OAS.ApiException e) {
            throw new AuraHandledException(e.getBody());
        }
    }

    @AuraEnabled
    public static void setConsentRequirementsMet(String personId, Boolean consentRequirementsMet, Id applicantId) {

        try {
            Account acc = [SELECT Id, ConsentRequirementsMet__c FROM Account WHERE DomainId__c = :personId LIMIT 1];
            List <Opportunity> oppList = [SELECT Id, ConsentRequirementsMet__c FROM Opportunity WHERE AccountId = :acc.Id];
            for (Integer i = 0; i < oppList.size(); i++) {
                oppList[i].ConsentRequirementsMet__c = consentRequirementsMet;
                oppList[i].Wrap_Up_Reason__c = 'Automated';
            }

            if (consentRequirementsMet == true && applicantId != null) {
                LoanApplicant la = [SELECT Id, idvFinalScore__c FROM LoanApplicant WHERE Id = :applicantId];
                la.idvFinalScore__c = 85;
                update la;
            }


            acc.ConsentRequirementsMet__c = consentRequirementsMet;

            update acc;
            update oppList;

        } catch (OAS.ApiException e) {
            throw new AuraHandledException(e.getBody());
        }
    }
    @AuraEnabled
    public static LoanApplicant getLoanApplicant(String loanApplicantId) {

        LoanApplicant la = [
                SELECT Id,  Personal_ID_Number__c,Name, Name_Title__c ,Status__c, SourceOpportunity__c, Contact.Account.Identification_Number__c
//                        ,creditCheckRagIndicator__c, creditCheckDispute__c, creditCheckAdverse__c, creditCheckArrears__c,
//                        creditCheckDebtReview__c, creditCheckDebtReviewGranted__c, creditCheckDebtReviewRequested__c, creditCheckDeceased__c,
//                        creditCheckJudgements__c, creditCheckMonthsInArrears__c, creditCheckNotices__c, creditCheckNumberAdverseJudgements1Year__c,
//                        creditCheckNumberJudgementsLast5Years__c, creditCheckOverdueBalances__c, creditCheckScore__c, creditCheckSequestration__c,
//                        creditCheckThinFile__c, creditCheckTotalValueMonthlyInstallments__c, idvFinalScore__c, Contact.Account.Identification_Type__c,
//                        CreditCheckDate__c
                FROM LoanApplicant
                WHERE Id = :loanApplicantId
                LIMIT 1
        ];
        return la;
    }

    @AuraEnabled
    public static Opportunity getOpportunity(String loanApplicantId) {

        Opportunity opp = new Opportunity();

        try {
            opp = [SELECT Id, emailSendTrigger__c, Status__c, Template_Selection__c FROM Opportunity WHERE Id = :[SELECT SourceOpportunity__c from LoanApplicant where Id = :loanApplicantId AND Is_Main_Applicant__c = true].SourceOpportunity__c];
            return opp;
        } catch (Exception e){

            return opp;
        }

    }
}