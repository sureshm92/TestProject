import { LightningElement,api } from 'lwc';
import createPreset from "@salesforce/apex/PIR_HomepageController.createPreset";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 
export default class Pir_createpreset extends LightningElement {

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
            console.log('>>presetName>'+event.target.value);
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
        let successMessage = presetNameEnter +" has been created.";
        let uniqueNameMessage = presetNameEnter + "already exists please enter another name to continue"
         
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
                    message: "You have reached maximum permissible limit, please delete a preset to continue.",
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