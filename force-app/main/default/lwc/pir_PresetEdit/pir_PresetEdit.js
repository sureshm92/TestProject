import { api, LightningElement } from 'lwc';

export default class Pir_PresetEdit extends LightningElement {
    @api
    opts;
    @api
    allPresets;
    @api
    presetSel;
    filterVal;
    showFilter=false;
    @api
    get selectedFilter(){ return true;}
    set selectedFilter(value){
        this.filterVal = value;
        this.showFilter = true;
    }
    closeModel(){
        const closeEventModel = new CustomEvent("closepresetmodel");
        this.dispatchEvent(closeEventModel);
    }
    handlePresetChange(event){
        for(var i=0;i<this.allPresets.length;i++){
            if(event.detail.value==this.allPresets[i].presetId){
                this.template.querySelector("c-pir_filter").presetWrapperSet(this.allPresets[i]); 
                break;
            }
        }
    }
}