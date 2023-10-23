/**
 * Created by frans fourie on 2023/10/03.
 */

import {LightningElement, track, api} from 'lwc';
import UserAvailable from '@salesforce/apex/ConsultantAvailabilityController.userAvailable'
import futureUnavailabilities from '@salesforce/apex/ConsultantAvailabilityController.futureUnavailabilities'
import MarkUserAvailable from '@salesforce/apex/ConsultantAvailabilityController.MarkUserAvailable'
import CreateConsultantAvailability
    from '@salesforce/apex/ConsultantAvailabilityController.CreateConsultantAvailability'
import MarkUserUnavailable from '@salesforce/apex/ConsultantAvailabilityController.MarkUserUnavailable'
import DeleteFutureAvailabilityRecord
    from '@salesforce/apex/ConsultantAvailabilityController.DeleteFutureAvailabilityRecord'
export default class ConsultantsAvailable extends LightningElement {

    @api userId;
    @api userName;

    @track unavailableButtonEnabled = false;
    @track availableButtonEnabled = false;
    @track unavailabilityRecordExists = false;
    @track showSpinner = false;
    @track userUnavailableMessage;

    reason;
    futureDate;

    get unavailableOptions() {
        return [
            {label: 'Admin Time', value: 'Admin Time'},
            {label: 'Annual Leave', value: 'Annual Leave'},
            {label: 'Lunch', value: 'Lunch'},
            {label: 'Meeting/Training', value: 'Meeting/Training'},
            {label: 'Sick Leave', value: 'Sick Leave'},
            {label: 'Travelling', value: 'Travelling'},
        ]
    }

    userUpdated() {
        this.showSpinner = false;
        const userupdated = new CustomEvent('userupdated', {
            bubbles: true,
        })
        this.dispatchEvent(userupdated);
    }

    handleMarkAvailable() {
        this.showSpinner = true;
        this.availableButtonEnabled = false;
        this.unavailableButtonEnabled = false;
        MarkUserAvailable({userId: this.userId}).then(result => {
            this.userUpdated()
        })
    }

    handlePlannedUnavailability() {
        if (this.reason === undefined || this.futureDate === undefined) {
            alert('Please select a reason and future date before continuing')
        } else {
            this.showSpinner = true;
            CreateConsultantAvailability({
                userId: this.userId,
                reason: this.reason,
                futureEntry: true,
                futureDate: this.futureDate
            }).then(result => {
                this.userUpdated()
            })
        }
    }

    handleDeleteFutureUnavailability() {
        this.showSpinner = true;
        DeleteFutureAvailabilityRecord({userId: this.userId}).then(result => {
            this.userUpdated();
        })
    }

    handleDateChange(event) {
        this.futureDate = event.detail.value;
        console.log('futuredate', this.futureDate)
    }

    handleMarkUnavailableNow() {

        console.log('reason', this.reason)
        if (this.reason === undefined) {
            alert('Please select a reason before continuing')
        } else {
            this.showSpinner = true;
            CreateConsultantAvailability({
                userId: this.userId,
                reason: this.reason,
                futureEntry: false,
                futureDate: null
            }).then(result => {
                MarkUserUnavailable({userId: this.userId}).then(result => {
                    this.userUpdated()
                })
            })
        }
    }


    handleReasonChange(event) {
        this.reason = event.detail.value;
    }

    handleNowReasonChange(event) {
        this.reason = event.detail.value;
    }

    connectedCallback() {
        this.userName = 'Manage Availability for ' + this.userName;
        UserAvailable({userId: this.userId}).then(result => {
            this.availableButtonEnabled = result === false;
            this.unavailableButtonEnabled = result === true;
        })
        futureUnavailabilities({userId: this.userId}).then(result => {
            console.log('future',result)
            if (result !== 'No Record Found') {
                this.userUnavailableMessage = 'User will be marked as unavailable at ' + result;
                this.unavailabilityRecordExists = true;
            }
        })
    }
}