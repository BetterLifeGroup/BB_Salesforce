/**
 * Created by frans fourie on 2023/11/21.
 */

public without sharing class OpportunityMergeController {

    @AuraEnabled
    public static Opportunity getOpportunity(String recordId) {
        return [
                SELECT Id, Name, StageName, Status__c, (SELECT Id, Name, Contact.Account.PersonEmail, Contact.Account.Phone, Contact.Account.Identification_Number__c, Contact.Account.Passport_Number__c FROM Loan_Applicants__r)
                FROM Opportunity
                WHERE Id = :recordId
                LIMIT 1
        ];
    }

    @AuraEnabled
    public static List<Opportunity> searchOpportunities(String searchTerm, String excludedOppId) {

        String searchString = '%' + String.escapeSingleQuotes(searchTerm) + '%';
        searchString = searchString.replaceAll(' ', '%');
        System.debug(searchString);
        return [
                SELECT Id, Name, StageName, Status__c, (
                        SELECT Id, Name, Contact.Account.PersonEmail, Contact.Account.Phone, Contact.Account.Identification_Number__c, Contact.Account.Passport_Number__c
                        FROM Loan_Applicants__r
                        WHERE Is_Main_Applicant__c = TRUE
                        LIMIT 1
                )
                FROM Opportunity
                WHERE (RecordType.Name = 'Pre-Approval Opportunity' AND Id != :excludedOppId) AND
                (Name LIKE :searchString OR Account.PersonEmail LIKE :searchString OR Account.Name LIKE :searchString OR Account.Phone LIKE :searchString OR Account.Identification_Number__c LIKE :searchString OR Account.Passport_Number__c LIKE :searchTerm)
                ORDER BY Name DESC
                LIMIT 18
        ];
    }

    @AuraEnabled
    public static Boolean mergeOpps(String masterOpp, String slaveOpp) {
        try {

            List<SObject> listToUpsert = new List<SObject>();

            Opportunity masterOpportunity = [SELECT Id, (SELECT Id FROM Lending_Applications LIMIT 1) FROM Opportunity WHERE Id = :masterOpp];
            
            String loanApplicationId = masterOpportunity.Lending_Applications[0].Id;

            Opportunity slaveOpportunity = [SELECT Id, (SELECT Id FROM Tasks) FROM Opportunity WHERE Id = :slaveOpp];
            slaveOpportunity.StageName = 'Closed Lost';
            slaveOpportunity.Status__c = 'Duplicate';
            slaveOpportunity.Wrap_Up_Reason__c = 'Automated';
            listToUpsert.add(slaveOpportunity);

            for(Task ta : slaveOpportunity.Tasks) {
                ta.locked__c = false;
                ta.Status = 'Completed';
                listToUpsert.add(ta);
            }

            LoanApplicant slaveApplicant = [
                    SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate,
                            LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, LoanApplicationId,
                            ContactId, BorrowerType, CitizenshipStatus, HasMilitaryService, IsActiveMilitary, MaritalStatus,
                            DependentCount, DependentsAge, IsJointCredit, MilitaryTourExpirationMonth, MilitaryTourExpirationYear,
                            WasActiveMilitary, EthnicityType, RaceType, GenderType, ApplicantExtIdentifier, WasNonActivatedService,
                            IsSurvivingMilitarySpouse, PreferredLanguage, EthnicitySubType, OtherEthnicitySubType, AsianRaceSubType,
                            OtherAsianRaceSubType, PacIslandSubType, OtherPacIslandSubType, TribeName, SourceOpportunity__c,
                            Allow_Academic_Qual_Verification__c, Alternative_Phone_Number__c, Are_you_buying_your_first_home__c,
                            City_Current__c, City_Of_Birth__c, Country_Current__c, Country_Of_Birth__c, Country_Of_Marriage__c,
                            Country_Of_Tax_Code__c, CreditCheckDate__c, CreditCheckGroupId__c, Current_Address_Full__c,
                            Date_Of_Birth__c, Do_you_earn_any_additional_income_from_t__c, Do_you_have_a_South_African_ID_number__c,
                            Do_you_own_an_existing_property__c, Document_Requirements_Comment__c, Education_Type__c, Email_Address__c,
                            First_Name__c, Foreign_Tax_Number__c, Foreign_Tax_Obligations__c, Has_Alt_Phone_Number__c, Has_Home_Phone_Number__c,
                            Home_Phone_Number__c, In_what_capacity_are_you_buying__c, Income_Tax_Number__c, IsActive__c, Is_First_Time_Home_Buyer__c,
                            Is_Main_Applicant__c, Is_Public_Official__c, Is_RSA_Citizen__c, Is_Related_To_Public_Official__c, Is_Smoker__c,
                            Is_Social_Grant_Recipient__c, Last_Name__c, Marital_agreement__c, Mobile_Phone_Number__c, Name_Title__c,
                            Nationality__c, Nature_Of_Public_Official_Relationship__c, No_Foreign_Tax_Number_Reason__c, Notes__c,
                            Personal_ID_Number__c, Postal_Code_Current__c, Province_Current__c, Public_Official_In_Authority__c,
                            Received_Documents__c, Related_To_Public_Official__c, Requested_Documents__c, Status_Date__c, Status__c,
                            Street_Address_Current__c, What_is_your_credit_status__c, What_is_your_employment_status__c,
                            What_type_of_bond_are_you_applying_for__c, When_are_you_buying__c, When_are_you_paid__c, Work_Phone_Number__c,
                            creditCheckAdverse__c, creditCheckArrears__c, creditCheckDebtReviewGranted__c, creditCheckDebtReviewRequested__c,
                            creditCheckDebtReview__c, creditCheckDeceased__c, creditCheckDispute__c, creditCheckJudgements__c, creditCheckMonthsInArrears__c,
                            creditCheckNotices__c, creditCheckNumberAdverseJudgements1Year__c, creditCheckNumberJudgementsLast5Years__c,
                            creditCheckOverdueBalances__c, creditCheckRagIndicator__c, creditCheckScore__c, creditCheckSequestration__c,
                            creditCheckThinFile__c, creditCheckTotalValueMonthlyInstallments__c, idvFinalScore__c, idvResponseStatus__c,
                            idvVerificationRequestNumber__c, Total_Income_Amount__c, uploadedDocumentsVerification__c, Account_Email__c,
                            Bond_Repayment_Amount__c, Bond_Settlement_Amount__c, CreditReportPublicDownloadLink__c, CreditReportPublicViewLink__c,
                            Do_you_earn_commission_every_single_mont__c, Do_you_earn_overtime_every_single_month__c, Existing_Bond_Repayment__c,
                            Existing_Bond_Repayment_to_be_settled__c, Gross_Income__c, Opportunity__c, Payment_Frequency__c,
                            Subsidy_received_on_property_purchased__c, Total_Included_Contractual_Expenses__c, Total_Income_Amount_RTI__c,
                            Will_you_be_selling_this_property_to_buy__c, creditCheckIsFullCheckDone__c, emailSendTrigger_Applicant__c,
                            Total_Contractual_Expenses__c, Total_Deduction_Amount__c, Total_Living_Expense_Amount__c, Gross_Income_RTI__c,
                            Total_Nett_Income__c, relatedFilesIds__c, IDNumber__c, Opportunity_Owner_DigiApp_Link__c, Opportunity_Owner_Email__c,
                            Opportunity_Owner_First_Name__c, Opportunity_Owner_ID__c, Opportunity_Owner_Last_Name__c, Opportunity_Owner_Mobile__c,
                            Template_Selection__c, MC_Template_Selection__c,
                    (SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, LoanApplicationId, LoanApplicantId, IncomeSourceType, MonthlyIncomeAmount, IncomeExtIdentifier, Amount__c, Description__c, Frequency__c, Status__c FROM LoanApplicantIncomes),
                    (SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, LoanApplicantId, LoanApplicationLiabilityId, Role, Amount__c, ExpenseType__c, Medical_Monthly__c, Status__c, Expense_Category__c, Settled__c FROM LoanApplicantLiabilityRelations)
                    FROM LoanApplicant
                    WHERE LoanApplication.OpportunityId = :slaveOpp AND IsActive__c = TRUE AND Is_Main_Applicant__c = TRUE
                    LIMIT 1
            ];

            LoanApplicant newApplicant = slaveApplicant.clone(false,true,true,true);
            newApplicant.LoanApplicationId = loanApplicationId;
            newApplicant.SourceOpportunity__c = masterOpp;
            newApplicant.Is_Main_Applicant__c = false;

            insert newApplicant;

            List<LoanApplicationLiability> oldApplicationLiabilities = [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, LoanApplicationId, LoanApplicationAssetId, AccountType, LoanType, OtherLiabilityType, CreditorName, AccountNumber, MonthlyPaymentAmount, UnpaidBalanceAmount, ShouldBePaidInFull, IsJointLiability, CreditLimitAmount, LiabilityClass, LiabilityExtIdentifier, Description__c, Exclude_Expense_From_Calculation__c, Expense_Category__c, I_confirm_that_I_have_no_credit_expenses__c, Institution_Name__c, Last_Payment_Date__c, Monthly_Instalment_Amount__c, Opening_Balance_Amount__c, Outstanding_Balance_Amount__c, Reason_for_Deleting_Expense__c, Reason_why_Expenses_changed__c FROM LoanApplicationLiability WHERE Id IN (SELECT LoanApplicationLiabilityId FROM LoanApplicantLiability WHERE LoanApplicantId = :slaveApplicant.Id)];
            Map<String,LoanApplicationLiability> newApplicationLiabilityMap = new Map<String, LoanApplicationLiability>();
            List<LoanApplicationLiability> loanApplicationLiabilityToInsert = new List<LoanApplicationLiability>();


            for(LoanApplicationLiability lal : oldApplicationLiabilities) {

                LoanApplicationLiability newApplicationLiability = lal.clone(false,true,true,true);
                newApplicationLiability.LoanApplicationId = loanApplicationId;
                loanApplicationLiabilityToInsert.add(newApplicationLiability);
            }
            insert loanApplicationLiabilityToInsert;

            for(LoanApplicationLiability lal : loanApplicationLiabilityToInsert) {
                newApplicationLiabilityMap.put(lal.MonthlyPaymentAmount + lal.Expense_Category__c,lal);
            }
            
            for(LoanApplicantLiability lai : slaveApplicant.LoanApplicantLiabilityRelations) {
                LoanApplicantLiability newLal = lai.clone(false,true,true,true);
                newLal.LoanApplicationLiabilityId = newApplicationLiabilityMap.get(lai.Amount__c + lai.Expense_Category__c).Id;
                newLal.LoanApplicantId = newApplicant.Id;
                System.debug(newLal);
                listToUpsert.add(newLal);
            }

            for(LoanApplicantIncome lai : slaveApplicant.LoanApplicantIncomes) {

                LoanApplicantIncome newLai = lai.clone(false,true,true,true);
                newLai.LoanApplicationId = loanApplicationId;
                newLai.LoanApplicantId = newApplicant.Id;

                listToUpsert.add(newLai);
            }

            slaveApplicant.IsActive__c = false;
            listToUpsert.add(slaveApplicant);

            upsert listToUpsert;


        } catch (Exception e) {
            System.debug('Failed to merge');
            System.debug(e.getMessage());
            return false;
        }
        return true;
    }
}