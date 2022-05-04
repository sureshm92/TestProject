import { LightningElement,api } from 'lwc';
import createPreset from "@salesforce/apex/PIR_HomepageController.createPreset";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PIR_Preset_Created_Message from "@salesforce/label/c.PIR_Preset_Created_Message";
import pir_presetUniqueName from "@salesforce/label/c.pir_presetUniqueName";
import pir_preset_count from "@salesforce/label/c.pir_preset_count";
import PIR_CreatePresetPopup from "@salesforce/label/c.PIR_CreatePresetPopup";
import BTN_Close from "@salesforce/label/c.BTN_Close";
import Create from "@salesforce/label/c.Create";
import BTN_Cancel from "@salesforce/label/c.BTN_Cancel";
import PIR_CreatePreset from "@salesforce/label/c.PIR_CreatePreset";
import PresetName from "@salesforce/label/c.PIR_PresetName";
 
export default class Pir_createpreset extends LightningElement {

    label={PIR_Preset_Created_Message
           ,pir_presetUniqueName
            ,pir_preset_count
            ,PIR_CreatePresetPopup
            ,BTN_Close
            ,Create,BTN_Cancel
            ,PIR_CreatePreset
            ,PresetName
        };
    
    @api maindivcls;    
    @api
    filterWrapper;
    filterWrapperToInsert;
    isNameBlank = false;
    isDataloaded = false;

    connectedCallback(){
        this.isNameBlank = true;
        this.isDataloaded = true;
    }

    checkCreateButton(event){
         
         var getPresetName = event.target.value; 
        if(getPresetName.trim())
        {
            this.filterWrapperToInsert = JSON.parse(JSON.stringify(this.filterWrapper));
            this.filterWrapperToInsert.presetName = getPresetName.trim();
            this.filterWrapperToInsert.presetId = null;
            this.isNameBlank = false;
        }
        else 
            this.isNameBlank = true;
    }

    closeModel(){
        const closeEventModel = new CustomEvent("closepresetmodel", {
            detail: "closed"
            });
        this.dispatchEvent(closeEventModel);
    }
    
    insertPreset(){
         this.isDataloaded = false;
         let presetNameEnter = this.filterWrapperToInsert.presetName;
        let successMessage = presetNameEnter + " " +this.label.PIR_Preset_Created_Message;
        let uniqueNameMessage = presetNameEnter + " " +this.label.pir_presetUniqueName;
         
        createPreset({strPresetwrapper:JSON.stringify(this.filterWrapperToInsert),isUpdate:false })
        .then((result) => { 
            this.isDataloaded = true;
            if(result == 'duplicateName')
            {  
                const event = new ShowToastEvent({
                    title: "Error",
                    message: '{0}',
                    messageData: [uniqueNameMessage],
                    variant: "Error",
                    mode: "sticky",
                  });
                  this.dispatchEvent(event);
            }
            else if(result == 'limitexced'){
                const event = new ShowToastEvent({
                    title: "Error",
                    message: this.label.pir_preset_count,
                    variant: "Error",
                    mode: "sticky",
                  });
                  this.dispatchEvent(event);

            }
            else{  
                const evt = new ShowToastEvent({
                    title: successMessage,
                    message: '{0}',
                    messageData: [successMessage],
                    variant: "success",
                    mode: "dismissable"
                  });
                  this.dispatchEvent(evt);
                 
                  const closeEventModel = new CustomEvent("closepresetmodel", {
                    detail: "created"
                    });
                this.dispatchEvent(closeEventModel); 
            }
             
        })
        .catch((error) => { 
           this.isDataloaded = true;
            console.log(error); 
            
        });
    }





}