import { LightningElement, api } from 'lwc';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import PP_No_files_available from '@salesforce/label/c.PP_No_files_available';
import PIR_Download from '@salesforce/label/c.PIR_Download';
import pir_Delete_Btn from '@salesforce/label/c.pir_Delete_Btn';
import fetchUploadedFiles from '@salesforce/apex/PpPastStudiesFilesController.fetchUploadedFiles';
import fetchMessageFiles from "@salesforce/apex/ppFileUploadController.fetchMessageFiles";
import deleteFile from '@salesforce/apex/PpPastStudiesFilesController.deleteFile';
import profileTZ from "@salesforce/i18n/timeZone";
import PP_DeleteFile from '@salesforce/label/c.PP_DeleteFile';
import PP_DeleteConfirmation from '@salesforce/label/c.PP_DeleteConfirmation';
import BTN_Cancel from '@salesforce/label/c.BTN_Cancel';

export default class PpPastStudiesMyFiles extends LightningElement {
    downloadIcon = pp_icons + '/' + 'download.svg';
    deleteIcon = pp_icons + '/' + 'delete.svg';
    timeZone = profileTZ;
    @api fileUploaded=false;
    @api study;
    @api peId;
    @api contId;
    loaded=false;
    showFiles =false;
    fileList=[];
    noFilesIcon = pp_icons + '/' + 'no-files.svg';
    iconClass="full";
    nofiles=false;
    previewLink;
    openDeleteModel;
    label={PP_No_files_available,
            PIR_Download,
            pir_Delete_Btn,
            PP_DeleteFile,
            PP_DeleteConfirmation,
            BTN_Cancel
          };
    connectedCallback(){
        this.loadFiles();
    } 
    loadFiles(){ 
        this.previewLink =null;       
        this.loaded=false;        
        this.showFiles =false;
        if(this.fileUploaded){
            fetchUploadedFiles({
                contID: this.contId,
                pageNumber: 1,
                selectedStudyId: this.study,
                sortOn: "CreatedDate",
                sortType: "DESC",
                isInitial: true,
                firstClick: false
            })
            .then((result) => {
                console.log('OUTPUT : ',JSON.stringify(result));
                if(result.totalCount==0){
                    this.nofiles = true;
                }
                else{
                    if(result.totalCount>4){
                        this.dispatchEvent(new CustomEvent('morefiles', {
                            detail: {
                                message: 'uploaded'
                            }
                        }));
                    }
                    this.fileList=[];
                    for(let i = 0; i < result.cvList.length; i++){
                        if(i<4){
                            this.fileList.push({
                                title: result.cvList[i].Title,
                                type: result.cvList[i].FileType,
                                uploadDate: result.cvList[i].CreatedDate,
                                cvid: result.cvList[i].Id,
                                cdid: result.cvList[i].ContentDocumentId,
                            });
                        }
                        else{
                            break;
                        }
                    }
                    this.previewLink =  result.previewLinks;
                    this.showFiles =true;
                }
                this.loaded=true;
            })
            .catch((error) => {
                console.error('Error:', error);
            });
        }
        else{
            fetchMessageFiles({
                perId: this.peId,
                pageNumber: 1,
                sortOn: "CreatedDate",
                sortType: "DESC",
                isInitial: true,
                firstClick: false
            })
            .then((result) => {
                console.log('OUTPUT : ',JSON.stringify(result));
                if(result.totalCount==0){
                    this.nofiles = true;
                }
                else{
                    if(result.totalCount>4){
                        this.dispatchEvent(new CustomEvent('morefiles', {
                            detail: {
                                message: 'shared'
                            }
                        }));
                    }
                    this.fileList=[];
                    for(let i = 0; i < result.cdlList.length; i++){
                        if(i<4){
                            let fileName = result.cdlList[i].ContentDocument.Title;
                            if(fileName.lastIndexOf(".")!=-1){
                                fileName = fileName.substring(0,fileName.lastIndexOf("."));
                            }
                            this.fileList.push({                               
                                title: fileName,
                                type: result.cdlList[i].ContentDocument.FileExtension.toUpperCase(),
                                uploadDate: result.cdlList[i].ContentDocument.CreatedDate,
                                cvid: result.cdlList[i].ContentDocument.LatestPublishedVersionId,
                                cdid: result.cdlList[i].ContentDocumentId,
                            });
                        }
                        else{
                            break;
                        }
                    }
                    this.previewLink =  result.previewLinks;
                    this.showFiles =true;
                }
                this.loaded=true;
            })
            .catch((error) => {
                console.error('Error:', error);
            });
        }
    }
    previewFile(event){
        var y = window.outerHeight / 2 + window.screenY - ( 500 / 2);
        var x = window.outerWidth / 2 + window.screenX - ( 600 / 2);
        window.open(this.previewLink[event.target.dataset.pvid],'popup','toolbar=no,scrollbars=no,resizable=no,top=' + y + ',left=' + x +',width=600,height=500'); 
    }
    downloadFile(event){
        window.open('../sfc/servlet.shepherd/document/download/'+event.target.dataset.cdid, "_self");
    }
    deleteFile(event){
        this.openDeleteModel = true;
        this.deleteFileID = event.target.dataset.cvid;
        
    }
    handleContinueModel(event) {
        this.openDeleteModel = false;
        this.loaded = false;
        this.showFiles =false;
        
        deleteFile({
            fileID: this.deleteFileID
        })
        .then((result) => {
            this.deleteFileID=null;
            this.dispatchEvent(new CustomEvent("filedeleted"));
            this.loadFiles();
        })
        .catch((error) => {
            console.error('Error:', error);
        });
    
    }
    handleCancelModel(event) {
        this.deleteFileID=null;
        this.openDeleteModel = false;
    }
    get sectionClass(){
        if(this.fileUploaded){
            return "sectionHeight uploaded";
        }
        return "sectionHeight shared";
            
    }
}