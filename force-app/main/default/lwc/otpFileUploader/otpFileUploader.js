/**
 * Created by frans fourie on 2023/05/16.
 */

import {LightningElement, track, api, wire} from 'lwc';
import {updateRecord} from "lightning/uiRecordApi";
import {FlowNavigationNextEvent} from "lightning/flowSupport";
import getAllFiles from '@salesforce/apex/ExternalResourceInterface.getAllFiles'
import deleteFile from '@salesforce/apex/ExternalResourceInterface.deleteFile'
import {NavigationMixin} from "lightning/navigation";


export default class OtpFileUploader extends NavigationMixin(LightningElement) {

    @api label;
    @api opportunityId
    @api uploadedSuccess;
    @api recordId;
    @api viewOnly = false;


    @track fileName;
    @track uploadedFiles = [];
    @track showNextButton = false;
    @track showUploadedFiles = false;
    @track showUploader = true;
    @track showRefresh = true;

    contentDocumentId;

    handleRefresh() {
        this.fileName = null;
        this.showRefresh = false;
        this.showNextButton = false;
        this.uploadedSuccess = false;
        this.connectedCallback()
    }

    connectedCallback() {
        this.uploadedFiles = [];
        getAllFiles({recordId: this.opportunityId}).then(result => {
            // console.log('the files', result)
            this.uploadedFiles = result;
            this.uploadedFiles = this.uploadedFiles.filter(uf => !uf.Title.includes('Preapproval'))
            if (this.uploadedFiles.length > 0) {
                this.showNextButton = true;
                this.uploadedFiles.map(uf => uf.thumbUrl = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB240BY180&versionId=' + uf.Id);
                this.showUploadedFiles = true;
                this.showRefresh = true;
            } else {
                this.showUploadedFiles = false;
                this.showNextButton = false;
            }
        })
    }

    handleFileNameClick(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: event.target.dataset.id
            }
        })
    }


    handleFileNameClickViewOnly(event) {

        this[NavigationMixin.GenerateUrl]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: event.target.dataset.id
            }
        }).then(result => {
            window.open(result, "_blank");
        })
    }

    handleUploadFinished(event) {

        this.showUploader = false;
        this.fileName = event.detail.files[0].name;
        let date = new Date();
        const fields = {};
        fields.Id = event.detail.files[0].contentVersionId;
        fields.Title = 'Offer To Purchase - ' + date.getFullYear() + "-" + (((date.getMonth() + 1) < 10) ? "0" : "") + (date.getMonth() + 1) + "-" + ((date.getDate() < 10) ? "0" : "") + date.getDate() + ' ' + ((date.getHours() < 10) ? "0" : "") + date.getHours() + ":" + ((date.getMinutes() < 10) ? "0" : "") + date.getMinutes() + ":" + ((date.getSeconds() < 10) ? "0" : "") + date.getSeconds();
        const recordInput = {fields};
        updateRecord(recordInput).then(result => {
            this.uploadedSuccess = true;
            this.showUploader = true;
            this.showNextButton = true;
            this.connectedCallback();
        }).catch(error => {
            console.log('error', error)
        })

    }

    handleNextClick() {

        const navigateNextEvent = new FlowNavigationNextEvent()
        this.dispatchEvent(navigateNextEvent);
    }

    handleFileDelete(event) {
        this.uploadedSuccess = false;
        this.showUploader = false;
        this.contentDocumentId = event.target.dataset.id
        deleteFile({contentDocumentId: this.contentDocumentId}).then(result => {
            console.log(result)
            this.showUploader = true;
            this.connectedCallback()
        })
    }

}