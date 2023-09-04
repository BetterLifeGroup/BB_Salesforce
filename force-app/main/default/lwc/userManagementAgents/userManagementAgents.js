/**
 * Created by frans fourie on 2023/06/22.
 */

import {LightningElement, track} from 'lwc';
import getAgentDetails from '@salesforce/apex/UserManagementController.getAgentDetails'
import updateAgent from '@salesforce/apex/UserManagementController.updateAgent'
import getRealEstateBranches from '@salesforce/apex/UserManagementController.getRealEstateBranches'
import getAllConsultants from '@salesforce/apex/UserManagementController.getAllConsultants'
// import deleteCCR from '@salesforce/apex/UserManagementController.deleteCCR'
// import createCCR from '@salesforce/apex/UserManagementController.createCCR'
import getAllLinkedConsultants from '@salesforce/apex/UserManagementController.getAllLinkedConsultants'
import deleteCCRById from '@salesforce/apex/UserManagementController.deleteCCRById'
import createCCRByAgent from '@salesforce/apex/UserManagementController.createCCRByAgent'
import getAllConsultantsNotLinkedToRunningAgent
    from '@salesforce/apex/UserManagementController.getAllConsultantsNotLinkedToRunningAgent'
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import emailRegex from '@salesforce/label/c.EmailRegex';

export default class UserManagementAgents extends LightningElement {

    @track constantTrue = true;

    @track selectedAgentName;
    @track selectedAgentId;
    @track agent;

    @track branchOptions = [];

    @track agentSelected = false;
    @track disableUpdate = false;

    @track working = false;
    @track showLinkedConsultants = false;

    @track linkedConsultants = [];
    @track linkedConsultantOptions = [];

    tempWorking = false;

    regex = emailRegex;


    connectedCallback() {
        getRealEstateBranches({}).then(result => {
            for (let i = 0; i < result.length; i++) {
                this.branchOptions.push({label: result[i].Name, id: result[i].Id})
            }
        })


    }


    contactSelected(event) {

        this.selectedAgentId = event.detail.id;
        this.selectedAgentName = event.detail.name;

        getAgentDetails({contactId: this.selectedAgentId}).then(result => {
            this.agent = result;
            this.agentSelected = true;
            this.reloadLinkedConsultants()
        })

    }

    reloadLinkedConsultants() {
        this.tempWorking = false;
        this.showLinkedConsultants = false;
        this.working = true;
        this.linkedConsultants = [];
        this.linkedConsultantOptions = [];
        getAllLinkedConsultants({agentContactId: this.selectedAgentId}).then(result => {
            console.log('ccrs', result);
            this.linkedConsultants = result;
            if (!this.linkedConsultants.length > 0) {

                this.linkedConsultants.push({
                    FinServ__RelatedContact__c: '',
                    Id: '',
                    Name: '',
                    FinServ__RelatedContact__r: {
                        Id: '',
                        Name: ''
                    },
                    iconDisabled: true
                })
            }
            if (this.tempWorking) {
                this.working = false;
            } else {
                this.tempWorking = true;
            }
        })
        getAllConsultantsNotLinkedToRunningAgent({agentContactId: this.selectedAgentId}).then(result => {
            console.log('agents', result)
            this.linkedConsultantOptions = [];
            for (let i = 0; i < result.length; i++) {
                this.linkedConsultantOptions.push({label: result[i].Name, id: result[i].Id})
            }
            if (this.tempWorking) {
                this.working = false;
            } else {
                this.tempWorking = true;
            }
            this.showLinkedConsultants = true;
            console.log('linked Consultants', this.linkedConsultantOptions);
        })
    }

    handleAddNewLinkedConsultant() {
        this.linkedConsultants.push({
            FinServ__RelatedContact__c: '',
            Id: '',
            Name: '',
            FinServ__RelatedContact__r: {
                Id: '',
                Name: ''
            },
            iconDisabled: true
        })
    }

    handleLinkedConsultantSelected(event) {

        this.working = true;
        console.log(event.detail.id)
        console.log(this.selectedAgentId)
        createCCRByAgent({agentContactId: this.selectedAgentId, consultantContactId: event.detail.id}).then(result => {
            if (result) {
                this.working = false;
                this.showToast('Success', 'Success', 'success')
            } else {
                this.working = false;
                this.showToast('Error', 'Error', 'error')
            }
            this.reloadLinkedConsultants();
        })
    }

    handleRemoveLinkedConsultant(event) {
        this.working = true;
        deleteCCRById({ccrId: event.target.dataset.id}).then(result => {
            if (result) {
                this.working = false;
                this.showToast('Success', 'Success', 'success')
            } else {
                this.working = false;
                this.showToast('Error', 'Error', 'error')
            }
            this.reloadLinkedConsultants();
        })
    }

    handleSelectionCleared(event) {
        this.agentSelected = false;
    }

    handleAgentMobilePhoneChange(event) {
        let field = this.template.querySelector("[data-field='mobile']")
        if ((event.target.value.length === 10 && event.target.value.startsWith('0')) || (event.target.value.length === 12 && event.target.value.includes('+27'))) {
            field.validity = {valid: true};
            field.setCustomValidity("");
            this.agent.agent.MobilePhone = event.detail.value;
            this.disableUpdate = false;
        } else {
            this.disableUpdate = true;
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
            this.disableUpdate = false;
        } else {
            this.disableUpdate = true;
            field.validity = {valid: false};
            field.setCustomValidity("Invalid input");
        }

    }

    handleAgentLastNameChange(event) {
        this.agent.agent.LastName = event.detail.value;

    }

    handleAgentFirstNameChange(event) {
        this.agent.agent.FirstName = event.detail.value;
    }

    handleP40Change(event){
        this.agent.agent.P40_Indicator__c = event.target.checked;
    }

    handle4dxChange(event){
        this.agent.agent.X4DX_Indicator__c = event.target.checked;
    }

    handleUpdate(event) {
        console.log(this.agent)
        this.working = true;
        updateAgent({agent: this.agent.agent}).then(result => {
                this.working = false;
                if (result) {
                    this.showToast('Updated successfully', 'Updated successfully', 'success')
                }
            }
        ).catch(error => {
            this.showToast('Failed to update', error.body.message, 'error')
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

    handleBranchSelected(event) {
        this.working = true;
        this.agent.agent.AccountId = event.detail.id;
        updateAgent({agent: this.agent.agent}).then(result => {
            if (result) {
                this.showToast('Updated successfully', 'Updated successfully', 'success')
            }
            this.working = false;
        }).catch(error => {
            this.working = false;
            this.showToast('Failed to update', error.body.message, 'error')
        })
    }

}