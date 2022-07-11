import { LightningElement, wire, track, api } from "lwc";
import bulkicons from '@salesforce/resourceUrl/bulkicons';
import DownloadParticipantTemplate from '@salesforce/resourceUrl/PARTICIPANTS_TEMPLATE'; 
import AllStudy from "@salesforce/label/c.PIR_All_Study";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import AllStudySite from "@salesforce/label/c.PIR_All_Study_Site";
import getShowInstructValue from '@salesforce/apex/PIR_BulkImportController.getShowInstructValue';
import getInstruction from '@salesforce/apex/PIR_BulkImportController.getInstruction';
import getBulkImportHistoryInProgress from '@salesforce/apex/PIR_BulkImportController.getBulkImportHistoryInProgress';
import getBulkImportHistoryCompleted from '@salesforce/apex/PIR_BulkImportController.getBulkImportHistoryCompleted';
import getStudyStudySiteDetails from "@salesforce/apex/PIR_BulkImportController.getStudyStudySiteDetails";
export default class Pir_BulkImportFiles extends LightningElement {
    instructionsSvgURL = bulkicons+'/instructions.svg';
    downloadSvgURL = bulkicons+'/Download.svg';
    impotrtSvgURL = bulkicons+'/icon.svg';
    fileicon=bulkicons+'/file-xls.svg';
    importParticipant=false;
    
    bulkImportList;
    bulkHistoryDataCompleted;
    bulkHistoryDataInProgress;
    noRecords=false;
    saving=true;
    totalRecord;
    isInstrModalOpen=false;
    showInstruction = false;
    batchStartIntervalId;
    currentBatchStatus;
    BatchReturnValue;
    inProgressData=false;
    @api stopSpinner=false;
    isSpinnerRunning=false;
    @api pageNumber=1;
    @api getStudy;
    @api getStudySite=[];
    @api studylist;
    siteAccessLevels;
    studyToStudySite;
    studysiteaccess=false;
    selectedSite='';
    studySiteList;
    selectedStudy='';
    getimportids=[];

    label = {AllStudy,
        AllStudySite};
    downloadTemplate = DownloadParticipantTemplate;

    get dontshowInstruction() {
        return !this.showInstruction; 
    }
   
    connectedCallback() {
        // Register error listener
        //this.saving=true;
        this.getStudySiteData();
        //this.fetchData();
        this.getInstructionData();
        //this.getLatest();
       
    }
    getStudySiteData(){
        getStudyStudySiteDetails()
        .then(data => {
                var siteAccessLevels = data.siteAccessLevels;
                var ctpListNoAccess = [];
                var studySiteMap = data;
                var studylist;
                var studyToStudySite;
                ctpListNoAccess = data.ctpNoAccess;
                var k = 0;var a = 0;
                
                var accesslevels = Object.keys(siteAccessLevels).length;
                if (studySiteMap.ctpMap) {
                    var conts = studySiteMap.ctpMap;
                    let options = [];
                    options.push({ label: this.label.AllStudy, value: "All Study" });
                    var sites = studySiteMap.studySiteMap; 
                    for (var key in conts) {
                        if(!ctpListNoAccess.includes(conts[key])){ 
                            var temp = sites[conts[key]];
                            let z = 0;
                            for (var j in temp) {
                                 if(accesslevels == 0){
                                    z=z+1;
                                    a=a+1;
                                 }else{
                                    var level = siteAccessLevels[temp[j].Id];
                                    if(level != 'Level 3' && level != 'Level 2'){
                                        z=z+1;
                                        a=a+1;
                                    }
                                 }
                            }
                            if(z != 0){
                                options.push({ label: key, value: conts[key] });
                                k=k+1;
                            }
                        }
                    }
                    studylist = options;
                    if (studySiteMap.studySiteMap) {
                        studyToStudySite = studySiteMap.studySiteMap;
                    }
                }
                if(k != 0 && a != 0){
                        this.studylist = studylist;
                        this.siteAccessLevels = siteAccessLevels;
                        this.studyToStudySite = studyToStudySite;
                        this.studysiteaccess = true;
                        this.selectedStudy = this.studylist[0].value; 
                            var picklist_Value;
                            picklist_Value=this.selectedStudy;
                            var accesslevels = Object.keys(this.siteAccessLevels).length;
                            var conts = this.studyToStudySite;
                            let options = [];
                            options.push({ label: this.label.AllStudySite, value: "All Study Site" });
                            var i = this.siteAccessLevels;
                            if (picklist_Value != "All Study") {
                                for (var key in conts) {
                                  if (key == picklist_Value) {
                                    var temp = conts[key];
                                    for (var j in temp) {
                                        if(accesslevels == 0){
                                            options.push({ label: temp[j].Name, value: temp[j].Id });
                                        }else{
                                            var level = this.siteAccessLevels[temp[j].Id];
                                            if(level != 'Level 3' && level != 'Level 2'){
                                                options.push({ label: temp[j].Name, value: temp[j].Id });
                                            }
                                        }
                                    }
                                  }
                                }
                              } else {
                                for (var key in conts) {
                                  var temp = conts[key];
                                  for (var j in temp) {
                                    if(accesslevels == 0){
                                        options.push({ label: temp[j].Name, value: temp[j].Id });
                                    }else{
                                        var level = this.siteAccessLevels[temp[j].Id];
                                        if(level != 'Level 3' && level != 'Level 2'){
                                            options.push({ label: temp[j].Name, value: temp[j].Id });
                                        }
                                    }
                                  }
                                }
                              }
                              this.studySiteList = options;
                              this.selectedSite = this.studySiteList[0].value;
                              this.studysiteaccess = false;
                              var getStudySiteList=[];
                               if (this.selectedSite != null && this.selectedSite == "All Study Site") {
                                    for (var i = 1; i < this.studySiteList.length; i++) {
                                      getStudySiteList.push(this.studySiteList[i].value);
                                      this.getStudySite=getStudySiteList;
                                    }
                                  } else if (
                                    this.selectedSite != null &&
                                    this.selectedSite != "All Study Site"
                                  ) {
                                    this.getStudySite=this.selectedSite;
                                  }
                                  this.fetchData();
                                  this.getLatest();
                            
                        }
                })
            .catch(error => {
                this.err = error;
                console.log('Error : '+JSON.stringify( this.err));
                console.log('Error : '+error.message);
            });
    
        
                
    }
    getTotalCount;
    showToastSuccess=false;
    oldMap = new Map();
    inProgressOldDataid=[];
    successBoolean=false;
    @api fetchData(){
        if(!this.stopSpinner){
        this.saving = true; 
        this.isSpinnerRunning=true;
        }
        getBulkImportHistoryCompleted({getStudySite:this.getStudySite, pageNumber:this.pageNumber})
        .then(result => {
            this.bulkHistoryDataCompleted=result.bulkHistoryDataCompleted;
           // this.bulkHistoryDataInProgress=result.bulkHistoryDataInProgress;
            this.totalRecord=result.totalCount;
            //this.isInstrModalOpen=!result.showInstructions;  
            //this.showInstruction = !result.showInstructions; 

            /*if(this.getTotalCount==null){
                this.getTotalCount=this.totalRecord; //34 35
            }
            else{
                if(this.getTotalCount!=this.totalRecord){
                    console.log('record updated');
                    this.showToastSuccess=true; 

                }
            }
            if(this.showToastSuccess){
                this.showSuccessToast('Success');
                this.showToastSuccess=false; 
            }*/

            const selectEvent = new CustomEvent('gettotalrecord', {
                detail: this.totalRecord
            });
            this.dispatchEvent(selectEvent);
            
            const selectEventnew = new CustomEvent('resetpagination', {
                detail: ''
            });
            this.dispatchEvent(selectEventnew);

            console.table(result);
            if(result.bulkHistoryDataCompleted.length>0){
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
           /* if(this.bulkHistoryDataInProgress.length>0){
                this.inProgressData=true;
            }
            else{
                this.inProgressData=false;
            }*/

            if(this.isSpinnerRunning){
            this.saving = false; 
            this.isSpinnerRunning=false;
            this.stopSpinner=true;
            }
            
            
        })
        .catch(error => {
            this.saving = true; 
            this.err = error;
            console.log('Error : '+JSON.stringify( this.err));
            console.log('Error : '+error.message);
        });
        getBulkImportHistoryInProgress({getStudySite:this.getStudySite})
        .then(result => {
            this.bulkHistoryDataInProgress=result;
            var conts=result;
            var newResultIds=[];
           
            for(var key in conts){
                newResultIds.push(conts[key].Id);
            }
            
            if(result.length>0){
                this.inProgressData=true;
                if(this.inProgressOldDataid==null || this.inProgressOldDataid==undefined||this.inProgressOldDataid.length==0){
                    for(var key in conts){
                        this.inProgressOldDataid.push(conts[key].Id);
					
                    }

                }
                else{
                    var arrayLength =  this.inProgressOldDataid.length;
                    console.log('old data length:'+arrayLength);console.log('new data length:'+newResultIds.length);
                    for (var i = 0; i < arrayLength; i++) {
                      console.log(this.inProgressOldDataid[i]);
                      if(!newResultIds.includes(this.inProgressOldDataid[i])){
                          console.log('NOT THERE');
                          this.isToast=true;

                      }else{
                          console.log('ITS THERE');
                      }
                    //Do something
                    }
                    this.inProgressOldDataid=newResultIds;

                }
				
            }     
            else{
                this.inProgressData=false;
                
            }
            if(result.length==0 && this.inProgressOldDataid.length!=0){
                this.successBoolean=true;
                this.inProgressOldDataid=[];
            }

            if(this.isToast ||this.successBoolean){
                this.showSuccessToast('Participant record import completed succesfully.');
                this.isToast=false;
                this.successBoolean=false;
            }
          
        })
        .catch(error => {
            this.saving = true; 
            this.err = error;
            console.log('Error : '+JSON.stringify( this.err));
            console.log('Error : '+error.message);
        });

    }

    @api updateInProgressOldData(){
        this.inProgressOldDataid=[];
    }
    getInstructionData(){
        getInstruction()
        .then(result => {
            this.isInstrModalOpen=!result;  
            this.showInstruction = !result; 
        })
        .catch(error => {
            this.saving = true; 
            this.err = error;
            console.log('Error : '+JSON.stringify( this.err));
            console.log('Error : '+error.message);
        });
       
    }
    getLatest(){
        this._interval = setInterval(() => {  
            if (this.inProgressData) {
            this.fetchData();
            }
            console.log('>>callback fro  batch>>');
            if (!this.inProgressData) {
                clearInterval(this._interval);
                console.log('>>cleared');
                this.successBoolean=false;
                
              } 
                
        }, 10000); 
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
    showSuccessToast(messageRec) {
        const evt = new ShowToastEvent({
            title: 'Success Message',
            message: messageRec,
            variant: 'success',
            duration:400,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    
}