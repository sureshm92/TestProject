import { api, LightningElement } from 'lwc';
import deletePreset from "@salesforce/apex/PIR_HomepageController.deletePreset";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 
export default class Pir_deletepreset extends LightningElement {

    @api
    selectedpreset;
    isDeleted = false;

    connectedCallback(){ 
        console.log('>>>prsetId>>>'+this.selectedpreset.presetId);
        console.log('>>>presetName>>>'+this.selectedpreset.presetName);
    }

    deletePreset(){
        this.isDeleted = true;
        let deleteMessage = this.selectedpreset.presetName +" has been deleted.";
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
            const closeEventModel = new CustomEvent("closedeletemodel");
            this.dispatchEvent(closeEventModel);
        })
        .catch((error) => {
            this.isDeleted = false;
            console.error("Error:", error);
        });

    }


    closeModel(){ 
        const closeEventModel = new CustomEvent("closedeletemodel");
        this.dispatchEvent(closeEventModel);
    }



}