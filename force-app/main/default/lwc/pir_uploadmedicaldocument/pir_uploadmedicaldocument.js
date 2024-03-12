import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import BulkImport_Drag_file_here_or from '@salesforce/label/c.BulkImport_Drag_file_here_or';
import BulkImport_browse from '@salesforce/label/c.BulkImport_browse';
import BulkImport_Max_size from '@salesforce/label/c.BulkImport_Max_size';
import BulkImport_Wait_Warning from '@salesforce/label/c.BulkImport_Wait_Warning';
import MedicalImport_MaxSize from '@salesforce/label/c.MedicalImport_MaxSize';
import pir_MedicalImport_header from '@salesforce/label/c.pir_MedicalImport_header';
import pir_MedicalImport_subHead from '@salesforce/label/c.pir_MedicalImport_subHead';
import BTN_Save from '@salesforce/label/c.BTN_Save';
import pir_Delete_close from '@salesforce/label/c.pir_Delete_close';
import PIR_medicalAcceptedFile from '@salesforce/label/c.PIR_medicalAcceptedFile';
import PIR_uploadFile_exced from '@salesforce/label/c.PIR_uploadFile_exced';
import PP_Browsefiles from '@salesforce/label/c.PP_Browsefiles';
import saveTheChunkFile from '@salesforce/apex/nonReferedBulkUpload.saveTheChunkFile'; 
 


import deleteFile from '@salesforce/apex/nonReferedBulkUpload.deleteFile';

const MAX_FILE_SIZE = 4500000; //2621440;// 4500000; max file size prog can handle
const CHUNK_SIZE = 750000;//9000;//750000; max chunk size prog can handle 
const MAX_FILE_SIZE_mb = 4;
 
export default class Pir_uploadmedicaldocument extends LightningElement {


    BulkImport_Drag_file_here_or = BulkImport_Drag_file_here_or;
    BulkImport_browse = BulkImport_browse;
    PP_Browsefiles = PP_Browsefiles;
    BulkImport_Max_size = BulkImport_Max_size;
    BulkImport_Wait_Warning = BulkImport_Wait_Warning;
    MedicalImport_MaxSize = MedicalImport_MaxSize;
    BTN_Save = BTN_Save;
    pir_MedicalImport_header = pir_MedicalImport_header;
    pir_MedicalImport_subHead = pir_MedicalImport_subHead;
    pir_Delete_close = pir_Delete_close;
    PIR_medicalAcceptedFile = PIR_medicalAcceptedFile;
    PIR_uploadFile_exced = PIR_uploadFile_exced;
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
    validFile =true;
    isDoneLoading = true;
    @api
    isFileAdded = false;
    @api 
    uploadonid;
    @api maindivcls;
    @api ismobiledevice;
    @api isrequirerefreshtable;
    calledfromclosePopup =false;

    handleFilesChange(event) {
        
        if(event.target.files.length > 0) {
            this.template.querySelector('[data-id="browsediv"]').classList.add('disabledrag');
            this.calledfromclosePopup =false;
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
        var fileSiezeMb = (fileCon.size / 1024 / 1024).toFixed(2);
        let extension_index = this.fileName.lastIndexOf('.');
        let extension =   this.fileName.slice(extension_index + 1);

        if (extension.toLowerCase() != 'jpg' && extension.toLowerCase() != 'pdf' && extension.toLowerCase() != 'jpeg' 
            && extension.toLowerCase() != 'gif'  && extension.toLowerCase() != 'png')
        {
            let message = PIR_medicalAcceptedFile;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error'
            }));
            this.template.querySelector(".fileInput").value = null;
            this.template.querySelector(".fileInput").disabled = false;
            this.fileName = '';
            this.template.querySelector('[data-id="browsediv"]').classList.remove('disabledrag');
            return;
        }

        if (fileCon.size > MAX_FILE_SIZE) {
            let message = PIR_uploadFile_exced;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error'
            }));
            this.template.querySelector(".fileInput").value=null; 
            this.template.querySelector(".fileInput").disabled = false;
            this.fileName = '';
            this.template.querySelector('[data-id="browsediv"]').classList.remove('disabledrag');
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
            parentId: this.uploadonid,
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
                this.progress = 100;
                this.progressWidth = 'width :'+this.progress+'%;background-color: #00C221;';
                this.isLoading = false;   
                this.isFileAdded = true;  
                 
         
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

    get enableDel(){
        return this.progress == 100;
    }

    get enableImport(){
        return (this.progress == 100) ;
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
    
    
    closepopup(){
        let shouldRefreshTable = this.isFileAdded ? 'success' : 'false';
         
        const closemodel = new CustomEvent("closemodelpopup",{
            detail : shouldRefreshTable
          }) ;
        this.dispatchEvent(closemodel); 
    }

    deleteFiles(){
        this.isDoneLoading = false;
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
            this.isDoneLoading = true;
            this.isFileAdded = false;
            this.template.querySelector('[data-id="browsediv"]').classList.remove('disabledrag');
            if(this.calledfromclosePopup){
            let shouldRefreshTable = this.isrequirerefreshtable ? 'success' : 'false';
            
            const closemodel = new CustomEvent("closemodelpopup",{
                detail : shouldRefreshTable
            }) ;
            this.dispatchEvent(closemodel); 
            }
        })
        .catch(error => {
            this.isDoneLoading = true;
            console.error('Error: ', error);
        })
        .finally(()=>{
            this.isDoneLoading = true;
        })
    }
    //close model for refresh
    closeUploadModal() {
        if(this.progress == 100 || this.progress == 0){
            if(this.progress == 100) 
            {
                this.calledfromclosePopup =true;
                this.deleteFiles();
            }
            else{
            this.template.querySelector(".fileInput").value=null; 
            this.template.querySelector(".fileInput").disabled = false;
            this.fileName = '';
            this.progress = 0;
            this.progressWidth='width :0%';
            this.base = 1;
            this.progressMultiplier = 0;
            this.isFileAdded = false;

            let shouldRefreshTable = this.isrequirerefreshtable ? 'success' : 'false';
            
                const closemodel = new CustomEvent("closemodelpopup",{
                    detail : shouldRefreshTable
                }) ;
            this.dispatchEvent(closemodel); 
            }

            // const closemodel = new CustomEvent("closemodelpopup" ) ;
            // this.dispatchEvent(closemodel);
        }
    }

}