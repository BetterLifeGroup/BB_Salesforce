/**
 * Created by Danielle Benade on 2023/07/25.
 */

import {LightningElement, wire, track, api} from 'lwc';
import {getObjectInfo, getPicklistValues} from 'lightning/uiObjectInfoApi';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import STAGE_FIELD from '@salesforce/schema/Opportunity.StageName';
import STATUS_FIELD from '@salesforce/schema/Opportunity.Status__c';

export default class flowFilteredDependantPicklist extends LightningElement {
    @api excludedValues = '';
    listOfExcludedValues = [];

    @api selectedStage = 'Closed Won';
    @api selectedStatus = '';

    @track stageOptions = [];
    @track statusOptions = [];
    @track loading = true;

    // Wire the object info and stage picklist values
    @wire(getObjectInfo, {objectApiName: OPPORTUNITY_OBJECT})
    objectInfo;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: STAGE_FIELD})
    stagePicklistValues({data}) {
        if (data) {
            this.stageOptions = data.values.map((item) => ({label: item.label, value: item.value}));
            this.loading = false;
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: STATUS_FIELD,
        controllingFieldApiName: STAGE_FIELD.fieldApiName,
        controllingFieldValue: '$selectedStage'
    })
    wiredStatusOptions({data}) {
        this.listOfExcludedValues = this.excludedValues.split(';');
        if (data) {
            const filteredOptions = data.values.filter((option) => {
                // Filter out "PA Issued" status and statuses that are not related to the selected stage
                return option.validFor.includes(this.stageOptions.findIndex((stage) => stage.value.toLowerCase() === this.selectedStage.toLowerCase()));
            });

            this.statusOptions = filteredOptions.map((item) => ({label: item.label, value: item.value}));

            for (let i = 0; i < this.listOfExcludedValues.length; i++) {
                let index = this.statusOptions.findIndex(so => so.value.toLowerCase() === this.listOfExcludedValues[i].toLowerCase());

                if (index >= 0) {
                    this.statusOptions.splice(index, 1)
                }
            }
            this.loading = false;
        }
    }

    connectedCallback() {
        const statusOptions = this.template.querySelector('.status-select');

        // Add an event listener to update the selectedStatus variable when the status selection changes
        if (statusOptions) {
            statusOptions.addEventListener('change', (event) => {
                this.selectedStatus = event.target.value;
                console.log(this.selectedStatus, 'the selected status');
            });
        }
    }

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
        console.log(this.selectedStatus, 'the selected status');
    }
}