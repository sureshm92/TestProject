import { LightningElement, api } from 'lwc';
import myPNG_icon from '@salesforce/resourceUrl/Icon';
export default class UpcomingTelevisitTooltip extends LightningElement {
    @api top;
    @api left;
    @api width;
    @api relatedAttendees;
    @api ismobile;
    @api displaytext;
    peoplePng = myPNG_icon;
    //newline = '<br/>';
    helpTextClass =
        'slds-popover slds-popover_tooltip slds-nubbin_right slds-fall-into-ground slds-hide popover-position';
    helpTextClassmobile =
        'slds-popover slds-popover_tooltip slds-nubbin_left slds-fall-into-ground slds-hide popover-position';

    togglePasswordHint() {
        if(!this.ismobile){
            this.helpTextClass =
            this.helpTextClass ==
            'slds-popover slds-popover_tooltip slds-nubbin_right slds-fall-into-ground slds-hide popover-position'
                ? 'slds-popover slds-popover_tooltip slds-nubbin_right slds-rise-from-ground popover-position'
                : 'slds-popover slds-popover_tooltip slds-nubbin_right slds-fall-into-ground slds-hide popover-position';
        }else{
            this.helpTextClassmobile =
            this.helpTextClassmobile ==
            'slds-popover slds-popover_tooltip slds-nubbin_left slds-fall-into-ground slds-hide popover-position'
                ? 'slds-popover slds-popover_tooltip slds-nubbin_left slds-rise-from-ground popover-position'
                : 'slds-popover slds-popover_tooltip slds-nubbin_left slds-fall-into-ground slds-hide popover-position';
        }
            
        
    }

    connectedCallback() {
        console.log('relatedAttendees'+this.relatedAttendees);
    }
    renderedCallback() {
        /*let toolTipElement = this.template.querySelector('.popover-position');
        toolTipElement.style.position = 'absolute';
        if (this.top) toolTipElement.style.top = this.top;
        if (this.left) toolTipElement.style.left = this.left;
        if (this.width) toolTipElement.style.width = this.width;*/
    }
    //Return the help text value which is passed from the parent component.
    get helpTextHeadervalue() {
        return this.header;
    }
    get helpTextValue() {
        return this.helpText;
    }
}