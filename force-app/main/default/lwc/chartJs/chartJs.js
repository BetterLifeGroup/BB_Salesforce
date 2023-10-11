/**
 * Created by frans fourie on 2023/10/03.
 */

import {LightningElement, track, api} from 'lwc'
import chartjs from '@salesforce/resourceUrl/chartJs';
import {loadScript} from 'lightning/platformResourceLoader';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class ChartJs extends LightningElement {

    @api chartDataset;
    chart;

    connectedCallback() {
        loadScript(this, chartjs)
            .then(() => {
                const ctx = this.template.querySelector('canvas');
                this.chart = new window.Chart(ctx, JSON.parse(JSON.stringify(this.chartDataset)));

            })
            .catch(error => {
                console.log(error)
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading Chart',
                        message: 'error.message',
                        variant: 'error',
                    })
                );
            });

    }


    handleChartClick(event) {
        let activeElement = this.chart.getElementAtEvent(event);
        let selectedType = '';

        switch (activeElement[0]._options.backgroundColor) {
            case 'rgb(100,180,9)': {
                selectedType = 'Available';
                break;
            }
            case 'rgb(215,156,21)': {
                selectedType = 'Lunch';
                break;
            }
            case 'rgb(196,40,68)': {
                selectedType = 'Meeting';
                break;
            }
            case 'rgb(54,78,235)': {
                selectedType = 'Admin';
                break;
            }
            case 'rgb(175,54,235)': {
                selectedType = 'Travelling';
                break;
            }
            case  'rgb(54, 162, 235)': {
                selectedType = 'Annual Leave';
                break;
            }
            case  'rgb(18,222,215)': {
                selectedType = 'Sick Leave';
                break;
            }
        }
        const typeselected = new CustomEvent('typeselected', {
            bubbles: true,
            detail: selectedType
        })
        this.dispatchEvent(typeselected);

    }
};