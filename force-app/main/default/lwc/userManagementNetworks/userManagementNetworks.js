/**
 * Created by frans fourie on 2023/06/23.
 */

import {LightningElement, track} from 'lwc';
import modal from "c/userManagementNetworksModal"
import editModal from "c/userManagementNetworksEditModal"
import userManagementNetworks from '@salesforce/apex/UserManagementController.userManagementNetworks'
import getSobjectType from '@salesforce/apex/UserManagementController.getSobjectType'
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class UserManagementNetworks extends LightningElement {
    @track constantTrue = true;

    @track isLoading = false;

    searchTerm = '';

    searchByAgent = false;

    handleSelect(event) {
        console.log('open edit modal', event.detail.name)
        getSobjectType({recordId: event.detail.name}).then(result => {
            if (result === 'Account') {
                editModal.open({
                    size: 'medium',
                    options: {accountId: event.detail.name}
                }).then((result) => {
                    console.log(result)
                    if (result === 'success') {
                        this.showToast('Success', 'Success', 'success')
                        this.handleSearchChangeAfterDebounce({detail: {value: this.searchTerm}})
                    } else if (result !== undefined) {
                        this.showToast('Error', result, 'error')

                    }
                });
            }
        });
    }

    @track finalResult = [];


    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }


    handleClick() {
        modal.open({
            size: 'small'
        }).then((result) => {
            console.log(result)
            if (result === 'success') {
                this.showToast('Success', 'Success', 'success')
            } else if (result !== 'success') {
                this.showToast('Error', result, 'error')
            }
        }).catch(error => {
            this.showToast('Error', error, 'error')
        });
    }

    static timerId;
    addDebounce = (fn, wait = 300) => {
        clearTimeout(this.timerId);
        this.timerId = setTimeout(fn, wait);
    }

    handleSearchChange(event) {

        this.addDebounce(() => this.handleSearchChangeAfterDebounce(event), 600)
    }

    handleSearchByAgentCheck() {
        this.searchByAgent = !this.searchByAgent;
        this.handleSearchChangeAfterDebounce({detail: {value: this.searchTerm}})
    }

    handleSearchChangeAfterDebounce(event) {
        this.searchTerm = event.detail.value;
        if (this.searchTerm.length > 2) {
            this.isLoading = true;
            userManagementNetworks({
                searchString: event.detail.value,
                reState: true,
                searchByContact: this.searchByAgent
            }).then(result => {

                this.isLoading = false;
                if (result.accounts.length > 0) {
                    let nodeMap = new Map();
                    result.accounts.forEach(account => {
                        nodeMap.set(account.Id, {
                            id: account.Id,
                            name: account.Id,
                            label: account.Name + ' - ' + account.RecordType.Name,
                            parentId: account.ParentId,
                            items: result.contacts?.filter(contact => contact.AccountId === account.Id).map(contact => {
                                return {
                                    id: contact.Id,
                                    accountId: contact.AccountId,
                                    name: contact.Id,
                                    label: contact.Name
                                }
                            }) || []
                        });
                    });

                    Array.from(nodeMap.values())?.filter(account => account.parentId).forEach(childAccount => {
                        if (nodeMap.has(childAccount.parentId)) {
                            nodeMap.get(childAccount.parentId).items.push(childAccount);
                        }
                    });

                    let rootNodes = Array.from(nodeMap.values()).filter(account => !account.parentId);
                    this.finalResult = rootNodes;
                    console.log('final Results', JSON.parse(JSON.stringify(this.finalResult)))
                } else {
                    this.finalResult = [{label: 'No Results Found', name: 'No Results Found'}];
                }
            })
            this.dataHasLoaded = true;
        }
    }
}