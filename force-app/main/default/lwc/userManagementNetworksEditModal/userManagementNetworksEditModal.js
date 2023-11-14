/**
 * Created by frans fourie on 2023/06/21.
 */

import {api, track} from 'lwc';
import LightningModal from 'lightning/modal';
import getAccount from '@salesforce/apex/UserManagementController.getAccount'
import updateAccountName from '@salesforce/apex/UserManagementController.updateAccountName'
import deleteAccount from '@salesforce/apex/UserManagementController.deleteAccount'


export default class UserManagementNetworksEditModal extends LightningModal {

    @api options = [];

    @track accountData = {};

    @track disableClose = false;

    @track dataHasLoaded = false;

    @track deleteSelected = false;

    @track showSpinner = false;

    @track constantTrue = true;

    @track label = '';
    @track deleteLabel = '';

    connectedCallback() {
        getAccount({recordId: this.options.accountId}).then(result => {
            this.accountData = result;
            console.log(JSON.parse(JSON.stringify(this.accountData)));
            if (this.accountData.RecordType.Name === 'Real Estate Network') {
                this.label = 'Network Name';
                this.deleteLabel = 'Delete Network';
            } else if (this.accountData.RecordType.Name === 'Real Estate Agency') {
                this.label = 'Agency Name';
                this.deleteLabel = 'Delete Agency';
            } else {
                this.label = 'Branch Name';
                this.deleteLabel = 'Delete Branch';

            }
            this.dataHasLoaded = true;
        }).catch(error => {
            console.error('accounts not found')
        })
        console.log(JSON.parse(JSON.stringify(this.options)))
    }

    handleOptionClick(e) {
        const {target} = e;
        const {id} = target.dataset;
        // this.close() triggers closing the modal
        // the value of `id` is passed as the result
        this.close(id);
    }

    handleNameChange(event) {
        this.accountData.Name = event.detail.value
    }

    handleDeletePrompt() {
        this.deleteSelected = true;
    }

    handleUpdate() {

        this.showSpinner = true;
        updateAccountName({acc: this.accountData}).then(result => {
            console.log('updated');
            this.showSpinner = false;
            this.close('success');
        }).catch(error => {
            this.showSpinner = false;
            console.error(error);
            this.close('error')
        })
    }


    handleDelete(event) {
        this.showSpinner = true;
        deleteAccount({recordId: this.options.accountId}).then(result => {
            if (result === 'success') {
                this.close('success');
            } else {
                this.close(result);
            }
            this.showSpinner = false;
        }).catch(error => {
            console.error('unable to delete records', error)
            this.showSpinner = false;
            this.close('error')
        })
    }

    handleDeleteCancel() {
        this.deleteSelected = false;
    }


}