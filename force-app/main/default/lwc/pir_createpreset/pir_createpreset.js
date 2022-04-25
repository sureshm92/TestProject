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
        console.log('>>filterwrapper>>'+JSON.stringify(this.filterWrapper)); 
        console.log('>>>presetName>>>'+this.filterWrapper.presetName);
    }

    checkCreateButton(event){
         
        if(event.target.value.length != 0)
        {
            console.log('>>presetName>'+event.target.value);
            this.filterWrapperToInsert = JSON.parse(JSON.stringify(this.filterWrapper));
            this.filterWrapperToInsert.presetName = event.target.value;
            this.filterWrapperToInsert.presetId = null;
            this.isNameBlank = false;
        }
        else 
            this.isNameBlank = true;

    }

    closeModel(){
        const closeEventModel = new CustomEvent("closepresetmodel");
        this.dispatchEvent(closeEventModel);
    }

    insertPreset(){
          
         this.isDataloaded = false;
        createPreset({strPresetwrapper:JSON.stringify(this.filterWrapperToInsert) })
        .then((result) => { 
            this.isDataloaded = true;
            if(result == 'duplicateName')
            {
                this.isDataloaded = true;
                const event = new ShowToastEvent({
                    title: "Error",
                    message: "Plesae enter an unique Name",
                    variant: "Error",
                    mode: "sticky",
                  });
                  this.dispatchEvent(event);
            }
            else if(result == 'limitexced'){
                const event = new ShowToastEvent({
                    title: "Error",
                    message: "Preset cannot exced 5",
                    variant: "Error",
                    mode: "sticky",
                  });
                  this.dispatchEvent(event);

            }
            else{ 
                
                 
                const evt = new ShowToastEvent({
                    title: this.filterWrapperToInsert.presetName +" has been created.",
                    message: this.filterWrapperToInsert.presetName +" has been created.",
                    variant: "success",
                    mode: "dismissable"
                  });
                  this.dispatchEvent(evt);
            const closeEventModel = new CustomEvent("closepresetmodel");
            this.dispatchEvent(closeEventModel); 
            }
             
        })
        .catch((error) => { 
           this.isDataloaded = true;
            console.log(error); 
            
        });
    }





}