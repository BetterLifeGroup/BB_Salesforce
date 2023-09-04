/**
 * Created by frans fourie on 2023/05/02.
 */

import {LightningElement, track, api} from 'lwc';
import modal from "c/userManagementNetworksModal"
import getRelatedReAccounts from '@salesforce/apex/UserManagementController.getRelatedReAccounts'

export default class UserManagementReNetworks extends LightningElement {

    @track devInProgress = false;
    @track dataHasLoaded = false;
    @track constantTrue = true;
    @track selectedAgency = true;
    @track selectedNetwork = true;

    @track returnedAccounts = [];
    @track viewRelations = false;

    @api content;

    handleClick() {
        modal.open({
            size: 'small'
        }).then((result) => {
            if (result === 'canceled') {
                this.handleClick()
            }
            console.log(result);
        });
    }

    connectedCallback() {
        this.dataHasLoaded = true;
    }

    accountSelected(event) {
        console.log(event.detail.id)
        getRelatedReAccounts({searchId: event.detail.id}).then(result => {
            console.log('returned accounts', result)
            this.returnedAccounts = result;
            this.viewRelations = true;
        })
    }

    handleSelectionCleared(event) {
        this.returnedAccounts = [];
        this.viewRelations = false;
    }

}