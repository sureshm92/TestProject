import { api, LightningElement } from 'lwc';

import createPreset from "@salesforce/apex/PIR_HomepageController.createPreset";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import pirResources from '@salesforce/resourceUrl/pirResources';


export default class Pir_PresetEdit extends LightningElement {
    
    editIcon = pirResources+'/pirResources/icons/pencil.svg';
    @api
    opts;
    @api
    allPresets;
    @api
    presetSel;
    @api 
    presetSelectedName;
    filterVal;
    isUpdating = false;
    showFilter=false;
    selectedPresetWrapper;
    shoulddisplaydelete = false;
    
    @api
    get selectedFilter(){ return true;}
    set selectedFilter(value){
        this.filterVal = value;
        this.selectedPresetWrapper = value;
        this.showFilter = true;
        this.presetSelectedName=value.presetName;
        this.seletedPresetName = value.presetName;
    }
    closeModel(){
        const closeEventModel = new CustomEvent("closepresetmodel");
        this.dispatchEvent(closeEventModel);
    }
    handlePresetChange(event){
        for(var i=0;i<this.allPresets.length;i++){
            if(event.detail.value==this.allPresets[i].presetId){
                this.template.querySelector("c-pir_filter").presetWrapperSet(this.allPresets[i]); 
                this.cantUpdate = true;
                this.filterErr=false;
                this.filterUpdated=false;
                this.selectedPresetWrapper = this.allPresets[i];
                this.presetSel = this.allPresets[i].presetId;
                this.presetSelectedName = this.allPresets[i].presetName;
                this.seletedPresetName = this.allPresets[i].presetName;
                console.log('>>>presetName on handle>>'+this.allPresets[i].presetName);
                break;
            }
        }
    }
    cantUpdate = true;
    updatedWR={};
    filterErr=false;
    filterUpdated=false;
    checkUpd(event){
        var updWraper = event.detail.fw;
        this.updatedWR = updWraper;
        this.filterErr=event.detail.err;
        this.filterUpdated=JSON.stringify(this.selectedPresetWrapper)!=JSON.stringify(updWraper).replace(',"ethnicityList":[]', '');
        if(event.detail.err || JSON.stringify(this.selectedPresetWrapper)==JSON.stringify(updWraper).replace(',"ethnicityList":[]', '')){
            console.log(this.seletedPresetName+">>"+this.presetSelectedName);
            if(!event.detail.err && this.seletedPresetName!=this.presetSelectedName) {
                this.cantUpdate = false;;
            }
            else{
                this.cantUpdate = true;
            }
        }     
        else{            
            this.cantUpdate = false;
        }
    }
    updatePR(){
        this.isUpdating = true;
        if(Object.keys(this.updatedWR).length === 0){
            this.updatedWR=this.selectedPresetWrapper;
        }
        this.updatedWR.presetName = this.seletedPresetName;
        let successMessage = this.updatedWR.presetName +" successfuly updated.";
        let uniqueNameMessage = this.updatedWR.presetName + "already exists please enter another name to continue";
        createPreset({strPresetwrapper : JSON.stringify(this.updatedWR),isUpdate:true})
        .then((result) => {
            this.isUpdating = false;
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
            else {
                const evt = new ShowToastEvent({
                    title: successMessage,
                    message: '{0}',
                    messageData: [successMessage],
                    variant: "success",
                    mode: "dismissable"
                  });
                  this.dispatchEvent(evt);
            }
        })
        .catch((error) => {
            this.isUpdating = false;
            console.error("Error:", error);
        });
    }
    deletePR(){
        this.shoulddisplaydelete = true; 
    }
    closeDeletemodel(){
        this.shoulddisplaydelete = false;
    }
    isnameUpdate=false;
    seletedPresetName='';
    editname(){
        this.isnameUpdate=true;
    }
    handleNameChange(event){
        let val = event.target.value;
        let tempval= val.trim();
        if(tempval ==''){
            event.target.value = tempval;
            val = tempval;
        }
        this.seletedPresetName =val;
        if(!this.filterUpdated){
            if(!this.filterErr && this.seletedPresetName!=this.presetSelectedName){
                this.cantUpdate=false;
            }
            else{
                this.cantUpdate = true;
            }
        }
    }
    updateName(event){
        //this.isnameUpdate=false;
    }
}