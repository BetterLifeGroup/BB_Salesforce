/**
 * Created by frans fourie on 2022/10/24.
 */

import {LightningElement, track, api} from 'lwc';
import simpleCreditCheck from '@salesforce/apex/SRVCRDCreditCheckController.creditCheckSimple'
import getLoanApplicant from '@salesforce/apex/SRVCRDCreditCheckController.getLoanApplicant'
import {FlowNavigationNextEvent} from "lightning/flowSupport";

export default class CreditCheck extends LightningElement {

    creditCheckDone = false;
    @api recordId;
    @track loading = true;
    @track resultData;
    @track refreshDisabled = true;
    @track idvPassed = false;
    @track scoreClass;
    idNumber;
    @track showHtmlErrorToast = false;
    @track showHtmlSuccessToast = false;
    @track showHtmlWarningToast = false;
    @track toastMessage;
    recordDate;

    connectedCallback() {
        this.loanApplicant()
    }

    loanApplicant() {

        getLoanApplicant({loanApplicantId: this.recordId}).then(result => {

            this.resultData = result
            this.loading = false
            this.scoreClass = result.creditCheckRagIndicator__c
            if (result.idvFinalScore__c > 59) {
                this.idvPassed = true
            }

            this.recordDate = new Date(result.CreditCheckDate__c).getTime() + 2592000000
            this.refreshDisabled = !(this.recordDate < Date.now());

        }).catch((error) => {
            this.showToast('DOMAIN RESPONSE ERROR: Please contact support desk', 'DOMAIN RESPONSE ERROR: Please contact support desk', 'error')
        })
    }


    doCreditCheck() {
        this.loading = true
        simpleCreditCheck({loanApplicantId: this.recordId}).then(result => {
            this.refreshDisabled = true;
            if (result.creditCheckScore__c > 0) {
                this.idvPassed = true
            }

            this.scoreClass = result.creditCheckRagIndicator__c

            this.loading = false
            this.resultData = result
        }).catch(error => {
            this.showToast('DOMAIN RESPONSE ERROR: Please contact support desk', 'DOMAIN RESPONSE ERROR: Please contact support desk', 'error');
            this.loading = false

        })

    }

    get options() {
        return [{
            value: '', label: 'South African ID'
        },
            {value: '', label: 'Passport'}]
    }

    handleNextClick() {

        const navigateNextEvent = new FlowNavigationNextEvent()
        this.dispatchEvent(navigateNextEvent);
    }


    showToast(title, message, variant) {

        if (variant.toLowerCase() === 'error') {
            this.showHtmlErrorToast = true
            this.toastMessage = message;
            setTimeout(() => {

                // this.showHtmlErrorToast = false;
            }, 2000)
        } else if (variant.toLowerCase() === 'warning') {

            this.showHtmlWarningToast = true
            this.toastMessage = message;
            setTimeout(() => {

                this.showHtmlWarningToast = false;
            }, 2000)

        } else {

            this.showHtmlSuccessToast = true
            this.toastMessage = message;
            setTimeout(() => {

                this.showHtmlSuccessToast = false;
            }, 2000)

        }

    }

    handleCloseToast() {
        this.showHtmlSuccessToast = false;
        this.showHtmlWarningToast = false;
        this.showHtmlErrorToast = false;

    }



}