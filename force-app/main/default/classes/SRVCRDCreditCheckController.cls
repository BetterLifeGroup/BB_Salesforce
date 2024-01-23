/**
 * Created by frans fourie on 2022/10/24.
 */

public with sharing class SRVCRDCreditCheckController {

    @InvocableMethod(Label='Credit Check, do full credit check')
    public static List<Boolean> fullCreditCheck(List<String> loanApplicantId) {

        Boolean success = false;

        LoanApplicant la = [
                SELECT Id, CreditCheckGroupId__c, Gross_Income__c, Total_Nett_Income__c, Total_Deduction_Amount__c, First_Name__c, Last_Name__c, Total_Living_Expense_Amount__c, idvFinalScore__c, Contact.Account.Identification_Number__c
                FROM LoanApplicant
                WHERE Id = :loanApplicantId[0]
                LIMIT 1
        ];


        SRVCRDCreditCheckAppCCFullRequest param = new SRVCRDCreditCheckAppCCFullRequest();
        param.idNumber = la.Contact.Account.Identification_Number__c;
        param.totalBondRepaymentToBeSettled = 0;
        param.totalBondRepayment = 0;
        param.returnPdfAsBase64 = true;
        param.repaymentTerm = 20;
//        param.nettIncome = la.Total_Nett_Income__c;
        param.nettIncome = 100000;
        param.isCreditCheckOnMyself = true;
//        param.grossIncome = la.Gross_Income__c;
        param.grossIncome = 75000;
//        param.expenses = la.Total_Living_Expense_Amount__c + la.Total_Deduction_Amount__c;
        param.expenses = 25000;
        param.firstName = la.First_Name__c;
        param.lastName = la.Last_Name__c;

        System.debug(param);
        Map<String, Object> params = new Map<String, Object>{
                'SRVCRDCreditCheckAppCCFullRequest' => param
        };

        SRVCRDClient client;

        client = new SRVCRDClient();
        Integration_Parameter__mdt integrationParam = Integration_Parameter__mdt.getInstance('Subscription_Key');
        ((OAS.ApiKeyAuth) client.getAuthentication('apiKeyHeader')).setApiKey(integrationParam.Parameter_Value__c);

        SRVCRDCreditCheckAppCreditCheckRespo obj = new SRVCRDCreditCheckAppCreditCheckRespo();

        SRVCRDCreditCheck_DeligateApi crd = new SRVCRDCreditCheck_DeligateApi(client);
        try {
            obj = crd.postCreditcheckFullDeligate(params);
        } catch (OAS.ApiException e) {
            System.debug(e);
            throw new AuraHandledException(e.getBody());
        }
        la.CreditCheckGroupId__c = obj.groupId;
        success = true;
        List<Boolean> successList = new List<Boolean>{
                success
        };


        update la;

        System.debug(obj);
        return successList;
    }

    @AuraEnabled
    public static LoanApplicantResponse creditCheckSimple(String loanApplicantId) {

        LoanApplicantResponse response = new LoanApplicantResponse();

        LoanApplicant la = [
                SELECT Id, Personal_ID_Number__c, creditCheckRagIndicator__c, creditCheckDispute__c, creditCheckAdverse__c, creditCheckArrears__c,
                        creditCheckDebtReview__c, creditCheckDebtReviewGranted__c, creditCheckDebtReviewRequested__c, creditCheckDeceased__c,
                        creditCheckJudgements__c, creditCheckMonthsInArrears__c, creditCheckNotices__c, creditCheckNumberAdverseJudgements1Year__c,
                        creditCheckNumberJudgementsLast5Years__c, creditCheckOverdueBalances__c, creditCheckScore__c, creditCheckSequestration__c,
                        creditCheckThinFile__c, creditCheckTotalValueMonthlyInstallments__c, idvFinalScore__c, Contact.Account.Identification_Type__c,
                        CreditCheckDate__c, Contact.Account.Passport_Number__c, CreditCheckGroupId__c, Contact.Id, Contact.Account.Identification_Number__c
                FROM LoanApplicant
                WHERE Id = :loanApplicantId
                LIMIT 1
        ];

        if (la.idvFinalScore__c < 60 || la.idvFinalScore__c == null) {


            response.applicant = new LoanApplicant(creditCheckScore__c = 0);
            response.errorMessage = 'No IDV';
            return response;
        }
//        Account acc = [SELECT Id,Identification_Number__c FROM Account WHERE Id = :[SELECT Id,Contact.AccountId from LoanApplicant where Id = :loanApplicantId].Contact.AccountId];

        SRVCRDCreditCheckAppCCSimpleRequest param = new SRVCRDCreditCheckAppCCSimpleRequest();

        String idType;
        if (la.Contact.Account.Identification_Type__c == 'Green Barcoded ID' || la.Contact.Account.Identification_Type__c == 'Smart ID') {
            idType = 'SID';
            param.idNumber = la.Contact.Account.Identification_Number__c;
        } else {
            idType = 'PASSPORT';
            param.idNumber = la.Contact.Account.Passport_Number__c;
        }


        param.clientConsent = 'Y';
        param.forcePerformNewCheck = true;
        param.doAffordabilityCheck = true;
        param.idType = idType;

        System.debug(param);
        Map<String, Object> params = new Map<String, Object>{
                'SRVCRDCreditCheckAppCCSimpleRequest' => param
        };

        SRVCRDClient client;

        client = new SRVCRDClient();
        Integration_Parameter__mdt integrationParam = Integration_Parameter__mdt.getInstance('Subscription_Key');
        ((OAS.ApiKeyAuth) client.getAuthentication('apiKeyHeader')).setApiKey(integrationParam.Parameter_Value__c);

        SRVCRDCreditCheckAppSimpleCreditChec obj = new SRVCRDCreditCheckAppSimpleCreditChec();

        SRVCRDCreditCheck_DeligateApi crd = new SRVCRDCreditCheck_DeligateApi(client);

        if (la.CreditCheckDate__c < Date.today().addDays(30) || la.creditCheckScore__c == null) {
//            try {

                try {
                    obj = crd.postCreditcheckSimpleDeligate(params);
                } catch (OAS.ApiException e) {
                    System.debug(e);
                    response.errorOccurred = true;
                    response.errorMessage = e.getBody();
                    return response;
                }

                Boolean thinFile = false;

                for (SRVCRDCreditCheckAppClientCustomScor cScore : obj.clientScores) {
                    if (cScore.scoreValue != null) {
                        if (cScore.thinFileIndicator == 'Y') {

                            thinFile = true;
                            la.creditCheckRagIndicator__c = obj.affordabilityResponseModel.ragIndicator;
                            la.creditCheckScore__c = Decimal.valueOf(cScore.scoreValue);
                            la.creditCheckThinFile__c = 'Yes';
                        }
                    }
                }

                if (!thinFile) {
                    la.creditCheckTotalValueMonthlyInstallments__c = obj.affordabilityResponseModel.installment;
                    la.creditCheckRagIndicator__c = obj.affordabilityResponseModel.ragIndicator;
                    la.creditCheckAdverse__c = obj.affordabilityResponseModel.adverse;
                    la.creditCheckArrears__c = Integer.valueOf(obj.affordabilityResponseModel.arrears);
                    la.creditCheckDebtReview__c = obj.affordabilityResponseModel.debtReview;
                    la.creditCheckDebtReviewGranted__c = obj.affordabilityResponseModel.debtReviewGranted;
                    la.creditCheckDebtReviewRequested__c = obj.affordabilityResponseModel.debtReviewRequested;
                    la.creditCheckDeceased__c = obj.affordabilityResponseModel.deceased;
                    la.creditCheckJudgements__c = obj.affordabilityResponseModel.judgements;
                    la.creditCheckMonthsInArrears__c = obj.affordabilityResponseModel.monthsInArrears;
                    la.creditCheckNotices__c = obj.affordabilityResponseModel.notices;
                    la.creditCheckNumberAdverseJudgements1Year__c = obj.affordabilityResponseModel.numberAdverseJudgements1Year;
                    la.creditCheckNumberJudgementsLast5Years__c = obj.affordabilityResponseModel.numberJudgementsLast5Years;
                    la.creditCheckOverdueBalances__c = obj.affordabilityResponseModel.overdueBalances;
                    la.creditCheckScore__c = Integer.valueOf(obj.affordabilityResponseModel.score);
                    la.creditCheckSequestration__c = obj.affordabilityResponseModel.sequestration;
                    la.creditCheckThinFile__c = obj.affordabilityResponseModel.thinFile;
                    la.creditCheckDispute__c = obj.affordabilityResponseModel.dispute;
                    la.CreditCheckDate__c = Date.today();
                    la.CreditCheckGroupId__c = obj.groupId;
                }

                update la;
//            } catch (Exception e) {
//                System.debug(e.getMessage());
//                return la;
//            }
        }
        System.debug(obj);
        response.applicant = la;
        response.errorOccurred = false;
        return response;
    }

    @AuraEnabled
    public static LoanApplicantResponse getLoanApplicant(String loanApplicantId) {

        LoanApplicantResponse response = new LoanApplicantResponse();


        LoanApplicant la = [
                SELECT Id, creditCheckRagIndicator__c, creditCheckDispute__c, creditCheckAdverse__c, creditCheckArrears__c,
                        creditCheckDebtReview__c, creditCheckDebtReviewGranted__c, creditCheckDebtReviewRequested__c, creditCheckDeceased__c,
                        creditCheckJudgements__c, creditCheckMonthsInArrears__c, creditCheckNotices__c, creditCheckNumberAdverseJudgements1Year__c,
                        creditCheckNumberJudgementsLast5Years__c, creditCheckOverdueBalances__c, creditCheckScore__c, creditCheckSequestration__c,
                        creditCheckThinFile__c, creditCheckTotalValueMonthlyInstallments__c, idvFinalScore__c, Contact.Account.Identification_Type__c,
                        CreditCheckDate__c, CreditCheckGroupId__c
                FROM LoanApplicant
                WHERE Id = :loanApplicantId
                LIMIT 1
        ];
        if (la.creditCheckScore__c == null) {

            response = SRVCRDCreditCheckController.creditCheckSimple(loanApplicantId);
        }
        return response;
    }

    public class LoanApplicantResponse{
        @AuraEnabled public LoanApplicant applicant;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public Boolean errorOccurred;
    }


    @AuraEnabled
    public static String getCreditCheckDocument(String loanApplicantId) {

        try {
            return EncodingUtil.base64Encode([SELECT Id, Title, ContentSize, FileType, VersionData, FirstPublishLocationId FROM ContentVersion WHERE Title LIKE '%Credit Report' AND FirstPublishLocationId = :loanApplicantId].VersionData);

        } catch (Exception e) {
        }
        LoanApplicant la = [
                SELECT Id, CreditCheckGroupId__c, Name, Is_Main_Applicant__c
                FROM LoanApplicant
                WHERE Id = :loanApplicantId
                LIMIT 1
        ];


        if (la.CreditCheckGroupId__c == null) {
            String noDocument = '';
            return noDocument;
        }

        Map<String, Object> param = new Map<String, Object>();
        param.put('groupId', la.CreditCheckGroupId__c);
        param.put('returnPdfAsBase64', true);
        param.put('removePdfPassword', true);

        System.debug(param);

        SRVCRDClient client;

        client = new SRVCRDClient();
        Integration_Parameter__mdt integrationParam = Integration_Parameter__mdt.getInstance('Subscription_Key');
        ((OAS.ApiKeyAuth) client.getAuthentication('apiKeyHeader')).setApiKey(integrationParam.Parameter_Value__c);

        String base64String;

        SRVCRDCreditCheck_DeligateApi crd = new SRVCRDCreditCheck_DeligateApi(client);
        try {
            base64String = crd.SRVCRDgetCreditcheckGetdocumentGroupidReturnpdfasbase64Removepdfpassword_Deligate(param);

//            System.debug('the returned document ' + base64String);
            ContentVersion newCV = new ContentVersion();
            newCV.Title = 'Credit Report';
            newCV.FirstPublishLocationId = loanApplicantId;
            if (Test.isRunningTest()) {
                base64String = 'somebase64stringgoeshere';
            }

            newCV.VersionData = EncodingUtil.base64Decode(base64String);
            newCV.PathOnClient = 'report.pdf';

            insert newCV;
        } catch (OAS.ApiException ex) {
            System.debug(ex);
            throw new AuraHandledException(ex.getBody());
        }

        if (la.Is_Main_Applicant__c == true) {
            SRVCRDIdvController.setOpportunityStatus(la.Id, 'PA Requested - awaiting documents', 'Working', 'Automated');
        }

        return base64String;
    }

    @AuraEnabled
    public static List<Boolean> fullCreditCheckAura(String loanApplicantId) {

        Boolean success = false;

        LoanApplicant la = [
                SELECT Id, CreditCheckGroupId__c, Contact.Account.Identification_Type__c, Gross_Income__c, Total_Nett_Income__c, Total_Deduction_Amount__c, First_Name__c, Last_Name__c, Total_Living_Expense_Amount__c, idvFinalScore__c, Contact.Account.Identification_Number__c, Contact.Account.Passport_Number__c
                FROM LoanApplicant
                WHERE Id = :loanApplicantId
                LIMIT 1
        ];

        SRVCRDCreditCheckAppCCFullRequest param = new SRVCRDCreditCheckAppCCFullRequest();
        String idType;
        if (la.Contact.Account.Identification_Type__c == 'Green Barcoded ID' || la.Contact.Account.Identification_Type__c == 'Smart ID') {
            idType = 'SID';
            param.idNumber = la.Contact.Account.Identification_Number__c;
        } else {
            idType = 'PASSPORT';
            param.idNumber = la.Contact.Account.Passport_Number__c;
        }


// TODO hard coded values below, Income and expenses not available at this point in process


        param.totalBondRepaymentToBeSettled = 0;
        param.totalBondRepayment = 0;
        param.returnPdfAsBase64 = true;
        param.repaymentTerm = 20;
//        param.nettIncome = la.Total_Nett_Income__c;
        param.nettIncome = 100000;
        param.isCreditCheckOnMyself = true;
//        param.grossIncome = la.Gross_Income__c;
        param.grossIncome = 75000;
//        param.expenses = la.Total_Living_Expense_Amount__c + la.Total_Deduction_Amount__c;
        param.expenses = 25000;
        param.firstName = la.First_Name__c;
        param.lastName = la.Last_Name__c;

        System.debug(param);
        Map<String, Object> params = new Map<String, Object>{
                'SRVCRDCreditCheckAppCCFullRequest' => param
        };

        SRVCRDClient client;

        client = new SRVCRDClient();
        Integration_Parameter__mdt integrationParam = Integration_Parameter__mdt.getInstance('Subscription_Key');
        ((OAS.ApiKeyAuth) client.getAuthentication('apiKeyHeader')).setApiKey(integrationParam.Parameter_Value__c);

        SRVCRDCreditCheckAppCreditCheckRespo obj = new SRVCRDCreditCheckAppCreditCheckRespo();

        SRVCRDCreditCheck_DeligateApi crd = new SRVCRDCreditCheck_DeligateApi(client);
        try {
            obj = crd.postCreditcheckFullDeligate(params);
        } catch (OAS.ApiException e) {
            System.debug(e);
            throw new AuraHandledException(e.getBody());
        }
        la.CreditCheckGroupId__c = obj.groupId;
        success = true;
        List<Boolean> successList = new List<Boolean>{
                success
        };


        update la;


        System.debug(obj);
        return successList;
    }
}