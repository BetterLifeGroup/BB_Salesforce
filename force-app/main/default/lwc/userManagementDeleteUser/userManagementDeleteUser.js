/**
 * Created by frans fourie on 2023/04/26.
 */

import {LightningElement, track} from 'lwc';
import getUserOpenOpps from '@salesforce/apex/UserManagementController.getUserOpenOpps'
import consultantsAvailable from '@salesforce/apex/UserManagementController.consultantsAvailable'
import officeAdminCanBeDeleted from '@salesforce/apex/UserManagementController.officeAdminCanBeDeleted'
import reassignBulkOpps from '@salesforce/apex/UserManagementController.reassignBulkOpps'
import deactivateUser from '@salesforce/apex/UserManagementController.deactivateUser'
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import getOrgBaseUrl from '@salesforce/apex/UserManagementController.getOrgBaseUrl'

export default class UserManagementDeleteUser extends LightningElement {

    @track constantTrue = true;
    @track openoppsExists = false;
    @track showSpinner = false;
    @track noOpenOpps = false;
    @track hideForm = false;
    @track userCanBeDeactivated = false;
    @track showProgress = false;
    @track openOpps = [];
    @track availableConsultantsList = [];

    @track progress = '0';

    @track listOfLinks = [];

    @track hasSelectedOpportunities = false;
    @track selectedOpportunityIds = [];
    @track selectedConsultantIds = [];
    @track searchKeywordOpp = '';
    @track searchKeywordConsultant = '';
    @track isNewOppOwnerSelected = false;
    @track newOppOwnerSelectedValue;

    @track selectedRegion = null;
    @track availableRegions = [];

    @track deactivateErrorMessage = '';
    @track isDeactivateDisabled = true;
    @track errorMessage = '';
    selectedUserId;

    baseUrl;
    totalNumberOfBatches;
    batchNumber;
    batchSize;
    consultants;

    get allOptions() {
        return this.formattedOpenOpps;
    }

    get formattedOpenOpps() {
        // Format openOpps array to match the format required by lightning-dual-listbox
        return this.openOpps.map(oo => ({
            label: oo.Name + ' - ' + oo.Consultant_Region_Name__c,
            value: oo.Id
        }));
    }

    handleSelectAllOpps() {
        const selectedIdsSet = new Set(this.selectedOpportunityIds);
        this.selectedOpportunityIds = this.formattedOpenOpps;
        if (this.searchKeywordOpp.length > 0) {
            this.selectedOpportunityIds = this.selectedOpportunityIds.filter((option) =>
                option.label.toLowerCase().includes(this.searchKeywordOpp.toLowerCase()) || selectedIdsSet.has(option.value)).map(opportunity => opportunity.value);
        } else {
            this.selectedOpportunityIds = this.formattedOpenOpps.map(opportunity => opportunity.value)
        }
        this.hasSelectedOpportunities = true;
    }

    handleDeselectAllOpps() {
        this.selectedOpportunityIds = [];
        this.hasSelectedOpportunities = false;
    }

    handleSelectAllConsultant() {
        // Create a new array containing only the consultant IDs from formattedConsultant
        this.selectedConsultantIds = this.availableConsultantsList.map((consultant) => consultant.value);
    }

    handleDeselectAllConsultant() {
        this.selectedConsultantIds = [];
    }

    onDataBubbles(event) {
        this.selectedUserId = event.detail.id;
        this.getUserOpps();
        this.handleUserDeactivationOnLoad();
    }

    connectedCallback() {
        getOrgBaseUrl({}).then(result => {
            this.baseUrl = result;
        })
    }

    handleUserDeactivationOnLoad() {
        this.showSpinner = true;
        this.userCanBeDeactivated = false;
        this.isDeactivateDisabled = true;
        this.deactivateErrorMessage = '';

        // Call the Apex method to check if the user can be deactivated
        officeAdminCanBeDeleted({userId: this.selectedUserId})
            .then((result) => {
                let resultBool = result.length === 0;
                if (result.length > 0) {
                    this.listOfLinks = [];
                    for (let i = 0; i < result.length; i++) {
                        this.listOfLinks.push({
                            'url': '/lightning/setup/ManageUsers/page?address=%2F' + result[i].Id + '%3Fnoredirect%3D1%26isUserEntityOverride%3D1%26appLayout%3Dsetup%26tour%3D%26sfdcIFrameOrigin%3Dhttps%253A%252F%252F' + this.baseUrl + '%26sfdcIFrameHost%3Dweb%26nonce%3D3405d520bb7ca5a1d468d15b0a4c924ea35d70195c7d9d4375397fd749e72ea2%26ltn_app_id%3D06m8d000001OuAhAAK%26clc%3D1',
                            'Name': result[i].Name
                        })
                    }
                }
                // Handle successful deactivation here (if needed)
                this.userCanBeDeactivated = resultBool;
                this.isDeactivateDisabled = !resultBool; // Enable/disable the button based on the result
                this.showSpinner = false;
                if (!resultBool) {
                    this.deactivateErrorMessage = 'Cannot deactivate the user. They are the only admin on at least one Consultant\'s opportunity team.';
                } else {
                    this.deactivateErrorMessage = '';
                }
            })
            .catch((error) => {
                console.error('Error while checking user deactivation:', error);
                this.isDeactivateDisabled = true; // Disable the button in case of an error
                this.showSpinner = false;
            });
    }

    handleDeactivateUser() {
        this.userCanBeDeactivated = false;
        this.hideForm = true;
        this.showSpinner = true;
        this.noOpenOpps = false;

        // proceed with the deactivation process
        deactivateUser({userId: this.selectedUserId})
            .then((result) => {
                this.showSpinner = false;
                this.showToast('User Deactivated', 'User Deactivated', 'success');
                setTimeout(() => {
                    this.hideForm = false;
                }, 500);
            })
            .catch((error) => {
                // Handle errors here
                console.error('Error while deactivating user:', error);
                this.showSpinner = false;
                this.hideForm = false;

                if (this.deactivateErrorMessage) {
                    // Show the custom error message if available
                    this.showToast('Error', this.deactivateErrorMessage, 'error');
                } else if (error.body && error.body.message) {
                    // Show the generic error message for other scenarios
                    this.showToast('Error', error.body.message, 'error');
                } else {
                    this.showToast('Error', 'An error occurred while deactivating the user.', 'error');
                }
            });
    }


    getUserOpps() {
        getUserOpenOpps({userId: this.selectedUserId}).then(currentOpenOpps => {
            this.openOpps = [];
            this.openOpps = currentOpenOpps;
            this.openOpps.map(oo => {
                oo.reassigned = false,
                    oo.Consultant_Region_Name__c = oo.Consultant_Region_Name__c ? oo.Consultant_Region_Name__c : 'Not Applicable',
                    oo.Affordability_Amount__c = oo.Affordability_Amount__c ? 'R ' + oo.Affordability_Amount__c : 'Not Applicable';
            });

            // Extract unique regions from openOpps
            const uniqueRegions = Array.from(new Set(this.openOpps.map(oo => oo.Consultant_Region_Name__c)));

            // Create an array of objects with label and value properties for each region
            this.availableRegions = uniqueRegions.map(region => ({label: region, value: region}));

            // Add "All Regions" option to the beginning of the availableRegions array
            this.availableRegions.unshift({label: 'All Regions', value: 'All Regions'});

            // Set the default selected region to 'All Regions' if availableRegions is not empty
            if (this.availableRegions.length > 0) {
                // this.selectedRegion = 'All Regions';
            }

            if (!this.selectedRegion) {

                this.selectedRegion = 'All Regions';
            }


            if (this.openOpps.length > 0) {
                this.noOpenOpps = false;
                consultantsAvailable({userId: this.selectedUserId}).then(result => {
                    this.consultants = result;
                    this.availableConsultantsList = [];
                    for (let i = 0; i < result.length; i++) {
                        this.availableConsultantsList.push({
                            label: result[i].Name,
                            value: result[i].Consultant__c,
                            regionName: result[i].Account?.Parent?.Parent?.Name ? result[i].Account?.Parent?.Parent?.Name : 'Not Applicable'
                        })
                    }
                    this.recalculateAvailableConsultants();

                    this.openoppsExists = true;
                    this.showSpinner = false;
                })
            } else {
                this.userCanBeDeactivated = true;
                this.showSpinner = false;
                this.noOpenOpps = true;
            }
        })
    }

    recalculateAvailableConsultants() {
        this.availableConsultantsList = [];
        for (let i = 0; i < this.consultants.length; i++) {
            this.availableConsultantsList.push({
                label: this.consultants[i].Name,
                value: this.consultants[i].Consultant__c,
                regionName: this.consultants[i].Account?.Parent?.Parent?.Name ? this.consultants[i].Account?.Parent?.Parent?.Name : 'Not Applicable'
            })
        }
        if (this.selectedRegion === 'All Regions') {
            this.availableConsultantsList = this.availableConsultantsList.filter((acl) => acl.label.toLowerCase().includes(this.searchKeywordConsultant.toLowerCase()))
            return;
        }
        if (this.selectedRegion) {
            this.availableConsultantsList = this.availableConsultantsList.filter((acl) => (acl.regionName.toLowerCase().includes(this.selectedRegion.toLowerCase())))
            if (this.searchKeywordConsultant.length > 0) {
                this.availableConsultantsList = this.availableConsultantsList.filter((acl) => (acl.label.toLowerCase().includes(this.searchKeywordConsultant.toLowerCase())))
            }
        }
    }

    handleRegionChange(event) {
        this.selectedRegion = event.detail.value;
        this.recalculateAvailableConsultants();
    }

    get regionOptions() {
        return this.availableRegions.map((region) => ({label: region.label, value: region.value}));
    }

    get filteredOppOptions() {
        const selectedIdsSet = new Set(this.selectedOpportunityIds);
        const filteredOptions = this.formattedOpenOpps.filter((option) =>
            option.label.toLowerCase().includes(this.searchKeywordOpp.toLowerCase()) || selectedIdsSet.has(option.value)
        );

        // If "All Regions" is selected, show all open opportunities without filtering
        if (this.selectedRegion === 'All Regions') {
            return filteredOptions;
        }
        // Apply the region filter only when a specific region is selected

        if (this.selectedRegion) {
            return filteredOptions.filter((option) => option.label.toLowerCase().includes(this.selectedRegion.toLowerCase()));
        } else {
            return filteredOptions;
        }
    }

    bulkReassign(oppIdsList) {
        this.showSpinner = true;
        this.batchNumber++;
        this.progress = (this.batchNumber / this.totalNumberOfBatches) * 100
        this.showProgress = true;

        reassignBulkOpps({
            oppIds: oppIdsList.splice(0, this.batchSize),
            newUserIdList: this.selectedConsultantIds
        }).then(result => {
            this.bulkReassignPartTwo(oppIdsList);
        })
    }


    bulkReassignPartTwo(oppIdsList) {
        if (oppIdsList.length > 0) {
            this.bulkReassign(oppIdsList);
        } else {
            this.showSpinner = false;
            this.showProgress = false;
            this.showToast('Success', 'Opportunities Reassigned Successfully', 'success');
            this.showSpinner = false;
            this.handleRefresh();
        }
    }

    handleReassignSelected() {
        if (this.selectedConsultantIds.length === 0) {
            this.showToast('Error', 'Please select at least one new opportunity owner.', 'error');
            return;
        }

        const oppIdsToReassign = this.selectedOpportunityIds;

        const newUserIdList = this.selectedConsultantIds;
        if (oppIdsToReassign.length > 10) {

            this.batchSize = newUserIdList.length < 10 ? newUserIdList.length * 4 : newUserIdList.length < 20 ? newUserIdList.length * 2 : newUserIdList.length;
            this.totalNumberOfBatches = oppIdsToReassign.length / this.batchSize;
            this.batchNumber = 0;
            this.bulkReassign(oppIdsToReassign);
        } else {
            this.showSpinner = true;
            // Call the Apex method to reassign the opportunities to consultants.
            reassignBulkOpps({oppIds: oppIdsToReassign, newUserIdList: newUserIdList})
                .then(result => {
                    this.showToast('Success', 'Opportunities Reassigned Successfully', 'success');
                    this.showSpinner = false;
                    this.handleRefresh();

                    // Clear selected consultants after reassignment
                    this.selectedConsultantIds = [];
                })
                .catch(error => {
                    console.error('Error reassigning opportunities:', error);
                    this.showToast('Error', 'An error occurred while reassigning opportunities.', 'error');
                    this.showSpinner = false;
                });
        }
    }

    get availableConsultants() {
        return this.availableConsultantsList;
    }

    handleRefresh() {
        this.showSpinner = true;
        this.openoppsExists = false;
        this.getUserOpps();
    }


    handleSelectionCleared() {
        this.noOpenOpps = false;
        this.openoppsExists = false;
        this.userCanBeDeactivated = false;
        this.selectedOpportunityIds = [];
        this.selectedConsultantIds = [];
    }

    handleOpportunityChange(event) {
        this.selectedOpportunityIds = event.detail.value;
        this.hasSelectedOpportunities = this.selectedOpportunityIds.length > 0;
    }

    handleOppSearchChange(event) {
        this.searchKeywordOpp = event.target.value;
    }

    handleConsultantChange(event) {
        this.selectedConsultantIds = event.detail.value;
    }

    get filteredConsultantOptions() {
        const selectedIdsSet = new Set(this.selectedConsultantIds);
        return this.availableConsultantsList.filter((option) =>
            option.label.toLowerCase().includes(this.searchKeywordConsultant.toLowerCase()) || selectedIdsSet.has(option.value)
        );
    }

    handleConsultantSearchChange(event) {
        const selectedIdsSet = new Set(this.selectedConsultantIds);
        this.searchKeywordConsultant = event.target.value;
        this.availableConsultantsList.filter((option) =>
            option.label.toLowerCase().includes(this.searchKeywordConsultant.toLowerCase()) || selectedIdsSet.has(option.value));
        this.recalculateAvailableConsultants();
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