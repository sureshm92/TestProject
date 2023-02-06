import { LightningElement, api } from 'lwc';

export default class CustomToolTipHelpText extends LightningElement {
    @api header;
    @api helpText;
    @api top;
    @api left;
    @api width;
    @api isDesktop;
    @api helpTextClass;
    helpTextClassLocal;

    // helpTextClass =
    //     'slds-popover slds-popover_tooltip slds-nubbin_right-bottom slds-fall-into-ground slds-hide popover-position';
    toggleHelpText() {
        if (this.isDesktop) {
            this.helpTextClassLocal =
                this.helpTextClassLocal ==
                'slds-popover slds-popover_tooltip slds-nubbin_right-bottom slds-fall-into-ground slds-hide popover-position'
                    ? 'slds-popover slds-popover_tooltip slds-nubbin_right-bottom slds-rise-from-ground popover-position'
                    : 'slds-popover slds-popover_tooltip slds-nubbin_right-bottom slds-fall-into-ground slds-hide popover-position';
        }
    }
    onClickToggleHelpText() {
        if (!this.isDesktop) {
            this.helpTextClassLocal =
                this.helpTextClassLocal ==
                'slds-popover slds-popover_tooltip slds-nubbin_top-right slds-fall-into-ground slds-hide popover-position'
                    ? 'slds-popover slds-popover_tooltip slds-nubbin_top-right slds-rise-from-ground popover-position'
                    : 'slds-popover slds-popover_tooltip slds-nubbin_top-right slds-fall-into-ground slds-hide popover-position';
        }
    }
    onMouseLeaveToggleHelpText() {
        if (!this.isDesktop) {
            this.helpTextClassLocal =
                'slds-popover slds-popover_tooltip slds-nubbin_top-right slds-fall-into-ground slds-hide popover-position';
        }
    }
    connectedCallback() {
        this.helpTextClassLocal = this.helpTextClass;
    }
    renderedCallback() {
        let toolTipElement = this.template.querySelector('.popover-position');
        toolTipElement.style.position = 'absolute';
        if (this.top) toolTipElement.style.top = this.top;
        if (this.left) toolTipElement.style.left = this.left;
        if (this.width) toolTipElement.style.width = this.width;
    }
    //Return the help text value which is passed from the parent component.
    get helpTextHeadervalue() {
        return this.header;
    }
    get helpTextValue() {
        return this.helpText;
    }
}