/**
 * Created by frans fourie on 2022/09/20.
 */

import {LightningElement, track, api} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import * as RecordIdService from 'c/recordIdService'
import DeleteExternalResource from '@salesforce/apex/ExternalResourceInterface.DeleteExternalResource';
import GetExternalResource from '@salesforce/apex/ExternalResourceInterface.GetExternalResource';
import getAllFiles from '@salesforce/apex/ExternalResourceInterface.getAllFiles';
import {NavigationMixin} from "lightning/navigation";

export default class ExternalResourceManager extends NavigationMixin(LightningElement) {
    @track fileAvailable;
    @track spinnerOn = false;

    @track fileClass = 'pointer';
    @api filesList = [];
    @api refreshVar;
    localRefreshVar = false;
    @track fileResult = [];
    @track categoryFiles = [];
    @track showFile = false;

    @api contentType;
    @api progressBarPercentage;
    @api fileName;
    @api recordId;
    @api category;
    @api reloadVar = false;
    @api categories;

    @api loading = false;

    @api fileViewMode;

    @api opportunityScope = false;
    fileExtension;
    working = false;
    // MAX_CHUNK_SIZE = 3000000;



    connectedCallback() {
        this.getAllFiles()
    }

    getAllFiles() {
        getAllFiles({
            recordId: this.recordId
        }).then(result => {

            this.categoryFiles = [];
            this.fileResult = result
            this.filesList = result
            for (const element of this.filesList) {
                for (const elementB of this.category.fileName) {
                    if (this.opportunityScope === true) {
                        if (element.Title.includes(elementB.substring(4,7)) || (element.Title.includes(elementB))) {
                            this.categoryFiles.push({
                                'name': element.Title,
                                'createdDate': 'Created - ' + element.createdDate,
                                'contentType': this.fileExtension,
                                'dataUrl': element.VersionDataUrl,
                                'date': element.CreatedDate,
                                'extension': element.FileExtension,
                                'size': (Math.round((element.ContentSize / 1000000) * 100) / 100) + 'MB',
                                'id': element.Id,
                                'documentId': element.ContentDocumentId,
                                'thumbUrl': '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB240BY180&versionId=' + element.Id
                            })
                        }
                    } else {
                        if (element.Title === elementB) {
                            this.categoryFiles.push({
                                'name': element.Title,
                                'createdDate': 'Created - ' + element.createdDate,
                                'contentType': this.fileExtension,
                                'dataUrl': element.VersionDataUrl,
                                'date': element.CreatedDate,
                                'extension': element.FileExtension,
                                'size': (Math.round((element.ContentSize / 1000000) * 100) / 100) + 'MB',
                                'id': element.Id,
                                'documentId': element.ContentDocumentId,
                                'thumbUrl': '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB240BY180&versionId=' + element.Id
                            })
                        }
                    }
                }
            }
            this.spinnerOn = false
            this.fileAvailable = this.categoryFiles.length !== 0;

        })
    }


    get dataHasChanged() {
        if (this.refreshVar !== this.localRefreshVar) {
            this.getAllFiles()
            this.localRefreshVar = this.refreshVar
        }
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

    handleModalCancelClick() {
        this.showFile = false
    }

}