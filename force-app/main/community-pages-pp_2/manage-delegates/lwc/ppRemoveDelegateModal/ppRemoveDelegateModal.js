import { LightningElement,api } from 'lwc';

export default class PpRemoveDelegateModal extends LightningElement {
    @api callback;
    @api messtext;
    @api tittext;
    @api contact;
    @api usermode;
    @api selectedparent;
    isLoading = false;

    showmodal = false;
    connectedCallback() {
        this.showmodal = true;

    }

    closeModal() {
        const selectedEvent = new CustomEvent('modalclose', {
            detail: false
        });
        this.dispatchEvent(selectedEvent);
    }
    confirmModal(){
        const selectedEvent = new CustomEvent('confirmmodal', {
            detail: {contact : this.contact, usermode: this.usermode, selectedparent : this.selectedparent}
        });

        this.dispatchEvent(selectedEvent);
        this.showmodal = false;
    }
}
