import { LightningElement, api } from 'lwc';

export default class PpModalOld extends LightningElement {
    @api headerText = '';
    @api size = 'medium';
    @api isShow = false;

    //Public methods:---------------------------------------------------------------------------------------------------
    @api show() {
        this.isShow = true;
    }

    @api hide() {
        this.isShow = false;
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
