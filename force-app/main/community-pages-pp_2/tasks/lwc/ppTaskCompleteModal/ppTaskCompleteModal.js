import { LightningElement, api } from 'lwc';
import BTN_Confirm from '@salesforce/label/c.BTN_Confirm';
import BTN_Cancel from '@salesforce/label/c.BTN_Cancel';
import taskMarkCompleteHeader from '@salesforce/label/c.Task_Mark_Complete';
import taskMarkComplete from '@salesforce/label/c.Task_Mark_Complete_Msg';

export default class PpTaskCompleteModal extends LightningElement {
    @api contact;
    @api usermode;
    @api selectedparent;
    isLoading = false;

    label = {
        BTN_Confirm,
        BTN_Cancel,
        taskMarkCompleteHeader,
        taskMarkComplete
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
