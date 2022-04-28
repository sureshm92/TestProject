import { api, LightningElement } from 'lwc';
import deletePreset from "@salesforce/apex/PIR_HomepageController.deletePreset";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PIR_Delete_Preset from "@salesforce/label/c.PIR_Delete_Preset";
import PIR_Preset_Delete_Message from "@salesforce/label/c.PIR_Preset_Delete_Message";
import PIR_Delete_Preset_Popup_1 from "@salesforce/label/c.PIR_Delete_Preset_Popup_1";
import PIR_Delete_Preset_Popup_2 from "@salesforce/label/c.PIR_Delete_Preset_Popup_2";
import BTN_Close from "@salesforce/label/c.BTN_Close";
import BTN_Back from "@salesforce/label/c.BTN_Back";
import pir_Delete_Btn from "@salesforce/label/c.pir_Delete_Btn";
 
export default class Pir_deletepreset extends LightningElement {

    label = {PIR_Preset_Delete_Message,PIR_Delete_Preset
            ,BTN_Close,PIR_Delete_Preset_Popup_1,PIR_Delete_Preset_Popup_2 
             ,pir_Delete_Btn,BTN_Back};

    @api
    selectedpreset;
    isDeleted = false; 

    deletePreset(){
        this.isDeleted = true;
        let deleteMessage = this.selectedpreset.presetName + " " +this.label.PIR_Preset_Delete_Message;
        deletePreset({strPresetwrapper : JSON.stringify(this.selectedpreset)})
        .then((result) => {
            this.isDeleted = false;
            const evt = new ShowToastEvent({
                title: deleteMessage,
                message: '{0}',
                messageData: [deleteMessage],
                variant: "success",
                mode: "dismissable"
            });
            this.dispatchEvent(evt);
            const closeEventModel = new CustomEvent("closedeletemodel", {
            detail: this.selectedpreset.presetId
            });
            this.dispatchEvent(closeEventModel);
        })
        .catch((error) => {
            this.isDeleted = false;
            console.error("Error:", error);
        });

    }


    closeModel(){ 
        const closeEventModel = new CustomEvent("closedeletemodel", {
            detail: "closed"
            });
        this.dispatchEvent(closeEventModel);
    }



}