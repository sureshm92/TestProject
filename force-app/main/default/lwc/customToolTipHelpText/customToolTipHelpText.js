import { LightningElement, api } from 'lwc';

export default class CustomToolTipHelpText extends LightningElement {
    @api header;
    @api helpText;
    @api top;
    @api left;
    @api width;

    helpTextClass =
        'slds-popover slds-popover_tooltip slds-nubbin_right-bottom slds-fall-into-ground slds-hide popover-position';
    toggleHelpText() {
        this.helpTextClass =
            this.helpTextClass ==
            'slds-popover slds-popover_tooltip slds-nubbin_right-bottom slds-fall-into-ground slds-hide popover-position'
                ? 'slds-popover slds-popover_tooltip slds-nubbin_right-bottom slds-rise-from-ground popover-position'
                : 'slds-popover slds-popover_tooltip slds-nubbin_right-bottom slds-fall-into-ground slds-hide popover-position';
    }

    connectedCallback() {}
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
