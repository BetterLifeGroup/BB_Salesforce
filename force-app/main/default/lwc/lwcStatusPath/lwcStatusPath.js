/**
 * Created by frans fourie on 2023/01/13.
 */

import {LightningElement, api, track} from 'lwc';
import getLoanApplicants from '@salesforce/apex/workFlowManager.getLoanApplicants'
import {FlowNavigationNextEvent} from "lightning/flowSupport";

export default class WorkFlowManager extends LightningElement {

    @api recordId;
    @track loanApplicants = [];
    @track showBar = false;
    @track showFileUploader = false;
    @track loanApplicantName;
    applicants = [];
    opportunityId;
    connectedCallbackRan = false;

    connectedCallback() {
        if (this.connectedCallbackRan === false) {
            this.opportunityId = this.recordId;
            this.connectedCallbackRan = true;
        }
        this.loadData();
    }

    loadData() {
        this.showBar = false;
        getLoanApplicants({recordId: this.opportunityId}).then((applicant) => {

            this.applicants = applicant;

            for (const element of applicant) {
                if(element.loanApplicant.Status__c === 'Verification Successful'){
                    element.loanApplicant.Status__c = 'Processed Successfully'
                }
                if(element.loanApplicant.Status__c === 'Verification Failed'){
                    element.loanApplicant.Status__c = 'Processed Unsuccessfully'
                }
                console.log('picklist values',element.pickListValues)
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

                    //-------------------Show Maximum of 5 path steps-----------------------------//
                    element.pickListValues = element.pickListValues.splice(
                        (element.pickListValues.findIndex(plv => plv === element.loanApplicant.Status__c) - 2) > 0 ?
                            element.pickListValues.findIndex(plv => plv === element.loanApplicant.Status__c) - 2 :
                            0, 5);
                }
            }
            this.loanApplicants = applicant;
            this.showBar = true;
        })
    }

}