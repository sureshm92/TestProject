import { LightningElement, api } from 'lwc';
import MODAL_HEADER_PP from '@salesforce/resourceUrl/Modal_Header_PP.png';
import MODAL_HEADER_WELCOME from '@salesforce/resourceUrl/Modal_Header_Welcome.png';
export default class PpModal extends LightningElement {
    @api headerText = '';
    @api size = 'medium';
    @api isShow = false;
    @api isHeaderImage = false;
    @api isAlertChanged = false;

    headerPP = MODAL_HEADER_PP;
    headerWelcome = MODAL_HEADER_WELCOME;
    //Public methods:---------------------------------------------------------------------------------------------------
    @api show() {
        this.isShow = true;
    }

    @api hide() {
        this.isShow = false;
    }

    get headerImage() {
        return this.isAlertChanged ? this.headerPP : this.headerWelcome;
    }

    //Expressions for html attributes-----------------------------------------------------------------------------------
    get sectionClass() {
        return (
            'slds-modal ' +
            (this.size === 'small' ? 'web-modal-window' : 'slds-modal_' + this.size) +
            (this.isShow ? ' slds-fade-in-open ' : '')
        );
    }

    get backDropClass() {
        return 'slds-backdrop ' + (this.isShow ? ' slds-backdrop_open ' : '');
    }

    get topBackground() {
        return this.ppBackgroundRequired ? 'slds-grid card-top-bg' : 'slds-hide';
    }

    handleCloseModal() {
        this.dispatchEvent(
            new CustomEvent('close', {
                detail: false
            })
        );
    }
}
