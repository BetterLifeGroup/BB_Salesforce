import {LightningElement, api, track} from 'lwc';
import getSobjectRecords from '@salesforce/apex/lwcLookupController.getSobjectRecords';
import getSobjectRecordsAgents from '@salesforce/apex/lwcLookupController.getSobjectRecordsAgents';
import getAgents from '@salesforce/apex/lwcLookupController.getAgents';
import getCampaigns from '@salesforce/apex/lwcLookupController.getCampaigns';
import getCustomers from '@salesforce/apex/lwcLookupController.getCustomers';
import getAllRegionSuburbs from '@salesforce/apex/lwcLookupController.getAllRegionSuburbs';
import getUsers from '@salesforce/apex/lwcLookupController.getUsers';


export default class recordSearch extends LightningElement {

    static delegatesFocus = true;


    @track recordsList = [];
    @api queriedRecordId;
    @api searchField;
    @api queriedObjectType;
    @api queryFilter;
    @api contactMode = false;
    @api paddingBottom = false;
    @api userScope;
    @api label = '';
    @api searchKey = '';
    @api selectedValue = '';
    @track showSearchResults = false;
    @track iconName = 'standard:record_lookup'
    @api contactContactScope = false;
    @api campaignScope = false;
    @api suburbScope = false;
    @api agentMode = false;
    @api userId;
    @track space = ' - ';
    @api paddingControl = 'padding-bottom: 1px';

    // @track message = '';

    @track constantTrue = true;


    connectedCallback() {
        console.log(this.campaignScope && !this.contactContactScope)
        if(this.campaignScope && !this.contactContactScope){
            this.getRecords();
            this.showSearchResults = true;
            console.log('this fired')
        }
    }

    addDebounce = (fn, wait = 300) => {
        clearTimeout(this.timerId);
        this.timerId = setTimeout(fn, wait);
    }

    handleKeyChange(event) {
        this.showSearchResults = true;
        this.searchKey = event.detail.value
        this.addDebounce(() => this.getRecords(event), 600)
    }

    handleSearchEscape() {
        console.log('escape fired')
        //
        setTimeout(() => {
            console.log('escape executed')
            this.showSearchResults = false;
        }, 1200)
    }

    handleSearchFocus(event) {

        if (this.searchKey.length > 0) {
            this.getRecords()
            this.showSearchResults = true;
        }
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
            }).catch(error => {
                this.error = error;
                this.recordsList = undefined;
                this.message = 'No Records Found'
            })
        } else if (this.contactContactScope === true) {
            getAgents({
                searchKey: this.searchKey,
                objectName: this.queriedObjectType,
                queryFilter: this.queryFilter,
                searchField: this.searchField,
                userId: this.userId
            }).then((result) => {
                this.recordsList = [...result];
                this.recordsList.unshift({'Name': 'Not Applicable(Direct)', 'Id': 'Direct'})
                this.message = "";
                // }
                this.error = undefined;
            }).catch((error) => {
                this.error = error;
                this.recordsList = undefined;
                this.message = 'No Records Found'
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
                }).catch((error) => {
                this.error = error;
                this.recordsList = undefined;
                this.message = 'No Records Found'
            });
        } else if (this.suburbScope === true) {
            getAllRegionSuburbs({
                searchKey: this.searchKey,
            })

                .then((result) => {
                    this.recordsList = result;
                    this.recordsList.map(re => re.Name = re.Suburb__c + ', ' + re.City__c + ', ' + re.Province__c)
                    this.message = "";
                    // }
                    this.error = undefined;
                }).catch((error) => {
                this.error = error;
                this.recordsList = undefined;
            });
        } else if (this.agentMode === true) {
            getSobjectRecordsAgents({
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
                        this.recordsList = result;
                        this.message = "";
                    }
                    this.recordsList.map(rl => rl.accountExists = rl.Account !== undefined)
                    this.error = undefined;
                }).catch((error) => {
                this.error = error;
                this.recordsList = undefined;
            });
        } else {
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
                        this.recordsList = result;
                        this.message = "";
                    }
                    this.error = undefined;
                }).catch((error) => {
                this.error = error;
                this.recordsList = undefined;
            });
        }
    }


    onRecordSelection(event) {

        this.queriedRecordId = event.currentTarget.dataset.key;
        this.selectedValue = event.currentTarget.dataset.name;

        // this.searchKey = "";
        const selectedRecord = new CustomEvent('recordselected', {bubbles: true, detail: this.queriedRecordId});
        this.dispatchEvent(selectedRecord);
        setTimeout(() => {
            const selectedRecordName = new CustomEvent('recordselectedname', {
                bubbles: true,
                detail: this.selectedValue
            });
            this.dispatchEvent(selectedRecordName);
        }, 500)
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