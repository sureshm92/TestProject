import { LightningElement, api } from 'lwc';
import Duplicatelabel from '@salesforce/label/c.Duplicate_Delegate_Message';
import myResource from '@salesforce/resourceUrl/icon_statusAlertOrange';

export default class Pir_duplicateDelegateMessage extends LightningElement {
    @api duplicateInfo;
    duplicateMessage;
    imgSrc;
    label = {
        Duplicatelabel
    }

    connectedCallback() {    
        this.imgSrc = myResource;     
        let msg = this.label.Duplicatelabel;
        msg = msg.replace(new RegExp('##firstName', 'g'), this.duplicateInfo.firstName);
        msg = msg.replace('##lastName', this.duplicateInfo.lastName);

        this.duplicateMessage = msg;

    }

}