import {LightningElement, api, track} from 'lwc';
import getSobjectRecords from '@salesforce/apex/lwcLookupController.getSobjectRecords';
import getAgents from '@salesforce/apex/lwcLookupController.getAgents';
import getCampaigns from '@salesforce/apex/lwcLookupController.getCampaigns';
import getCustomers from '@salesforce/apex/lwcLookupController.getCustomers';
import getAccounts from '@salesforce/apex/UserManagementController.getAccountsForUserManagement';
import getUsers from '@salesforce/apex/lwcLookupController.getUsers';


export default class userManagementRecordSearch extends LightningElement {


    @track recordsList = [];
    @api queriedRecordId;
    @api accountScope;
    @api accountMode = false;
    @api agentMode = false;
    @api searchField;
    @api queriedObjectType;
    @api queryFilter;
    @api contactMode = false;
    @api userScope;
    @api label = '';
    @api searchKey = '';
    @api selectedValue = false;
    @track dataHasLoaded = false;
    @track showSearchResults = false;
    @track iconName = 'standard:record_lookup'
    @api contactContactScope = false;
    @api campaignScope = false;
    @api userId;
    @track space = ' - '
    @api userManagementAdditionalSearch;
    @api additionalInfoVisible = false;


    connectedCallback() {
        console.log('search mode',this.contactMode)
    }

    addDebounce = (fn, wait = 600) => {
        clearTimeout(this.timerId);
        this.timerId = setTimeout(fn, wait);
    }
    handleKeyChange(event) {
        this.searchKey = event.detail.value
        this.addDebounce(() => this.getRecords(event), 600)
    }

    handleOnInputChange(event) {
        this.searchKey = event.target.value;
        this.addDebounce(() => this.getRecords(event), 600)
    }

    handleSearchEscape() {
        //
        setTimeout(() => {
            this.showSearchResults = false;
        }, 1500)
    }

    handleSearchFocus() {
        this.getRecords()
        this.showSearchResults = true;
    }

    getRecords() {
        if (this.campaignScope === true && this.contactContactScope === true) {

            getCustomers({
                searchKey: this.searchKey,
                objectName: null,
                queryFilter: null,
                searchField: null,
                userId: null
            }).then(result => {
                this.recordsList = result
                this.dataHasLoaded = true;
            })
        } else if (this.campaignScope === true) {
            getCampaigns({
                searchKey: this.searchKey,
                objectName: this.queriedObjectType,
                queryFilter: this.queryFilter,
                searchField: this.searchField,
                userId: this.userId
            }).then(result => {
                this.recordsList = result;
                this.error = undefined;
                this.dataHasLoaded = true;
            })
        } else if (this.contactContactScope === true) {
            getAgents({
                searchKey: this.searchKey,
                objectName: this.queriedObjectType,
                queryFilter: this.queryFilter,
                searchField: this.searchField,
                userId: this.userId
            })

                .then((result) => {
                    this.recordsList = result;
                    this.recordsList.unshift({'Name': 'Not Applicable(Direct)', 'Id': 'Direct'})
                    this.message = "";
                    // }
                    this.error = undefined;
                    this.dataHasLoaded = true;
                }).catch((error) => {
                this.error = error;
                this.recordsList = undefined;
            });
        } else if (this.userScope === true) {
            getUsers({
                searchKey: this.searchKey,
                objectName: this.queriedObjectType,
                queryFilter: this.queryFilter,
                searchField: this.searchField,
                userId: this.userId
            })

                .then((result) => {
                    this.recordsList = result;
                    this.message = "";
                    // }
                    this.error = undefined;
                    this.dataHasLoaded = true;
                }).catch((error) => {
                this.error = error;
                this.recordsList = undefined;
            });
        } else if (this.accountMode === true) {
            getAccounts({
                accountScope:this.accountScope,
                searchKey:this.searchKey,
                parentId : this.userManagementAdditionalSearch
            })

                .then((result) => {
                    this.recordsList = result;
                    // console.log('scope',this.accountScope,' ',this.userManagementAdditionalSearch, ' - ',this.recordsList)
                    this.message = "";
                    this.dataHasLoaded = true;
                    // }
                    this.error = undefined;
                }).catch((error) => {
                this.error = error;
                this.recordsList = undefined;
            });
        }else {
            getSobjectRecords({
                searchKey: this.searchKey,
                objectName: this.queriedObjectType,
                queryFilter: this.queryFilter,
                searchField: this.searchField
            })

                .then((result) => {
                    if (result.length === 0) {
                        this.recordsList = [];
                        this.message = "No Records Found";
                    } else {
                        console.log('sRecords',result)
                        this.recordsList = result;
                        this.recordsList.map(re => re.Profile ? re.Profile : re.Profile = {Name:''});
                        console.log('sRecords2',result)
                        this.message = "";
                    }
                    this.error = undefined;
                    this.dataHasLoaded = true;
                }).catch((error) => {
                this.error = error;
                this.recordsList = undefined;
            });
        }
    }

    onRecordSelection(event) {
        this.queriedRecordId = event.target.dataset.key;
        this.selectedValue = event.target.dataset.name;
        this.searchKey = "";

        const selectedRecord = new CustomEvent('recordselected', {bubbles: true, detail: {id:this.queriedRecordId,name:event.target.dataset.name}});
        this.dispatchEvent(selectedRecord);

    }

    removeRecordOnLookup() {
        this.queriedRecordId = null;
        this.searchKey = "";
        this.selectedValue = '';
        const selectioncleared = new CustomEvent('selectioncleared', {bubbles: true});
        this.dispatchEvent(selectioncleared);
        this.getRecords()
    }

}