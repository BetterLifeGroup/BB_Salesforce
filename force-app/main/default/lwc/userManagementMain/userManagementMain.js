/**
 * Created by frans fourie on 2023/04/24.
 */

import {LightningElement, track, api} from 'lwc';
import getUserDetails from '@salesforce/apex/UserManagementController.getUserDetails'
import getUserDigiAppLink from '@salesforce/apex/UserManagementController.getUserDigiAppLink'
import getAdmins from '@salesforce/apex/UserManagementController.getAdmins'
import getRoles from '@salesforce/apex/UserManagementController.getRoles'
import getProfiles from '@salesforce/apex/UserManagementController.getProfiles'
import removePermissionAssignment from '@salesforce/apex/UserManagementController.removePermissionAssignment'
import getOrgBaseUrl from '@salesforce/apex/UserManagementController.getOrgBaseUrl'
import updateUserDetails from '@salesforce/apex/UserManagementController.updateUserDetails'
import updateUserDetailsPartTwo from '@salesforce/apex/UserManagementController.updateUserDetailsPartTwo'
import getAllSubBranches from '@salesforce/apex/UserManagementController.getAllSubBranches'
import getMortgagePermission from '@salesforce/apex/UserManagementController.getMortgagePermission'
import subBranchChange from '@salesforce/apex/UserManagementController.subBranchChange'
import getUserAssignedSubBranches from '@salesforce/apex/UserManagementController.getUserAssignedSubBranches'
import assignPermissionAssignment from '@salesforce/apex/UserManagementController.assignPermissionAssignment'
import addAdditionalSubBranch from '@salesforce/apex/UserManagementController.addAdditionalSubBranch'
import deleteAdditionalSubBranch from '@salesforce/apex/UserManagementController.deleteAdditionalSubBranch'
import updateCommissionEntityId from '@salesforce/apex/UserManagementController.updateCommissionEntityId'
import updateSkills from '@salesforce/apex/UserManagementController.updateSkills'
import getPicklistValues from '@salesforce/apex/UserManagementController.getPicklistValues'
import getAllLinkedAgents from '@salesforce/apex/UserManagementController.getAllLinkedAgents'
import deleteCCRById from '@salesforce/apex/UserManagementController.deleteCCRById'
import createCCRByConsultant from '@salesforce/apex/UserManagementController.createCCRByConsultant'
import reactivateUser from '@salesforce/apex/UserManagementController.reactivateUser'
import {NavigationMixin} from "lightning/navigation";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import emailRegex from '@salesforce/label/c.EmailRegex';


export default class UserManagementMain extends NavigationMixin(LightningElement) {

    selectedUserId;
    modifiedUserId;
    baseUrl;
    commissionEntityId = '';
    digiAppLink;
    roles = [];
    profiles = [];
    multiSelectOptionsValues = [];
    subBranches = [];
    @track assignedSubBranches = [];
    @track showUserDetails = false;
    @track displayError = false;
    @track showSpinner = false;
    @track isConsultant = false;
    @track userDetailsChanged = false;
    @track permissionSetAssigned = false;
    @track emailChanged = false;
    @track showBranch = false;
    @track includeInactiveUsers = false;
    @track showSkillGroups = false;
    @track updateAllowedForConsultant = false;
    @track isInactiveUser = false;
    @track users;
    @track error;
    @track admins;
    @track constantTrue = true;
    @track linkedAgentOptions = [];
    @track linkedAgents = [];
    @track queryFilter = ' AND RecordType.Name = \'Real Estate Agent\'';

    mobileValid = true;
    emailValid = true;

    regex = emailRegex;

    onDataBubbles(event) {
        this.selectedUserId = event.detail.id;
        this.getUser();
    }

    handleInactiveUserChange(event) {
        this.includeInactiveUsers = event.target.checked;
    }


    handleSelectionCleared() {
        this.showUserDetails = false;
        this.emailChanged = false;
        this.error = null;
        this.displayError = false;
        this.assignedSubBranches = [];
        this.linkedAgents = [];
        this.digiAppLink = '';
        this.permissionSetAssigned = false;
    }

    handleLinkedAgentSelected(event) {
        if (this.linkedAgents.findIndex(la => la.FinServ__RelatedContact__c === event.detail.id) > -1) {
            this.showToast('Error', 'Assignment already exists', 'error')
            this.getUser()
            this.showSpinner = false;
        } else {
            this.showSpinner = true;
            createCCRByConsultant({
                agentContactId: event.detail.id,
                consultantUserId: this.selectedUserId
            }).then(result => {
                if (result) {
                    this.showSpinner = false;
                    this.showToast('Success', 'Success', 'success')
                } else {
                    this.showSpinner = false;
                    this.showToast('Error', 'Error', 'error')
                }
                this.getUser()
            })
        }
    }

    handleAddNewLinkedAgent() {
        this.linkedAgents.push({
            FinServ__RelatedContact__c: '',
            Id: '',
            Name: '',
            FinServ__RelatedContact__r: {
                Id: '',
                Name: ''
            },
            iconDisabled: true
        })
    }

    handleRemoveLinkedAgent(event) {
        this.showSpinner = true;
        deleteCCRById({ccrId: event.target.dataset.id}).then(result => {
            if (result) {
                this.showSpinner = false;
                this.showToast('Success', 'Success', 'success')
            } else {
                this.showSpinner = false;
                this.showToast('Error', 'Error', 'error')
            }
            this.getUser();
        })
    }

    connectedCallback() {
        getOrgBaseUrl({}).then(result => {
            this.baseUrl = result;
        })
        getRoles({}).then(result => {
            for (let i = 0; i < result.length; i++) {
                this.roles.push({label: result[i].Name, value: result[i].Id})

            }
        })
        getProfiles({}).then(result => {
            for (let i = 0; i < result.length; i++) {
                this.profiles.push({label: result[i].Name, value: result[i].Id})

            }
        })
        getAllSubBranches({}).then(result => {
            for (let i = 0; i < result.length; i++) {
                this.subBranches.push({label: result[i].Name, id: result[i].Id})
            }
        })
        getPicklistValues({}).then(result => {

            for (const resultKey of result) {
                this.multiSelectOptionsValues.push({label: resultKey, value: resultKey})
            }
        })
    }

    handleSkillsChange(event) {
        updateSkills({
            userId: this.selectedUserId,
            selectedSkills: event.detail.value,
            subBranchId: event.target.dataset.id
        }).then(result => {
        })
    }

    handleAdditionalRecordSelected(event) {

        this.handleAdditionalSubBranch(event.detail)
    }

    handleAdditionalSubBranch(payload) {

        let isNew;
        this.showSpinner = true;
        isNew = payload.additionalVariable === '';
        addAdditionalSubBranch({
            userId: this.selectedUserId,
            subBranchId: payload.id,
            oldSubBranch: payload.additionalVariable,
            isNew: isNew,
            commissionEntityId: this.commissionEntityId
        }).then(result => {
            this.getUser()
        }).catch(error => {
            if (error.body.message.includes('DUPLICATE_VALUE')) {
                this.showToast('Duplicate Assignment', 'Assignment Already Exists', 'warning')
            } else {
                this.showToast('Error Occurred', 'Error Occurred', 'error')
            }
        }).finally(() => {
            this.getUser()
        })


    }

    handleDeleteSubBranch(event) {
        this.showSpinner = true;
        deleteAdditionalSubBranch({userId: this.selectedUserId, subBranchId: event.target.dataset.id}).then(result => {
            this.getUser()
        })
    }

    handleAddNewSubBranch(event) {
        this.getUser(true)
    }

    handleRecordSelected(event) {

        this.handleSubBranchChange(event.detail)

    }

    handleSubBranchChange(payload) {
        this.showSpinner = true;
        if (payload.id !== payload.additionalVariable) {
            subBranchChange({
                userId: this.selectedUserId,
                newSubBranch: payload.id,
                oldSubBranch: payload.additionalVariable
            }).then(result => {
                this.getUser()
            })
        } else {
            this.getUser()
        }
    }

    get subBranchOptions() {
        return this.subBranches;
    }

    handlePermissionChange() {

        if (this.permissionSetAssigned) {
            removePermissionAssignment({userId: this.selectedUserId}).then(result => {
                this.permissionSetAssigned = !this.permissionSetAssigned;
            }).catch(error => {
                this.error = error.body.message;
                this.displayError = true;
            })
        } else {
            assignPermissionAssignment({userId: this.selectedUserId}).then(result => {
                this.permissionSetAssigned = !this.permissionSetAssigned
            }).catch(error => {
                this.error = error.body.message;
                this.displayError = true;
            })
        }
    }

    updateUser() {
        this.showSpinner = true;
        this.userDetailsChanged = false;
        if (this.emailChanged) {
            alert('Please note that after clicking update, a confirmation email will be send to the new email address. Only once this email has been actioned will the email address for the user update.')
        }
        updateUserDetails({updatedUser: this.users[0]}).then(result => {
            updateUserDetailsPartTwo({updatedUser: this.users[0], digiAppLink: this.digiAppLink}).then(result => {
                this.getUser();
                this.showSpinner = false;
            })
        }).catch(error => {
            this.displayError = true;
            this.showSpinner = false;
            this.error = error.body.message;
        })

    }

    handleDigiAppLinkChange(event) {
        this.digiAppLink = event.target.value;
        this.userDetailsChanged = true;
        this.canUpdate();
    }

    handleReactiveUserClick() {
        this.isInactiveUser = false;
        this.showSpinner = true;
        reactivateUser({userId: this.selectedUserId}).then(result => {
            if (result === 'true') {
                this.getUser();
                this.showSpinner = false;
            } else {
                this.isInactiveUser = true;
                this.showSpinner = false;
                console.log(result)
                this.showSpinner = false;
                this.showToast('Unable to reactivate', result, 'error');

            }
        }).catch(error => {
            console.log(error)
            this.showSpinner = false;
            this.showToast('Unable to reactivate', error.message, 'error');
        })

    }


    getUser(addAdditionalSubBranch) {
        this.updateAllowedForConsultant = false;
        this.userDetailsChanged = false;
        this.mobileValid = true;
        this.emailValid = true;
        this.assignedSubBranches = [];
        this.linkedAgents = [];
        this.digiAppLink = '';
        this.permissionSetAssigned = false;
        getUserDetails({userId: this.selectedUserId}).then(result => {
            if (!result[0].IsActive) {
                this.isInactiveUser = true;
            } else {
                this.isInactiveUser = false;
                getUserAssignedSubBranches({userId: this.selectedUserId}).then(result => {
                    this.assignedSubBranches = result
                    this.assignedSubBranches.map(asb => asb.commissionIdAvailable = true);
                    if (result.length < 1) {
                        addAdditionalSubBranch = true;
                    } else {
                        this.assignedSubBranches.map(re => {
                            re.deleteRelationshipDisabled = false , re.addRelationshipDisabled = true , re.subBranchName = this.subBranches.find(sb => sb.id === re.subBranchId).label
                        });
                        this.assignedSubBranches[0].deleteRelationshipDisabled = true;
                        this.assignedSubBranches[this.assignedSubBranches.length - 1].addRelationshipDisabled = false;
                    }


                    if (addAdditionalSubBranch === true) {
                        this.assignedSubBranches.push({
                            'branchName': '',
                            'addRelationshipDisabled': true,
                            'deleteRelationshipDisabled': false,
                            'subBranchId': '',
                            'regionName': '',
                            'subBranchName': '',
                            'commissionIdAvailable': !this.isConsultant
                        })
                        this.showBranch = true;
                        this.showSpinner = false;
                    } else {
                        this.showBranch = true;
                        this.showSpinner = false;
                    }
                }).catch(error => {
                })
                this.modifiedUserId = result[0].Id.substring(0, 15);
                this.users = result;
                this.showUserDetails = true;
                this.showSpinner = false;
                if (result[0].Profile.Name === 'Consultant') {
                    this.showSkillGroups = true;
                    // todo, hide button if consultant and digiapp empty
                    getAdmins({userId: this.selectedUserId}).then(result => {
                        this.admins = result;
                        this.isConsultant = true;
                    })
                } else {
                    this.showSkillGroups = false;
                    this.isConsultant = false;
                }
            }

        }).catch(error => {
            console.log('error', error)
        })
        getUserDigiAppLink({userId: this.selectedUserId}).then(result => {
            this.digiAppLink = result;
        }).catch(error => {
        })
        getMortgagePermission({userId: this.selectedUserId}).then(result => {
            this.permissionSetAssigned = result;
        })
        getAllLinkedAgents({consultantUserId: this.selectedUserId}).then(result => {
            this.linkedAgents = result;
            if (!this.linkedAgents.length > 0) {

                this.linkedAgents.push({
                    FinServ__RelatedContact__c: '',
                    Id: '',
                    Name: '',
                    FinServ__RelatedContact__r: {
                        Id: '',
                        Name: ''
                    },
                    iconDisabled: true
                })
            }
        })

    }

    get profileComboboxOptions() {

        return this.profiles;

    }

    get roleComboboxOptions() {

        return this.roles;
    }

    get multiSelectOptions() {

        return this.multiSelectOptionsValues;
    }

    handleManageAdmin() {
        if (confirm('Please ensure all other details are correct before assigning Default Opportunity Team Members. You will have to close the tab manually that\'s about to open.') === true) {
            let url = '/lightning/setup/ManageUsers/page?address=%2F' + this.selectedUserId + '%3Fnoredirect%3D1%26isUserEntityOverride%3D1%26appLayout%3Dsetup%26tour%3D%26sfdcIFrameOrigin%3Dhttps%253A%252F%252F' + this.baseUrl + '%26sfdcIFrameHost%3Dweb%26nonce%3D3405d520bb7ca5a1d468d15b0a4c924ea35d70195c7d9d4375397fd749e72ea2%26ltn_app_id%3D06m8d000001OuAhAAK%26clc%3D1';
            window.open(url)
        }

    }

    handleFirstNameChange(event) {
        this.userDetailsChanged = true;
        this.displayError = false;
        this.users[0].FirstName = event.target.value
        this.canUpdate();
    }

    handleLastNameChange(event) {
        this.userDetailsChanged = true;
        this.displayError = false;
        this.users[0].LastName = event.target.value
        this.canUpdate();
    }

    handleEmailChange(event) {
        let field = this.template.querySelector("[data-field='email']");
        if (event.target.value.match(this.regex)) {
            field.validity = {valid: true};
            field.setCustomValidity("");
            this.emailChanged = true;
            this.userDetailsChanged = true;
            this.displayError = false;
            this.users[0].Email = event.target.value
            this.emailValid = true;
            this.canUpdate();
        } else {
            this.emailChanged = false;
            field.validity = {valid: false};
            field.setCustomValidity("Invalid input");
            this.userDetailsChanged = false;
            this.emailValid = false;
        }
    }

    handleRoleChange(event) {
        this.userDetailsChanged = true;
        this.displayError = false;
        this.users[0].UserRoleId = event.target.value
        this.canUpdate();
    }

    handleProfileChange(event) {
        this.userDetailsChanged = true;
        this.displayError = false;
        this.users[0].ProfileId = event.target.value
        this.canUpdate();
    }

    handleMobileChange(event) {
        let field = this.template.querySelector("[data-field='mobile']")
        if ((event.target.value.length === 10 && event.target.value.startsWith('0')) || (event.target.value.length === 12 && event.target.value.includes('+27'))) {
            field.validity = {valid: true};
            field.setCustomValidity("");
            this.userDetailsChanged = true;
            this.displayError = false;
            this.users[0].MobilePhone = event.target.value
            this.mobileValid = true;
            this.canUpdate();
        } else {
            field.validity = {valid: false};
            field.setCustomValidity("Invalid input");
            this.userDetailsChanged = false;
            this.mobileValid = false;
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    canUpdate() {
        this.updateAllowedForConsultant = (this.isConsultant ? this.digiAppLink?.length > 0 : true) && this.mobileValid && this.emailValid;
    }

    handleCommissionEntityIdBlur(event) {

        this.commissionEntityId = event.target.value;

        if (event.target.dataset.id.length === 0 && (event.target.value.length > 0 || !this.isConsultant)) {

            this.assignedSubBranches[this.assignedSubBranches.length - 1].commissionIdAvailable = true;
        } else if (event.target.dataset.id.length === 0 && event.target.value.length === 0 && this.isConsultant) {
            this.assignedSubBranches[this.assignedSubBranches.length - 1].commissionIdAvailable = false;
        }
        if (event.target.dataset.id.length > 0 && (event.target.value.length > 0 || !this.isConsultant)) {
            this.assignedSubBranches.find(asb => asb.subBranchId === event.target.dataset.id).commissionIdAvailable = true;
        } else if (event.target.dataset.id.length > 0 && event.target.value.length === 0 && this.isConsultant) {
            this.assignedSubBranches.find(asb => asb.subBranchId === event.target.dataset.id).commissionIdAvailable = false;
        }


        if (this.commissionEntityId.length > 0 && event.target.dataset.id.length > 0) {
            this.showSpinner = true;
            updateCommissionEntityId({
                commissionEntityId: this.commissionEntityId,
                subBranchId: event.target.dataset.id,
                userId: this.selectedUserId,
            }).then(result => {
                this.showSpinner = false;
            }).catch(error => {
                console.log('error', error)
            })
        }
    }
}