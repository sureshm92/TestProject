import { LightningElement, track, api } from 'lwc';
import formFactor from '@salesforce/client/formFactor';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';



export default class PpPastStudiesFileTable extends LightningElement {
    noDocumentAvailable = pp_icons + '/' + 'noDocumentAvailable.svg';
    uploadNewDocuments = pp_icons + '/' + 'uploadNewDocuments.svg';
    noRecords=false;
    @api pageNumber=1;
    isFile=true;
    isDelegate=false;
    @api totalRecord=10;
    isMobile = false;
    selectedmenu = 'Uploaded';
    selectedsortOption = 'Sort By'

    connectedCallback(){
        console.log('>>connected callback>>');
        this.noRecords=true;
        if (formFactor === 'Small' || formFactor === 'Medium') {
            this.isMobile = true;
        } else {
            this.isMobile = false;
        } 
    
    }
    get optionstab() {
        return [
            { label: 'Uploaded', value: 'uploaded' },
            { label: 'Shared with Me', value: 'sharewithme' }
        ];
    }
    handleChange(event) {
        this.value = event.detail.value;
    }
    get optionsSort() {
        return [
            { label: 'Title: A-Z', value: 'titleasc' },
            { label: 'Title: Z-A', value: 'titledesc' },
            { label: 'File Type: A-Z', value: 'filetypeasc' },
            { label: 'File Type: Z-A', value: 'filetypedesc' },
            { label: 'Date: Last Uploaded', value: 'datedesc' },
            { label: 'Date: First Uploaded', value: 'dateasc' }
        ];
    }
    handleChangeSort(event) {
        //this.value = event.detail.value;
    }

    opendropdown(event){

        this.template.querySelectorAll(".D").forEach(function (L) {
            L.classList.toggle("slds-is-open");
        });

    }
    handleonblur(event){
        console.log('>>onblue called>>');
         let classListforUploaded = this.template.querySelector(".D").classList;
         console.log('>>oclassListforUploaded>>'+classListforUploaded);
         try{
         console.log('>>121212>>'+classListforUploaded.contains("slds-is-open"));
         console.log('>>2223>>'+classListforUploaded.contains('slds-is-open'));
         }
         catch(ex){
             console.log('>>eddd>>'+ex);
         }
         if(classListforUploaded.contains("slds-is-open"))
         {
             console.log('>>inside uplaod>>');
            this.template.querySelectorAll(".D").forEach(function (L) {
                L.classList.remove("slds-is-open");
            });
         }
         let classListforSort = this.template.querySelector(".Sort").classList;
         console.log('>>classListforSort>>'+classListforSort);
         if(classListforSort.contains("slds-is-open"))
         {
            console.log('>>inside sorting>>');
            this.template.querySelectorAll(".Sort").forEach(function (L) {
                L.classList.remove("slds-is-open");
            });
         }
    }
    handlenewOnSelect(event){
        this.selectedmenu =  event.target.dataset.title;
        console.log('>>>click menu is>>>'+event.target.dataset.title);
    }
    handlenewOnSelectSort(event){
        this.selectedsortOption = 'By: '+ event.target.dataset.title;
        console.log('>>>click menu is>>>'+event.target.dataset.title);
    }
    opendropdownSort(event){
        console.log('>>sort is>>'+event.target.dataset.id);
        this.template.querySelectorAll(".Sort").forEach(function (L) {
            L.classList.toggle("slds-is-open");
        });
    }
}