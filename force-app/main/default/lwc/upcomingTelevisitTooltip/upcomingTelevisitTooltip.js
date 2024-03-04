import { LightningElement, api } from 'lwc';
import myPNG_icon from '@salesforce/resourceUrl/Icon';
export default class UpcomingTelevisitTooltip extends LightningElement {
    @api top;
    @api left;
    @api width;
    @api relatedAttendees;
    @api ismobile;
    @api displaytext;
    @api isIpad;
    peoplePng = myPNG_icon;
    floatClass;
    toolTipBox;
    helpTextClass =
        'slds-popover slds-popover_tooltip slds-nubbin_right slds-fall-into-ground slds-hide popover-position';
    helpTextClassmobile =
        'slds-popover slds-popover_tooltip slds-nubbin_left slds-fall-into-ground slds-hide popover-position';

    togglePasswordHint() {
        if (!this.ismobile) {
            if (this.isIpad) {
                this.helpTextClass =
                    this.helpTextClass ==
                        'slds-popover slds-popover_tooltip slds-nubbin_left slds-fall-into-ground slds-hide popover-position'
                        ? 'slds-popover slds-popover_tooltip slds-nubbin_left slds-rise-from-ground popover-position'
                        : 'slds-popover slds-popover_tooltip slds-nubbin_left slds-fall-into-ground slds-hide popover-position';
            } else {
                this.helpTextClass =
                    this.helpTextClass ==
                        'slds-popover slds-popover_tooltip slds-nubbin_right slds-fall-into-ground slds-hide popover-position'
                        ? 'slds-popover slds-popover_tooltip slds-nubbin_right slds-rise-from-ground popover-position'
                        : 'slds-popover slds-popover_tooltip slds-nubbin_right slds-fall-into-ground slds-hide popover-position';
            }
        } else {
            this.helpTextClassmobile =
                this.helpTextClassmobile ==
                    'slds-popover slds-popover_tooltip slds-nubbin_left slds-fall-into-ground slds-hide popover-position'
                    ? 'slds-popover slds-popover_tooltip slds-nubbin_left slds-rise-from-ground popover-position'
                    : 'slds-popover slds-popover_tooltip slds-nubbin_left slds-fall-into-ground slds-hide popover-position';
        }


    }

    connectedCallback() {
        console.log('relatedAttendees' + this.relatedAttendees);
        this.floatClass = this.isIpad ? '' : 'slds-float_right';
        this.toolTipBox = this.isIpad ? 'width: 120px;position: absolute;left: 65px;text-align:left;' : 'width: 270px;position: absolute;left: 37px;text-align:left;';
        if (this.isIpad) {
            this.helpTextClass =
                'slds-popover slds-popover_tooltip slds-nubbin_left slds-fall-into-ground slds-hide popover-position';
        } else {
            this.helpTextClass =
                'slds-popover slds-popover_tooltip slds-nubbin_right slds-fall-into-ground slds-hide popover-position';
        }
    }
    renderedCallback() {

    }

    get helpTextHeadervalue() {
        return this.header;
    }
    get helpTextValue() {
        return this.helpText;
    }
}