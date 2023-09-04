/**
 * Created by frans fourie on 2023/06/21.
 */

import {LightningElement, track} from 'lwc';
import getRealEstateAgentsByAccountId from '@salesforce/apex/UserManagementController.getRealEstateAgentsByAccountId';

export default class UserManagementReAgents extends LightningElement {

    @track constantTrue = true;

    @track returnedAgents = [];

    @track dataHasLoaded = false;


}