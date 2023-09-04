/**
 * Created by frans fourie on 2023/06/21.
 */

import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class ReusableModal extends LightningModal {

    @api content;
    @api options = [];

    handleOkay() {
        this.close('okay');
    }
    handleOptionClick(e) {
        const { target } = e;
        const { id } = target.dataset;
        // this.close() triggers closing the modal
        // the value of `id` is passed as the result
        this.close(id);
    }
}