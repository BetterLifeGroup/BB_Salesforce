/**
 * Created by frans fourie on 2023/06/21.
 */

import {api, track, wire} from 'lwc';
import LightningModal from 'lightning/modal';
import CreateNetwork from '@salesforce/apex/UserManagementController.CreateNetwork'
import CreateAgency from '@salesforce/apex/UserManagementController.CreateAgency'
import CreateBranch from '@salesforce/apex/UserManagementController.CreateReBranch'
import CreateNetworkAgencyBranch from '@salesforce/apex/UserManagementController.CreateNetworkAgencyBranch'
import CreateCampaign from '@salesforce/apex/UserManagementController.CreateCampaign'

import BBCampaignObject from '@salesforce/schema/BLG_Campaign__c'
import TypeOfCampaign from '@salesforce/schema/BLG_Campaign__c.Type_of_Campaign__c';
import Campaign_List__c from '@salesforce/schema/BLG_Campaign__c.Campaign_List__c';
import Campaign_Owner__c from '@salesforce/schema/BLG_Campaign__c.Campaign_Owner__c';
import Priority__c from '@salesforce/schema/BLG_Campaign__c.Priority__c';
import Group__c from '@salesforce/schema/BLG_Campaign__c.Group__c';
import Type_of_Lead__c from '@salesforce/schema/BLG_Campaign__c.Type_of_Lead__c';
import {getObjectInfo, getPicklistValues} from "lightning/uiObjectInfoApi";

export default class UserManagementNetworksModal extends LightningModal {


    @track typeOfLeadOptions;
    typeOfCampaignApex;

    @track showTypeOfLead = false;

    @wire(getPicklistValues, {
        recordTypeId: '$bbCampaignInfo.data.defaultRecordTypeId',
        fieldApiName: Type_of_Lead__c,
        controllingFieldApiName: TypeOfCampaign.fieldApiName,
        controllingFieldValue: '$selectedTypeOfCampaign'
    })
    filteredTypeOfLead({data}) {
        this.typeOfCampaignApex = data;
        // this.listOfExcludedValues = this.excludedValues.split(';');
        if (data) {
            const filteredOptions = data.values.filter((option) => {
                // Filter out "PA Issued" status and statuses that are not related to the selected stage
                return option.validFor.includes(this.typeOfCampaignOptions.findIndex((stage) => stage.value.toLowerCase() === this.selectedTypeOfCampaign.toLowerCase()));
            });

            this.typeOfLeadOptions = filteredOptions.map((item) => ({label: item.label, value: item.value}));
            this.showTypeOfLead = this.typeOfLeadOptions.length > 0;
            this.loading = false;
        }
    }

    @wire(getObjectInfo, {objectApiName: BBCampaignObject})
    bbCampaignInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$bbCampaignInfo.data.defaultRecordTypeId',
        fieldApiName: TypeOfCampaign
    })
    TypeOfCampaignInfo({data, error}) {
        if (data) {
            this.typeOfCampaignOptions = data.values;
        }
        if (error) {
            console.error(error)
        }
    }

    @track campaignListOptions;

    @wire(getPicklistValues, {
        recordTypeId: '$bbCampaignInfo.data.defaultRecordTypeId',
        fieldApiName: Campaign_List__c
    })
    CampaignListInfo({data, error}) {
        if (data) {
            this.campaignListOptions = data.values;
        }
        if (error) {
            console.error(error)
        }
    }

    @track campaignOwnerOptions;

    @wire(getPicklistValues, {
        recordTypeId: '$bbCampaignInfo.data.defaultRecordTypeId',
        fieldApiName: Campaign_Owner__c
    })
    CampaignOwnerInfo({data, error}) {
        if (data) {
            this.campaignOwnerOptions = data.values;
        }
        if (error) {
            console.error(error)
        }
    }

    @track priorityOptions;

    @wire(getPicklistValues, {
        recordTypeId: '$bbCampaignInfo.data.defaultRecordTypeId',
        fieldApiName: Priority__c
    })
    CampaignPriorityInfo({data, error}) {
        if (data) {
            this.priorityOptions = data.values;
        }
        if (error) {
            console.error(error)
        }
    }

    @track groupOptions;

    @wire(getPicklistValues, {
        recordTypeId: '$bbCampaignInfo.data.defaultRecordTypeId',
        fieldApiName: Group__c
    })
    CampaignGroup({data, error}) {
        if (data) {
            this.groupOptions = data.values;
        }
        if (error) {
            console.error(error)
        }
    }

    connectedCallback() {
        console.log('connected')
    }

    @api content;
    @api options = [];

    @track newNetwork = false;
    @track newAgency = false;

    @track disableClose = false;

    @track constantTrue = true;

    @track selectedNewComboboxValue;
    @track typeOfCampaignOptions;
    @track selectedNetworkName;
    @track selectedNetworkId;

    @track selectedAgencyId;
    @track selectedAgencyName;

    @track createNewNetwork = false;
    @track createNewAgency = false;
    @track createNewBranch = false;

    @track enableSave = false;
    @track success = false;
    @track failure = false;

    newNetworkName;
    newAgencyName;
    newBranchName = '';

    slaValue = '';
    startDateValue = '';

    handleOptionClick(e) {
        const {target} = e;
        const {id} = target.dataset;
        // this.close() triggers closing the modal
        // the value of `id` is passed as the result
        this.close(id);
    }

    createNetworkAgencyBranch() {
        this.disableClose = true;
        let networkName = null;
        let networkId = null;
        let agencyName = null;
        let agencyId = null;
        let branchName = null;
        if (this.newNetwork) {
            networkName = this.newNetworkName;
        } else {
            networkId = this.selectedNetworkId;
        }
        if (this.newAgency) {
            agencyName = this.newAgencyName;
        } else {
            agencyId = this.selectedAgencyId;
        }
        if (this.newBranchName) {
            branchName = this.newBranchName;
        }
        if (agencyId === undefined) {
            agencyId = null;
            agencyName = this.newAgencyName;
        }
        CreateNetworkAgencyBranch({
            networkName: networkName,
            networkId: networkId,
            agencyName: agencyName,
            agencyId: agencyId,
            branchName: branchName
        }).then(result => {
            console.log('resultttt',result)
            if (branchName !== null) {
                this.createCampaign(result)
            } else {
                this.disableClose = false;
                if (result) {
                    this.close('success');
                } else {
                    this.close('fail');
                }
            }

        }).catch(error => {
            console.log('error occurred', error);
        })

    }

    get createNewComboboxOptions() {
        return [
            {label: 'Network', value: 'Network'},
            {label: 'Agency', value: 'Agency'},
            {label: 'Branch', value: 'Branch'},
        ]
    }

    handleChange(event) {
        this.selectedNewComboboxValue = event.detail.value;

        this.createNewNetwork = event.detail.value === 'Network';
        this.createNewAgency = event.detail.value === 'Agency';
        this.createNewBranch = event.detail.value === 'Branch';

        this.newNetwork = false;
        this.newAgency = false;

    }

    handleNewNetworkName(event) {
        this.success = false;
        this.failure = false;
        this.newNetworkName = event.detail.value;
        this.enableSave = this.newNetworkName.length > 0;
    }

    handleClickNewNetworkSaveButton(event) {
        this.disableClose = true;
        CreateNetwork({name: this.newNetworkName}).then(result => {
            this.disableClose = false;
            if (result === true) {
                this.close('success');
                this.success = true;
            } else {
                this.failure = true;
                this.close('fail');
            }
        })


        this.disableClose = true;
        this.close('closed');

    }

    networkSelected(event) {
        this.selectedNetworkName = event.detail.name;
        this.selectedNetworkId = event.detail.id;
    }

    agencySelected(event) {
        this.selectedAgencyName = event.detail.name;
        this.selectedAgencyId = event.detail.id;
    }


    handleSelectionCleared(event) {
        // this.close('canceled');
        this.newNetworkName = null;
        this.newAgencyName = null;
        this.newBranchName = null;
        this.enableSave = false;
        this.selectedNetworkName = null;
        this.selectedNetworkId = null;
        this.selectedAgencyName = null;
        this.selectedAgencyId = null;
        this.selectedNewComboboxValue = null;
    }

    handleClickNewAgencySaveButton(event) {
        if (this.newAgency || this.newNetwork) {
            this.createNetworkAgencyBranch();
        } else {
            this.disableClose = true;
            CreateAgency({name: this.newAgencyName, parentId: this.selectedNetworkId}).then(result => {
                this.disableClose = false;
                if (result === true) {
                    this.success = true;
                    this.close('success');
                } else {
                    this.failure = true;
                    this.close('fail');
                }
            })
        }
    }


    handleNewAgencyName(event) {
        this.success = false;
        this.failure = false;
        this.newAgencyName = event.detail.value;
        this.enableSave = this.newAgencyName.length > 0;
    }


    handleClickNewBranchSaveButton(event) {
        if (this.newAgency || this.newNetwork) {
            this.createNetworkAgencyBranch();
        } else {

            this.disableClose = true;
            CreateBranch({name: this.newBranchName, parentId: this.selectedAgencyId}).then(result => {
                this.createCampaign(result)
                // this.disableClose = false;
            })
        }
    }

    createCampaign(branchId) {
        CreateCampaign({
            name: this.newBranchName,
            sla: this.slaValue,
            endDate: this.endDateValue?.length > 1 ? this.endDateValue : null,
            startDate: this.startDateValue,
            active: true,
            branchId: branchId,
            campaignList: this.selectedCampaignList.length > 1 ? this.selectedCampaignList : null,
            typeOfCampaign: this.selectedTypeOfCampaign,
            typeOfLead: this.selectedTypeOfLead.length > 0 ? this.selectedTypeOfLead : null,
            priority: this.priority.length > 0 ? this.priority : null,
            campaignOwner: this.campaignOwner,
            campaignGroup: this.selectedGroup
        }).then(result => {
            this.disableClose = false;
            if (result) {
                this.close('success');
            } else {
                this.close('fail');
            }
            console.log('campaign result')
        }).catch(error => {
            console.error(error);
        })
    }

    handleNewBranchName(event) {
        this.success = false;
        this.failure = false;
        this.newBranchName = event.detail.value;
        this.handleSaveEnable();
        // this.enableSave = this.newBranchName.length > 0 && this.startDateValue.length > 0 && this.slaValue.length > 0;
    }

    handleStartDateChange(event) {
        this.startDateValue = event.detail.value === null ? ' ' : event.detail.value;
        this.handleSaveEnable();
        // this.enableSave = this.newBranchName.length > 0 && this.startDateValue.length > 1 && this.slaValue.length > 0;
    }

    endDateValue = '';

    handleEndDateChange(event) {
        this.endDateValue = event.detail.value === null ? ' ' : event.detail.value;
        this.handleSaveEnable();
    }

    handleSlaChange(event) {
        this.slaValue = event.detail.value;
        this.handleSaveEnable();
        // this.enableSave = this.newBranchName.length > 0 && this.startDateValue.length > 0 && this.slaValue.length > 0;
    }

    handleNewNetworkCheckbox(event) {
        this.newNetwork = event.detail.checked;
        if (!this.newNetwork) {
            this.selectedNetworkName = false;
            this.selectedAgencyName = false;
            this.newAgency = false;
        }
        this.selectedNetworkName = this.newNetwork ? 'a' : null;
    }

    handleNewAgencyCheckbox(event) {
        this.newAgency = event.detail.checked;
        this.selectedAgencyName = this.newAgency ? 'a' : null;
    }

    selectedTypeOfCampaign = '';

    handleTypeOfCampaignChange(event) {
        this.selectedTypeOfCampaign = event.detail.value;
        this.handleSaveEnable();
    }

    priority = '';

    handlePriorityChange(event) {
        this.priority = event.detail.value;
        this.handleSaveEnable();
    }

    campaignOwner = '';

    handleCampaignOwnerChange(event) {
        this.campaignOwner = event.detail.value;
        this.handleSaveEnable();
    }

    selectedCampaignList = '';

    handleCampaignListChange(event) {
        this.selectedCampaignList = event.detail.value;
        this.handleSaveEnable();
    }

    selectedTypeOfLead = '';

    handleTypeOfLeadChange(event) {
        this.selectedTypeOfLead = event.detail.value;
        this.handleSaveEnable();
    }

    selectedGroup = '';

    handleGroupChange(event) {
        this.selectedGroup = event.detail.value.join(';');
        this.handleSaveEnable();
    }

    @track campaignActive = true;

    handleActiveChange(event) {
        this.campaignActive = event.detail.checked;
        this.handleSaveEnable();
    }

    handleSaveEnable() {
        this.enableSave =
            // this.campaignActive === true &&
            this.selectedGroup.length > 0 &&
            // this.endDateValue.length > 1 &&
            this.selectedTypeOfCampaign.length > 0 &&
            // this.priority.length > 0 &&
            this.campaignOwner.length > 0 &&
            this.selectedCampaignList.length > 0 &&
            // this.selectedTypeOfLead.length > 0 &&
            this.newBranchName.length > 0 &&
            this.startDateValue.length > 1 &&
            this.slaValue.length > 0 && (this.startDateValue < this.endDateValue)

    }

}