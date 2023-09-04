/**
 * Created by frans fourie on 2023/05/15.
 */

import {LightningElement, track, api} from 'lwc';

export default class SearchableCombobox extends LightningElement {


    @api options = []; // list of objects
    @api label;
    @api disabled = false;
    @api additionalVariable;
    @api placeHolder = 'Start typing to search...';
    @api selectedValue = '';
    @api iconName = 'utility:record_alt';

    @track devInProgress = false;
    @track showOptions = false;
    @track recordSelected = false;
    @track filteredOptions = [];

    @track dropdownClass = "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
    // comment
    connectedCallback() {
        this.devInProgress = true;
        if (this.selectedValue !== '') {
            this.recordSelected = true;
        }

    }

    handleInputChange(event) {
        console.log('fired')
        this.showOptions = true;
        this.filteredOptions = this.options.filter(op => op.label.toLowerCase().includes(event.detail.value.toLowerCase()));
        this.filteredOptions.length > 10 ? this.filteredOptions.length = 10 : this.filteredOptions;
        console.log(this.filteredOptions)
    }

    handleInputBlur() {
        setTimeout(() => {
            this.showOptions = false;
        }, 2000)

    }

    handleFocus() {
        // this.showOptions = true;
    }

    handleRecordSelect(event) {
        this.selectedValue = event.currentTarget.dataset.name;
        const recordselected = new CustomEvent('recordselected', {
            bubbles: true,
            detail: {id: event.currentTarget.dataset.id, additionalVariable: this.additionalVariable}
        })
        this.dispatchEvent(recordselected);
        this.recordSelected = true;

    }

    removeSelectedRecord() {
        const recordremoved = new CustomEvent('recordremoved', {bubbles: true})
        this.dispatchEvent(recordremoved);
        this.selectedValue = null;
        this.recordSelected = false;
    }

}
