import { LightningElement, api } from 'lwc';
import BTN_Continue from '@salesforce/label/c.Continue';
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
    @api removeStudyPDId;
    isLoading = false;

    label = {
        BTN_Continue,
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
                pdenrollmentid: this.pdenrollmentid,
                removeStudyPDId: this.removeStudyPDId
            }
        });

        this.dispatchEvent(selectedEvent);
        this.showmodal = false;
    }
}
