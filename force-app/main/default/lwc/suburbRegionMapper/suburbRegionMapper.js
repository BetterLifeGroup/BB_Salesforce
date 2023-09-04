/**
 * Created by frans fourie on 2023/05/23.
 */

import {LightningElement, track, api} from 'lwc';
import getProvinces from '@salesforce/apex/SuburbRegionMapperController.getProvinces'
import getCities from '@salesforce/apex/SuburbRegionMapperController.getCities'
import getSuburbs from '@salesforce/apex/SuburbRegionMapperController.getSuburbs'
import getRegionId from '@salesforce/apex/SuburbRegionMapperController.getRegionId'
import getRegionId2 from '@salesforce/apex/SuburbRegionMapperController.getRegionId2'
import getSuburbDetails from '@salesforce/apex/SuburbRegionMapperController.getSuburbDetails'
import getRegionAccountId from '@salesforce/apex/SuburbRegionMapperController.getRegionAccountId'
import {FlowNavigationNextEvent} from "lightning/flowSupport";

export default class SuburbRegionMapper extends LightningElement {

    @track provinces = [];
    @track cities = [];
    @track suburbs = [];
    @track provincesHasLoaded = false;
    @track citiesHasLoaded = false;
    @track suburbsHasLoaded = false;
    @track showNextButton = false;
    @track completeSuburb = false;
    @track recordSelected = false;
    @track constantTrue = true;
    // @track selectedRegion;

    @api selectedRegion;
    @api queriedRecordId;
    @api selectedValue = '';
    @api regionAccountId = '';
    @api subBranchAccountId;
    @api Suburb;
    @api City;
    @api Province;
    @api addressLineOne = '';
    @api addressLineTwo = '';
    @api selectedRegionName = '';


    selectedProvince;


    selectedCity;
    selectedSuburb;

    connectedCallback() {

        getProvinces({}).then(result => {
            for (let i = 0; i < result.length; i++) {
                this.provinces.push({label: result[i], value: result[i]})
                this.provincesHasLoaded = true;
            }
        })
    }

    provinceSelected(event) {
        this.selectedCity = null;
        this.selectedSuburb = null;
        this.suburbsHasLoaded = false;
        this.citiesHasLoaded = false;
        this.cities = [];
        this.suburbs = [];
        this.selectedProvince = event.detail.value;
        getCities({province: this.selectedProvince}).then(result => {
            for (let i = 0; i < result.length; i++) {
                this.cities.push({label: result[i], value: result[i]})
                this.citiesHasLoaded = true;
            }
        })
    }

    citySelected(event) {
        this.selectedCity = event.detail.value;
        getSuburbs({province: this.selectedProvince, city: this.selectedCity}).then(result => {
            for (let i = 0; i < result.length; i++) {
                this.suburbs.push({label: result[i], value: result[i]})
                this.suburbsHasLoaded = true;
            }
        })
    }

    suburbSelected(event) {
        this.selectedSuburb = event.detail.value;
        getRegionId({
            province: this.selectedProvince,
            city: this.selectedCity,
            suburb: this.selectedSuburb
        }).then(result => {
            this.selectedRegion = result
            console.log('regionId', this.selectedRegion)
        })
    }

    isInputValid() {
        let isValid = true;
        this.completeSuburb = !(this.selectedSuburb !== undefined || this.selectedValue !== '');
        setTimeout(() => {
            let inputFields = this.template.querySelectorAll('.validate');
            inputFields.forEach(inputField => {
                if (!inputField.checkValidity()) {
                    inputField.reportValidity();
                    isValid = false;
                }
            });
            console.log(isValid)
            if (isValid && this.regionAccountId !== '') {
                const navigateNextEvent = new FlowNavigationNextEvent()
                this.dispatchEvent(navigateNextEvent);
            }
            // return isValid;
        }, 800)

    }

    handleSuburbSelectedName(event) {
        this.selectedValue = event.detail;
    }

    handleSuburbSelected(event) {
        this.recordSelected = true;
        this.selectedSuburb = event.detail;
        getRegionId2({suburb: this.selectedSuburb}).then(result => {
            this.selectedRegion = result;
            getRegionAccountId({regionName: this.selectedRegion}).then(result => {
                this.regionAccountId = result
            })
        })
        getSuburbDetails({suburb: this.selectedSuburb}).then(result => {
            this.City = result.City__c;
            this.Province = result.Province__c;
            this.Suburb = result.Suburb__c;
            console.log(this.City, this.Suburb, this.Province)
        })

        this.subBranchAccountId = this.selectedSuburb;
    }

    handleRecordCleared() {
        this.selectedProvince = null;
        this.selectedCity = null;
        this.selectedSuburb = null;
        // this.relatedAccounts = [];
    }

    handleAddLineOneChange(event) {
        this.addressLineOne = event.detail.value;
    }

    handleAddLineTwoChange(event) {
        this.addressLineTwo = event.detail.value;
    }


}