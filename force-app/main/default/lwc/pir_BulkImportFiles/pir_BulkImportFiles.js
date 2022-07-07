import { LightningElement, wire, track, api } from "lwc";
import bulkicons from '@salesforce/resourceUrl/bulkicons';
import DownloadParticipantTemplate from '@salesforce/resourceUrl/PARTICIPANTS_TEMPLATE'; 
import getShowInstructValue from '@salesforce/apex/PIR_BulkImportController.getShowInstructValue';
import getBulkImportHistory from '@salesforce/apex/PIR_BulkImportController.getBulkImportHistory';
export default class Pir_BulkImportFiles extends LightningElement {
    instructionsSvgURL = bulkicons+'/instructions.svg';
    downloadSvgURL = bulkicons+'/Download.svg';
    impotrtSvgURL = bulkicons+'/icon.svg';
    
    importParticipant=false;
    
    bulkImportList;
    noRecords=false;
    saving=true;
    totalRecord;
    isInstrModalOpen;
    showInstruction = false;
    batchStartIntervalId;
    @api pageNumber=1;
    @api getStudy;
    @api getStudySite=[];


    downloadTemplate = DownloadParticipantTemplate;

    get dontshowInstruction() {
        return !this.showInstruction; 
    }
   
    connectedCallback() {
        // Register error listener
        this.saving=true;
        this.fetchData();
       
       
    }
    @api fetchData(){
        console.log('getStudySite@@',this.getStudySite);
        console.log('pageNumber@@',this.pageNumber);
        this.saving = true; 
        getBulkImportHistory({getStudySite:this.getStudySite, pageNumber:this.pageNumber})
        .then(result => {
            this.bulkImportList=result.bulkHistoryData;
            this.totalRecord=result.totalCount;
            this.isInstrModalOpen=!result.showInstructions;  
            this.showInstruction = !result.showInstructions; 

            const selectEvent = new CustomEvent('gettotalrecord', {
                detail: this.totalRecord
            });
            this.dispatchEvent(selectEvent);
            
            const selectEventnew = new CustomEvent('resetpagination', {
                detail: ''
            });
            this.dispatchEvent(selectEventnew);

            console.table(result);
            if(this.bulkImportList.length>0){
                this.noRecords=false;
                this.template.querySelectorAll(".nodata").forEach(function (L) {
                    L.classList.remove("table-width-nodata");
                });
            }
            else{
                this.template.querySelectorAll(".nodata").forEach(function (L) {
                    L.classList.add("table-width-nodata");
                });
                this.noRecords=true;
            }
            this.saving = false; 
        })
        .catch(error => {
            this.saving = true; 
            this.err = error;
            console.log('Error : '+JSON.stringify( this.err));
            console.log('Error : '+error.message);
        });

    }
    
    handleImportModal(){
        this.importParticipant=true;
    }

    handleImportParticipant(){
        this.importParticipant=false;
    }
    openIntructModal(){
        this.isInstrModalOpen = true;
    }
    handleClose(){
        this.isInstrModalOpen=false;
    }
    instructionUpdate(event) {
        this.showInstruction = !event.target.checked; 
    }
    updateShowInstructValue() {
        getShowInstructValue({
            flag: !this.showInstruction 
        }).then((result) => {
            this.isInstrModalOpen = false;
        });
       
        
    }

    
}