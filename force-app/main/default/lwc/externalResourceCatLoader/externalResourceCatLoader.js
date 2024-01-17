/**
 * Created by frans fourie on 2022/09/21.
 */

import {LightningElement, track, api} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import updateFileName from '@salesforce/apex/FileManagerContentVersionController.updateFileName';
import createContentVersion from '@salesforce/apex/FileManagerContentVersionController.createContentVersion';
import documentController from '@salesforce/apex/FileManagerContentVersionController.documentController';
import getGlobalPickList from '@salesforce/apex/FileManagerGetMDT.getGlobalPickList';
import {updateRecord} from "lightning/uiRecordApi";
import * as RecordIdService from 'c/recordIdService';

export default class ExternalResourceCatLoader extends LightningElement {

    @api opportunityScope = false;
    @api categories = [];
    @api testCategories = {};
    @track requestedDocsMutated = [];
    @track notRequestedReceivedDocs = [];
    @track showModal = false;
    @track fileNameOptionsDisabled;
    @track fileUploadDisabled;
    @track showProgressBar = false;
    @track progressBarPercentage;
    @api recordId;
    @api filesList = [];
    @api requestedDocs = [];
    @api receivedDocs = [];
    @api outstandingDocs = [];
    @api consentScope = false;
    fileName;
    blockId;
    fileSize;
    fileType;
    hasError = false;
    fileExtension;
    byteRange;
    blockIdList = [];
    chunkContent;
    contentTotalLength;
    uploadButtonDisabled = true;
    uploadIterationNumber = 0;
    uploadComplete = false;
    endByte = 0;
    blockIdVar100 = 0;
    blockIdVar10 = 0;
    blockIdVar1 = 0;
    fileContents;
    MAX_CHUNK_SIZE = 3000000;
    MAX_FILE_SIZE = 4000000;
    startByte = 0 - this.MAX_CHUNK_SIZE;
    @api refreshVar = false;
    @track categoryOptions = [];
    @track fileNameOptions = [];
    @api fileViewMode;
    @track buttonIcon = 'utility:opened_folder'
    addVar;
    selectedCategory;

    testEventFire(event) {
    }


    handleLightningUpload(event) {
        const fields = {};
        fields.Id = event.detail.files[0].contentVersionId;
        fields.Category__c = this.selectedCategory;
        fields.Title = this.fileName;
        // fields.FileClassification__c = 'Copy of ID';
        fields.Category__c = 'Personal Documents';
        const recordInput = {fields};
        updateRecord(recordInput).then(result => {
            console.log('updated', result)
            this.checkDocuments()
            this.refreshVar = !this.refreshVar
        }).catch(error => {
            console.log('error', error)
        })

    }

    handleUploadFinished(event) {

        const filesList = event.detail.files;
        this.filesCount = filesList.length;
        this.filesList = filesList;

        if (event.target.files.length > 0) {

            console.log('file size', event.target.files[0].length)
            if (event.target.files[0].length > this.MAX_FILE_SIZE) {
                this.showToast('File too large', '', 'error')
            } else {
                for (const element of event.target.files) {
                    let indexOfDot = element.name.lastIndexOf(',');
                    let fileExtension = element.name.substring(indexOfDot + 1);
                    // this.showToast('Consent Manager', 'Uploading...', 'warning')
                    this.consentFileUploaded = true
                    let file = element;
                    let reader = new FileReader();
                    reader.onload = () => {
                        let base64 = 'base64,';
                        let content = reader.result.indexOf(base64) + base64.length;
                        let fileContents = reader.result.substring(content);
                        console.log('file size again', fileContents.length)
                        if (fileContents.length > this.MAX_FILE_SIZE) {
                            this.showToast('File too large', '', 'error')
                            return;
                        }
                        createContentVersion({
                            base64: fileContents,
                            category: this.selectedCategory,
                            fileName: this.fileName,
                            relatedId: this.recordId,
                            fileExtension: fileExtension
                        }).then(result => {
                            // this.showToast('Consent Manager', 'File Uploaded', 'success')
                            this.checkDocuments()
                            this.refreshVar = !this.refreshVar

                        }).catch(error => {
                            this.showToast('Failed to upload file', error.message, 'error')
                        })
                    };
                    reader.readAsDataURL(file);
                }
            }
        }
    }

    customHandleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;

        for (const file of uploadedFiles) {

            updateFileName({
                contentVersionId: file.contentVersionId,
                category: this.selectedCategory,
                fileName: this.fileName

            }).then(() => {
                this.checkDocuments()
                this.refreshVar = !this.refreshVar
            })


        }
    }

    handleFileViewModeChange() {
        this.fileViewMode = !this.fileViewMode
        if (this.buttonIcon === 'utility:opened_folder') {
            this.buttonIcon = 'utility:list'
        } else {
            this.buttonIcon = 'utility:opened_folder'
        }
    }

    handleUploadFileButton() {
        this.fileUploadDisabled = true
        this.fileNameOptionsDisabled = true
        this.showModal = true
    }

    handleModalCancelClick() {
        // if (this.consentScope) {
        //     console.log('event fired 1')
        //     const filemodalclose = new CustomEvent('filemodalclose', {bubbles: true, detail: this.queriedRecordId});
        //     this.dispatchEvent(filemodalclose);
        //     console.log('event fired 2')
        // } else {
        this.showModal = false
        // }
    }

    progressBarUpdate() {

        if (this.contentTotalLength < this.MAX_CHUNK_SIZE) {
            this.progressBarPercentage = '50'
        } else {
            this.progressBarPercentage =
                95 / (this.contentTotalLength / this.MAX_CHUNK_SIZE) * this.uploadIterationNumber

        }
    }

    handleFilesChange(event) {
        this.fileUploadDisabled = true
        this.hasError = false
        this.progressBarPercentage = 0
        this.uploadIterationNumber = 0
        this.showProgressBar = true
        this.blockIdList = [];
        this.blockIdVar100 = 0;
        this.blockIdVar10 = 0;
        this.blockIdVar1 = 0;
        this.startByte = 0 - this.MAX_CHUNK_SIZE;
        this.uploadComplete = false
        if (event.target.files.length > 0) {
            for (const element of event.target.files) {
                this.fileSize = element.size
                let lastDot = element.name.lastIndexOf('.')
                this.fileExtension = element.name.substring(lastDot + 1)

                if (element.size > this.MAX_FILE_SIZE) {
                    this.showToast('File Manager', 'File too large', 'error')
                } else {

                    let file = element;
                    this.fileType = element.type
                    let reader = new FileReader();
                    reader.onload = () => {
                        let base64 = 'base64,';
                        let content = reader.result.indexOf(base64) + base64.length;
                        this.fileContents = reader.result.substring(content);
                        this.contentTotalLength = this.fileContents.length
                        this.handleContentChunkSize({}).then()

                    };
                    reader.readAsDataURL(file);


                }
            }
        }
        this.checkDocuments()

    }


    handleContentChunkSize() {
        this.blockId = 'A' + this.blockIdVar100 + this.blockIdVar10 + this.blockIdVar1

        if (this.uploadComplete === false) {

            this.startByte = this.startByte + this.MAX_CHUNK_SIZE
            this.endByte = this.startByte + this.MAX_CHUNK_SIZE

            if (this.endByte >= this.contentTotalLength) {
                this.endByte = this.contentTotalLength - 1
                this.uploadComplete = true
            }
            this.chunkContent = this.fileContents.substring(this.startByte, this.endByte)
            this.byteRange = 'bytes=' + this.startByte + '-' + this.endByte
            this.uploadIterationNumber++
            this.uploadBlock({blockId: this.blockId, complete: this.uploadComplete})
            this.blockIdVar1++
            if (this.blockIdVar1 > 9) {
                this.blockIdVar1 = 0
                this.blockIdVar10++
            }
            if (this.blockIdVar10 > 9) {
                this.blockIdVar10 = 0
                this.blockIdVar100++
            }

        } else {
            this.fileUploadDisabled = false
            this.refreshVar = !this.refreshVar
            if (this.hasError === false) {
                this.CreateExternalResource({
                    fileName: this.fileName,
                    fileSize: this.contentTotalLength,
                    container: RecordIdService.convertIdToLowerCase(this.recordId),
                    fileType: this.fileExtension,
                    recordId: this.recordId
                })
            }
            this.showProgressBar = false

            return true
        }
    }

    CreateExternalResource(erParams) {
        // CreateExternalResource(
        //     {
        //         fileName: erParams.fileName,
        //         fileSize: erParams.fileSize,
        //         fileType: erParams.fileType,
        //         container: erParams.container,
        //         recordId: erParams.recordId
        //     })
        //     .then(result => {
        this.checkDocuments()
        // })
    }

    uploadBlock(blockId) {
        this.progressBarUpdate()
        this.blockIdList.push(blockId.blockId.toString())
        PutBlockAzure({
            fileType: this.fileType,
            content: this.chunkContent,
            fileName: this.fileName,
            container: RecordIdService.convertIdToLowerCase(this.recordId),
            recordId: this.recordId,
            complete: blockId.complete,
            blockId: blockId.blockId.toString(),
            blockIdList: this.blockIdList
        }).then(result => {
            if (result === false) {
                this.showToast('File Manager', 'Failed to upload file, please try again in a few moments', 'error')
                this.hasError = true
                this.fileUploadDisabled = false
                this.showProgressBar = false
            } else {
                this.progressBarUpdate()
                this.handleContentChunkSize()
            }
        })
    }


    handleFileNameChange(event) {
        this.fileUploadDisabled = false
        this.fileName = event.detail.value
    }


    handleCategoryChange(event) {
        this.fileUploadDisabled = true;
        this.fileNameOptions = []
        this.selectedCategory = event.detail.value;

        this.fileNameList = this.categories.find(co => co.category === this.selectedCategory).fileName

        for (const element of this.fileNameList) {
            this.fileNameOptions.push({label: element, value: element})


        }

        // if (this.consentScope) {
        //     if (this.fileNameList.findIndex(fno => fno.label === 'Invoices') >= 0) {
        //         this.fileNameList.splice(this.fileNameList.findIndex(fno => fno.label === 'Invoices'), 1);
        //     }
        // }
        if (this.fileNameOptions.findIndex(fno => fno.label === 'Credit Report') >= 0) {
            if (!this.consentScope) {
                this.fileNameOptions.splice(this.fileNameOptions.findIndex(fno => fno.label === 'Credit Report'), 1);
            }
        }
        if (this.fileNameOptions.findIndex(fno => fno.label === 'Preapproval') >= 0) {
            this.fileNameOptions.splice(this.fileNameOptions.findIndex(fno => fno.label === 'Preapproval'), 1);
        }

        this.fileNameOptions.sort(function (a, b) {
            let x = a.value.toLowerCase();
            let y = b.value.toLowerCase();
            if (x < y) {
                return -1;
            }
            if (x > y) {
                return 1;
            }
            return a.value - b.value
        })
        this.fileNameOptionsDisabled = false

    }

    renderedCallback() {
        console.log('rendered run');
        this.checkDocuments();
    }

    checkDocuments() {
        documentController({loanApplicantId: this.recordId}).then(result => {
            if (result.Received_Documents__c && result.Received_Documents__c.length > 1) {
                this.receivedDocs = true ? result.Received_Documents__c.split(';') : '';
            }
            this.requestedDocs = result.Requested_Documents__c !== undefined || result?.Requested_Documents__c?.length > 2 ? result.Requested_Documents__c.split(';') : '';
            this.requestedDocsMutated = [];
            for (let i = 0; i < this.requestedDocs.length; i++) {
                this.requestedDocsMutated.push({name: this.requestedDocs[i], received: false})
            }
            for (let i = 0; i < this.requestedDocsMutated.length; i++) {
                for (let j = 0; j < this.receivedDocs.length; j++) {

                    if (this.receivedDocs[j] === this.requestedDocsMutated[i].name) {
                        this.requestedDocsMutated[i].received = true
                    }
                }

            }
            this.notRequestedReceivedDocs = [];
            this.addVar = true;
            for (let i = 0; i < this.receivedDocs.length; i++) {
                this.addVar = true;
                for (let j = 0; j < this.requestedDocs.length; j++) {

                    if (this.receivedDocs[i] === this.requestedDocs[j]) {
                        this.addVar = false;
                    }
                }
                if (this.addVar === true) {
                    this.notRequestedReceivedDocs.push({name: this.receivedDocs[i], received: true})
                }
            }
            if (this.requestedDocsMutated.length === 0) {
                this.requestedDocsMutated.push({name: '--None--', received: false})
            }
            if (this.notRequestedReceivedDocs.length === 0) {
                this.notRequestedReceivedDocs.push({name: '--None--', received: false})
            }
        }).catch(error => {
            console.log(error)
        })
    }

    connectedCallback() {

        this.fileViewMode = 'true'
        this.getMDT()
        if (this.opportunityScope === false) {
            this.checkDocuments()
        }
    }

    getMDT() {
        getGlobalPickList({
            objectName: 'ContentVersion',
            controllingField: 'Category__c',
            dependentField: 'FileClassification__c'
        }).then(result => {
            // this.categories = result
            this.categories = result
            for (const element of result) {

                this.categoryOptions.push({label: element.category, value: element.category})
            }
            if (this.consentScope) {
                // if (this.categoryOptions.findIndex(fno => fno.label === 'Invoices') >= 0) {
                this.categoryOptions.splice(this.categoryOptions.findIndex(fno => fno.label === 'Invoices'), 1);
                this.categoryOptions.splice(this.categoryOptions.findIndex(fno => fno.label === 'Bank Statements'), 1);
                this.categoryOptions.splice(this.categoryOptions.findIndex(fno => fno.label === 'Financial Documents'), 1);
                this.categoryOptions.splice(this.categoryOptions.findIndex(fno => fno.label === 'Payslips'), 1);
                this.categories.splice(this.categories.findIndex(fno => fno.category === 'Invoices'), 1);
                this.categories.splice(this.categories.findIndex(fno => fno.category === 'Bank Statements'), 1);
                this.categories.splice(this.categories.findIndex(fno => fno.category === 'Financial Documents'), 1);
                this.categories.splice(this.categories.findIndex(fno => fno.category === 'Payslips'), 1);
                // }
            }
            if (this.opportunityScope === true) {
                this.categories.splice(this.categories.findIndex(co => co.category === 'Bank Statements'), 1);
                this.categories.splice(this.categories.findIndex(co => co.category === 'Invoices'), 1);
                this.categories.splice(this.categories.findIndex(co => co.category === 'Credit Report'), 1);
                this.categories.splice(this.categories.findIndex(co => co.category === 'Financial Documents'), 1);
                this.categories.splice(this.categories.findIndex(co => co.category === 'Payslips'), 1);
                this.categories.splice(this.categories.findIndex(co => co.category === 'Personal Documents'), 1);
            } else {
                this.categories.splice(this.categories.findIndex(co => co.category === 'Pre-Approval'), 1);
                this.categories.splice(this.categories.findIndex(co => co.category === 'Offer To Purchase'), 1);
                // this.categories.splice(this.categories.findIndex(co => co.category === 'Credit Report'), 1);
            }

            this.categoryOptions.splice(this.categoryOptions.findIndex(co => co.label === 'Pre-Approval'), 1);
            // this.categoryOptions.splice(this.categoryOptions.findIndex(co => co.label === 'Credit Report'), 1);
            this.categoryOptions.splice(this.categoryOptions.findIndex(co => co.label === 'Offer To Purchase'), 1);
            this.uploadButtonDisabled = this.opportunityScope === true;

        })
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}