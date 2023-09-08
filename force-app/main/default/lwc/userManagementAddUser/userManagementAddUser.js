/**
 * Created by frans fourie on 2023/04/25.
 */

import {LightningElement, track, api} from 'lwc';
import getUserDetails from '@salesforce/apex/UserManagementController.getUserDetails'
import getAdmins from '@salesforce/apex/UserManagementController.getAdmins'
import getRoles from '@salesforce/apex/UserManagementController.getRoles'
import getProfiles from '@salesforce/apex/UserManagementController.getProfiles'
import removePermissionAssignment from '@salesforce/apex/UserManagementController.removePermissionAssignment'
import getOrgBaseUrl from '@salesforce/apex/UserManagementController.getOrgBaseUrl'
import updateUserDetails from '@salesforce/apex/UserManagementController.updateUserDetails'
import insertUser from '@salesforce/apex/UserManagementController.insertUser'
import getAllSubBranches from '@salesforce/apex/UserManagementController.getAllSubBranches'
import getSelectedSubBranchDetails from '@salesforce/apex/UserManagementController.getSelectedSubBranchDetails'
import getMortgagePermission from '@salesforce/apex/UserManagementController.getMortgagePermission'
import subBranchChange from '@salesforce/apex/UserManagementController.subBranchChange'
import getUserAssignedSubBranches from '@salesforce/apex/UserManagementController.getUserAssignedSubBranches'
import assignPermissionAssignment from '@salesforce/apex/UserManagementController.assignPermissionAssignment'
import insertUserPartTwo from '@salesforce/apex/UserManagementController.insertUserPartTwo'
import updateSkills from '@salesforce/apex/UserManagementController.updateSkills'
import getPicklistValues from '@salesforce/apex/UserManagementController.getPicklistValues'
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from "lightning/navigation";
import emailRegex from '@salesforce/label/c.EmailRegex';

export default class UserManagementAddUser extends NavigationMixin(LightningElement) {


    selectedUserId;
    modifiedUserId;
    baseUrl;
    roles = [];
    profiles = [];
    subBranches = [];
    multiSelectOptionsValues = [];
    assignedSubBranches = [];
    @track showUserDetails = false;
    @track displayError = false;
    @track showSpinner = false;
    @track isConsultant = false;
    @track userDetailsChanged = false;
    @track permissionSetAssigned = false;
    @track showBranch = false;
    @track showSaveButton = false;
    @track dataHasLoaded = false;
    @track showSkillGroups = false;
    @track users = [];
    @track error;
    @track admins;
    @track constantTrue = true;
    mustAssignMortgage = false;
    @track forceCommissionEntityId = false;
    commissionEntityId;

    digiAppLink = '';
    commissionEntityIdChanged = false;
    subBranchSelected = false;
    nameChanged = false;
    surnameChanged = false;

    skillsChanged = false;
    emailChanged = false;
    profileChanged = false;
    mobileChanged = false;
    roleChanged = false;


    regex = emailRegex;
    onDataBubbles(event) {
        this.selectedUserId = event.detail;
        this.getUser();
    }


    connectedCallback() {
        this.subBranchSelected = false;
        this.nameChanged = false;
        this.surnameChanged = false;
        this.emailChanged = false;
        this.profileChanged = false;
        this.mobileChanged = false;
        this.roleChanged = false;
        this.commissionEntityIdChanged = false;
        this.skillsChanged = false;
        this.showSpinner = true;
        this.mustAssignMortgage = false;
        this.showSaveButton = false;
        this.users = [];
        this.users.push({
            'FirstName': '',
            'LastName': '',
            'MobilePhone': '',
            'ProfileId': '',
            'UserRoleId': '',
            'Email': '',
            'Id': null
        });
        this.assignedSubBranches = [];
        this.assignedSubBranches.push({'': ''})

        getRoles({}).then(result => {
            this.roles = [];
            for (let i = 0; i < result.length; i++) {
                this.roles.push({label: result[i].Name, value: result[i].Id})
            }

            getOrgBaseUrl({}).then(result => {
                this.baseUrl = result;

                getAllSubBranches({}).then(result => {
                    this.subBranches = [];
                    for (let i = 0; i < result.length; i++) {
                        this.subBranches.push({label: result[i].Name, id: result[i].Id})
                    }
                    this.dataHasLoaded = true;
                    getProfiles({}).then(result => {
                        console.log('profiles', result)
                        this.profiles = [];
                        for (let i = 0; i < result.length; i++) {
                            this.profiles.push({label: result[i].Name, value: result[i].Id})
                        }
                        this.showSpinner = false;
                        this.showUserDetails = true;
                        this.showBranch = true;
                    })
                })
            })
        })
        getPicklistValues({}).then(result => {

            for (const resultKey of result) {
                this.multiSelectOptionsValues.push({label: resultKey, value: resultKey})
            }
        })
    }

    get multiSelectOptions() {

        return this.multiSelectOptionsValues;
    }


    handleRecordSelected(event) {
        this.handleSubBranchChange(event.detail.id)
    }

    handleSubBranchChange(subBranch) {
        this.subBranchSelected = true;
        this.selectedSubBranch = subBranch;
        getSelectedSubBranchDetails({selectedSubBranch: subBranch}).then(result => {
            this.assignedSubBranches = result;
            this.showOrHideSaveButton();
        })
    }

    handleRecordRemoved() {
        this.showBranch = false;
        this.assignedSubBranches[0].regionName = '';
        this.assignedSubBranches[0].branchName = '';
        this.showBranch = true;
    }

    get subBranchOptions() {
        return this.subBranches;
    }

    handlePermissionChange(event) {
        this.mustAssignMortgage = event.target.checked;

    }

    createUser() {
        this.showSpinner = true;
        this.userDetailsChanged = false;
        console.log(this.users[0],' - ',this.selectedSubBranch,' - ',this.digiAppLink)
        insertUser({newUser: this.users[0], subBranch: this.selectedSubBranch, digiAppLink:this.digiAppLink}).then(resultOfUserInsert => {
            this.selectedUserId = resultOfUserInsert.Id;
            insertUserPartTwo({
                newUser: resultOfUserInsert,
                subBranch: this.selectedSubBranch,
                commissionEntityId: this.commissionEntityId,
                assignedSkills: this.selectedSkills
            }).then(result => {
                this.showUserDetails = false;
                if (this.mustAssignMortgage) {
                    assignPermissionAssignment({userId: resultOfUserInsert.Id}).then(result => {
                        this.showSpinner = false;
                        this.connectedCallback()
                        console.log('permission result', result)
                        this.showToast('User Created', 'User successfully created', 'success')
                        if (confirm('Would you like to set up the default opportunity team for this user?') === true) {
                            let url = '/lightning/setup/ManageUsers/page?address=%2F' + this.selectedUserId + '%3Fnoredirect%3D1%26isUserEntityOverride%3D1%26appLayout%3Dsetup%26tour%3D%26sfdcIFrameOrigin%3Dhttps%253A%252F%252F' + this.baseUrl + '%26sfdcIFrameHost%3Dweb%26nonce%3D3405d520bb7ca5a1d468d15b0a4c924ea35d70195c7d9d4375397fd749e72ea2%26ltn_app_id%3D06m8d000001OuAhAAK%26clc%3D1';
                            window.open(url,)
                        }
                    })

                } else {
                    this.showSpinner = false;
                    this.showToast('User Created', 'User successfully created', 'success')
                    if (confirm('Would you like to set up the default opportunity team for this user?') === true) {
                        let url = '/lightning/setup/ManageUsers/page?address=%2F' + this.selectedUserId + '%3Fnoredirect%3D1%26isUserEntityOverride%3D1%26appLayout%3Dsetup%26tour%3D%26sfdcIFrameOrigin%3Dhttps%253A%252F%252F' + this.baseUrl + '%26sfdcIFrameHost%3Dweb%26nonce%3D3405d520bb7ca5a1d468d15b0a4c924ea35d70195c7d9d4375397fd749e72ea2%26ltn_app_id%3D06m8d000001OuAhAAK%26clc%3D1';
                        window.open(url)
                    }
                    this.connectedCallback()
                }
            }).catch(error => {
                this.showToast('Failed to create user', 'Failed to create user', 'error')
                this.showSpinner = false;
                this.error = error.body.message;
                this.displayError = true;
                console.log('error updating user', error)
            })
            // console.log('user updated', result)
        }).catch(error => {
            this.showToast('Failed to create user', 'Failed to create user', 'error')
            this.showSpinner = false;
            this.error = error.body.message;
            this.displayError = true;
            console.log('error updating user', error)
        })

    }


    get profileComboboxOptions() {

        return this.profiles;

    }

    get roleComboboxOptions() {

        return this.roles;

    }


    handleManageAdmin() {
        if (confirm('Please ensure all other details are correct before assigning Default Opportunity Team Members. You will have to close the tab manually that\'s about to open.') === true) {
            let url = '/lightning/setup/ManageUsers/page?address=%2F' + this.selectedUserId + '%3Fnoredirect%3D1%26isUserEntityOverride%3D1%26appLayout%3Dsetup%26tour%3D%26sfdcIFrameOrigin%3Dhttps%253A%252F%252F' + this.baseUrl + '%26sfdcIFrameHost%3Dweb%26nonce%3D3405d520bb7ca5a1d468d15b0a4c924ea35d70195c7d9d4375397fd749e72ea2%26ltn_app_id%3D06m8d000001OuAhAAK%26clc%3D1';
            window.open(url)
        }

    }

    handleFirstNameChange(event) {
        this.nameChanged = event.target.value.length > 0;
        this.userDetailsChanged = true;
        this.displayError = false;
        this.users[0].FirstName = event.target.value;
        this.showOrHideSaveButton();
    }

    handleLastNameChange(event) {
        this.surnameChanged = event.target.value.length > 0;
        this.userDetailsChanged = true;
        this.displayError = false;
        this.users[0].LastName = event.target.value;
        this.showOrHideSaveButton();
    }

    handleEmailChange(event) {
        let field = this.template.querySelector("[data-field='email']");
        if (event.target.value.match(this.regex)) {
            field.validity = {valid: true};
            field.setCustomValidity("");
            this.emailChanged = event.target.value.length > 0;
            this.userDetailsChanged = true;
            this.displayError = false;
            this.users[0].Email = event.target.value;
            this.showOrHideSaveButton();
        } else {
            this.emailChanged = false;
            field.validity = {valid: false};
            field.setCustomValidity("Invalid input");
            this.showOrHideSaveButton();
        }
    }

    handleRoleChange(event) {
        this.roleChanged = event.target.value.length > 0;
        this.userDetailsChanged = true;
        this.displayError = false;
        this.users[0].UserRoleId = event.target.value;
        this.showOrHideSaveButton();
    }

    handleProfileChange(event) {
        this.profileChanged = event.target.value.length > 0;
        this.userDetailsChanged = true;
        this.displayError = false;
        this.users[0].ProfileId = event.target.value;
        this.forceCommissionEntityId = this.profiles.find(pr => pr.value === event.target.value).label === 'Consultant';
        this.showSkillGroups = this.profiles.find(pr => pr.value === event.target.value).label === 'Consultant';
        if(!this.showSkillGroups){
            this.selectedSkills = '';
        }
        this.showOrHideSaveButton();
    }

    handleMobileChange(event) {
        let field = this.template.querySelector("[data-field='mobile']")
        if ((event.target.value.length === 10 && event.target.value.startsWith('0')) || (event.target.value.length === 12 && event.target.value.includes('+27'))) {
            field.validity = {valid: true};
            field.setCustomValidity("");
            this.mobileChanged = event.target.value.length > 0;
            this.userDetailsChanged = true;
            this.displayError = false;
            this.users[0].MobilePhone = event.target.value;
            this.showOrHideSaveButton();
        } else {
            this.mobileChanged = false;
            field.validity = {valid: false};
            field.setCustomValidity("Invalid input");
            this.showOrHideSaveButton();
        }
    }

    handleDigiAppLinkChange(event) {
        this.digiAppLink = event.target.value;
        this.showOrHideSaveButton();
    }

    handleCommissionEntityIdChange(event) {
        this.commissionEntityId = event.target.value;
        this.commissionEntityIdChanged = event.target.value.length > 0;
        this.showOrHideSaveButton();
    }

    handleSkillsChange(event) {
        this.selectedSkills = event.detail.value;
        this.skillsChanged = true;
        this.showOrHideSaveButton()
    }

    showOrHideSaveButton() {
        this.showSaveButton = this.mobileChanged && this.profileChanged && this.roleChanged && this.emailChanged && this.surnameChanged && this.nameChanged && this.subBranchSelected && (this.forceCommissionEntityId ? this.commissionEntityIdChanged : true) && (this.forceCommissionEntityId ? this.digiAppLink.length > 0 : true);
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