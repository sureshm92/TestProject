import { LightningElement, api } from 'lwc';
import PopupHeader from '@salesforce/label/c.PIR_Discard_Changes';
import BackBtnText from '@salesforce/label/c.BTN_Back';
import DiscardBtnText from '@salesforce/label/c.PIR_Discard';
import PopupBody from '@salesforce/label/c.PIR_PopupMessage';

export default class Pir_notificationOnTabChange extends LightningElement {

    label = {
        PopupHeader,
        BackBtnText,
        DiscardBtnText,
        PopupBody
    };
    @api maindivcls;

    handleCloseModal() {
        this.dispatchEvent(new CustomEvent('notificationevent', { detail:{'action':'close'} }));

        
    }
    doDiscard() {
        this.dispatchEvent(new CustomEvent('notificationevent', { detail:{'action':'discard'} }));
    }
}