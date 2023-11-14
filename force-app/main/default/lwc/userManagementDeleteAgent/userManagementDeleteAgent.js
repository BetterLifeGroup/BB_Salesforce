/**
 * Created by frans fourie on 2023/10/30.
 */

import {LightningElement, track, api} from 'lwc';

export default class UserManagementDeleteAgent extends LightningElement {

    @track constantTrue = true;

    handleSelectionCleared(event) {
        console.log('cleared',JSON.parse(JSON.stringify(event)));
    }

    onDataBubbles(event) {
        console.log('bubbles',JSON.parse(JSON.stringify(event)));
    }

}