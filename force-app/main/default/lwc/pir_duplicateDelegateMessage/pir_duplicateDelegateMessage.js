import { LightningElement, api } from 'lwc';
import Duplicatelabel from '@salesforce/label/c.Duplicate_Delegate_Message';
import updatelabel from '@salesforce/label/c.Create_Update_Delegate_Info';
import BTN_Create_New_Delegate from '@salesforce/label/c.BTN_Create_New_Delegate';
import BTN_Updating_Existing_Delegate from '@salesforce/label/c.BTN_Updating_Existing_Delegate';
import UseEnteredEmailAddress from '@salesforce/label/c.BTN_Use_Entered_Email_Address';
import myResource from '@salesforce/resourceUrl/icon_statusAlertOrange';

export default class Pir_duplicateDelegateMessage extends LightningElement {
    @api duplicateInfo;
    @api isNotDupMsg = false;
    duplicateMessage;
    imgSrc= myResource;  
    label = {
        Duplicatelabel,
        UseEnteredEmailAddress,
        updatelabel,
        BTN_Create_New_Delegate,
        BTN_Updating_Existing_Delegate
    }

    connectedCallback() {    
        if(!this.isNotDupMsg){
            // this.imgSrc = myResource;     
            let msg = this.label.Duplicatelabel;
            msg = msg.replace(new RegExp('##firstName', 'g'), this.duplicateInfo.firstName);
            msg = msg.replace('##lastName', this.duplicateInfo.lastName);

            this.duplicateMessage = msg;
        }
    }

    onClickHandler() {
        this.dispatchEvent(new CustomEvent('useduplicaterecord', { bubbles: true, composed: true }));
        
    }
    createNew(){
        this.dispatchEvent(new CustomEvent('createupdate', {  detail: "insert"  }));
    }
    useExisting(){
        this.dispatchEvent(new CustomEvent('createupdate', {  detail: "update" }));       
    }
}