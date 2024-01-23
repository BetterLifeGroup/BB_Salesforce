/**
 * Created by fkleynhans on 2022/09/15.
 */

import {LightningElement, api, wire, track} from 'lwc';
import callConsents from "@salesforce/apex/SRVCNTGetConsentsPersonId_Controller.getPersonConsents";
import updateConsents from "@salesforce/apex/SRVCNTGetConsentsPersonId_Controller.updateConsents";
import uploadConsentsFile from "@salesforce/apex/SRVCNTGetConsentsPersonId_Controller.uploadConsentsFile";
import updateConsentRequirements from '@salesforce/apex/SRVCNTGetConsentsPersonId_Controller.setConsentRequirementsMet'
import getLoanApplicant from '@salesforce/apex/SRVCNTGetConsentsPersonId_Controller.getLoanApplicant'
import createContentVersion from '@salesforce/apex/FileManagerContentVersionController.createContentVersion'
import {FlowNavigationNextEvent} from "lightning/flowSupport";
import telephonicConsentScript from '@salesforce/label/c.TelephonicConsentScript';
import setOpportunityStatus
    from '@salesforce/apex/SRVCRDIdvController.setOpportunityStatus';
import setLoanApplicantStatus
    from '@salesforce/apex/SRVCRDIdvController.setLoanApplicantStatus';
import manualConsentPending from '@salesforce/apex/SRVCRDIdvController.manualConsentPending';
import {updateRecord} from "lightning/uiRecordApi";
import updateLoanApplicant from '@salesforce/apex/SRVCRDIdvController.updateLoanApplicant';
import biometricUpdates from '@salesforce/apex/SRVCRDIdvController.biometricUpdates';
import closeOppBiometricLowXdsScore from '@salesforce/apex/SRVCRDIdvController.closeOppBiometricLowXdsScore';
import documentCheck from '@salesforce/apex/SRVCRDIdvController.documentCheck';
import * as idVerify from 'c/saIdVerify'

export default class ConsentViewer extends LightningElement {
    isLoaded = false;
    loanApplicantId;
    consentFileUploaded = false;
    idFileUploaded = false;
    @track manualConsent = false;
    @track telephonicConsent = false;
    @track typeOfConsent = false;
    consentsList = {};
    updatesList = [];
    @api scopes = [];
    @api exitFlow = false;
    @api exitToFlow = false;
    @api personId;
    @api consentRefused = false;
    @track label;
    @track iconName = 'utility:close';
    @track showIdFileName = false;
    @track showHtmlErrorToast = false;
    @track showHtmlSuccessToast = false;
    @track showHtmlWarningToast = false;
    @track biometricsSelected = false;
    @track allowUpdate = false;
    @track creditReportUploaded = false;
    @track idValid = false;
    @track idFileName;
    @track toastMessage;
    @track loanApplicantName;
    @track completeConsentsWarningVisible = false;
    @api recordId;
    @api consentsIncomplete;
    success;
    @track error;
    MAX_FILE_SIZE = 3800000;
    fileName;
    xdsScore;
    idNumber;
    filesCount = 0;
    filesList = [];
    @track constantTrue = true;

    @wire(callConsents, {personId: '$personId', scopes: '$scopes'})
    wiredResult(value) {
        if (value.error) {
            this.error = value?.error?.body?.message;
            this.showToast('Unable to load consents from domain', 'Unable to load consents from domain', 'warning')
        } else if (value.data) {
            console.log('consent list', value.data)
            // this.consentsList = [...value.data];
            this.consentsList = JSON.parse(JSON.stringify(value.data));
            console.log('consents list', JSON.parse(JSON.stringify(this.consentsList)))
            this.consentsList = this.consentsList.filter(cl => {
                return cl.consentTypeSnapshot.name === 'Broad consent BB'
            })
            this.consentsList = this.consentsList.sort(function (a, b) {
                let x = a.consentTypeSnapshot.description.toLowerCase();
                let y = b.consentTypeSnapshot.description.toLowerCase();
                if (x < y) {
                    return -1;
                }
                if (x > y) {
                    return 1;
                }
                return a.value - b.value
            });

            for (let i = 0; i < this.consentsList.length; i++) {
                this.consentsList[i].consentTypeSnapshot.declaration = this.consentsList[i].consentTypeSnapshot.declaration.replaceAll('${MOBusinessGroup}', 'Betterbond');
            }

            for (let i = 0; i < this.consentsList.length; i++) {
                this.updatesList.push(this.consentsList[i]);
            }
            this.getApplicantDetail();
        }
    }

    handleTelephonicClick() {
        this.completeConsentsWarningVisible = false
        this.typeOfConsent = false
        this.telephonicConsent = true
    }


    handleManualClick() {
        this.completeConsentsWarningVisible = false
        this.typeOfConsent = false
        this.manualConsent = true
    }


    validate() {
        console.log('bio selected', this.biometricsSelected)
        setTimeout(() => {
            this.allowUpdate = (this.biometricsSelected ? this.creditReportUploaded && this.idValid && this.xdsScore?.length > 0 : true) && this.idFileUploaded && this.consentFileUploaded;
        }, 10)

    }

    renderedCallback() {
        this.validate();
    }

    handleConfirmBiometricsClick() {

        this.updatesList = [];

        this.isLoaded = false
        if (this.consentsList !== null) {


            for (let i = 0; i < this.consentsList.length; i++) {

                let localConsentList = [...this.consentsList];
                localConsentList[i] = {
                    ...this.consentsList[i],
                    granted: true,
                    fileName: this.fileName,
                    notSet: false
                };

                this.consentsList = localConsentList;
                this.updatesList.push(this.consentsList[i]);
            }
            this.consentsList = this.updatesList;
        }
        this.isLoaded = true;
        this.biometricsSelected = true;
        this.handleManualClick()
    }

    handleIdNumberChange(event) {
        let field = this.template.querySelector("[data-field='idNumber']");
        this.idValid = event.detail.value?.length > 5 ? idVerify.validateIdNumber(event.detail.value).valid : false;
        if (this.idValid) {
            field.validity = {valid: true};
            field.setCustomValidity("");
        } else {
            field.validity = {valid: false};
            field.setCustomValidity("Invalid input");
        }
        this.idNumber = event.detail.value;
        this.validate();
    }

    handleXdsScoreChange(event) {
        this.xdsScore = event.detail.value;
        this.validate();
    }

    handleCreditReportUpload(event) {
        const fields = {};

        fields.Id = event.detail.files[0].contentVersionId;
        fields.Title = 'Credit Report';
        fields.FileClassification__c = 'Credit Report';
        fields.Category__c = 'Credit Report';


        const recordInput = {fields};
        updateRecord(recordInput)
            .then(result => {
                this.creditReportUploaded = true
                this.validate()
            })
    }

    get options() {
        return [
            {label: 'Yes', value: 'true'},
            {label: 'No', value: 'false'},
        ];
    }

    connectedCallback() {
        this.label = {telephonicConsentScript,};
        this.allowUpdate = false;
        documentCheck({loanApplicantId: this.recordId}).then(result => {
            this.consentFileUploaded = false;
            this.idFileUploaded = false;
            this.creditReportUploaded = false
            if (result.includes('Consent Document')) {
                this.consentFileUploaded = true;
            }
            if (result.includes('Credit Report')) {
                this.creditReportUploaded = true;
            }
            if (result.includes('Copy of ID')) {
                this.idFileUploaded = true;
            }
            this.validate();
        }).catch(error => {
            console.log('error checking uploaded documents', error)
        })
    }


    getApplicantDetail() {


        manualConsentPending({loanApplicantId: this.recordId}).then(result => {
            if (result === true) {
                this.completeConsentsWarningVisible = false
                this.typeOfConsent = false
                this.manualConsent = true
                this.isLoaded = true

            } else {
                getLoanApplicant({loanApplicantId: this.recordId}).then(result => {
                    this.loanApplicantName = 'Please select type of consent for ' + (result.Name_Title__c ? result.Name_Title__c : '') + ' ' + result.Name;
                    this.isLoaded = true
                    this.loanApplicantId = result.Id;
                    this.typeOfConsent = true;

                }).catch((error) => {
                    this.showToast(error, error, 'warning')
                })
            }
        })

        updateConsentRequirements({personId: this.personId, consentRequirementsMet: false}).then(result => {

        }).catch((error) => {
            this.showToast(error, error, 'warning')
        })
    }

    handleCloseCheck() {

        this.showToast('Consent Required To Continue', 'Please select type of consent to continue', 'error');
        this.telephonicConsent = false
        this.manualConsent = false
        this.biometricsSelected = false;
        this.typeOfConsent = true
    }

    handleAllConsentsUpdate() {

        this.updatesList = [];
        this.isLoaded = false

        if (this.consentsList !== null) {
            for (let i = 0; i < this.consentsList.length; i++) {

                let localConsentList = [...this.consentsList];
                localConsentList[i] = {
                    ...this.consentsList[i],
                    granted: true,
                    fileName: this.fileName
                };
                this.consentsList = localConsentList;
                this.updatesList.push(this.consentsList[i]);
            }
            this.handleUpdate()
        }
    }

    handleModalCancelClick() {
        this.showToast('Consent Required To Continue', 'Please select type of consent to continue', 'error');
        this.telephonicConsent = false
        this.manualConsent = false
        this.typeOfConsent = true
    }

    handleDoNotAgree() {
        this.exitFlow = true;
        this.consentRefused = true;
        setOpportunityStatus({
            loanApplicantId: this.recordId,
            status: 'No PA consent received',
            stageName: 'Closed Lost',
            wrapUpReason: 'Automated'
        }).then(result => {
            setLoanApplicantStatus({loanApplicantId: this.recordId, status: 'Consent Refused'}).then(result => {
                const navigateNextEvent = new FlowNavigationNextEvent()
                this.dispatchEvent(navigateNextEvent);
            })

        }).catch((error) => {
            this.showToast(error, error, 'warning')
        })
    }

    handleExitToFlow() {
        this.exitToFlow = true;
        this.telephonicConsent = false
        this.manualConsent = false
        this.typeOfConsent = false
        this.consentRefused = false;
        const navigateNextEvent = new FlowNavigationNextEvent()
        this.dispatchEvent(navigateNextEvent);
    }

    handleChange(event) {
        const eventIndex = event.target.dataset.index;
        let localConsentList = [...this.consentsList];
        let booleanValue = event.detail.value === "true";
        if (this.consentsList[eventIndex].required != event.detail.value) {
            if (this.consentsList[eventIndex].required === "true") {
                this.showToast('Consent Manager', 'Consent is required to continue', 'warning');
            }
        }
        localConsentList[eventIndex] = {
            ...this.consentsList[eventIndex],
            granted: booleanValue,
            fileName: this.fileName
        };
        this.consentsList = localConsentList;
        if (this.updatesList.findIndex(ul => ul.consentTypeId === this.consentsList[eventIndex].consentTypeId) !== -1) {
            this.updatesList.splice(this.updatesList.findIndex(ul => ul.consentTypeId === this.consentsList[eventIndex].consentTypeId), 1)
        }
        this.updatesList.push(this.consentsList[eventIndex]);
    }

    handleUpdate() {
        this.validate();
        if (this.allowUpdate) {
            this.allowUpdate = false;
            this.isLoaded = false;
            if (this.consentFileUploaded === false && this.manualConsent === true) {
                this.showToast('Consent Manager', 'Consent document required to continue', 'error');
            } else if (this.idFileUploaded === false && this.manualConsent === true) {
                this.showToast('Consent Manager', 'Identification document required to continue', 'error');
            } else {
                let canContinue = true;
                for (const consentKey in this.consentsList) {

                    if (typeof this.consentsList[consentKey].granted === 'undefined') {
                        // Check if it is required
                        if (typeof this.consentsList[consentKey].required === 'undefined') {
                            continue;
                        } else {
                            canContinue = false;
                            continue;
                        }
                    } else if (this.consentsList[consentKey].required === this.consentsList[consentKey].granted.toString()) {
                        continue;
                    }
                    if (this.consentsList[consentKey].required === 'false' && this.consentsList[consentKey].granted.toString() === 'true') {
                        continue;
                    } else if (typeof this.consentsList[consentKey].required === 'undefined') {
                        continue;
                    } else if (typeof this.consentsList[consentKey].required === 'string') {
                        canContinue = false;
                        continue;
                    }
                }

                if (canContinue) {
                } else {
                    this.completeConsentsWarningVisible = true
                    this.manualConsent = false
                    this.telephonicConsent = false
                    this.typeOfConsent = true
                    this.showToast('Consent Manager', 'Consent requirements not met', 'error')
                    return
                }
                if (this.manualConsent === true && canContinue) {
                    updateConsentRequirements({
                        personId: this.personId,
                        consentRequirementsMet: canContinue,
                        applicantId: this.recordId
                    }).then(result => {
                        if (this.biometricsSelected) {
                            updateLoanApplicant({
                                loanApplicantId: this.recordId,
                                idNumber: this.idNumber,
                                idType: 'SID',
                                passportNumber: ''
                            }).then(result => {
                                if (this.xdsScore > 678) {
                                    biometricUpdates({
                                        loanApplicantId: this.recordId,
                                        xdsScore: this.xdsScore
                                    }).then(result => {
                                        console.log('bio update', result)
                                        const navigateNextEvent = new FlowNavigationNextEvent()
                                        this.dispatchEvent(navigateNextEvent);
                                    })
                                } else {
                                    closeOppBiometricLowXdsScore({
                                        applicantId: this.recordId,
                                        xdsScore: this.xdsScore
                                    }).then(result => {
                                        const navigateNextEvent = new FlowNavigationNextEvent()
                                        this.dispatchEvent(navigateNextEvent);
                                        console.log('opp closed, or if coapp, only coapp updated', result)
                                    })
                                }
                            }).catch(error => {
                                console.log('error updating', error)
                            })
                        } else {
                            const navigateNextEvent = new FlowNavigationNextEvent()
                            this.dispatchEvent(navigateNextEvent);
                        }
                    }).catch((error) => {
                        this.showToast(error, error, 'warning')
                    })
                }
                if (this.updatesList.length > 0 && this.manualConsent === true) {
                    updateConsents({personId: this.personId, consentReqList: this.updatesList})
                        .then((result) => {
                            this.success = result;
                            this.error = undefined;
                        })
                        .catch((error) => {
                            this.error = error;
                            this.success = undefined;
                            this.isLoaded = true;
                        });
                } else if (this.updatesList.length > 0) {
                    updateConsents({personId: this.personId, consentReqList: this.updatesList})
                        .then((result) => {

                            this.success = result;
                            this.error = undefined;
                            updateConsentRequirements({
                                personId: this.personId,
                                consentRequirementsMet: canContinue,
                                applicantId: null
                            }).then(result => {
                                const navigateNextEvent = new FlowNavigationNextEvent()
                                this.dispatchEvent(navigateNextEvent);
                                // })
                            })
                        })
                        .catch((error) => {
                            this.error = error;
                            this.success = undefined;
                            this.isLoaded = true;
                        });
                } else {
                    const navigateNextEvent = new FlowNavigationNextEvent()
                    this.dispatchEvent(navigateNextEvent);
                }
            }
        } else {
            this.allowUpdate = false;
            this.connectedCallback();
        }
    }

    get acceptedFormats() {
        return ['.pdf', '.png'];
    }

    handleConsentFilesChange(event) {
        const filesList = event.detail.files;
        this.filesCount = filesList.length;
        this.filesList = filesList;

        if (event.target.files.length > 0) {

            for (const element of event.target.files) {
                if (element.size > this.MAX_FILE_SIZE) {
                    this.showToast('Consent Manager', 'File too large', 'error')
                } else {
                    let indexOfDot = element.name.lastIndexOf(',');
                    let fileExtension = element.name.substring(indexOfDot + 1);
                    this.showToast('Consent Manager', 'Uploading...', 'warning')
                    // this.consentFileUploaded = true
                    let file = element;
                    let reader = new FileReader();
                    reader.onload = () => {
                        let base64 = 'base64,';
                        let content = reader.result.indexOf(base64) + base64.length;
                        let fileContents = reader.result.substring(content);
                        uploadConsentsFile({
                            fileName: file.name,
                            fileContents: fileContents
                        }).then(result => {
                            this.consentFileUploaded = true
                            this.validate();
                            this.fileName = result;
                            createContentVersion({
                                relatedId: this.recordId,
                                base64: fileContents,
                                category: 'Personal Documents',
                                fileName: 'Consent Document',
                                fileExtension: fileExtension
                            }).then(result => {

                            })

                        })
                            .catch((error) => {
                                this.showToast('Consent Manager', 'Failed to upload file to domain.', 'error')
                                // this.error = error;
                                this.success = undefined;
                                //this.isLoaded = true;
                            });
                    };
                    reader.readAsDataURL(file);
                }
            }
        }
    }

    handleIdFilesChange(event) {
        this.idFileUploaded = true
        const uploadedFiles = event.detail.files;
        this.idFileName = 'The uploaded identity document is: ' + event.detail.files[0].name
        this.showIdFileName = true

        const fields = {};
        fields.Id = event.detail.files[0].contentVersionId;
        fields.Title = 'Copy of ID';
        fields.FileClassification__c = 'Copy of ID';
        fields.Category__c = 'Personal Documents';

        const recordInput = {fields};
        updateRecord(recordInput)
            .then(result => {
                this.validate()
                console.log('file updated', result)
            })
    }

    showToast(title, message, variant) {

        if (variant.toLowerCase() === 'error') {
            this.showHtmlErrorToast = true
            this.toastMessage = message;
            setTimeout(() => {

                this.showHtmlErrorToast = false;
            }, 2000)
        } else if (variant.toLowerCase() === 'warning') {
            this.showHtmlWarningToast = true
            this.toastMessage = message;
            setTimeout(() => {

                this.showHtmlWarningToast = false;
            }, 2000)

        } else {
            this.showHtmlSuccessToast = true
            this.toastMessage = message;
            setTimeout(() => {

                this.showHtmlSuccessToast = false;
            }, 2000)
        }
    }

    handleCloseToast() {
        this.showHtmlSuccessToast = false;
        this.showHtmlWarningToast = false;
        this.showHtmlErrorToast = false;
    }

    @track showUploader = false;

    handleManageFiles() {
        this.allowUpdate = false;
        this.showUploader = !this.showUploader;
        this.fadeDiv = this.fadeDiv.includes('fade') ? '' : 'fade';
        console.log(this.fadeDiv)
        console.log(this.showUploader)
    }

    async closeFileUploaderModal() {
        this.showUploader = false;
        this.connectedCallback();

    }

    @track disableClose;

    handleDisableClose() {
        this.disableClose = true;
    }

    handleEnableClose() {
        this.disableClose = false;
    }

}