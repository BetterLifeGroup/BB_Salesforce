/**
 * Created by frans fourie on 2023/11/21.
 */

import {LightningElement, api, track} from 'lwc';
import getOpportunity from '@salesforce/apex/OpportunityMergeController.getOpportunity'
import searchOpportunities from '@salesforce/apex/OpportunityMergeController.searchOpportunities'
import mergeOpps from '@salesforce/apex/OpportunityMergeController.mergeOpps'
import {FlowNavigationFinishEvent} from "lightning/flowSupport";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class OpportunityMerge extends LightningElement {


    @api recordId;

    @track mainOpportunity;

    @track searchScope = false;

    @track mainOppLoaded = false;

    @track applicantLimitReached = false;


    connectedCallback() {
        this.searchScope = true;
        getOpportunity({recordId: this.recordId}).then(mainOpp => {
            if (mainOpp.Loan_Applicants__r.length > 1) {
                this.applicantLimitReached = true;
            }
            this.mainOppLoaded = true;
            this.mainOpportunity = mainOpp;
            this.spinner = false;
        }).catch(error => {
            console.error('Error occurred retrieving main opportunity', error);
        })
    }

    handleMaxAppCloseClick() {
        this.handleNextClick();
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    @track isLoading = false;
    @track relatedOppsList;
    @track relatedNotLoaded = true;

    relatedOppSearch(event) {
        searchOpportunities({searchTerm: event.detail.value, excludedOppId: this.recordId}).then(relatedOpps => {
            this.relatedOppsList = relatedOpps
            for (let i = 0; i < this.relatedOppsList.length; i++) {
                this.relatedOppsList[i].selectedAsMaster = false;

            }
            this.isLoading = false;
        }).catch(error => {
            this.isLoading = false;
            console.error('Error retrieving related opportunities')
        })
    }

    addDebounce = (fn, wait = 600) => {
        clearTimeout(this.timerId);
        this.timerId = setTimeout(fn, wait);
    }

    handleOppSearchChange(event) {
        this.searchKey = event.detail.value
        this.addDebounce(() => this.relatedOppSearch(event), 600)
    }

    mouseOverCard(event) {

        let div = this.template.querySelector('[data-id="' + event.currentTarget.dataset.id + '"]');
        div.className = div.className.includes(' onMouseOver') ? div.className : div.className + ' onMouseOver';

    }

    mouseLeaveCard(event) {
        let div = this.template.querySelector('[data-id="' + event.currentTarget.dataset.id + '"]');
        div.className = div.className.replaceAll(' onMouseOver', '');
    }

    @track allowProceed = false;
    @track selectScope = false;
    @track slaveOppIsMaster = false;
    @track masterOppIsMaster = true;
    selectedOpportunityId;

    selectCard(event) {
        this.allowProceed = true;
        this.selectedOpportunityId = event.currentTarget.dataset.id;
        console.warn('selected Opp Id', this.selectedOpportunityId)
        let slaveIsMaster = false;
        for (let i = 0; i < this.relatedOppsList.length; i++) {
            if (this.relatedOppsList[i].selectedAsMaster === true) {
                slaveIsMaster = true;
            }
        }
        if (slaveIsMaster) {
            for (let i = 0; i < this.relatedOppsList.length; i++) {
                this.relatedOppsList[i].selectedAsMaster = this.relatedOppsList[i].Id === event.currentTarget.dataset.id;
            }
        }
        this.template.querySelectorAll("[data-field='card']").forEach(ad => {
            ad.className = 'card';
        });
        let div = this.template.querySelector('[data-id="' + event.currentTarget.dataset.id + '"]');
        div.className = 'card selected'
        this.enableNext();
    }

    @track spinner = true;

    clickedCombine() {
        this.spinner = true;
        this.searchScope = false;
        this.selectScope = true;
        let master = this.recordId;
        let slave = this.selectedOpportunityId;
        if (this.slaveOppIsMaster) {
            slave = this.recordId;
            master = this.selectedOpportunityId;
        }

        mergeOpps({masterOpp: master, slaveOpp: slave}).then(result => {
            this.spinner = false;
            if (result) {
                this.showToast('Merged successfully', 'Merged successfully', 'success')
            } else {
                this.showToast('Merge failed', 'Merge failed', 'error')
            }
            this.handleNextClick();
        }).catch(error => {
            this.showToast('Merge failed', 'Merge failed', 'error')
            console.error('error occurred merging - ', error)
            this.spinner = false;

        })
    }

    handleSlaveIsMaster(event) {
        this.relatedNotLoaded = false;
        for (let i = 0; i < this.relatedOppsList.length; i++) {
            this.relatedOppsList[i].selectedAsMaster = !(this.relatedOppsList[i].Id !== event.currentTarget.dataset.id);
        }
        this.masterOppIsMaster = false;
        this.slaveOppIsMaster = true;
    }

    handleMasterIsMaster() {
        for (let i = 0; i < this.relatedOppsList?.length; i++) {
            this.relatedOppsList[i].selectedAsMaster = false;

        }
        this.masterOppIsMaster = true;
        this.slaveOppIsMaster = false;
    }

    enableNext() {
        this.nextDisabled = this.selectedOpportunityId.length > 2;
    }

    @track nextDisabled = true;

    handleNextClick() {
        const navigateFinishEvent = new FlowNavigationFinishEvent()
        this.dispatchEvent(navigateFinishEvent);

    }
}