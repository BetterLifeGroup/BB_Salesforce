/**
 * Created by frans fourie on 2023/06/23.
 */

import {LightningElement, track, wire} from 'lwc';
import updateAgent from '@salesforce/apex/UserManagementController.updateAgent';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getRealEstateBranches from '@salesforce/apex/UserManagementController.getRealEstateBranches';
import emailRegex from '@salesforce/label/c.EmailRegex';

import {getObjectInfo, getPicklistValues} from "lightning/uiObjectInfoApi";

import Contact from '@salesforce/schema/Contact';
import Visibility from '@salesforce/schema/Contact.Visibility__c';

export default class UserManagementAddNewAgent extends LightningElement {

    @wire(getObjectInfo, {objectApiName: Contact})
    contactObjectInfo;

    @track vizOptions;

    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: Visibility
    })
    VizFieldInfo({data, error}) {
        if (data) {
            this.vizOptions = data.values;
        }
        if (error) {
            console.error(error)
        }
    }

    @track agent = [];

    @track working = false;

    @track saveEnabled = false;

    @track branchOptions = [];

    emailIsValid = false;
    mobileIsValid = true;

    regex = emailRegex;

    @track queryFilter = ' AND RecordType.Name = \'Real Estate Branch\'';

    @track constantTrue = true;

    connectedCallback() {
        // getRealEstateBranches({}).then(result => {
        //     for (let i = 0; i < result.length; i++) {
        //         this.branchOptions.push({label: result[i].Name, id: result[i].Id})
        //     }
        // })
        this.agent.agent = {};
        this.agent.agent.FirstName = '';
        this.agent.agent.LastName = '';
        this.agent.agent.Email = '';
        this.agent.agent.MobilePhone = '';
        this.agent.agent.AccountId = '';
        this.agent.agent.Visibility__c = 'Always Visible';
        this.agent.agent.FinServ__PreferredName__c = '';

    }

    handleBranchSelected(event) {
        this.agent.agent.AccountId = event.detail.id;
        this.checkValidity();
    }

    @track branchSelected = false;

    handleBranchSelectedRs(event) {
        this.agent.commId = '';
        this.agent.agent.AccountId = event.detail.id;
        this.branchSelected = true;
        this.checkValidity();
    }

    handleRemoveBranchRs(event) {
        this.agent.agent.AccountId = null;
        this.branchSelected = false;
        this.checkValidity();
    }

    @track commIdSupplied = false;

    handleAgentCommIdChangeNew(event) {
        let field = this.template.querySelector("[data-field='commId']")
        if (event.target.value.length > 0) {
            this.agent.commId = event.detail.value;
            this.commIdSupplied = true;
            this.checkValidity();
        } else {
            this.agent.commId = '';
            this.commIdSupplied = false;
            this.checkValidity();
        }
    }

    handleAgentMobilePhoneChange(event) {
        let field = this.template.querySelector("[data-field='mobile']");
        if ((event.target.value.length === 10 && event.target.value.startsWith('0')) || (event.target.value.length === 12 && event.target.value.includes('+27'))) {
            field.validity = {valid: true};
            field.setCustomValidity("");
            this.agent.agent.MobilePhone = event.detail.value;
            this.mobileIsValid = true
            this.checkValidity();
        } else if (event.target.value.length === 0) {
            field.validity = {valid: true};
            field.setCustomValidity("");
            this.mobileIsValid = true;
            this.checkValidity();
        } else {
            this.mobileIsValid = false;
            field.validity = {valid: false};
            field.setCustomValidity("Invalid input");
            this.checkValidity();
        }
    }


    handleAgentVizChange(event) {
        let field = this.template.querySelector("[data-field='viz']")
        if (event.target.value.length > 0) {
            field.validity = {valid: true};
            field.setCustomValidity("");
            this.agent.agent.Visibility__c = event.detail.value;
            this.checkValidity();
        } else {
            this.showUpdate = false;
            field.validity = {valid: false};
            field.setCustomValidity("Invalid input");
        }
    }


    handleAgentEmailChange(event) {
        let field = this.template.querySelector("[data-field='email']");
        if (event.target.value.match(this.regex)) {
            field.validity = {valid: true};
            field.setCustomValidity("");
            this.agent.agent.Email = event.detail.value;
            this.emailIsValid = true
            this.checkValidity();
        } else {
            this.emailIsValid = false;
            field.validity = {valid: false};
            field.setCustomValidity("Invalid input");
            this.checkValidity();
        }

    }

    handleP40Change(event) {
        this.agent.agent.P40_Indicator__c = event.target.checked;
    }

    handle4dxChange(event) {
        this.agent.agent.X4DX_Indicator__c = event.target.checked;
    }

    handleAgentLastNameChange(event) {
        this.agent.agent.LastName = event.detail.value;
        this.checkValidity();

    }

    handleAgentFirstNameChange(event) {
        this.agent.agent.FirstName = event.detail.value;
        this.checkValidity();
    }

    handleAgentPreferredNameChange(event) {
        this.agent.agent.FinServ__PreferredName__c = event.detail.value;
    }

    handleRecordRemoved() {
        this.agent.agent.AccountId = null;
        this.checkValidity();
    }


    checkValidity() {
        this.saveEnabled =
            this.agent?.agent?.LastName?.length > 0
            && this.emailIsValid
            && this.mobileIsValid
            && (this.agent.agent.AccountId ? this.agent?.commId?.length > 0 : true)
            && (this.commIdSupplied ? this.agent?.agent?.AccountId?.length > 0 : true);
    }

    handleCreate(event) {
        console.log(this.agent)
        this.working = true;
        updateAgent({
            agent: this.agent.agent,
            commId: this.agent?.commId ? this.agent.commId : null
        }).then(result => {
                if (result) {
                    this.showToast('Created successfully', 'Created successfully', 'success')
                    this.agent.agent = {};
                    this.agent.agent.FirstName = '';
                    this.agent.agent.LastName = '';
                    this.agent.agent.Email = '';
                    this.agent.agent.MobilePhone = '';
                    this.agent.agent.AccountId = '';
                    this.agent.agent.FinServ__PreferredName__c = '';
                    this.agent.commId = '';
                }
                this.working = false;
            }
        ).catch(error => {
            console.log(error)
            this.showToast('Failed to create', error.body.message, 'error')
            this.working = false;
        })
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

}