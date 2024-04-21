import { LightningElement, api } from 'lwc';
import My_Resource from '@salesforce/resourceUrl/Televisit_Icons_List';
export default class CustomHelpText extends LightningElement {
    @api top;
    @api left;
    @api width;
    @api relatedAttendees;
    @api ismobile;
    attendeehover = My_Resource + '/televisitAttendees_icon_HOVER.svg';
    attendeewithouthover = My_Resource + '/televisitAttendees_icon.svg';
    //newline = '<br/>';
    helpTextClass =
        'slds-popover slds-popover_tooltip slds-nubbin_right slds-fall-into-ground slds-hide popover-position';
    helpTextClassmobile =
        'slds-popover slds-popover_tooltip slds-nubbin_left slds-fall-into-ground slds-hide popover-position';
    avatareffect = false;
    togglePasswordHint() {
        this.avatareffect = true;
        if(!this.ismobile){
            this.helpTextClass = 'slds-popover slds-popover_tooltip slds-nubbin_right slds-rise-from-ground popover-position';
        }else{
            this.helpTextClassmobile ='slds-popover slds-popover_tooltip slds-nubbin_left slds-rise-from-ground popover-position';
        }
            
        
    }
    togglePasswordHintout() {
        this.avatareffect = false;
        if(!this.ismobile){
            this.helpTextClass ='slds-popover slds-popover_tooltip slds-nubbin_right slds-fall-into-ground slds-hide popover-position';
        }else{
            this.helpTextClassmobile ='slds-popover slds-popover_tooltip slds-nubbin_left slds-fall-into-ground slds-hide popover-position';
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
