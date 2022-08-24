import { LightningElement, api } from 'lwc';
import BTN_Confirm from '@salesforce/label/c.BTN_Confirm';
import BTN_Cancel from '@salesforce/label/c.BTN_Cancel';
import PP_Delegate_Deactivated from '@salesforce/label/c.PP_Delegate_Deactivated';

export default class PpRemoveDelegateModal extends LightningElement {
    @api callback;
    @api messtext;
    @api tittext;
    @api contact;
    @api usermode;
    @api selectedparent;
    @api isDelegate = false;
    isLoading = false;

    label = {
        BTN_Confirm,
        BTN_Cancel,
        PP_Delegate_Deactivated
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
                contact: this.contact,
                usermode: this.usermode,
                selectedparent: this.selectedparent
            }
        });

        this.dispatchEvent(selectedEvent);
        this.showmodal = false;
        communityService.showToast(
            '',
            'success',
            this.label.PP_Delegate_Deactivated 
        );

    }
}
