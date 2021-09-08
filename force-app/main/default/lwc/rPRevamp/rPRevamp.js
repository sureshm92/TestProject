import { LightningElement, api, track, wire } from 'lwc';
import xlsxmin from '@salesforce/resourceUrl/xlsxmin';
import getHCPInitData from '@salesforce/apex/FileContainer.getHCPInitData';
import getShowInstructValue from '@salesforce/apex/FileContainer.getShowInstructValue';
import bulkicons from '@salesforce/resourceUrl/bulkicons';
import {loadScript} from 'lightning/platformResourceLoader';
import rrCommunity from '@salesforce/resourceUrl/rr_community_js';
import saveTheChunkFile from '@salesforce/apex/nonReferedBulkUpload.saveTheChunkFile';
import fetchFiles from '@salesforce/apex/nonReferedBulkUpload.fetchFiles';
import processvalidateFile from '@salesforce/apex/nonReferedBulkUpload.processvalidateFile';
import deleteFile from '@salesforce/apex/nonReferedBulkUpload.deleteFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import downloadBulkTemplate from '@salesforce/resourceUrl/Import_Patient_Template';


const MAX_FILE_SIZE = 2621440;// 4500000; max file size prog can handle
const CHUNK_SIZE = 9000;//750000; max chunk size prog can handle

export default class RPRevamp extends LightningElement {
    templateFile =downloadBulkTemplate;
    instructionsSvgURL = bulkicons+'/instructions.svg';
    downloadSvgURL = bulkicons+'/Download.svg';
    impotrtSvgURL = bulkicons+'/icon.svg';
    @api recordId;
    isloading;
    @track fileList;
    renderTable = false;
    @track isInstrModalOpen = false;
    @track isUploadModalOpen = false;
    @track userMode;
    @track hasAccess;
    @track hcpInitData;
    studies = [];
    @api contentFiles = [];
    rpState;
    rpCountry;
    userConID;
    inProgress = false;
    loaded = false;
    showInstruction =false;
    nofiles=false;
    @api recordsToDisplay = [];
    baseUrl;
    filesLoaded = false;
    
    get dontshowInstruction(){
        return !this.showInstruction;
    }

    connectedCallback() {
        if(!this.loaded){
            loadScript(this, rrCommunity).then(() => {
                //this is the name of the function that’s present
                //in the uploaded static resource.
                const delegateid = communityService.getDelegateId();
                const userMode = communityService.getUserMode();
                const baseUrl = communityService.getBaseUrl();
                this.userMode = userMode;
                this.baseUrl = baseUrl;
                this.loaded = true;
                getHCPInitData({ 
                    userMode: userMode ,
                    delegateId: delegateid 
                })
                .then(result => {
                    for(var i = 0 ; i< result.activelyEnrollingStudies.length; i++){
                        this.studies.push(result.activelyEnrollingStudies[i].studies);
                    }
                    this.userConID = result.delegateDetails.Id;
                    this.rpState =result.delegateDetails.MailingState;
                    this.rpCountry = result.delegateDetails.MailingCountry;
                    this.isInstrModalOpen = result.showInstructions;
                    this.showInstruction = result.showInstructions;
                    this.getDetailsApex();
                });
            });
            loadScript(this, xlsxmin).then(() => {                
            });
        }
    }
    getDetailsApex() {
        this.nofiles = false;
        fetchFiles({delegateId : this.userConID})
            .then((result) => {
                this.contentFiles = result;
                this.recordsToDisplay = result;                
                this.error = undefined;
                this.filesLoaded = true;
                if(result.length==0) this.nofiles = true;
            })
            .catch((error) => {
                this.nofiles = true;
                this.contentFiles = undefined;
            });
    }
    
    
    /*@wire(fetchFiles) peList(result) {

        if (result.data) {
            this.contentFiles = result.data;
            this.recordsToDisplay = result.data;
            this.error = undefined; 

        } else if (result.error) {
            this.error = result.error;
            this.contentFiles = undefined;
        }
    }*/

    //Capture the event fired from the paginator component
    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail;
        this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
    }

    openIntructModal() {
        this.isInstrModalOpen = true;
    }
    //close model for refresh
    closeIntructModal() {
        this.isInstrModalOpen = false;
    }

    openUploadModal() {
        this.isUploadModalOpen = true;
    }
    //close model for refresh
    closeUploadModal() {
        if(this.progress == 100 || this.progress == 0){
            if(this.progress == 100) 
            {
                this.deleteFiles();
            }
            
            this.selectedStudy = '';
            this.template.querySelector(".fileInput").value=null; 
            this.template.querySelector(".fileInput").disabled = false;
            this.fileName = '';
            this.progress = 0;
            this.progressWidth='width :0%';
            this.base = 1;
            this.progressMultiplier = 0;
            this.isUploadModalOpen = false;
        }
    }
   
    progress = 0;
    progressWidth='width :0%';
    base = 1;
    progressMultiplier = 0;
    fileName = '';
    filesUploaded = [];
    isLoading = false;
    fileSize;
    fileId = '';
    csvData = '';
    totalRecs = 0;
    handleFilesChange(event) {
        
        if(event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            event.target.disabled = true;
            this.fileName = event.target.files[0].name;
            this.progress = 0;
            this.progressWidth='width :0%';
            this.base = 1;
            this.totalRecs = 0;
            this.progressMultiplier = 0;
            this.saveFile();
        }
    }

    saveFile(){
        var fileCon = this.filesUploaded[0];
        this.fileSize = this.formatBytes(fileCon.size, 2);
        if (fileCon.size > MAX_FILE_SIZE) {
            let message = 'File size cannot exceed ' + MAX_FILE_SIZE + ' bytes.\n' + 'Selected file size: ' + fileCon.size;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error'
            }));
            this.template.querySelector(".fileInput").value=null; 
            this.template.querySelector(".fileInput").disabled = false;
            this.fileName = '';
            return;
        }
        if(this.fileName.split('.')[1]!='csv' && this.fileName.split('.')[1]!='xlsx' && this.fileName.split('.')[1]!='xls'){
            let message = 'Please upload only csv, xlsc or xls format files.';
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error'
            }));
            this.template.querySelector(".fileInput").value=null; 
            this.template.querySelector(".fileInput").disabled = false;
            this.fileName = '';
            return;
        }
        this.progressWidth='width :8%';
        this.progress = 8;
        this.base = Math.floor((CHUNK_SIZE/fileCon.size)*100);

        var reader = new FileReader();
        var self = this;
        reader.onload = function() {
            var fileContents = reader.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            fileContents = fileContents.substring(dataStart);
            self.upload(fileCon, fileContents);
        };
        var reader2 = new FileReader();    
        reader2.onload = function (e) {  
            try{
                var binary = '';    
                var bytes = new Uint8Array(e.target.result);    
                var length = bytes.byteLength;    
                
                for (var i = 0; i < length; i++) {    
                    binary += String.fromCharCode(bytes[i]);
                }
                var workbook = XLSX.read(binary, { type: 'binary', raw: true });    
                var sheet_name_list = workbook.SheetNames;    
                var fileData = String(XLSX.utils.sheet_to_csv(workbook.Sheets[sheet_name_list[0]]));
                self.csvData = fileData;                  
                var csvRows = fileData.split('\n');
                if(csvRows.length > 4){
                    self.totalRecs = csvRows.length-2;
                }
            }
            catch(e){
                console.log('error'+ e.message)
            }

        }
        reader2.readAsArrayBuffer(fileCon); 
        reader.readAsDataURL(fileCon);
    }

    upload(file, fileContents){
        var fromPos = 0;
        var toPos = Math.min(fileContents.length, fromPos + CHUNK_SIZE);
        this.uploadChunk(file, fileContents, fromPos, toPos, ''); 
    }

    uploadChunk(file, fileContents, fromPos, toPos, attachId){
        this.isLoading = true;
        var chunk = fileContents.substring(fromPos, toPos);
        
        saveTheChunkFile({ 
            parentId: this.userConID,
            fileName: file.name,
            base64Data: encodeURIComponent(chunk), 
            contentType: file.type,
            fileId: attachId    
        })
        .then(result => {
            this.fileId = result;
            attachId = result;
            fromPos = toPos;
            toPos = Math.min(fileContents.length, fromPos + CHUNK_SIZE);    
            if (fromPos < toPos) {
                this.progressMultiplier ++;
                if(this.base * this.progressMultiplier<100){
                    this.progress = this.base * this.progressMultiplier;
                }
                else{ 
                    this.progress = 99;                
                }
                this.progressWidth = 'width :'+this.progress+'%';
                this.uploadChunk(file, fileContents, fromPos, toPos, attachId);  
            }else{
                if(this.totalRecs > 500){
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: 'Total number of records greater than 500, please try again with upto 500 records.',
                        variant: 'error'
                    }));
                    this.deleteFiles();
                    this.isLoading = false;
                }
                else{
                    this.progress = 100;
                    this.progressWidth = 'width :'+this.progress+'%;background-color: #00C221;';
                    this.isLoading = false;
                }
            }
        })
        .catch(error => {
            console.error('Error: ', error);
        })
        .finally(()=>{
            
        })
    }

    formatBytes(bytes,decimals) {
        if(bytes == 0) return '0 Bytes';
        var k = 1024,
            dm = decimals || 2,
            sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
            i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }

    selectedStudy = '';

    get enableDel(){
        return this.progress == 100;
    }

    get enableImport(){
        return (this.progress == 100 && this.selectedStudy !='') ;
    }

    get fileRemaining(){
        var fs = this.fileSize.split(' ');
        var fu = ((fs[0]*this.progress)/100).toFixed(2);
        if(fs[0]/fu == 1){
            return this.fileSize;
        }
        else{
            return fu + ' ' + fs[1] + ' of '+this.fileSize;
        }
    }

    selectStudy(event) {
        this.selectedStudy = event.detail.value;
    }    

    deleteFiles(){
        deleteFile({ 
            fileId: this.fileId   
        })
        .then(result => {
            this.template.querySelector(".fileInput").value=null; 
            this.template.querySelector(".fileInput").disabled = false;
            this.fileName = '';
            this.progress = 0;
            this.progressWidth='width :0%';
            this.base = 1;
            this.progressMultiplier = 0;
        })
        .catch(error => {
            console.error('Error: ', error);
        })
        .finally(()=>{
            
        })
    }

    importRec(){
        this.template.querySelector(".fileInput").value=null; 
        this.template.querySelector(".fileInput").disabled = false;
        this.fileName = '';
        this.progress = 0;
        this.progressWidth='width :0%';
        this.base = 1;
        this.progressMultiplier = 0;
        this.isUploadModalOpen = false;
        this.inProgress = true;
        processvalidateFile({ 
            fileID: this.fileId,
            studyID: this.selectedStudy,
            rpState: this.rpState,
            rpCountry: this.rpCountry,
            csvData : this.csvData
        })
        .then(result => {
            this.selectedStudy = '';
            this.inProgress = false;
            this.filesLoaded = false;
            this.getDetailsApex();
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!',
                message: 'File Upload Success',
                variant: 'success'
            }));

        })
    }
    

    instructionUpdate(event) {
        this.showInstruction = !event.target.checked;
    }    

    updateShowInstructValue(){
        getShowInstructValue({ 
            flag: this.showInstruction,
        })
        .then(result => {
            this.isInstrModalOpen = false;
        })
    }

    //mobile
    showButtons = false;

    toggleButtons(){
        this.showButtons = !this.showButtons;
    }
}