import { api, LightningElement } from 'lwc';

import createPreset from "@salesforce/apex/PIR_HomepageController.createPreset";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import pirResources from '@salesforce/resourceUrl/pirResources';
import fetchPreset from '@salesforce/apex/PIR_HomepageController.fetchPreset';
import pir_presetUniqueName from "@salesforce/label/c.pir_presetUniqueName";
import pir_updatePreset from "@salesforce/label/c.pir_updatePreset";


export default class Pir_PresetEdit extends LightningElement {

    label = { pir_presetUniqueName ,
              pir_updatePreset };
    
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
    updatedWR={};
    
    @api
    get selectedFilter(){ return true;}
    set selectedFilter(value){
        if(this.presetSel != "no preset"){
            this.filterVal = JSON.parse(JSON.stringify(value));;
            this.selectedPresetWrapper = JSON.parse(JSON.stringify(value));;
            this.showFilter = true;
            this.presetSelectedName=value.presetName;
            this.seletedPresetName = value.presetName;
            this.updatedWR  = JSON.parse(JSON.stringify(value));
        }
        else{
            this.presetSel = this.allPresets[0].presetId;
            this.filterVal = JSON.parse(JSON.stringify(this.allPresets[0]));
            this.selectedPresetWrapper = JSON.parse(JSON.stringify(this.allPresets[0]));
            this.showFilter = true;
            this.presetSelectedName=this.allPresets[0].presetName;
            this.seletedPresetName = this.allPresets[0].presetName;
            this.updatedWR  = JSON.parse(JSON.stringify(this.allPresets[0]));
        }
        var optsTemp =[];
        for(var i = 1; i<this.opts.length;i++){
            optsTemp.push(this.opts[i]);
        }
        this.opts=optsTemp;
    }
    closeModel(){
        const closeEventModel = new CustomEvent("closepresetmodel", {
            detail: {upd:this.isUpdatePreset,upList:this.updList,delList:this.delList}
            });
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
                this.updatedWR = JSON.parse(JSON.stringify(this.allPresets[i]));
                console.log('>>>presetName on handle>>'+this.allPresets[i].presetName);
                break;
            }
        }
    }
    cantUpdate = true;
   
    filterErr=false;
    filterUpdated=false;
    checkUpd(event){
        console.log('>>coming 75>'+event.detail.err);
        var updWraper = event.detail.fw;
        this.updatedWR = updWraper;
        this.filterErr=event.detail.err;
        this.filterUpdated=JSON.stringify(this.selectedPresetWrapper)!=JSON.stringify(updWraper).replace(',"ethnicityList":[]', '');
        console.log('>>coming 80>'+JSON.stringify(this.selectedPresetWrapper));
        console.log('>>coming 81>'+JSON.stringify(updWraper));
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
        
        if(this.seletedPresetName == ""){
            this.cantUpdate = true;
        }
    }
    updatePR(){
        this.isUpdating = true;
        this.updatedWR.presetName = this.seletedPresetName;
        let successMessage = this.updatedWR.presetName + " " +this.label.pir_updatePreset;
        let uniqueNameMessage = this.updatedWR.presetName + " " +this.label.pir_presetUniqueName;
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
                  this.updList +=','+this.updatedWR.presetId;
                  this.refreshAllPreset();
            }
        })
        .catch((error) => {
            this.isUpdating = false;
            console.error("Error:", error);
        });
       
        
    }
    isUpdatePreset = false;
    delList="";
    updList="";
    refreshAllPreset(){
        var presets = [];
        this.updatedWR ={};
        fetchPreset()
        .then(data => {
            this.allPresets = data;
            for(var i=0;i<data.length;i++){
                if(this.presetSel == data[i].presetId){
                    this.template.querySelector("c-pir_filter").presetWrapperSet(data[i]); 
                    this.cantUpdate = true;
                    this.filterErr=false;
                    this.filterUpdated=false;
                    this.selectedPresetWrapper = data[i];
                    this.presetSel = data[i].presetId;
                    this.presetSelectedName = data[i].presetName;
                    this.seletedPresetName = data[i].presetName;
                     
                }
                presets.push({ label: data[i].presetName, value: data[i].presetId });
            }
            this.opts = presets;
            this.isnameUpdate = false;
            this.isUpdatePreset = true;
            
        })
        .catch(error => {
            this.error = error;
            console.log("Error: "+error.message);
        });
    }



    deletePR(){
        this.shoulddisplaydelete = true; 
    }
    disableEdit = false;
    closeDeletemodel(event){
        this.shoulddisplaydelete = false;
        if(event.detail!="closed"){            
            this.isUpdatePreset = true;
            if(this.opts.length==1){
                this.disableEdit = true;
                this.delList +=','+event.detail; 
            }
            else{
                for(var i = 0; i<this.opts.length;i++){
                    if(this.presetSel != this.opts[i].value){
                        this.presetSel = this.opts[i].value;
                        this.delList +=','+event.detail; 
                        this.refreshAllPreset();
                        break;
                    }
                }
            }
        }
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
        if(this.seletedPresetName == ""){
            this.cantUpdate = true;
        }
    }
    updateName(event){
        //this.isnameUpdate=false;
    }
}