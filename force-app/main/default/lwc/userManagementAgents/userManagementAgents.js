/**
 * Created by frans fourie on 2023/06/22.
 */

import {LightningElement, track, wire} from 'lwc';
import getAgentDetails from '@salesforce/apex/UserManagementController.getAgentDetails'
import updateAgent from '@salesforce/apex/UserManagementController.updateAgent'
import getRealEstateBranches from '@salesforce/apex/UserManagementController.getRealEstateBranches'
import deactivateAgent from '@salesforce/apex/UserManagementController.deactivateAgent'
import reactivateAgent from '@salesforce/apex/UserManagementController.reactivateAgent'
import getAllLinkedConsultants from '@salesforce/apex/UserManagementController.getAllLinkedConsultants'
import deleteCCRById from '@salesforce/apex/UserManagementController.deleteCCRById'
import createCCRByAgent from '@salesforce/apex/UserManagementController.createCCRByAgent'
import getAllConsultantsNotLinkedToRunningAgent
    from '@salesforce/apex/UserManagementController.getAllConsultantsNotLinkedToRunningAgent'
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import emailRegex from '@salesforce/label/c.EmailRegex';

import {getObjectInfo, getPicklistValues} from "lightning/uiObjectInfoApi";

import Contact from '@salesforce/schema/Contact';
import Visibility from '@salesforce/schema/Contact.Visibility__c';

export default class UserManagementAgents extends LightningElement {

    @track constantTrue = true;

    @track selectedAgentName;
    @track selectedAgentId;
    @track agent;

    // @track branchOptions = [];

    @track agentSelected = false;
    @track showUpdate = false;

    @track working = false;
    @track reloadView = false;
    @track showLinkedConsultants = false;
    @track activeAgent = false;

    @track linkedConsultants = [];
    @track linkedConsultantOptions = [];

    @track accountScope = 'agents';

    @track queryFilter = ' AND RecordType.Name = \'Real Estate Branch\'';

    tempWorking = false;

    regex = emailRegex;


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

    connectedCallback() {
        // getRealEstateBranches({}).then(result => {
        //     for (let i = 0; i < result.length; i++) {
        //         this.branchOptions.push({label: result[i].Name, id: result[i].Id})
        //     }
        // })


    }


    contactSelected(event) {

        this.selectedAgentId = event.detail.id;
        this.selectedAgentName = event.detail.name;

        getAgentDetails({contactId: this.selectedAgentId}).then(result => {
            this.agent = result;
            this.agent.commId = this.agent.commId ? this.agent.commId : '' ;
            console.log('this.agent',JSON.parse(JSON.stringify(this.agent)))
            this.activeAgent = this.agent.agent.Active__c;
            // this.showUpdate = !this.agent.agent.Active__c;
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
            this.validateInput();
        } else {
            this.showUpdate = false;
            field.validity = {valid: false};
            field.setCustomValidity("Invalid input");
        }

    }

    handleAgentCommIdChange(event) {
        let field = this.template.querySelector("[data-field='commId']")
        if (event.target.value.length > 0) {
            field.validity = {valid: true};
            field.setCustomValidity("");
            this.agent.commId = event.detail.value;
            this.validateInput();
        } else {
            this.showUpdate = false;
            field.validity = {valid: false};
            field.setCustomValidity("Invalid input");
        }
    }

    handleAgentVizChange(event) {
        let field = this.template.querySelector("[data-field='viz']")
        if (event.target.value.length > 0) {
            field.validity = {valid: true};
            field.setCustomValidity("");
            this.agent.agent.Visibility__c = event.detail.value;
            this.validateInput();
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
            this.validateInput();
        } else {
            this.showUpdate = false;
            field.validity = {valid: false};
            field.setCustomValidity("Invalid input");
        }

    }

    handleAgentLastNameChange(event) {
        this.agent.agent.LastName = event.detail.value;
        this.validateInput();

    }

    handleAgentFirstNameChange(event) {
        this.agent.agent.FirstName = event.detail.value;
        this.validateInput();
    }

    handleP40Change(event) {
        this.agent.agent.P40_Indicator__c = event.target.checked;
    }

    handleAgentPreferredNameChange(event) {
        this.agent.agent.FinServ__PreferredName__c = event.detail.value;
        this.validateInput();
    }

    handle4dxChange(event) {
        this.agent.agent.X4DX_Indicator__c = event.target.checked;
    }

    handleUpdate(event) {
        console.log(this.agent)
        this.working = true;
        updateAgent({agent: this.agent.agent,commId:this.agent?.commId ? this.agent.commId : null}).then(result => {
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
        updateAgent({agent: this.agent.agent,commId:this.agent?.commId ? this.agent.commId : null}).then(result => {
            if (result) {
                this.showToast('Updated successfully', 'Updated successfully', 'success')
            }
            this.working = false;
        }).catch(error => {
            this.working = false;
            this.showToast('Failed to update', error.body.message, 'error')
        })
    }

    handleDeactivate() {
        this.working = true;
        this.reloadView = true;
        deactivateAgent({contactId: this.selectedAgentId}).then(result => {
            this.reloadView = false;
            this.agentSelected = false;
            this.agent = {};
            this.working = false;
            this.showToast('Success', 'Success', 'success');
        }).catch(error => {
            this.showToast('Error', 'Something Went Wrong', 'error');
            console.error(error)
        })
    }

    handleReactivate() {
        this.working = true;
        this.reloadView = true;
        reactivateAgent({contactId: this.selectedAgentId}).then(result => {
            this.reloadView = false;
            this.agentSelected = false;
            this.agent = {};
            this.working = false;
            this.showToast('Success', 'Success', 'success');
        }).catch(error => {
            this.showToast('Error', 'Something Went Wrong', 'error');
            console.error(error)
        })
    }

    handleInactiveSearchChange(event) {
        this.accountScope = event.detail.checked ? 'inactiveAgents' : 'agents';
    }

    valid = true;
    handleRemoveBranchRs(event) {
        this.agent.agent.AccountId = null;
        this.valid = false;
        this.validateInput();
    }

    handleBranchSelectedRs(event) {
        console.log('in here')
        // this.working = true;
        this.agent.agent.AccountId = event.detail.id;
        this.agent.commId = '';
        this.valid = true;
        this.validateInput();
        // updateAgent({agent: this.agent.agent,commId:this.agent?.commId ? this.agent.commId : null}).then(result => {
        //     if (result) {
        //         this.valid = true;
        //         this.validateInput();
        //         this.showToast('Updated successfully', 'Updated successfully', 'success')
        //     }
        //     this.validateInput();
        //     this.working = false;
        // }).catch(error => {
        //     this.working = false;
        //     this.showToast('Failed to update', error.body.message, 'error')
        // })
    }

    validateInput() {
        this.showUpdate = (
            // this.agent?.agent?.FirstName?.length > 0
            this.agent?.commId?.length > 0
            && this.agent?.agent?.Active__c
            && this.agent?.agent?.LastName?.length > 0
            && this.agent?.agent?.Email?.length > 0
            && this.valid
            // && this.agent?.agent?.MobilePhone?.length > 0
            // && this.agent?.agent?.AccountId != null
        )
    }

}