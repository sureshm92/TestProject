import { LightningElement, api } from 'lwc';
import BTN_Confirm from '@salesforce/label/c.BTN_Confirm';
import BTN_Cancel from '@salesforce/label/c.BTN_Cancel';

export default class PpRemoveDelegateModalOld extends LightningElement {
    @api callback;
    @api messtext;
    @api tittext;
    @api contact;
    @api usermode;
    @api selectedparent;
    @api isDelegate = false;
    @api pdenrollmentid;
    isLoading = false;

    label = {
        BTN_Confirm,
        BTN_Cancel
    };

    showmodal = false;

    connectedCallback() {
        this.showmodal = true;
    }

    handleModalClose() {
        const selectedEvent = new CustomEvent('modalclose', {
            detail: false
        });
        this.dispatchEvent(selectedEvent);
    }
    confirmModal() {
        const selectedEvent = new CustomEvent('confirmmodal', {
            detail: {
                pdenrollmentid: this.pdenrollmentid
            }
        });

        this.dispatchEvent(selectedEvent);
        this.showmodal = false;
    }
}
