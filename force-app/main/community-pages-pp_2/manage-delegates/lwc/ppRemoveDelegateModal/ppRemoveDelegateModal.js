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
    @api isDesktop;
    @api isHeaderImage;
    isLoading = false;

    label = {
        BTN_Continue,
        BTN_Cancel
    };

    showmodal = false;

    connectedCallback() {
        this.showmodal = true;
    }
    initialRender = true;
    renderedCallback() {
        if (!this.initialRender) {
            return;
        }
        if (this.template.querySelector('.slds-icon-utility-close ')) {
            this.template.querySelector('.slds-icon-utility-close ').classList.add('slds-hide');
            this.initialRender = false;
        }
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
