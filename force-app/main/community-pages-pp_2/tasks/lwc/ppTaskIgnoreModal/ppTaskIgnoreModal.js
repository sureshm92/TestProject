import { LightningElement, api } from 'lwc';
import BTN_Confirm from '@salesforce/label/c.BTN_Confirm';
import taskIgnoreContinue from '@salesforce/label/c.Continue';
import BTN_Cancel from '@salesforce/label/c.BTN_Cancel';
import taskIgnoreModalTitle from '@salesforce/label/c.Task_Ignore_Modal_Title';
import taskIgnoreModalBody from '@salesforce/label/c.Task_Ignore_Modal_Body';

export default class PpTaskIgnoreModal extends LightningElement {
    @api contact;
    @api usermode;
    @api selectedparent;
    isLoading = false;

    label = {
        BTN_Confirm,
        BTN_Cancel,
        taskIgnoreModalTitle,
        taskIgnoreModalBody,
        taskIgnoreContinue
    };

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
                contact: this.contact,
                usermode: this.usermode,
                selectedparent: this.selectedparent
            }
        });

        this.dispatchEvent(selectedEvent);
        this.showmodal = false;
    }
}
