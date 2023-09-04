/**
 * Created by frans fourie on 2023/02/15.
 */
@IsTest
public with sharing class applicantFinancialDetailsControllerTest {

    @TestSetup
    public static void createTestData() {

        SRVAFFPreapprovalControllerTest.createTestData();

        String loanApplicantId = [SELECT Id FROM LoanApplicant WHERE Name = 'testLa' LIMIT 1].Id;

        List<Income_and_Expense_Types__c> types = new List<Income_and_Expense_Types__c>();

        Income_and_Expense_Types__c type = new Income_and_Expense_Types__c();
        type.Name = 'test';
        type.Type__c = 'Deduction';
        types.add(type);

        Income_and_Expense_Types__c type2 = new Income_and_Expense_Types__c();
        type2.Name = 'test';
        type2.Type__c = 'Living Expense';

        types.add(type2);

        Income_and_Expense_Types__c type3 = new Income_and_Expense_Types__c();
        type3.Name = 'test';
        type3.Type__c = 'Contractual Expense';

        types.add(type3);

        insert types;

        LoanApplicationLiability loanAppLia2 = new LoanApplicationLiability();
        loanAppLia2.Expense_Category__c = 'Contractual Expense';
        loanAppLia2.LoanApplicationId = [SELECT Id FROM ResidentialLoanApplication WHERE Id IN (SELECT LoanApplicationId FROM LoanApplicant WHERE Id = :loanApplicantId)].Id;
        loanAppLia2.Name = 'test2';
        loanAppLia2.Monthly_Instalment_Amount__c = 12;
        loanAppLia2.MonthlyPaymentAmount = 12;

        insert loanAppLia2;

        LoanApplicantIncome laIncome = new LoanApplicantIncome();
        laIncome.LoanApplicantId = loanApplicantId;
        laIncome.IncomeSourceType = 'Commission';
        laIncome.MonthlyIncomeAmount = 12;
        laIncome.Name = 'test';

        insert laIncome;

        LoanApplicationLiability loanAppLia = new LoanApplicationLiability();
        loanAppLia.Expense_Category__c = 'Deduction';
        loanAppLia.LoanApplicationId = [SELECT Id FROM ResidentialLoanApplication WHERE Id IN (SELECT LoanApplicationId FROM LoanApplicant WHERE Id = :loanApplicantId)].Id;
        loanAppLia.Name = 'test';
        loanAppLia.Monthly_Instalment_Amount__c = 12;
        loanAppLia.MonthlyPaymentAmount = 12;

        insert loanAppLia;


        LoanApplicantLiability laLia = new LoanApplicantLiability();
        laLia.LoanApplicantId = loanApplicantId;
        laLia.LoanApplicationLiabilityId = loanAppLia.Id;
        laLia.Amount__c = 12;
        laLia.LoanApplicationLiabilityId = loanAppLia2.Id;

        insert laLia;


    }

    @IsTest
    public static void test() {

        String loanApplicantId = [SELECT Id FROM LoanApplicant WHERE Name = 'testLa' LIMIT 1].Id;

        Assert.isNotNull(applicantFinancialDetailsController.getIncomes(loanApplicantId));
        Assert.isNotNull(applicantFinancialDetailsController.getDeductions(loanApplicantId));
        Assert.isNotNull(applicantFinancialDetailsController.getContractualExpenses(loanApplicantId));
        Assert.isNotNull(applicantFinancialDetailsController.getExistingExposure(loanApplicantId));
        Assert.isNotNull(applicantFinancialDetailsController.getLivingExpenses(loanApplicantId));
        Assert.isNotNull(applicantFinancialDetailsController.updateDeduction((new LoanApplicantLiability(Expense_Category__c = 'Deduction',ExpenseType__c = 'Deduction',Amount__c = 14)),loanApplicantId,'Deduction'));
        Assert.isNotNull(applicantFinancialDetailsController.updateDeduction([SELECT Id,Expense_Category__c,ExpenseType__c,Amount__c,LoanApplicationLiabilityId FROM LoanApplicantLiability LIMIT 1],loanApplicantId,'Deduction'));
        Assert.isNotNull(applicantFinancialDetailsController.getLoanApplicant([SELECT Id FROM LoanApplicant WHERE Name = 'testLa' LIMIT 1].Id));
        applicantFinancialDetailsController.updateLoanApplicant([SELECT Id FROM LoanApplicant WHERE Name = 'testLa' LIMIT 1].Id, 'Bond_Repayment_Amount__c', '12');
        applicantFinancialDetailsController.updateLoanApplicant([SELECT Id FROM LoanApplicant WHERE Name = 'testLa' LIMIT 1].Id, 'Will_you_be_selling_this_property_to_buy__c', 'Yes');
        applicantFinancialDetailsController.updateLoanApplicant([SELECT Id FROM LoanApplicant WHERE Name = 'testLa' LIMIT 1].Id, 'Will_you_be_selling_this_property_to_buy__c', 'Yes');
        Assert.isNotNull(applicantFinancialDetailsController.updateLoanApplicantIncome([SELECT Id,MonthlyIncomeAmount,IncomeSourceType,Name FROM LoanApplicantIncome LIMIT 1],loanApplicantId));
        Assert.isNotNull(applicantFinancialDetailsController.updateLoanApplicantIncome( (new LoanApplicantIncome(MonthlyIncomeAmount = 12,IncomeSourceType = 'Commission',Name='test')),loanApplicantId));
        Assert.isNotNull(applicantFinancialDetailsController.updateContractualExpense([SELECT Id, Monthly_Instalment_Amount__c,Exclude_Expense_From_Calculation__c FROM LoanApplicationLiability WHERE Name = 'test2' LIMIT 1],'Investment','Contractual Expense',loanApplicantId));
        Assert.isNotNull(applicantFinancialDetailsController.createContractualExpense('description','13','Investment',loanApplicantId));
        Assert.isNotNull(applicantFinancialDetailsController.forceExistingExposure(loanApplicantId));
        Assert.isNotNull(applicantFinancialDetailsController.deleteContractualExpense([SELECT Id FROM LoanApplicationLiability WHERE Name = 'test' LIMIT 1].Id));
    }

}