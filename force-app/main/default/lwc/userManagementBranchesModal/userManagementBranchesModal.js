/**
 * Created by frans fourie on 2023/06/21.
 */

import {api, track} from 'lwc';
import LightningModal from 'lightning/modal';
import CreateRegion from '@salesforce/apex/UserManagementController.CreateRegion'
import CreateBranch from '@salesforce/apex/UserManagementController.CreateBranch'
import CreateSubBranch from '@salesforce/apex/UserManagementController.CreateSubBranch'

export default class UserManagementNetworksModal extends LightningModal {

    @api content;
    @api options = [];

    @track disableClose = false;

    @track constantTrue = true;

    @track selectedNewComboboxValue;
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
    newBranchName;

    handleOptionClick(e) {
        const {target} = e;
        const {id} = target.dataset;
        // this.close() triggers closing the modal
        // the value of `id` is passed as the result
        this.close(id);
    }


    get createNewComboboxOptions() {
        return [
            {label: 'Region', value: 'Region'},
            {label: 'Branch', value: 'Branch'},
            {label: 'Sub-Branch', value: 'Sub-Branch'},
        ]
    }

    handleChange(event) {
        this.selectedNewComboboxValue = event.detail.value;

        this.createNewNetwork = event.detail.value === 'Region';
        this.createNewAgency = event.detail.value === 'Branch';
        this.createNewBranch = event.detail.value === 'Sub-Branch';

        console.log(this.selectedNewComboboxValue)
    }

    handleNewNetworkName(event) {
        this.success = false;
        this.failure = false;
        this.newNetworkName = event.detail.value;
        this.enableSave = this.newNetworkName.length > 0;
    }

    handleClickNewNetworkSaveButton(event) {
        this.disableClose = true;
        CreateRegion({name: this.newNetworkName}).then(result => {
            this.disableClose = false;
            if (result === true) {
                this.success = true;
            } else {
                this.failure = true;
            }
            setTimeout(() => {
                this.close('closed');
            }, 1500)
        })


        this.disableClose = true;
        console.log('saved new network')
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
        this.close('canceled');
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
        this.disableClose = true;
        CreateBranch({name: this.newAgencyName, parentId: this.selectedNetworkId}).then(result => {
            this.disableClose = false;
            if (result === true) {
                this.success = true;
            } else {
                this.failure = true;
            }
            setTimeout(() => {
                this.close('closed');
            }, 1500)
        })
    }

    handleNewAgencyName(event) {
        this.success = false;
        this.failure = false;
        this.newAgencyName = event.detail.value;
        this.enableSave = this.newAgencyName.length > 0;
    }


    handleClickNewBranchSaveButton(event) {

        this.disableClose = true;
        CreateSubBranch({name: this.newBranchName, parentId: this.selectedAgencyId}).then(result => {
            this.disableClose = false;
            if (result === true) {
                this.success = true;
            } else {
                this.failure = true;
            }
            setTimeout(() => {
                this.close('closed');
            }, 1500)
        })
    }

    handleNewBranchName(event) {
        this.success = false;
        this.failure = false;
        this.newBranchName = event.detail.value;
        this.enableSave = this.newBranchName.length > 0;
    }

}