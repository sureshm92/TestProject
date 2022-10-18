import { LightningElement,api } from 'lwc';


import BTN_Delete from '@salesforce/label/c.pir_Delete_Btn';
import BTN_Back from '@salesforce/label/c.BTN_Back';
import PIR_Attachment_Delete_Preset_Popup_1 from '@salesforce/label/c.PIR_Attachment_Delete_Preset_Popup_1';
import PIR_Delete_Preset_Popup_2 from '@salesforce/label/c.PIR_Delete_Preset_Popup_2';
import PIR_Delete_Attachment from '@salesforce/label/c.PIR_Delete_Attachment';

export default class Pir_deletemedicaldocument extends LightningElement {
    BTN_Delete = BTN_Delete;
    BTN_Back = BTN_Back;
    PIR_Attachment_Delete_Preset_Popup_1 = PIR_Attachment_Delete_Preset_Popup_1;
    PIR_Delete_Preset_Popup_2 = PIR_Delete_Preset_Popup_2;
    PIR_Delete_Attachment = PIR_Delete_Attachment;

    @api maindivcls;
    @api deleteid;

    closeWithDeleting(){
        const closemodel = new CustomEvent("closemodelpopupanddelete",{
            detail: {deleteAttachment : true, docid : this.deleteid}
          }) ;
        this.dispatchEvent(closemodel); 
    }
    //close model for refresh
    closeWithoutDeleting() {
        const closemodel = new CustomEvent("closemodelpopupanddelete",{
            detail: {deleteAttachment : false, docid : this.deleteid}
          }) ;
        this.dispatchEvent(closemodel);        
    }

    closeUploadModal(){
        const closemodel = new CustomEvent("closemodelpopupanddelete",{
            detail: {deleteAttachment : false, docid : this.deleteid}
          }) ;
        this.dispatchEvent(closemodel);
    }
}