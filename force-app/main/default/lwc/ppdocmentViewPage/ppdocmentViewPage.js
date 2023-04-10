import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import fetchUploadedFiles from '@salesforce/apex/ppFileUploadController.fetchUploadedFiles'; 
import formFactor from '@salesforce/client/formFactor';

export default class ppdocmentViewPage extends LightningElement {
    noDocumentAvailable = pp_icons + '/' + 'noDocumentAvailable.svg';
    uploadNewDocuments = pp_icons + '/' + 'uploadNewDocuments.svg';

    value = 'inProgress';
    noRecords=true;
    @api pageNumber=1;
    isFile=true;
    isDelegate=false;
    cvList;
    totalRecord;
    isMobile = false;
    selectedmenu = 'Uploaded';
    selectedsortOption = 'Sort By'
    @api isctpenableUpload;
    isSaving=false;
    

    connectedCallback(){
        
        if (formFactor === 'Small' || formFactor === 'Medium') {
            this.isMobile = true;
        } else {
            this.isMobile = false;
        }
        console.log('this.isMobile'+this.isMobile);
        this.isSaving=true;
            if (!communityService.isDummy()) {
                this.getData = communityService.getParticipantData();
                if(communityService.getCurrentCommunityMode().currentDelegateId){ 
                    this.isDelegate=true;
                }
            
            fetchUploadedFiles({ 
                perId: this.getData.pe.Id,
                pageNumber: this.pageNumber,
                isDelegate: this.isDelegate
            })
            .then(result => {
                this.isSaving=false;
                this.cvList=result.cvList;
                this.totalRecord=result.totalCount;
                const selectEvent = new CustomEvent('gettotalrecord', {
                    detail: this.totalRecord
                });
                this.dispatchEvent(selectEvent);
                
                const selectEventnew = new CustomEvent('resetpagination', {
                    detail: ''
                });
                this.dispatchEvent(selectEventnew);
                })
            }
    }
    renderedCallback(){
    }

   get optionstab() {
        return [
            { label: 'Uploaded', value: 'uploaded' },
            { label: 'Shared with Me', value: 'sharewithme' }
        ];
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
    opendropdown(event){

        this.template.querySelectorAll(".D").forEach(function (L) {
            L.classList.toggle("slds-is-open");
        });

    }
    handleonblur(event){
         let classListforUploaded = this.template.querySelector(".D").classList;
         console.log('>>oclassListforUploaded>>'+classListforUploaded);
         try{
         
         }
         catch(ex){
             console.log('>>eddd>>'+ex);
         }
         if(classListforUploaded.contains("slds-is-open"))
         {
            this.template.querySelectorAll(".D").forEach(function (L) {
                L.classList.remove("slds-is-open");
            });
         }
         let classListforSort = this.template.querySelector(".Sort").classList;
         if(classListforSort.contains("slds-is-open"))
         {
            this.template.querySelectorAll(".Sort").forEach(function (L) {
                L.classList.remove("slds-is-open");
            });
         }
    }
    handlenewOnSelect(event){
        this.selectedmenu = event.target.dataset.title;
    }
    handlenewOnSelectSort(event){
        this.selectedsortOption = 'By: '+event.target.dataset.title;
    }
    opendropdownSort(event){
        this.template.querySelectorAll(".Sort").forEach(function (L) {
            L.classList.toggle("slds-is-open");
        });
    }
    handleChange(event) {
        this.value = event.detail.value;
    }
}