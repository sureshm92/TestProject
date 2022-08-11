import { LightningElement } from 'lwc';

export default class PpRemoveDelegateModal extends LightningElement {
    closeModal() {
        const selectedEvent = new CustomEvent('modalclose', {
            detail: false
        });
        this.dispatchEvent(selectedEvent);
    }
}
