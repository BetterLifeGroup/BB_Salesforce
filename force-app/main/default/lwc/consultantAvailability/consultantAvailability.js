/**
 * Created by frans fourie on 2023/10/03.
 */

import {LightningElement, track, api} from 'lwc';
import GetConsultantsAvailable from '@salesforce/apex/ConsultantAvailabilityController.GetNumberOfConsultantsAvailable';
import getUnavailableUsers from '@salesforce/apex/ConsultantAvailabilityController.getUnavailableUsers';
import getUserOpenOpps from '@salesforce/apex/UserManagementController.getUserOpenOpps'
import consultantsAvailable from '@salesforce/apex/ConsultantAvailabilityController.DirectOnlyAvailableConsultants'
import officeAdminCanBeDeleted from '@salesforce/apex/UserManagementController.officeAdminCanBeDeleted'
import reassignBulkOpps from '@salesforce/apex/UserManagementController.reassignBulkOpps'
import deactivateUser from '@salesforce/apex/UserManagementController.deactivateUser'
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import getOrgBaseUrl from '@salesforce/apex/UserManagementController.getOrgBaseUrl'

export default class ConsultantAvailability extends LightningElement {

    @track firstSectionIcon = 'utility:add';
    @track secondSectionIcon = 'utility:add';
    @track thirdSectionIcon = 'utility:add';
    @track showFirstSection = false;
    @track showSecondSection = false;
    @track showThirdSection = false;
    @track uniqueCampaigns = [];
    @track uniqueOppStatuses = [];
    @track uniqueOppStages = [];


    @api chartDataSet
    @api showChart = false;
    @api manageUser = false;
    @track unavailableUsers = [];
    @track filteredUnavailableUsers = [];
    @track selectedUserName = '';
    @track accordionClass = 'open';

    @track data = [{}];

    @track columns = [
        {label: 'Name', fieldName: 'Name', editable: false},
        {label: 'Type', fieldName: 'Unavailable_Reason__c', editable: false},
        {
            label: 'Unavailable Since',
            fieldName: 'Unavailable_From__c',
            type: 'date',
            editable: false,
            typeAttributes: {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                hour12: true
            },
        },
        {
            type: 'button',
            typeAttributes: {
                label: 'Manage User'
            },
            cellAttributes: {alignment: 'center'}
        },
    ];


    handleFirstSectionClick() {
        if (this.firstSectionIcon === 'utility:dash') {
            this.sectionManager(1, true);
        } else {
            this.sectionManager(1, false);
        }
    }

    handleSecondSectionClick() {
        if (this.secondSectionIcon === 'utility:dash') {
            this.sectionManager(2, true);
        } else {
            this.sectionManager(2, false);
        }
    }

    handleThirdSectionClick() {
        if (this.thirdSectionIcon === 'utility:dash') {
            this.sectionManager(3, true);
        } else {
            this.sectionManager(3, false);
        }
    }

    handleUserUpdatedEvent(event) {
        this.connectedCallback()
    }


    connectedCallback() {
        getOrgBaseUrl({}).then(result => {
            this.baseUrl = result;
        })
        GetConsultantsAvailable({}).then(result => {
            const data = {
                labels: [
                    'Available',
                    'Lunch',
                    'Meeting/Training',
                    'Admin Time',
                    'Travelling',
                    'Annual Leave',
                    'Sick Leave'
                ],
                datasets: [{
                    label: 'Consultant Availability',
                    data: [result.availableConsultants, result.lunch, result.meeting, result.adminTime, result.travelling, result.annualLeave, result.sickLeave],
                    // data: [22, 6, 3, 1, 2, 4, 5],
                    backgroundColor: [
                        'rgb(100,180,9)',
                        'rgb(215,156,21)',
                        'rgb(196,40,68)',
                        'rgb(54,78,235)',
                        'rgb(175,54,235)',
                        'rgb(54, 162, 235)',
                        'rgb(18,222,215)'
                    ],
                    hoverOffset: 4
                }]
            };
            this.chartDataSet = {
                type: 'doughnut',
                data: data,
                options: {
                    onClick: this.handleChartClick()
                }
            };
            this.sectionManager(1, false);
            this.showChart = true;
        })
        getUnavailableUsers({unavailableReason: ''}).then(result => {
            this.unavailableUsers = result;
            console.log(result)
            this.unavailableUsers.map(re => re.Name = re.Consultant__r.FirstName + ' ' + re.Consultant__r.LastName)
            console.log('unavail users', JSON.parse(JSON.stringify(this.unavailableUsers)))
            this.data = this.unavailableUsers;
        })
    }

    handleTypeSelected(event) {
        this.filteredUnavailableUsers = this.unavailableUsers.filter(uu => uu.Unavailable_Reason__c.includes(event.detail))
        console.log('filtered list', JSON.parse(JSON.stringify(this.filteredUnavailableUsers)))
        this.data = [{}];
        this.data = this.filteredUnavailableUsers;
        // this.data.map((da) => {
        //     da.Unavailable_Reason__c.picklistOptions  = [{label: 'a', value: 'b'}, {label: 'c', value: 'd'}]
        // })
        console.log('clicked', JSON.parse(JSON.stringify(this.data)));
    }

    handleChartClick() {
        console.log('clicked')
    }

    sectionManager(sectionNumber, closing) {
        this.firstSectionIcon = 'utility:add';
        this.showFirstSection = false;
        this.thirdSectionIcon = 'utility:add';
        this.showThirdSection = false;
        this.secondSectionIcon = 'utility:add';
        this.showSecondSection = false;

        if (sectionNumber === 1 && !closing) {
            // this.firstSectionIcon = 'utility:dash';
            this.showFirstSection = true;
            this.firstSectionIcon = this.firstSectionIcon === 'utility:dash' ? 'utility:add' : 'utility:dash';
        }

        if (sectionNumber === 2 && !closing) {
            // this.secondSectionIcon = 'utility:dash';
            this.showSecondSection = true;
            this.secondSectionIcon = this.secondSectionIcon === 'utility:dash' ? 'utility:add' : 'utility:dash';
        }

        if (sectionNumber === 3 && !closing) {
            // this.thirdSectionIcon = 'utility:dash';
            this.showThirdSection = true;
            this.thirdSectionIcon = this.thirdSectionIcon === 'utility:dash' ? 'utility:add' : 'utility:dash';
        }
    }

    handleRowClick(event) {
        this.selectedOpportunityIds = [];
        this.selectedConsultantIds = [];
        this.selectedUserName = event.detail.row.Name;
        let userId = this.unavailableUsers.find(uu => uu.Name === this.selectedUserName).Consultant__c;
        this.manageUser = true;

        this.sectionManager(2);

        this.firstSectionIcon = 'utility:add';
        this.showFirstSection = false;
        this.thirdSectionIcon = 'utility:add';
        this.showThirdSection = false;

        this.secondSectionIcon = 'utility:dash';
        this.showSecondSection = true;

        this.selectedUserId = userId;
        let event2 = {detail: {id: userId}};
        this.onDataBubbles(event2)
    }

    handleViewAll() {

        this.data = this.unavailableUsers;
    }


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
    @track selectedCampaignName = '';
    @track selectedOppStatus = '';
    @track selectedOppStage = '';
    @track selectedDateFrom = '';
    @track selectedDateTo = '';
    @track searchKeywordConsultant = '';
    @track isNewOppOwnerSelected = false;
    @track newOppOwnerSelectedValue;

    recalculateStages = true;
    recalculateStatuses = true;
    recalculateDates = true;

    @track dateFromMin ;
    @track dateFromMax;

    @track dateToMin;
    @track dateToMax;


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
            value: oo.Id,
            campaignName: oo.BLG_Campaign__r?.Name ? oo.BLG_Campaign__r?.Name : 'No Campaign',
            oppStatus: oo.Status__c,
            oppStage: oo.StageName,
            oppDate: oo.SLA_Deadline__c
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
        this.showSpinner = true;
        getUserOpenOpps({userId: this.selectedUserId}).then(currentOpenOpps => {
            console.log('oops', currentOpenOpps)
            this.openoppsExists = false;
            this.noOpenOpps = false;
            this.openOpps = [];
            this.openOpps = currentOpenOpps;
            const uniqueRegions = Array.from(new Set(this.openOpps.map(oo => oo.Consultant_Region_Name__c)));


            // Create an array of objects with label and value properties for each region
            this.availableRegions = uniqueRegions.map(region => ({label: region, value: region}));

            this.recalculateFilters();
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

    recalculateFilters() {
        this.openOpps.map(oo => {
            oo.reassigned = false,
                oo.Consultant_Region_Name__c = oo.Consultant_Region_Name__c ? oo.Consultant_Region_Name__c : 'Not Applicable',
                oo.Affordability_Amount__c = oo.Affordability_Amount__c ? 'R ' + oo.Affordability_Amount__c : 'Not Applicable';
        });

        // Extract unique regions from openOpps
        this.uniqueCampaigns = Array.from(new Set(this.openOpps.map(oo => oo?.BLG_Campaign__r?.Name ? oo?.BLG_Campaign__r?.Name : 'No Campaign')));
        this.uniqueCampaigns = this.uniqueCampaigns.map(uq => ({
            label: uq,
            value: uq
        }));
        this.uniqueCampaigns.unshift({label: 'All', value: 'All'})

        console.log('filtered opp', this.filteredOppOptions)
        if (this.recalculateStatuses) {
            this.uniqueOppStatuses = Array.from(new Set(this.filteredOppOptions.map(oo => oo.oppStatus)));
            this.uniqueOppStatuses = this.uniqueOppStatuses.map(uq => ({
                label: uq,
                value: uq
            }));
            this.uniqueOppStatuses.unshift({label: 'All', value: 'All'});
        }

        if (this.recalculateStages) {
            this.uniqueOppStages = Array.from(new Set(this.filteredOppOptions.map(oo => oo.oppStage)));
            this.uniqueOppStages = this.uniqueOppStages.map(uq => ({
                label: uq,
                value: uq
            }));
            this.uniqueOppStages.unshift({label: 'All', value: 'All'});
        }
        // if (this.recalculateDates) {
        //     let filteredOpps = this.formattedOpenOpps;
        //     // this.dateFromMax = filteredOpps[0].oppDate?.substring(0, 10);
        //     // this.dateFromMin = filteredOpps[0].oppDate?.substring(0, 10);
        //     // this.dateToMax = filteredOpps[0].oppDate?.substring(0, 10);
        //     // this.dateToMin = filteredOpps[0].oppDate?.substring(0, 10);
        //     let min = '0';
        //     let max = '0';
        //     for (let i = 0; i < filteredOpps.length; i++) {
        //         if (filteredOpps[i]?.oppDate?.substring(0, 10) > this.dateFromMax && filteredOpps[i]?.oppDate !== undefined || max === '0') {
        //             max = filteredOpps[i]?.oppDate?.substring(0, 10);
        //             // this.dateToMax = String.valueOf(filteredOpps[i]?.oppDate?.substring(0, 10));
        //         }
        //         if (filteredOpps[i]?.oppDate?.substring(0, 10) < this.dateFromMin && filteredOpps[i]?.oppDate !== undefined || min === '0') {
        //             min = filteredOpps[i]?.oppDate?.substring(0, 10);
        //             // this.dateToMin = String.valueOf(filteredOpps[i]?.oppDate?.substring(0, 10));
        //         }
        //         this.dateToMin = min;
        //         this.dateToMax = max;
        //         this.dateFromMin = min;
        //         this.dateFromMax = max;
        //
        //     }
        // }
        this.recalculateStages = true;
        this.recalculateStatuses = true;
        this.recalculateDates = true;

    }

    handleRegionChange(event) {
        this.selectedRegion = event.detail.value;
        this.recalculateAvailableConsultants();
    }

    get regionOptions() {
        return this.availableRegions.map((region) => ({label: region.label, value: region.value}));
    }

    handleCampaignChange(event) {
        this.selectedCampaignName = event.detail.value;
        this.selectedOppStage = 'All';
        this.selectedOppStatus = 'All';
        this.selectedDateFrom = undefined;
        this.selectedDateTo = undefined;
        this.recalculateFilters();
    }

    handleOppStageChange(event) {
        this.recalculateStages = false;
        this.selectedOppStage = event.detail.value;
        this.selectedOppStatus = 'All';
        this.selectedDateFrom = undefined;
        this.selectedDateTo = undefined;
        this.recalculateFilters();

    }

    handleOppStatusChange(event) {
        this.selectedDateFrom = undefined;
        this.selectedDateTo = undefined;
        this.recalculateStages = false;
        this.recalculateStatuses = false;
        this.selectedOppStatus = event.detail.value;
        this.recalculateFilters();
    }

    handleDateFromChange(event) {
        this.selectedDateFrom = event.detail.value;
        this.recalculateStages = false;
        this.recalculateStatuses = false;
        this.dateToMin = event.detail.value;
        this.recalculateDates = false;
        this.recalculateFilters();
    }

    handleDateToChange(event) {
        this.selectedDateTo = event.detail.value;
        this.dateFromMax = event.detail.value;
        this.recalculateDates = false;
        this.recalculateFilters();
    }

    handleClearFilters(){
        this.selectedCampaignName = 'All';
        this.selectedOppStage = 'All';
        this.selectedOppStatus = 'All';
        this.selectedDateFrom = '';
        this.selectedDateTo = '';
        this.searchKeywordOpp = '';
        this.dateFromMin = '';
        this.dateFromMax = '';
        this.dateToMax = '';
        this.dateToMin = '';
    }


    get filteredOppOptions() {
        console.log('this.selectedDateFrom',this.selectedDateFrom)
        console.log('this.selectedDateTo',this.selectedDateTo)
        const selectedIdsSet = new Set(this.selectedOpportunityIds);
        const filteredOptions = this.formattedOpenOpps.filter((option) =>
            (option.label.toLowerCase().includes(this.searchKeywordOpp.toLowerCase()) || selectedIdsSet.has(option.value)) &&
            ((!this.selectedCampaignName || this.selectedCampaignName === 'All') || String(option.campaignName) === String(this.selectedCampaignName)) &&
            ((!this.selectedOppStatus || this.selectedOppStatus === 'All') || option.oppStatus === this.selectedOppStatus) &&
            ((!this.selectedOppStage || this.selectedOppStage === 'All') || option.oppStage === this.selectedOppStage) &&
            ((!this.selectedDateFrom || option.oppDate?.substring(0, 10) >= this.selectedDateFrom) &&
            (!this.selectedDateTo || option.oppDate?.substring(0, 10) <= this.selectedDateTo))
        );


        // If "All Regions" is selected, show all open opportunities without filtering
        console.log(filteredOptions)
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