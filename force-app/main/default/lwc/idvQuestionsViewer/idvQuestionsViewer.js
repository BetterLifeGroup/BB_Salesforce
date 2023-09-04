/**
 * Created by frans fourie on 2022/10/19.
 */

import {LightningElement, track, api} from 'lwc';
import getQuestions from '@salesforce/apex/SRVCRDIdvController.getIdvQuestions'
import setManualConsentParamsForMC from '@salesforce/apex/SRVCRDIdvController.setManualConsentParamsForMC'
import setOpportunityStatus from '@salesforce/apex/SRVCRDIdvController.setOpportunityStatus'
import getLoanApplicant from '@salesforce/apex/SRVCRDIdvController.getLoanApplicant'
import redoConsent from '@salesforce/apex/SRVCRDIdvController.redoConsent'
import updateLoanApplicant from '@salesforce/apex/SRVCRDIdvController.updateLoanApplicant'
import checkAnswers from '@salesforce/apex/SRVCRDIdvController.checkIdvAnswers'
import accountEmailPopulated from '@salesforce/apex/SRVCRDIdvController.accountEmailPopulated'
import updateEmailAddress from '@salesforce/apex/SRVCRDIdvController.updateEmailAddress'
import {FlowNavigationNextEvent} from "lightning/flowSupport";
import mcConsentForm from '@salesforce/resourceUrl/BBPA_E02_PAlead_sendingconsentform_spoketoclient';
import emailRegex from '@salesforce/label/c.EmailRegex';

export default class IdvQuestionsViewer extends LightningElement {

    selectedAnswers = [];
    idTypeOptionsList = [];
    answerBody = {};
    passportNumber;
    questionsRequested = false;
    dataLoaded = false;
    @track toastMessage;
    @track showHtmlErrorToast = false;
    @track showHtmlSuccessToast = false;
    @track showHtmlWarningToast = false;
    @track error = false;
    @track idvPassed = false;
    @track backToConsentsButtonEnabled = false;
    @track showSpinner = false;
    @track retryIdv = false;
    @track idvCompletedWithManualConsent;
    @track idvFailed = false;
    @track showManualConsentForm = false;
    @track getQuestionsButtonEnabled = false;
    @track showError = false;
    @track idNumber;
    @track staticResource;
    @track passportSelected;
    @track idTypeValue = 'SID';
    @track errorMessage;
    @track idValid = false;
    @track idNotValid = false;
    @track showSendButton = false;
    @track showIdRequired = false;
    @track inputClass = 'regexPassed';
    @api recordId;
    @api mustExitFlow = false;
    @api consentRefused = false;
    attemptNumber = 1;
    @track questionList = [];
    regex = emailRegex;


    connectedCallback() {
        this.staticResource = mcConsentForm;
        this.idTypeValue = 'SID';
        getLoanApplicant({loanApplicantId: this.recordId}).then(result => {
            console.log(result)
            this.idvCompletedWithManualConsent = result.idvFinalScore__c === 85;
            if(this.idvCompletedWithManualConsent){
                this.idTypeOptionsList = [
                    {value: 'SID', label: 'South African ID'},
                    {value: 'Passport', label: 'Passport'}
                ]
            } else {
                this.idTypeOptionsList = [
                    {value: 'SID', label: 'South African ID'},
                ]
            }
        }).catch((error) => {
            this.showToast(error, error, 'warning')
        })
    }

    continueToCreditCheck() {
        updateLoanApplicant({loanApplicantId: this.recordId, idNumber: this.idNumber, idType:this.idTypeValue, passportNumber:this.passportNumber}).then(result => {
            const navigateNextEvent = new FlowNavigationNextEvent()
            this.dispatchEvent(navigateNextEvent);

        }).catch(error => {
            this.showToast('Update Failed', 'Update Failed', 'error')
        })

    }

    getIdvQuestions() {

        if (this.questionsRequested === false && (this.idNumber?.length === 13 || this.passportSelected === true)) {
            this.getQuestions()
            this.questionsRequested = true
        }
    }

    exitFlow() {
        this.mustExitFlow = true;
        const navigateNextEvent = new FlowNavigationNextEvent()
        this.dispatchEvent(navigateNextEvent);

    }

    sendManualConsentEmail() {

        this.showManualConsentForm = true;
        accountEmailPopulated({loanApplicantId: this.recordId}).then(result => {
            if (result === true) {
                this.showIdRequired = false;
                this.showSendButton = true;
            } else {
                this.showIdRequired = true;
                this.showSendButton = false
            }
        })
    }

    handleEmailInput(event) {

        updateEmailAddress({emailAddress: event.target.value, loanApplicantId: this.recordId}).then(result => {
            if (this.inputClass === 'regexPassed') {
                this.showSendButton = true;
            }
        })

    }

    handleInputChange(event) {

        if (!event.target.value.match(this.regex)) {
            this.inputClass = 'regexFailed';
            this.showSendButton = false;
        } else {
            this.inputClass = 'regexPassed';
        }
    }

    sendManualConsentEmailFinal() {

        setManualConsentParamsForMC({loanApplicantId: this.recordId})

            .then(() => {
                this.showToast('Manual Consent', 'Email send successfully', 'success');
                this.mustExitFlow = true
                const navigateNextEvent = new FlowNavigationNextEvent()
                this.dispatchEvent(navigateNextEvent);
            }).catch((error) => {
            this.showToast('Manual Consent', error.body.message, 'error');
        })
    }

    backToConsents() {
        redoConsent({loanApplicantId: this.recordId}).then(() => {
            const navigateNextEvent = new FlowNavigationNextEvent()
            this.dispatchEvent(navigateNextEvent);
        }).catch((error) => {
            this.showToast(error, error, 'warning')
        })

    }

    getQuestions() {
        this.showSpinner = true
        getQuestions({
            loanApplicantId: this.recordId,
            idNumber: this.idNumber !== undefined ? this.idNumber : this.passportNumber,
            idType: this.idTypeValue
        }).then(result => {
            this.showSpinner = false
            this.questionList = result;
            this.dataLoaded = true
        }).catch((error) => {
            console.log('idvQuestionsViewer error', error);
            this.backToConsentsButtonEnabled = true
            this.error = true
            this.getQuestionsButtonEnabled = false
            this.dataLoaded = true
            this.showToast('IDV Questions', 'IDV Questions Error', 'error');
        })
    }

    idNumberInputChange(event) {

        this.idNumber = event.target.value
        // this.getQuestionsButtonEnabled = this.idNumber.length === 13 && this.idTypeValue === 'SID' && this.idValid === true;
    }

    handleIdTypeChange(event) {
        this.getQuestionsButtonEnabled = false;
        this.idTypeValue = event.detail.value
        console.log(this.idTypeValue)
        this.passportSelected = event.detail.value === 'Passport';
        // this.getQuestionsButtonEnabled = this.passportSelected === true;
    }

    passportNumberInputChange(event){
        this.getQuestionsButtonEnabled = event.target.value.length > 0;
        this.passportNumber = event.target.value;
    }

    handleAnswerClick(event) {
        if (this.selectedAnswers.findIndex(sa => sa.questionNumber === event.currentTarget.dataset.questionNumber) !== -1) {
            this.selectedAnswers.splice(this.selectedAnswers.findIndex(sa => sa.questionNumber === event.currentTarget.dataset.questionNumber), 1)
        }
        this.selectedAnswers.push({
            questionNumber: event.currentTarget.dataset.questionNumber,
            answerNumber: event.detail.value
        })

    }

    get idTypeOptions() {
        return this.idTypeOptionsList;
    }

    handleSubmitAnswers() {

        // console.log('answerList', toJSON(this.selectedAnswers))

        this.answerBody.verificationRequestNumber = this.questionList.verificationRequestNumber
        this.answerBody.answers = this.selectedAnswers
        this.answerBody.sourceSystem = 'Salesforce'
        this.showSpinner = true
        checkAnswers({answers: this.answerBody, loanApplicantId: this.recordId}).then(result => {
            this.showSpinner = false
            this.dataLoaded = false
            // console.log(result)
            if (result.finalScore >= 60) {
                this.dataLoaded = false
                // this.idvPassed = true
                const navigateNextEvent = new FlowNavigationNextEvent()
                this.dispatchEvent(navigateNextEvent);
            } else {
                setOpportunityStatus({
                    loanApplicantId: this.recordId,
                    status: 'PA requested - IDV failed',
                    stageName: 'Working',
                    wrapUpReason: 'Automated'
                }).then().catch(() => {
                    this.showToast('IDV Questions', 'Unable to update opportunity', 'error');
                })
                this.attemptNumber++
                this.dataLoaded = false
                this.getQuestionsButtonEnabled = false
                this.retryIdv = true
            }

            if (this.attemptNumber > 2) {
                this.idvFailed = true
                setOpportunityStatus({
                    loanApplicantId: this.recordId,
                    status: 'PA requested - IDV failed - awaiting consent',
                    stageName: 'Working',
                    wrapUpReason: 'Automated'
                }).then().catch(() => {
                    this.showToast('IDV Questions', 'Unable to update opportunity', 'error');
                })
            }
            this.idvFinalScore = result.finalScore
            this.idvResponseStatus = result.responseStatus

        }).catch((error) => {
            this.showError = true;
            this.errorMessage = 'DOMAIN RESPONSE ERROR: Please contact support desk'
            this.backToConsentsButtonEnabled = true;
            this.showSpinner = false
            this.dataLoaded = false
            console.log('error', error);
            this.showToast('IDV Questions', this.errorMessage, 'error');

        })
    }


    handleRetryIdvClick() {

        this.dataLoaded = false
        this.retryIdv = false
        this.idvPassed = false
        this.getQuestions()
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

    verifyId(event) {
        if (event?.target?.value) {
            this.idValid = event.target.value.length === 13 ? IdvQuestionsViewer.validateIdNumber(event.target.value).valid : false;
            this.idNotValid = !(event.target.value.length === 13 ? IdvQuestionsViewer.validateIdNumber(event.target.value).valid : false);
            this.getQuestionsButtonEnabled = this.idNumber.length === 13 && this.idTypeValue === 'SID' && this.idValid === true;
        }
    }

    /**South African ID Number Verifier */

    /**
     *
     *
     * @author Frans Fourie
     * @since 2022/09/10
     */

    /** It takes a South African ID number and returns an object with the ID number's validity, gender, date of birth and
     citizenship status */
    // ************************************************************************************************************************
// A South African ID number is a 13-digit number which is defined by the following format: YYMMDDSSSSCAZ.
//
// The first six digits (YYMMDD) are based on your date of birth. For example, 23 January 1988 becomes 880123.
// Although rare, it can happen that someone’s birthdate does not correspond with their ID number.
//
// The next four digits (SSSS) are used to define your gender, with only the first digit of the sequence relevant.
// Females have a number of 0 to 4, while males are 5 to 9. 891020 5072 0 8 7
//
// The next digit (C) is 0 if you are an SA citizen, or 1 if you are a permanent resident.
//
// The next digit (A) was used until the late 1980s to indicate a person’s race. This has been eliminated and
// old ID numbers were reissued to remove this.
//
// The last digit (Z) is a checksum digit, used to check that the number sequence is accurate using the Luhn algorithm.
// ************************************************************************************************************************

    /** A function that takes a South African ID number and returns an object with the ID number's validity, gender, date of
     birth and citizenship status. */
    static validateIdNumber(idNumber) {

        // if the ID number is not valid
        if (this.checkLuhn(idNumber) === false) {
            return {
                valid: false,
            };
        }

        // finally return the details if the number is valid
        return {
            valid: true,
            gender: this.parseGender(idNumber),
            DOB: this.parseDOB(idNumber),
            isCitizen: this.parseCitizenship(idNumber),
        };
    };

    /**
     * It checks if the ID number is valid.
     * @param idNumber - The ID number to validate.
     * @returns a boolean value.
     */
    static checkLuhn(idNumber) {
        let nDigits = idNumber.length;
        let nSum = 0;
        let isSecond = true;
        for (let i = nDigits - 2; i >= 0; i--) {
            let d = parseInt(idNumber.charAt(i));
            if (isSecond === true) {
                d = d * 2;
            }
            if (d > 9) {
                d = d - 9
            }
            nSum += d;

            isSecond = !isSecond;
        }
        return (nSum % 10 === (10 - idNumber.charAt(12)) % 10);
    }

    /** A static method that takes an ID number and returns the gender of the person out of the SSSS sequence. */
    static parseGender = idNumber => {
        const genderCode = idNumber.substring(6, 10);
        const gender = Number(genderCode) < 5000 ? 'female' : 'male';
        return gender;
    };

    /** Checking if the person is a citizen or not. */
    static parseCitizenship = idNumber => {
        const citizenshipCode = idNumber.substring(10, 11);
        const isCitizen = Number(citizenshipCode) === 0;
        return isCitizen;
    }

    /** Getting the date of birth out of the ID number. */
    static parseDOB = idNumber => {
        // get year, and assume the century
        const currentYear = new Date().getFullYear();
        const currentCentury = Math.floor(currentYear / 100) * 100;
        const currentMonth = new Date().getMonth();
        const currentDay = new Date().getDay();

        let yearPart = currentCentury + parseInt(idNumber.substring(0, 2), 10);

        // In Javascript, Jan=0. In ID Numbers, Jan=1.
        const monthPart = parseInt(idNumber.substring(2, 4), 10) - 1;

        const dayPart = parseInt(idNumber.substring(4, 6), 10);

        // only 16 years and above are eligible for an ID
        const eligibleYear = currentYear - 16;
        // make sure the ID's DOB is not below 16 years from today, if so its last century issue
        if (yearPart > eligibleYear || yearPart === eligibleYear && (monthPart > currentMonth || monthPart === currentMonth && dayPart > currentDay)) {
            yearPart -= 100; // must be last century
        }


        const dateOfBirth = new Date(yearPart, monthPart, dayPart);

        // validate that date is in a valid range by making sure that it wasn't 'corrected' during construction
        if (
            !dateOfBirth ||
            dateOfBirth.getFullYear() !== yearPart ||
            dateOfBirth.getMonth() !== monthPart ||
            dateOfBirth.getDate() !== dayPart
        ) {
            return undefined;
        }
        return dateOfBirth;
    }


}