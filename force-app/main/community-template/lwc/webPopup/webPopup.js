/**
 * Created by Igor Malyuta on 28.11.2019.
 */

import { LightningElement, api, track } from 'lwc';

export default class WebPopup extends LightningElement {
    //Attributes--------------------------------------------------------------------------------------------------------
    @api title;
    @api titleImageUrl = '';
    @api headerText; //text before popup body
    @api footerText; //text under popup body
    @api variant = 'normal'; //normal;success;warning;error
    @api size = 'medium'; //small;large;medium

    @api primaryButtonLabel = 'Ok';
    @api secondaryButtonLabel = 'Cancel';
    @api customButtons = false;

    @api showHeader = false;
    @api showFooter = false;
    @api showClose = false;
    @api showScroll = false;
    @api showTitleImage = false;

    @api closeCallback;

    @api showModal = false;
    @api isRTL;

    //Public methods----------------------------------------------------------------------------------------------------
    @api show() {
        console.log('inside show');
        this.showModal = true;
    }

    @api hide() {
        this.showModal = false;
    }

    @api cancel() {
        this.doCancel();
    }

    //Inner methods-----------------------------------------------------------------------------------------------------
    clickedPrimary() {
        this.hide();
    }

    clickedSecondary() {
        this.hide();
    }

    doCancel() {
        this.hide();
        if (this.closeCallback) this.closeCallback();
    }

    //Expressions for html attributes-----------------------------------------------------------------------------------
    get modalClass() {
        return this.showModal ? 'transition-show' : '';
    }

    get containerSizeClass() {
        return 'p-container ' + this.size;
    }

    get iconButtonClass() {
        //slds-modal__close
        return (
            'slds-button slds-button--icon-inverse' +
            (this.showClose ? '' : ' slds-hide') +
            (navigator.userAgent.match(/iPhone/i) ? ' p-mobile-close' : '') +
            (this.isRTL ? ' rtl' : '')
        );
    }

    get divHeaderClass() {
        return 'p-header ' + this.variant;
    }

    get h2Class() {
        return this.showHeader ? '' : ' slds-hide';
    }

    get contentScrollClass() {
        return 'p-content' + (this.showScroll ? ' with-scroll' : '');
    }

    get footerVariantClass() {
        return 'p-footer p-variant-' + this.variant;
    }

    get backDropClass() {
        return 'slds-backdrop' + (this.showModal ? ' slds-backdrop--open' : '' + ' p-backdrop');
    }
}
