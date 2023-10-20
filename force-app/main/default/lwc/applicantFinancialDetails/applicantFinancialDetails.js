/**
 * Created by frans fourie on 2023/02/03.
 */

import {LightningElement, track, api} from 'lwc';

import getIncomes from '@salesforce/apex/applicantFinancialDetailsController.getIncomes'
import getDeductions from '@salesforce/apex/applicantFinancialDetailsController.getDeductions'
import getContractualExpenses from '@salesforce/apex/applicantFinancialDetailsController.getContractualExpenses'
import getExistingExposure from '@salesforce/apex/applicantFinancialDetailsController.getExistingExposure'
import getLivingExpenses from '@salesforce/apex/applicantFinancialDetailsController.getLivingExpenses'
import getLoanApplicant from '@salesforce/apex/applicantFinancialDetailsController.getLoanApplicant'
import updateDeduction from '@salesforce/apex/applicantFinancialDetailsController.updateDeduction'
import updateContractualExpense from '@salesforce/apex/applicantFinancialDetailsController.updateContractualExpense'
import createContractualExpense from '@salesforce/apex/applicantFinancialDetailsController.createContractualExpense'
import updateLoanApplicant from '@salesforce/apex/applicantFinancialDetailsController.updateLoanApplicant'
import updateLoanApplicantIncome from '@salesforce/apex/applicantFinancialDetailsController.updateLoanApplicantIncome'
import deleteContractualExpense from '@salesforce/apex/applicantFinancialDetailsController.deleteContractualExpense'
import forceExistingExposure from '@salesforce/apex/applicantFinancialDetailsController.forceExistingExposure'
import {FlowNavigationNextEvent} from "lightning/flowSupport";
import {FlowNavigationBackEvent} from "lightning/flowSupport";

export default class ApplicantFinancialDetails extends LightningElement {

    @api channelName = '/event/LoanApplicantEvent__e';

    @api recordId;
    @api loanApplicantId;
    @api mode = ''; // income / deductions / contractualExpenses / existingExposure / livingExpenses
    @track temp = false;
    @track incomeMode = false;
    @track deductionsMode = false;
    @track livingExpensesMode = false;
    @track contractualExpensesMode = false;
    @track showNavigationButtons = false;
    @track showNextButton = false;
    @track existingExposureMode = false;
    @track showBondQuestions = false;
    @track showSellingPropertyQuestion = false;
    @track showBondRepayment = false;
    @track lockBondRepaymentQuestion = false;
    @track showBondSettlementAmount = false;
    @track fieldMandatory = 'standard';
    @api showRunningNotes = false;
    @api forceValues = false;
    @track deductions = [];
    @track incomes = [];
    @track subsidyCurrentValue;
    @track paymentFrequencyCurrentValue;
    @track overtimeCurrentValue;
    @track commissionCurrentValue;
    @track bondRepaymentCurrentValue;
    @track bondSettlementCurrentValue;
    @track ownExistingPropertyCurrentValue;
    @track bondRepaymentAmountCurrentValue = {value: '', class: 'standard'};
    @track existingBondRepaymentCurrentValue;
    @track existingBondRepaymentToBeSettledCurrentValue;
    @track willYouSellCurrentPropertyCurrentValue;
    @track newAmount = {amount: '', class: 'standard'};
    @track bondSettlementAmountCurrentValue = {value: '', class: 'standard'};
    @track newAccountType;
    @track applicantName;
    @track newDescription;
    @track totalRTI;
    @track totalIncome;
    @track totalDeductions;
    @track totalLivingExpenses;
    @track totalContractualExpenses;
    @api runningNotes;
    @track internalRunningNotes;
    // @track notes = 'notes';
    initialRunningNotes;
    initialRunningNotesLength;
    initialRunningNotesCaptured = false;
    settlementAmountHolder;
    debounceTimer;
    regex = /(^[1-9]\d+$|^$|^[1-9]\d+[.|,]\d{2}$|^[1-9]$|^\d[.|,]\d{2}$|^[0]$)/;
    static delegatesFocus = true;


    captureRunningNotes() {
        this.initialRunningNotes = this.runningNotes;
        this.initialRunningNotesLength = this.runningNotes !== null ? this.initialRunningNotes?.length : 0;
    }

    connectedCallback() {
        this.internalRunningNotes = this.runningNotes;
        if (this.initialRunningNotesCaptured === false) {
            this.captureRunningNotes()
            this.initialRunningNotesCaptured = true;
        }
        this.loanApplicantId = this.recordId;
        getLoanApplicant({loanApplicantId: this.loanApplicantId}).then(result => {
            if (result.Is_Main_Applicant__c === true) {
                this.applicantName = 'Main Applicant - ' + result.Name + ' - '
            } else {
                this.applicantName = 'Co-Applicant - ' + result.Name + ' - '
            }

            switch (this.mode.toLowerCase()) {
                case 'income'.toLowerCase():
                    this.incomeMode = true;
                    this.applicantName = this.applicantName + 'Income'
                    getIncomes({loanApplicantId: this.loanApplicantId}).then(result => {
                        this.showNavigationButtons = true;
                        this.showNextButton = true;
                        result.map(re => {
                            re.class = 'standard', re.disabled = false, re.MonthlyIncomeAmount === 0 ? re.MonthlyIncomeAmount = null : re.MonthlyIncomeAmount
                        })
                        this.incomes = result.sort(function (a, b) {
                            let x = a.Name.toLowerCase();
                            let y = b.Name.toLowerCase();
                            if (x < y) {
                                return -1;
                            }
                            if (x > y) {
                                return 1;
                            }
                            return a.value - b.value
                        });
                    }).catch(error => {
                        console.log('Error', error)
                    })
                    getLoanApplicant({loanApplicantId: this.recordId}).then(result => {
                        console.log('loanApplicant', result)
                        this.temp = false
                        this.paymentFrequencyCurrentValue = result.Payment_Frequency__c;
                        this.overtimeCurrentValue = result.Do_you_earn_overtime_every_single_month__c;
                        this.commissionCurrentValue = result.Do_you_earn_commission_every_single_mont__c;
                        this.subsidyCurrentValue = result.Subsidy_received_on_property_purchased__c;
                        this.totalIncome = result.Total_Income_Amount__c;
                        this.totalRTI = result.Total_Income_Amount_RTI__c;
                    }).catch(error => {
                        console.log('Error', error)
                    })

                    break;

                case 'deductions'.toLowerCase():
                    this.deductionsMode = true;
                    this.applicantName = this.applicantName + 'Deductions'
                    getDeductions({loanApplicantId: this.loanApplicantId}).then(result => {
                        this.showNavigationButtons = true;
                        this.showNextButton = true;
                        result.map(re => {
                            re.class = 'standard', re.disabled = false, re.Amount__c === 0 ? re.Amount__c = null : re.Amount__c
                        })
                        this.deductions = result.sort(function (a, b) {
                            let x = a.ExpenseType__c.toLowerCase();
                            let y = b.ExpenseType__c.toLowerCase();
                            if (x < y) {
                                return -1;
                            }
                            if (x > y) {
                                return 1;
                            }
                            return a.value - b.value
                        });
                        getLoanApplicant({loanApplicantId: this.recordId}).then(result => {
                            this.temp = false
                            this.totalDeductions = result.Total_Deduction_Amount__c;
                        })
                    }).catch(error => {
                        console.log('Error', error)
                    })
                    break;

                case 'livingExpenses'.toLowerCase():
                    this.livingExpensesMode = true;
                    this.applicantName = this.applicantName + 'Living Expenses'
                    getLivingExpenses({loanApplicantId: this.loanApplicantId}).then(result => {
                        this.showNavigationButtons = true;
                        this.showNextButton = true;

                        this.deductions = result.sort(function (a, b) {
                            let x = a.ExpenseType__c.toLowerCase();
                            let y = b.ExpenseType__c.toLowerCase();
                            if (x < y) {
                                return -1;
                            }
                            if (x > y) {
                                return 1;
                            }
                            return a.value - b.value
                        });
                        this.deductions.map(re => {
                            re.class = 'standard', re.disabled = false, re.Amount__c === 0 ? re.Amount__c = null : re.Amount__c
                            getLoanApplicant({loanApplicantId: this.recordId}).then(result => {
                                this.temp = false
                                this.totalLivingExpenses = result.Total_Living_Expense_Amount__c;
                            })
                        })

                    }).catch(error => {
                        console.log('Error', error)
                    })
                    break;

                case 'contractualExpenses'.toLowerCase():
                    this.contractualExpensesMode = true;
                    this.applicantName = this.applicantName + 'Contractual Expenses'
                    getContractualExpenses({loanApplicantId: this.loanApplicantId}).then(result => {
                        this.showNavigationButtons = true;
                        this.showNextButton = true;
                        this.deductions = result
                        this.temp = false;
                        this.deductions.map(ded => {
                            ded.class = 'standard',
                                ded.disabled = false,
                                ded.Exclude_Expense_From_Calculation__c = !ded.Exclude_Expense_From_Calculation__c,
                                ded.AccountType === 'Mortgage Loan' ? ded.settleDisable = true : ded.settleDisable = false
                        })
                        getLoanApplicant({loanApplicantId: this.recordId}).then(result => {

                            this.temp = false
                            this.totalContractualExpenses = result.Total_Contractual_Expenses__c;
                        })
                    }).catch(error => {
                        console.log('Error', error)
                    })

                    break;

                case 'existingExposure'.toLowerCase():
                    this.existingExposureMode = true;
                    this.applicantName = this.applicantName + 'Existing Exposure'
                    getExistingExposure({loanApplicantId: this.loanApplicantId}).then(result => {
                        this.showNavigationButtons = true;
                        this.showNextButton = true;
                        this.bondRepaymentCurrentValue = result.Bond_Repayment_Amount__c;
                        this.ownExistingPropertyCurrentValue = result.Do_you_own_an_existing_property__c;
                        this.bondSettlementCurrentValue = result.Bond_Settlement_Amount__c;
                        this.existingBondRepaymentCurrentValue = result.Existing_Bond_Repayment__c;
                        this.existingBondRepaymentToBeSettledCurrentValue = result.Existing_Bond_Repayment_to_be_settled__c;
                        this.willYouSellCurrentPropertyCurrentValue = result.Will_you_be_selling_this_property_to_buy__c;
                        this.bondRepaymentAmountCurrentValue.value = result.Bond_Repayment_Amount__c;
                        this.bondSettlementAmountCurrentValue.value = result.Bond_Settlement_Amount__c;
                        this.temp = false
                        forceExistingExposure({laId: this.loanApplicantId}).then(result => {
                            if (result.force === true) {
                                this.ownExistingPropertyCurrentValue = 'Yes';
                                this.existingBondRepaymentCurrentValue = 'Yes';
                                this.showBondSettlementAmount = 'Yes';
                                this.forceValues = result.force;
                                result.monthlyRepayment > 0 ? this.bondRepaymentAmountCurrentValue.value = result.monthlyRepayment : this.bondRepaymentAmountCurrentValue.value = '';
                                this.showBondRepayment = this.existingBondRepaymentCurrentValue === 'Yes';
                                this.showBondQuestions = this.willYouSellCurrentPropertyCurrentValue === 'Yes';
                                this.showSellingPropertyQuestion = this.ownExistingPropertyCurrentValue === 'Yes';
                                // console.log(this.existingBondRepaymentToBeSettledCurrentValue.value)
                                // this.showBondSettlementAmount = this.existingBondRepaymentToBeSettledCurrentValue === 'Yes';
                            } else {
                                this.forceValues = false;
                                this.showBondRepayment = this.existingBondRepaymentCurrentValue === 'Yes';
                                this.showBondQuestions = this.willYouSellCurrentPropertyCurrentValue === 'Yes';
                                this.showSellingPropertyQuestion = this.ownExistingPropertyCurrentValue === 'Yes';
                            }
                            if (this.willYouSellCurrentPropertyCurrentValue === 'Yes') {
                                this.existingBondRepaymentToBeSettledCurrentValue = 'Yes';
                                this.lockBondRepaymentQuestion = true;
                            }
                            this.showBondSettlementAmount = this.existingBondRepaymentToBeSettledCurrentValue === 'Yes';
                        })
                    }).catch(error => {
                        console.log('Error', error)
                    })
            }
        })
    }

    newContractualExpense() {

        if (this.newDescription.length < 1 || this.newAmount.amount.length < 1 || this.newAccountType.length < 1) {

        } else {
            this.temp = true;
            createContractualExpense({
                description: this.newDescription,
                amount: this.newAmount.amount.replace(',', '.'),
                accountType: this.newAccountType,
                loanApplicantId: this.recordId
            }).then(result => {
                this.temp = false
                this.newDescription = null
                this.newAccountType = null
                this.newAmount.amount = null
                this.connectedCallback()
            }).catch(error => {
                console.log('Error', error)
            })
        }
    }

    get contractualExpenseAccountTypes() {

        return [
            // { label: 'None', value: 'None' },
            {label: 'Credit', value: 'Credit'},
            {label: 'Fixed Deposit', value: 'Fixed Deposit'},
            {label: 'Instalment Sale Agreement', value: 'Instalment Sale Agreement'},
            {label: 'Investment', value: 'Investment'},
            {label: 'Mortgage Loan', value: 'Mortgage Loan'},
            {label: 'Other', value: 'Other'},
            {label: 'Personal Loan', value: 'Personal Loan'},
        ];
    }

    handleContractualInputBlur(event) {

        event
        this.temp = true;

        let index = this.deductions.findIndex(ded => ded.Id === event.target.dataset.id)
        // this.deductions[index].Exclude_Expense_From_Calculation__c = !this.deductions[index].Exclude_Expense_From_Calculation__c
        if (!event.target.value.match(this.regex)) {
            this.deductions[index].Monthly_Instalment_Amount__c = null;
        }
        this.deductions[index].disabled = true;
        switch (event.target.dataset.fieldtype) {
            case 'description':
                this.deductions[index].Description__c = event.target.value;
                break;
            case 'accountType':
                this.deductions[index].AccountType = event.target.value;
                break;
            case 'amount':
                this.deductions[index].Monthly_Instalment_Amount__c = event.target.value.replace('.', ',');
                break;
            case 'excluded':
                this.deductions[index].Exclude_Expense_From_Calculation__c = event.target.checked;

        }

        updateContractualExpense({
            loanApplicationLiability: this.deductions[index],
            accountType: '',
            description: '',
            loanApplicantId: this.loanApplicantId
        }).then(result => {
            this.connectedCallback()
        }).catch(error => {
            console.log('Error', error)
        })
    }

    handleInputBlur(event) {

        if (!this.incomeMode) {
            let index = this.deductions.findIndex(ded => ded.ExpenseType__c === event.target.dataset.id)
            if (!event.target.value.match(this.regex)) {
                this.deductions[index].Amount__c = null;
            }

            this.deductions[index].disabled = true;
            this.deductions[index].Amount__c = event.target.value.replace('.', ',');
            updateDeduction({
                loanApplicantLiability: this.deductions[index],
                loanApplicantId: this.loanApplicantId,
                expenseCategory: this.deductions[index].Expense_Category__c
            }).then(result => {
                this.connectedCallback()
            }).catch(error => {
                console.log('Error', error)
            })
        } else {
            let index = this.incomes.findIndex(inc => inc.Name === event.target.dataset.id)
            if (!event.target.value.match(this.regex)) {
                this.incomes[index].MonthlyIncomeAmount = null;
            } else {

                this.incomes[index].disabled = true;
                this.incomes[index].MonthlyIncomeAmount = event.target.value.replace('.', ',');
                updateLoanApplicantIncome({la: this.incomes[index], loanApplicantId: this.recordId}).then(result => {
                    this.connectedCallback()
                }).catch(error => {
                    console.log('Error', error)
                })
            }
        }
    }

    get paymentFrequencyOptions() {
        return [
            // { label: 'None', value: 'None' },
            {label: 'Monthly', value: 'Monthly'},
            {label: 'Weekly', value: 'Weekly'},
            {label: 'Bi-Weekly/Fortnightly', value: 'Bi-Weekly/Fortnightly'},
        ];
    }

    get genericOptions() {
        return [
            {label: 'Yes', value: 'Yes'},
            {label: 'No', value: 'No'},
        ];
    }

    handleNewAmount(event) {
        if (!event.detail.value.match(this.regex)) {
            this.newAmount.class = 'red';
        } else {
            this.newAmount.class = 'standard';
            this.newAmount.amount = event.detail.value
        }
    }

    handleNewAccountType(event) {
        this.newAccountType = event.detail.value
    }

    handleNewDescription(event) {
        this.newDescription = event.detail.value
    }

    updateApplicant(event) {
        switch (event.target.dataset.id) {
            case 'paymentFrequency':

                updateLoanApplicant({
                    loanApplicantId: this.recordId,
                    key: 'Payment_Frequency__c',
                    value: event.detail.value
                }).then(result => {
                    this.connectedCallback()
                }).catch(error => {
                    console.log('Error', error)
                })
                break;

            case 'overtime':
                updateLoanApplicant({
                    loanApplicantId: this.recordId,
                    key: 'Do_you_earn_overtime_every_single_month__c',
                    value: event.detail.value
                }).then(result => {
                    this.connectedCallback()
                }).catch(error => {
                    console.log('Error', error)
                })
                break;

            case 'commission':
                updateLoanApplicant({
                    loanApplicantId: this.recordId,
                    key: 'Do_you_earn_commission_every_single_mont__c',
                    value: event.detail.value
                }).then(result => {
                    this.connectedCallback()
                }).catch(error => {
                    console.log('Error', error)
                })
                break;

            case 'subsidy':
                updateLoanApplicant({
                    loanApplicantId: this.recordId,
                    key: 'Subsidy_received_on_property_purchased__c',
                    value: event.detail.value
                }).then(result => {
                    this.connectedCallback()
                }).catch(error => {
                    console.log('Error', error)
                })
                break;

            case 'willYouBeSelling':
                this.showBondQuestions = event.detail.value === 'Yes';
                updateLoanApplicant({
                    loanApplicantId: this.recordId,
                    key: 'Will_you_be_selling_this_property_to_buy__c',
                    value: event.detail.value
                }).then(result => {
                    if (event.detail.value === 'No') {
                        updateLoanApplicant({
                            loanApplicantId: this.recordId,
                            key: 'Bond_Settlement_Amount__c',
                            value: '0'
                        }).then()
                    }
                    this.connectedCallback()
                }).catch(error => {
                    console.log('Error', error)
                })
                break;

            case 'existingBondToSettle':
                this.showBondSettlementAmount = event.detail.value === 'Yes';
                updateLoanApplicant({
                    loanApplicantId: this.recordId,
                    key: 'Existing_Bond_Repayment_to_be_settled__c',
                    value: event.detail.value
                }).then(result => {
                    updateLoanApplicant({
                        loanApplicantId: this.recordId,
                        key: 'Bond_Settlement_Amount__c',
                        value: '0'
                    }).then(result => {
                        this.connectedCallback()
                    })
                }).catch(error => {
                    console.log('Error', error)
                })
                break;

            case 'existingBondRepayment':
                this.showBondRepayment = event.detail.value === 'Yes';
                updateLoanApplicant({
                    loanApplicantId: this.recordId,
                    key: 'Existing_Bond_Repayment__c',
                    value: event.detail.value
                }).then(result => {
                    this.connectedCallback()
                }).catch(error => {
                    console.log('Error', error)
                })
                break;

            case 'bondRepaymentAmount':
                let value;
                if (event.target.value.length === 0) {
                    value = '0';
                } else {
                    value = event.target.value.replace(',', '.')
                }
                updateLoanApplicant({
                    loanApplicantId: this.recordId,
                    key: 'Bond_Repayment_Amount__c',
                    value: value
                }).then(result => {
                    this.connectedCallback()
                }).catch(error => {
                    console.log('Error', error)
                })
                break;

            case 'bondSettlementAmount':
                let values;
                if (event.target.value.length === 0) {
                    values = '0';
                } else {
                    values = event.target.value.replace(',', '.')
                }
                updateLoanApplicant({
                    loanApplicantId: this.recordId,
                    key: 'Bond_Settlement_Amount__c',
                    value: values
                }).then(result => {
                    this.connectedCallback()
                }).catch(error => {
                    console.log('Error', error)
                })
                break;

            case 'existingProperty':
                this.showSellingPropertyQuestion = event.detail.value === 'Yes';

                updateLoanApplicant({
                    loanApplicantId: this.recordId,
                    key: 'Do_you_own_an_existing_property__c',
                    value: event.detail.value
                }).then(result => {
                    this.connectedCallback()
                }).catch(error => {
                    console.log('Error', error)
                })
        }
    }

    handleAmountChange(event) {
        if (this.incomeMode) {
            let index = this.incomes.findIndex(inc => inc.Name === event.target.dataset.id)
            if (!event.target.value.match(this.regex)) {
                this.incomes[index].class = 'red';
            } else {
                this.incomes[index].class = 'standard';
            }
        } else if (this.contractualExpensesMode) {
            let index = this.deductions.findIndex(ded => ded.Id === event.target.dataset.id)
            if (!event.target.value.match(this.regex)) {
                this.deductions[index].class = 'red';
            } else {
                this.deductions[index].class = 'standard';
            }
        } else if (this.existingExposureMode) {
            this.fieldMandatory = 'standard'

            if (event.target.dataset.id === 'bondRepaymentAmount') {
                if (!event.target.value.match(this.regex)) {
                    this.bondRepaymentAmountCurrentValue.class = 'red'
                } else {
                    this.bondRepaymentAmountCurrentValue.class = 'standard'
                }
            } else if (event.target.dataset.id === 'bondSettlementAmount') {
                if (!event.target.value.match(this.regex)) {
                    this.bondSettlementAmountCurrentValue.class = 'red'
                } else {
                    this.bondSettlementAmountCurrentValue.class = 'standard'
                }
                this.updateApplicant(event)

            }

        } else {
            let index = this.deductions.findIndex(ded => ded.ExpenseType__c === event.target.dataset.id)
            if (!event.target.value.match(this.regex)) {
                this.deductions[index].class = 'red';
            } else {
                this.deductions[index].class = 'standard';
            }
        }
    }

    handleDeleteContractualExpense(event) {
        let index = this.deductions.findIndex(ded => ded.Id === event.target.dataset.id)
        this.deductions[index].disabled = true;
        deleteContractualExpense({loanApplicationLiabilityId: event.target.dataset.id}).then(result => {
            this.connectedCallback()
        }).catch(error => {
            console.log('delete error', error)
            this.connectedCallback()
        })

    }

    handleInput(event) {
        // Get the current value of the input field
        let currentValue = event.target.value;

        // If the current value does not start with the initial value, prevent editing
        // if (!currentValue.startsWith(this.initialRunningNotes)) {
        //     event.preventDefault();
        // Optionally, you can display a message to the user
        // this.dispatchEvent(new ShowToastEvent({message: 'Cannot edit initial value', variant: 'error'}));
        if (currentValue.length < this.initialRunningNotes.length) {
            // event.preventDefault();
            event.target.value = this.initialRunningNotes;
            // }
        }
    }

    runningNotesChange(event) {
        const currentValue = event.target.value;
        if (this.initialRunningNotesLength > 1) {
            if (!currentValue.startsWith(this.initialRunningNotes)) {
                this.showRunningNotes = false;
                setTimeout(handler => {
                    this.showRunningNotes = true;
                    this.internalRunningNotes = this.initialRunningNotes
                    setTimeout(handler => {
                        let textBox = this.template.querySelector(`[data-id="notes"]`);
                        textBox.focus();
                    }, 0)
                }, 0)

            } else {

                this.internalRunningNotes = currentValue;
                this.runningNotes = currentValue;
            }
        } else {
            this.internalRunningNotes = currentValue;
            this.runningNotes = currentValue;
        }
    }

    handlePreviousClick() {
        const navigateBackEvent = new FlowNavigationBackEvent()
        this.dispatchEvent(navigateBackEvent);
    }

    handleNextClick() {
        const navigateNextEvent = new FlowNavigationNextEvent()
        switch (this.mode.toLowerCase()) {
            case 'existingExposure'.toLowerCase():
                if (this.willYouSellCurrentPropertyCurrentValue === 'Yes' && this.existingBondRepaymentToBeSettledCurrentValue === 'Yes' && (this.bondSettlementAmountCurrentValue.value === '' || this.bondSettlementAmountCurrentValue.value === null || this.bondSettlementAmountCurrentValue.value === 0 || this.bondSettlementAmountCurrentValue.value === '0' || this.bondSettlementAmountCurrentValue.value === undefined)) {
                    this.fieldMandatory = 'mandatoryNotSatisfied';
                } else {
                    this.fieldMandatory = 'standard';
                    this.dispatchEvent(navigateNextEvent);

                }
                break;
            case 'contractualExpenses'.toLowerCase():
                this.dispatchEvent(navigateNextEvent);
                break;
            case 'livingExpenses'.toLowerCase():
                this.dispatchEvent(navigateNextEvent);
                break;
            case 'deductions'.toLowerCase():
                this.dispatchEvent(navigateNextEvent);
                break;
            case 'income'.toLowerCase():
                this.dispatchEvent(navigateNextEvent);
        }

    }

    handleSettlementAmountBlur(event) {
        this.fieldMandatory = 'standard'
        if (!this.settlementAmountHolder.match(this.regex)) {
            this.bondSettlementAmountCurrentValue.class = 'red'
        } else {
            this.bondSettlementAmountCurrentValue.class = 'standard'
        }
        this.updateApplicant(event)

    }

    handleSettlementAmountOnChange(event) {
        this.settlementAmountHolder = event.target.value;
        this.bondSettlementAmountCurrentValue.value = event.target.value;
    }

}