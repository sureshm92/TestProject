import { LightningElement, api } from 'lwc';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
export default class PpModal extends LightningElement {
    @api headerText = '';
    @api size = 'medium';
    @api isShow = false;
    @api isHeaderImage = false;
    @api isAlertChanged = false;

    headerPP = pp_community_icons + '/' + 'Modal_Header_PP.png';
    headerWelcome = pp_community_icons + '/' + 'Modal_Header_Welcome.png';
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
