/**
 * Created by frans fourie on 2023/01/13.
 */

import {LightningElement, api, track} from 'lwc';
import getLoanApplicants from '@salesforce/apex/workFlowManager.getLoanApplicants'
import {FlowNavigationNextEvent} from "lightning/flowSupport";
import {subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled} from 'lightning/empApi';

export default class WorkFlowManager extends LightningElement {

    @api recordId;
    @api displayOnly = false;
    @track displayOnlyVar = '';
    @track loanApplicants = [];
    @track showBar = false;
    @api bondMode = false;
    @track showFileUploader = false;
    @track loanApplicantName;
    eventMessage;
    applicants = [];
    opportunityId;
    connectedCallbackRan = false;
    @track buttonLabel = 'Refresh';

    subscription = {};
    @api channelName = '/event/LoanApplicantEvent__e';

    connectedCallback() {

        this.registerErrorListener();
        this.handleSubscribe();

        if (this.displayOnly === true) {
            this.displayOnlyVar = 'pointer-events:none'
        }
        if (this.connectedCallbackRan === false) {
            this.opportunityId = this.recordId;
            this.connectedCallbackRan = true;
        }
        this.loadData();
    }

    loadData() {
        this.showBar = false;
        this.buttonLabel = 'Refresh';
        getLoanApplicants({recordId: this.opportunityId}).then((applicant) => {

            this.applicants = applicant;

            if (this.bondMode === false) {
                for (const element of applicant) {
                    if (element.loanApplicant.Status__c === 'Verification Successful') {
                        element.loanApplicant.Status__c = 'Processed Successfully'
                    }
                    if (element.loanApplicant.Status__c === 'Verification Failed') {
                        element.loanApplicant.Status__c = 'Processed Unsuccessfully'
                    }
                    if (element.loanApplicant.Status__c === 'Poor Credit') {
                        element.pickListValues = ['Poor Credit']
                    } else if (element.loanApplicant.Status__c === 'Consent Refused') {
                        element.pickListValues = ['Consent Refused']
                    } else if (element.loanApplicant.Status__c === 'Processed Unsuccessfully') {
                        element.pickListValues = ['Processed Unsuccessfully']
                    } else {
                        element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'Poor Credit'), 1)
                        element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'Consent Refused'), 1)
                        element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'Processed Unsuccessfully'), 1)
                        element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'Attempting Contact'), 1)
                        element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'Awaiting OTP'), 1)
                        element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'OTP Received'), 1)
                        element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'OTP Received - Awaiting Docs'), 1)
                        element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'Ready For Verification'), 1)
                        element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'Awaiting Signature'), 1)
                        element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'Signed Application Uploaded'), 1)
                        element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'Deal Submitted'), 1)

                        //-------------------Show Maximum of 5 path steps-----------------------------//
                        element.pickListValues = element.pickListValues.splice(
                            (element.pickListValues.findIndex(plv => plv === element.loanApplicant.Status__c) - 2) > 0 ?
                                element.pickListValues.findIndex(plv => plv === element.loanApplicant.Status__c) - 2 :
                                0, 5);
                    }
                }
            } else if (this.bondMode === true) {
                for (const element of applicant) {
                    element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'Attempting Contact'), 1)
                    element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'Poor Credit'), 1)
                    element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'Consent Refused'), 1)
                    element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'Processed Unsuccessfully'), 1)
                    element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'Awaiting Consent'), 1)
                    element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'Awaiting Credit Check'), 1)
                    element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'Awaiting Documents'), 1)
                    element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'Awaiting Verification'), 1)
                    element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'Processed Successfully'), 1)
                    element.pickListValues.splice(element.pickListValues.findIndex(plv => plv === 'PA Issued'), 1)

                    //-------------------Show Maximum of 5 path steps-----------------------------//
                    element.pickListValues = element.pickListValues.splice(
                        (element.pickListValues.findIndex(plv => plv === element.loanApplicant.Status__c) - 2) > 0 ?
                            element.pickListValues.findIndex(plv => plv === element.loanApplicant.Status__c) - 2 :
                            0, 5);
                    // }
                }
            }
            this.loanApplicants = applicant;
            this.showBar = true;
        })
    }

    handleRefresh() {
        this.showFileUploader = false
        this.loadData()
    }

    handleClick(event) {

        this.recordId = event.target.dataset.id; // Must be set for external resource Cat Loader
        let index = this.applicants.findIndex(app => app.loanApplicant.Id === event.target.dataset.id)
        this.loanApplicantName = this.applicants[index].loanApplicant.Name;
        if (this.applicants[index].loanApplicant.Status__c !== 'Awaiting Documents') {
            const navigateNextEvent = new FlowNavigationNextEvent()
            this.dispatchEvent(navigateNextEvent);
            this.loadData();
        } else if (this.applicants[index].loanApplicant.Status__c === 'Awaiting Documents') {
            this.buttonLabel = 'Back to Applicants';
            this.showBar = false;
            this.showFileUploader = true;
        }
        this.showBar = false;
    }

    handleSubscribe() {
        // Platform event created, flow created to create platform event records on record triggered flow on applicant
        // Callback invoked whenever a new event message is received
        const thisReference = this;
        const messageCallback = (response) => {

            if (this.applicants.findIndex(apps =>
                apps.loanApplicant.Id === response.data.payload.recordId__c
            ) >= 0) {
                this.loadData();
            }
        };


        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }

    disconnectedCallback() {
        unsubscribe(this.subscription, response => {
            // console.log('unsubscribe() response: ', JSON.stringify(response));
            // Response is true for successful unsubscribe
        });
    }

}