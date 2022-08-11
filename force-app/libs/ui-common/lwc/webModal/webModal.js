/**
 * Created by Igor Malyuta on 27.11.2019.
 */

import { LightningElement, api } from 'lwc';

export default class WebModal extends LightningElement {
    @api isShow;
    @api headerText;
    @api size = 'medium';
    @api cancelCallback;
    @api ppBackgroundRequired = false;

    //Public methods:---------------------------------------------------------------------------------------------------
    @api show() {
        this.isShow = true;
    }

    @api hide() {
        this.isShow = false;
    }

    @api cancel() {
        if (this.cancelCallback) this.cancelCallback();
        this.hide();
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
}
