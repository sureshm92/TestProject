import { LightningElement, api } from 'lwc';
import BTN_Delete from '@salesforce/label/c.pir_Delete_Btn';
import BTN_Cancel from '@salesforce/label/c.BTN_Cancel';

export default class PpDeleteDelegateModal extends LightningElement {
    @api callback;
    @api messtext;
    @api tittext;
    @api contact;
    @api usermode;
    @api selectedparent;
    @api isDelegate = false;
    @api patientdelegateid;
    @api isDesktop;
    @api isHeaderImage;
    isLoading = false;

    label = {
        BTN_Delete,
        BTN_Cancel
    };

    showmodal = false;

    connectedCallback() {
        this.showmodal = true;
    }

    handleModalClose() {
        const selectedEvent = new CustomEvent('deletemodalclose', {
            detail: false
        });
        this.dispatchEvent(selectedEvent);
    }
    deleteModal() {
        const selectedEvent = new CustomEvent('deletemodal', {
            detail: {
                patientdelegateid: this.patientdelegateid
            }
        });

        this.dispatchEvent(selectedEvent);
        this.showmodal = false;
    }
}
