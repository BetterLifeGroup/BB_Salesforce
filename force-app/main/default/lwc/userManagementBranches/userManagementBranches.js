/**
 * Created by frans fourie on 2023/04/28.
 */

import {LightningElement, track} from 'lwc';
import modal from "c/userManagementBranchesModal"
import userManagementNetworks from '@salesforce/apex/UserManagementController.userManagementNetworks'


export default class UserManagementBranches extends LightningElement {

    @track constantTrue = true;

    handleSelect(event) {
        console.log(event.detail.name);
    }

    @track finalResult = [];

    handleClick() {
        modal.open({
            size: 'small'
        }).then((result) => {
            if (result === 'canceled') {
                this.handleClick()
            }
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

    handleSearchChangeAfterDebounce(event) {

        console.log(event.detail.value)
        userManagementNetworks({searchString: event.detail.value, reState: false}).then(result => {

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
            } else {
                this.finalResult = [{label: 'No Results Found', name: 'No Results Found'}];
            }
        })
        this.dataHasLoaded = true;
    }
}