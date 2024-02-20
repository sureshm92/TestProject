import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
//import saveTheChunkFile from '@salesforce/apex/nonReferedBulkUpload.saveTheChunkFile';  //Need to change the method
import saveTheChunkFile from '@salesforce/apex/ppFileUploadController.saveTheChunkFile'; //Need to change the method
import isUplaodAvailable from '@salesforce/apex/ppFileUploadController.isUplaodAvailable';
import DeleteAlldraftFiles from '@salesforce/apex/ppFileUploadController.DeleteAlldraftFiles';
import uploadFiles from '@salesforce/apex/ppFileUploadController.uploadFiles';
import deleteFile from '@salesforce/apex/ppFileUploadController.deleteFile';
import PP_AcceptedFileformats from '@salesforce/label/c.PP_AcceptedFileformats';
import PP_acceptedformats from '@salesforce/label/c.PP_acceptedformats';
import PP_MaxFileSize from '@salesforce/label/c.PP_MaxFileSize';
import PP_FileFormatNotAccept from '@salesforce/label/c.PP_FileFormatNotAccept';
import PP_RemoveFile from '@salesforce/label/c.PP_RemoveFile';
import PP_CancelUpload from '@salesforce/label/c.PP_CancelUpload';
import PP_UploadSuccess from '@salesforce/label/c.PP_UploadSuccess';
import PP_RemoveFileHeader from '@salesforce/label/c.PP_RemoveFileHeader';
import BTN_Cancel from '@salesforce/label/c.BTN_Cancel';
import Button_Remove from '@salesforce/label/c.Button_Remove';
import PP_NeedHelp from '@salesforce/label/c.PP_NeedHelp';
import PP_ReviewAcceptFile from '@salesforce/label/c.PP_ReviewAcceptFile';
import PP_ReviewFiles from '@salesforce/label/c.PP_ReviewFiles';
import RH_Upload_import from '@salesforce/label/c.RH_Upload_import';
import PP_CancelUploadHeader from '@salesforce/label/c.PP_CancelUploadHeader';
import PP_BacktoUpload from '@salesforce/label/c.PP_BacktoUpload';
import Continue from '@salesforce/label/c.Continue';
import PP_MyFiles from '@salesforce/label/c.PP_MyFiles';
import PP_UploadNewDocument from '@salesforce/label/c.PP_UploadNewDocument';
import PP_DragFiles from '@salesforce/label/c.PP_DragFiles';
import PP_or_smallcase from '@salesforce/label/c.PP_or_smallcase';
import PP_Browsefiles from '@salesforce/label/c.PP_Browsefiles';
import PP_MaxiumumFileUpload from '@salesforce/label/c.PP_MaxiumumFileUpload';
import PP_WaitTime from '@salesforce/label/c.PP_WaitTime';
import PP_FileNameRequired from '@salesforce/label/c.PP_FileNameRequired';
import PP_LimitCharacters from '@salesforce/label/c.PP_LimitCharacters';
import PP_UploadFailed from '@salesforce/label/c.PP_UploadFailed';
import RH_RP_Cancel from '@salesforce/label/c.RH_RP_Cancel';
import PP_Retry from '@salesforce/label/c.PP_Retry';
import PP_UploadedFilesShar from '@salesforce/label/c.PP_UploadedFilesShar';
import PP_UploadNewFile from '@salesforce/label/c.PP_UploadNewFile';
import PP_Backt_o_My_Files from '@salesforce/label/c.PP_Backt_o_My_Files';
import PP_Filerenamedsuccesfully from '@salesforce/label/c.PP_Filerenamedsuccesfully';
import PP_Limit10Files from '@salesforce/label/c.PP_Limit10Files';
import PP_Fileremovedsuccesfully from '@salesforce/label/c.PP_Fileremovedsuccesfully';
import formFactor from '@salesforce/client/formFactor';
import REMOVE from '@salesforce/label/c.PP_Remove';
import RENAME from '@salesforce/label/c.PP_Rename';
import PREVIEW from '@salesforce/label/c.PP_Preview';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const MAX_FILE_SIZE = 4500000; //2621440;// 4500000; max file size prog can handle
const CHUNK_SIZE = 750000; // 500000; //9000;//750000; max chunk size prog can handle 500000
const MAX_FILE_SIZE_mb = 4;

export default class PpfilesViewPage extends NavigationMixin(LightningElement) {
    noDocumentAvailable = pp_icons + '/' + 'noDocumentAvailable.svg';
    uploadNewDocuments = pp_icons + '/' + 'uploadNewDocuments.svg';
    threedots_imgUrl = pp_icons + '/' + 'three_dots.png';
    retry_icon = pp_icons + '/' + 'retry_icon.svg';
    chevron_left = pp_icons + '/' + 'chevron_left.svg';

    label = {
        PP_AcceptedFileformats,
        PP_acceptedformats,
        PP_MaxFileSize,
        PP_FileFormatNotAccept,
        PP_RemoveFile,
        PP_CancelUpload,
        PP_UploadSuccess,
        PP_RemoveFileHeader,
        BTN_Cancel,
        Button_Remove,
        PP_NeedHelp,
        PP_ReviewAcceptFile,
        PP_ReviewFiles,
        RH_Upload_import,
        PP_CancelUploadHeader,
        PP_BacktoUpload,
        Continue,
        PP_MyFiles,
        PP_UploadNewDocument,
        PP_DragFiles,
        PP_or_smallcase,
        PP_Browsefiles,
        PP_MaxiumumFileUpload,
        PP_WaitTime,
        PP_FileNameRequired,
        PP_LimitCharacters,
        PP_UploadFailed,
        RH_RP_Cancel,
        PP_Retry,
        PP_UploadedFilesShar,
        PP_UploadNewFile,
        PP_Backt_o_My_Files,
        PP_Filerenamedsuccesfully,
        PP_Limit10Files,
        PP_Fileremovedsuccesfully,
        REMOVE,
        RENAME,
        PREVIEW
    };

    value = 'inProgress';
    @track userId = Id;

    Nofilesupload = true;
    filesuploaded = false;
    isCTPenableUpload = false;
    getsize = 12;

    noRecords = true;
    filesUploaded = [];
    isPart;
    getData;
    popupActionItems = [];
    isFile = true;
    ShowuploadSection = false;
    isMobile;
    isDesktop;
    isSaving = false;
    openmodel = false;
    openfileUrl;
    isNameEmptyorNotValid = false;
    isLoaded = false;
    FileUploadPending = true;
    isFileNameNotvalid = false;

    cancelmodalisOpen = false;
    displaytooltiptitle = 'browse files';

    progresBarClass = ' progressBar slds-col slds-size_5-of-12 ';
    // progresBarClass =' progressBarError slds-col slds-size_5-of-12 ';

    renameObj = {
        name: RENAME
    };
    Preview = {
        name: PREVIEW
    };
    removeobj = {
        name: REMOVE
    };

    uploadonid; //perid

    @track
    filesData = [];
    @track isAndroid;

    get options() {
        return [
            { label: 'Uploaded', value: 'uploaded' },
            { label: 'Shares with Me', value: 'sharewithme' }
        ];
    }
    handleChange(event) {
        this.value = event.detail.value;
    }
    getRseult;
    connectedCallback() {
        this.isAndroid=this.isAndroidApp();
        if (formFactor === 'Small' || formFactor === 'Medium') {
            this.isMobile = true;
            this.isDesktop=false;
        } else {
            this.isMobile = false;
            this.isDesktop=true;
        }
       
        this.isSaving = true;
        if (!communityService.isDummy()) {
            this.getData = communityService.getParticipantData();
            this.popupActionItems.push(this.Preview);
            this.popupActionItems.push(this.renameObj);
            this.popupActionItems.push(this.removeobj);
            // if (this.getData.pe.Clinical_Trial_Profile__r.Document_Upload_Is_Available__c) {
            //     this.isCTPenableUpload = true;
            //     this.getsize=8;
            // }
            isUplaodAvailable({
                perId: this.getData.pe.Id
            }).then((result) => {
                this.isCTPenableUpload = result.isUplaodAvailable;
                if (this.isCTPenableUpload) {
                    this.getsize = 8;
                }
                this.isSaving = false;
            });
        }
    }
    isAndroidApp(){
        if ( (navigator.userAgent.match(/Android/i)) && communityService.isMobileSDK()) {
            return true;
        }  else{
            return false;
        }
    }
    showUploadSectiontoUser(event) {
        this.isSaving = true;
        this.ShowuploadSection = true;
        this.isSaving = false;
    }

    //pagination
    totalRecord;totalRecordMsg;
    showZeroErr = false;
    initialLoad = true;
    initialLoadMsg = true;
    page;
    pagemsg;
    issharedFilesTab = false;
    pageChanged(event) {
        if (!this.issharedFilesTab) {
            this.page = event.detail.page;
            this.template.querySelector('c-ppdocment-view-page').pageNumber = this.page;
            if (!this.initialLoad) {
                this.template.querySelector('c-ppdocment-view-page').stopSpinner = false;
                this.template.querySelector('c-ppdocment-view-page').getTableFilesData();
            }
            this.initialLoad = false;
        } else {
            this.pagemsg = event.detail.page;
            this.template.querySelector('c-ppdocment-view-page').pageNumberMsg = this.pagemsg;
            if (!this.initialLoadMsg) {
                console.log('>>>fetch page called>>>');
                this.template.querySelector('c-ppdocment-view-page').stopSpinner = false;
                this.template.querySelector('c-ppdocment-view-page').getTableMsgFilesData();
            }
            this.initialLoadMsg = false;
        }
    }
    changePage(event) {
        let dir = event.detail;
        if (dir == 'next') {
            this.template.querySelector('c-pir_participant-pagination').nextPage();
        }
        if (dir == 'prev') {
            this.template.querySelector('c-pir_participant-pagination').previousPage();
        }
    }
    handleUpdate = false;
    handleUpdateMsg = false;
    handletotalrecord(event) {
        this.totalRecord = event.detail;
        this.handleUpdate = true;
        this.handleresetpageonupdate();
    }
    handletotalrecordmsg(event) {
        this.totalRecordMsg = event.detail;
        this.handleUpdateMsg = true;
        this.handleresetpageonupdatemsg();
    }

    handleTabChange(event){
        if (event.detail == 'sharetab') {
            this.issharedFilesTab = true;
        } else {
            this.issharedFilesTab = false;
        }
    }
    isResetOnUpdate = false;
    isResetPagination = false;
    isResetPaginationMsg = false;

    handleresetpageonupdate() {
        this.initialLoad = true;
        if(this.totalRecord){
            this.template.querySelector('c-pir_participant-pagination').totalRecords =
                this.totalRecord;
            this.template.querySelector('c-pir_participant-pagination').updateInprogress();
        }
        this.handleUpdate = false;
        this.initialLoad = false;
    }
    handleresetpageonupdatemsg() {
        this.initialLoadMsg = true;
        if (this.totalRecordMsg) {
            this.template.querySelector('c-pir_participant-pagination').totalRecords =
                this.totalRecordMsg;
            this.template.querySelector('c-pir_participant-pagination').updateInprogress();
        }
        this.handleUpdateMsg = false;
        this.initialLoadMsg = false;
    }
    handleresetpagination(event) {
        this.isResetPagination = true;
        if (this.isResetPagination) {
            this.initialLoad = true;
            this.template.querySelector('c-pir_participant-pagination').totalRecords =
                this.totalRecord;
            this.template.querySelector('c-pir_participant-pagination').goToStart();
        }
        this.isResetPagination = false;
    }
    handleresetpaginationmsg(event) {
        this.isResetPaginationMsg = true;
        if (this.isResetPaginationMsg) {
            this.initialLoadMsg = true;
            this.template.querySelector('c-pir_participant-pagination').totalRecords =
                this.totalRecordMsg;
            this.template.querySelector('c-pir_participant-pagination').goToStart();
        }
        this.isResetPaginationMsg = false;
    }

    isDelete = false;
    handleresetondelete(event) {
        this.isDelete = true;
        if (this.isDelete) {
            this.initialLoad = true;
            this.template.querySelector('c-pir_participant-pagination').totalRecords =
                this.totalRecord;
            this.template.querySelector('c-pir_participant-pagination').previousPage();
            this.template.querySelector('c-ppdocment-view-page').pageNumber = this.page;
            this.template.querySelector('c-ppdocment-view-page').stopSpinner = false;
            this.template.querySelector('c-ppdocment-view-page').getTableFilesData();
        }
        this.isDelete = false;
    }

    showfileUplaodSection() {
        this.ShowuploadSection = true;
    }
    handlebacktoFile(){
        if(this.totalfilesUploaded>0){
             this.cancelFiles()
        }
        else{
            this.ShowuploadSection = false;
        }
       
    }
    totalfilesUploaded = 0;
    totalValidFile = 0;
    totalValidFileProcessed = 0;
    totalInvalidFile = 0;
    lengthGreater = false;

    handleFilesChange(event) {
        if (event.target.files.length > 0) {
            this.lengthGreater = false;

            // Limit 10 starts here
            if (event.target.files.length > 10) {
                this.template.querySelector('c-custom-toast-files-p-p').showToast('error',this.label.PP_Limit10Files,'utility:warning',3000);
                event.target.value = null;
                return;
        }

            if (this.totalfilesUploaded + event.target.files.length > 10) {
                this.template.querySelector('c-custom-toast-files-p-p').showToast('error',this.label.PP_Limit10Files,'utility:warning',3000);
                event.target.value = null;
                return;
            }
            if (this.totalfilesUploaded + event.target.files.length == 10) {
                this.disableInput();
            } else {
                if (this.template.querySelector('[data-id="browsediv"]')) {
                    let inputclassDivcss =
                        this.template.querySelector('[data-id="browsediv"]').classList.value;
                    if (inputclassDivcss.includes('disabledrag')) {
                       
                       this.template.querySelector('[data-id="browsediv"]').classList.remove('disabledrag');
                       if(this.template.querySelector(".fileInput")){
                         this.template.querySelector(".fileInput").disabled = false; 
                      }
                      if(this.template.querySelector(".fileInputMobile")){
                         this.template.querySelector(".fileInputMobile").disabled = false; 
                        }

                    }
                } 
                
            }
            // Limit 10 End here
            this.Nofilesupload = false;
            this.FileUploadPending = true;
            this.totalfilesUploaded = this.totalfilesUploaded + event.target.files.length;
            for (var i = 0; i < event.target.files.length; i++) {
                this.filesUploaded.push(event.target.files[i]);
            }
            this.progress = 0;
            this.progressWidth = 'width :0%';
            event.target.value = null;

            this.saveFile();
        }
    }

    //this method is also for limit 10
    eventdisable;
    disableInput() {
        clearTimeout(this.eventdisable);
        this.eventdisable = setTimeout(() => {
            this.template.querySelector('[data-id="browsediv"]').classList.add('disabledrag');
            if(this.template.querySelector(".fileInput")){
                this.template.querySelector(".fileInput").disabled = true; 
              }
              if(this.template.querySelector(".fileInputMobile")){
                this.template.querySelector(".fileInputMobile").disabled = true; 
            }
          }, 600);
    }

    saveFile() {
        this.progressWidth = 'width :2%';
        this.progress = 2;

        for (var i = 0; i < this.filesUploaded.length; i++) {
            let index = this.filesData.findIndex((x) => x.index === i);
            if (index != -1) continue;
            var fileCon = this.filesUploaded[i];

            this.base = Math.floor((CHUNK_SIZE / fileCon.size) * 100);

            let extension_index = fileCon.name.lastIndexOf('.');
            let extension = fileCon.name.slice(extension_index + 1);
            let filenamewitoutextension = fileCon.name.slice(0, extension_index);
            let blob = new Blob([fileCon], { type: fileCon.type });
            if (
                extension.toLowerCase() != 'jpg' &&
                extension.toLowerCase() != 'pdf' &&
                extension.toLowerCase() != 'jpeg' &&
                extension.toLowerCase() != 'gif' &&
                extension.toLowerCase() != 'png'
            ) {
                this.filesData.push({
                    progresBarClass: ' progressBar slds-col slds-size_5-of-12 ',
                    fileName: fileCon.name,
                    file: fileCon,
                    filecontentafterRead: '',
                    base: '',
                    progressMultiplier: '',
                    // fileSize: fileSize,
                    progress: this.progress,
                    index: i,
                    isValid: false,
                    isNameReadOnly: true,
                    ErrorMessage: this.label.PP_FileFormatNotAccept,
                    // fileRemaining: fileRemaining,
                    progressWidth: this.progressWidth,
                    UploadCompleted: true,
                    isDeleted: false,
                    isRetry: false,
                    isSuccessfullyDeleted: false,
                    fileContentVerId: '',
                    error: false,
                    tooltip: false,
                    isNameEmptyorNotValid: false,
                    fileNameTooLong: false,
                    fileNameForEdit: ''
                });
                this.totalInvalidFile = this.totalInvalidFile + 1;
                continue;
            } else if (fileCon.size > MAX_FILE_SIZE) {
                this.filesData.push({
                    progresBarClass: ' progressBar slds-col slds-size_5-of-12 ',
                    fileName: fileCon.name,
                    file: fileCon,
                    filecontentafterRead: '',
                    base: '',
                    progressMultiplier: '',
                    // fileSize: fileSize,
                    progress: this.progress,
                    index: i,
                    isValid: false,
                    isNameReadOnly: true,
                    ErrorMessage: this.label.PP_MaxFileSize,
                    // fileRemaining: fileRemaining,
                    progressWidth: this.progressWidth,
                    UploadCompleted: true,
                    isDeleted: false,
                    isRetry: false,
                    isSuccessfullyDeleted: false,
                    fileContentVerId: '',
                    error: false,
                    tooltip: false,
                    isNameEmptyorNotValid: false,
                    fileNameTooLong: false,
                    fileNameForEdit: ''
                });
                this.totalInvalidFile = this.totalInvalidFile + 1;
                continue;
            } else {
                this.filesData.push({
                    progresBarClass: ' progressBar slds-col slds-size_5-of-12 ',
                    fileName: fileCon.name,
                    file: fileCon,
                    filecontentafterRead: '',
                    base: '',
                    progressMultiplier: '',
                    // fileSize: fileSize,
                    progress: this.progress,
                    index: i,
                    isValid: true,
                    isNameReadOnly: true,
                    ErrorMessage: '',
                    // fileRemaining: fileRemaining,
                    progressWidth: this.progressWidth,
                    UploadCompleted: false,
                    isDeleted: false,
                    isRetry: false,
                    isSuccessfullyDeleted: false,
                    fileContentVerId: '',
                    error: false,
                    tooltip: false,
                    isNameEmptyorNotValid: false,
                    fileNameTooLong: false,
                    fileNameForEdit: ''
                });
                this.totalValidFile = this.totalValidFile + 1;
                this.setupReader(fileCon, i);
            }
        }
        this.toggleUploadButton();
    }
    setupReader(fileCon, indexoffile) {
        var reader = new FileReader();
        var self = this;

        self.progressWidth = 'width :10%';
        self.progress = 10;

        reader.onload = function () {
            var fileContents = reader.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            fileContents = fileContents.substring(dataStart);
            let index = self.filesData.findIndex((x) => x.index === indexoffile);
            self.filesData[index].progressWidth = self.progressWidth;
            self.filesData[index].progress = self.progress;
            self.filesData[index].filecontentafterRead = fileContents;
            self.filesData[index].base = Math.floor((CHUNK_SIZE / fileCon.size) * 100);
            self.filesData[index].progressMultiplier = 1;

            self.upload(fileCon, fileContents, indexoffile);
        };
        reader.readAsDataURL(fileCon);
    }
    upload(file, fileContents, indexoffile) {
        var fromPos = 0;
        var toPos = Math.min(fileContents.length, fromPos + CHUNK_SIZE);
        this.uploadChunk(file, fileContents, fromPos, toPos, '', '', indexoffile);
    }
    uploadChunk(
        file,
        fileContents,
        fromPos,
        toPos,
        attachId,
        strfileContentDocumentId,
        indexoffile
    ) {
        var chunk = fileContents.substring(fromPos, toPos);
        //disableInput();

        try {
            let index = this.filesData.findIndex((x) => x.index == indexoffile);

            let shouldcallserver = true;
            if (this.filesData[index].isDeleted) {
                shouldcallserver = this.filesData[index].fileContentVerId
                    ? this.filesData[index].isSuccessfullyDeleted
                        ? false
                        : true
                    : false;
            }

            if (index >= 0 && shouldcallserver && !this.iscancelButtonClick) {
                saveTheChunkFile({
                    parentId: this.getData.pe.Id,
                    fileName: file.name,
                    base64Data: encodeURIComponent(chunk),
                    // completeFile: encodeURIComponent(fileContents),
                    contentType: file.type,
                    fileId: attachId,
                    strfileContentDocumentId: strfileContentDocumentId,
                    isDeleted: this.filesData[index].isDeleted,
                    isRetry: this.filesData[index].isRetry,
                    Progress: this.filesData[index].progress,
                    isCancelButtonClicked: this.iscancelButtonClick
                })
                    .then((result) => {
                        let getresult = JSON.parse(result);
                        if (!this.iscancelButtonClick) {
                            this.fileId = getresult.filecontentversion;
                            if (!getresult.filecontentversion && this.filesData[index].isDeleted) {
                                this.filesData[index].isSuccessfullyDeleted = true;
                            }
                            if (this.filesData[index].isRetry) {
                                this.filesData[index].isRetry = false;
                            }
                            // this.filesData[index].fileContentVerId = getresult.FileContentDocId;
                            this.filesData[index].previewLinks = getresult.previewLinks;
                            this.filesData[index].fileContentVerId = getresult.filecontentversion;
                            attachId = getresult.filecontentversion;
                            strfileContentDocumentId = getresult.FileContentDocId;
                            fromPos = toPos;

                    // this.showdata = false;
                            if (index >= 0) {
                                toPos = Math.min(fileContents.length, fromPos + CHUNK_SIZE);
                                if (fromPos < toPos) {
                                    var uploadedPercent =
                                        (this.uploadedsize / (this.filesize + CHUNK_SIZE)) * 100;
                                    this.filesData[index].progressMultiplier++;

                                    if (
                                        this.filesData[index].base *
                                            this.filesData[index].progressMultiplier <
                                        100
                                    ) {
                                        this.filesData[index].progress =
                                            this.filesData[index].base *
                                            this.filesData[index].progressMultiplier;
                                    } else {
                                        this.filesData[index].progress = 99;
                                    }
                                    this.filesData[index].progressWidth =
                                        'width :' + this.filesData[index].progress + '%';
                                    this.uploadChunk(
                                        file,
                                        fileContents,
                                        fromPos,
                                        toPos,
                                        attachId,
                                        strfileContentDocumentId,
                                        indexoffile
                                    );
                                    this.toggleUploadButton();
                                } else {
                                    this.filesData[index].progress = 100;
                                    this.filesData[index].progressWidth =
                                        'width :' +
                                        this.filesData[index].progress +
                                        '%;background-color: #0768FD;'; //change 00C221 ths to 0768FD
                                    if (this.filesData[index].isDeleted) {
                                        // this.progressWidth = 'width :'+this.progress+'%';
                                        this.uploadChunk(
                                            file,
                                            fileContents,
                                            fromPos,
                                            toPos,
                                            attachId,
                                            strfileContentDocumentId,
                                            indexoffile
                                        );
                                        this.totalValidFileProcessed =
                                            this.totalValidFileProcessed - 1;
                                    }
                                    this.totalValidFileProcessed = this.totalValidFileProcessed + 1;
                                    this.filesData[index].UploadCompleted = true;
                                    this.toggleUploadButton();
                                }
                            }
                        }
                    })
                    .catch((error) => {
                        console.log('>>exception is>>', error);
                        console.log(
                            '>>exception is>>' + JSON.stringify(error) + '>>atindex>' + index
                        );
                        this.filesData[index].error = true;
                        this.filesData[index].progresBarClass =
                            'progressBarError slds-col slds-size_5-of-12 ';
                        let exceptionBody = error.body;

                        this.totalValidFile = this.totalValidFile - 1;
                        this.totalInvalidFile = this.totalInvalidFile + 1;
                        this.toggleUploadButton();
                    })
                    .finally(() => {});
            }
        } catch (error) {
            console.log('>>error in out>>' + error);
        }
    }

    formatBytes(bytes, decimals) {
        if (bytes == 0) return '0 Bytes';
        var k = 1024,
            dm = decimals || 2,
            sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
            i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }

    showActionMenu(event) {
        let index = event.currentTarget.dataset.key;
        // let indexcalled = this.template.querySelector("[data-key='" + index + "']");
        let indexcalled = this.template.querySelector(".imagecssDesk[data-key='" + index + "']");
        let classindexcalled = indexcalled.classList.value;

        let actionmenuDiv = this.template.querySelector(".action-menu[data-key='" + index + "']");
        let actionmenuDivCSSClass = actionmenuDiv.classList.value;
        if (this.filesData[index].isNameEmptyorNotValid || this.filesData[index].fileNameTooLong) {
            if (!actionmenuDivCSSClass.includes('addmarginwhenerror'))
                actionmenuDiv.classList.add('addmarginwhenerror');
        } else {
            if (actionmenuDivCSSClass.includes('addmarginwhenerror'))
                actionmenuDiv.classList.remove('addmarginwhenerror');
        }

        if (!classindexcalled.includes('slds-is-open')) indexcalled.classList.add('slds-is-open');
        if (classindexcalled.includes('slds-is-open')) indexcalled.classList.remove('slds-is-open');
    }

    closeMenu() {
        this.template.querySelectorAll('.D').forEach(function (L) {
            L.classList.remove('slds-is-open');
        });
    }

    isRenameOpen = false;
    fileNameForEdit = '';
    fileRemoveMessage = '';
    removefilefromDraftmodel = false;
    indexatDeleteClick;
    deleteFileID;
    previewHeader;
    modalHeaderFilePage = false;
    callMethod(event) {
        let methodNameCalled = event.currentTarget.dataset.method;
        let indexcalled = event.currentTarget.dataset.key;
        if (methodNameCalled == 'Rename') {
            let extension_index = this.filesData[indexcalled].fileName.lastIndexOf('.');
            let extension = this.filesData[indexcalled].fileName.slice(extension_index + 1);
            let filenamewitoutextension = this.filesData[indexcalled].fileName.slice(
                0,
                extension_index
            );

            let lightninginputatindex = this.template.querySelector(
                ".imgNamedesk[data-key='" + indexcalled + "']"
            );

            lightninginputatindex.classList.add('renameinputclassdiv');

            lightninginputatindex.classList.remove('imgname');

            this.filesData[indexcalled].fileNameForEdit = filenamewitoutextension.trim();
            this.filesData[indexcalled].isNameReadOnly = false;
            this.focusInput(indexcalled);
            this.isRenameOpen = true;
            this.toggleUploadButton();
        } else if (methodNameCalled == 'Preview') {
            let extension_index = this.filesData[indexcalled].fileName.lastIndexOf('.');
            let extension = this.filesData[indexcalled].fileName.slice(extension_index + 1);
            let filenamewitoutextension = this.filesData[indexcalled].fileName.slice(
                0,
                extension_index
            );
            this.previewHeader = filenamewitoutextension;
            this.openfileUrl =
                '../apex/MedicalHistoryPreviewVF?resourceId=' +
                this.filesData[indexcalled].fileContentVerId;
           if(this.isMobile && extension=='pdf'){
            this.template.querySelectorAll('.getpreviewCss').forEach(function (L) {
                L.classList.add('previewCssMobile');
            });
            this.template.querySelectorAll('.getpreviewCss').forEach(function (L) {
                L.classList.remove('previewCss');
            });
           }
           else{
            this.template.querySelectorAll('.getpreviewCss').forEach(function (L) {
                L.classList.remove('previewCssMobile');
            });
            this.template.querySelectorAll('.getpreviewCss').forEach(function (L) {
                L.classList.add('previewCss');
            });

           }
           this.openmodel = true;
           this.modalHeaderFilePage=true;
        }
        else if(methodNameCalled == 'Remove')
        {   
            let extension_index = this.filesData[indexcalled].fileName.lastIndexOf('.');
            let extension = this.filesData[indexcalled].fileName.slice(extension_index + 1);
            let filenamewitoutextension = this.filesData[indexcalled].fileName.slice(
                0,
                extension_index
            );
            let message = this.label.PP_RemoveFile;
            this.fileRemoveMessage = message.replace('#fileName', filenamewitoutextension);
            this.indexatDeleteClick = indexcalled;
            this.deleteFileID = this.filesData[indexcalled].fileContentVerId;
            // this.fileRemoveMessage = message;
            this.removefilefromDraftmodel = true;
            this.modalHeaderFilePage = false;
        }
    }
    event1;
    focusInput(indexcalled) {
        clearTimeout(this.event1);
        this.event1 = setTimeout(() => {
            this.template.querySelector("lightning-input[data-key='" + indexcalled + "']").focus();
        }, 600);
    }

    removeFileFromDraft() {
        this.isSaving = true;
        this.filesData[this.indexatDeleteClick].isDeleted = true;
        this.removefilefromDraftmodel = false;
        deleteFile({
            fileId: this.deleteFileID
        })
            .then((result) => {
                this.isSaving = false;

                this.totalfilesUploaded = this.totalfilesUploaded - 1;
                this.totalValidFile = this.totalValidFile - 1;
                this.totalValidFileProcessed = this.totalValidFileProcessed - 1;

        let inputclassDiv = this.template.querySelector('[data-id="browsediv"]'); 
        let inputclassDivcss = this.template.querySelector('[data-id="browsediv"]').classList.value; 
          if(inputclassDivcss.includes('disabledrag'))
          {  
              inputclassDiv.classList.remove('disabledrag');
              if(this.template.querySelector(".fileInput")){
                this.template.querySelector(".fileInput").disabled = false; 
              }
              if(this.template.querySelector(".fileInputMobile")){
                this.template.querySelector(".fileInputMobile").disabled = false; 
            }
          } 



        if(this.totalfilesUploaded == 0)  
        {
            this.Nofilesupload = true;
        }
        this.toggleUploadButton();

        this.template.querySelector('c-custom-toast-files-p-p').showToast('success',this.label.PP_Fileremovedsuccesfully,'utility:success',3000);

    })
    .catch((error) => {
        this.isSaving = false; 
        console.error("Error:", error);
    });
    }

    get cancelDisbledMbl(){
        if( this.isMobile){
            if(this.totalfilesUploaded>0 ){
                return false;
            }
            else{
                return true;
            }
        }
       
    }


    handleCancelModelRemove(){
        this.removefilefromDraftmodel = false;
    }
    
    closeModal(){
        this.openmodel = false;
        this.modalHeaderFilePage=false;
    }

    removeFiles(event) { 
        let indexcalled = event.currentTarget.dataset.key;
        if(this.filesData[indexcalled].isValid)
        {
            this.totalValidFile = this.totalValidFile - 1;
        }
        else { 
            this.totalInvalidFile = this.totalInvalidFile - 1 ; 
        }
        this.filesData[indexcalled].isDeleted = true;
        this.totalfilesUploaded = this.totalfilesUploaded-1;

         
        let inputclassDiv = this.template.querySelector('[data-id="browsediv"]'); 
          let inputclassDivcss = this.template.querySelector('[data-id="browsediv"]').classList.value; 
            if(inputclassDivcss.includes('disabledrag'))
            {  
                inputclassDiv.classList.remove('disabledrag');
                if(this.template.querySelector(".fileInput")){
                    this.template.querySelector(".fileInput").disabled = false; 
                  }
                if(this.template.querySelector(".fileInputMobile")){
                    this.template.querySelector(".fileInputMobile").disabled = false; 
                }


            } 

        if(this.totalfilesUploaded == 0)
        {
            this.Nofilesupload = true;
        }
        this.toggleUploadButton();
    }
    retryFiles(event){
        let indexcalled = event.currentTarget.dataset.key;
        this.filesData[indexcalled].isRetry = true;
        try{
            this.totalValidFile  = this.totalValidFile + 1;
            this.filesData[indexcalled].progressWidth = 'width :10%';
            this.filesData[indexcalled].progress = 10;
            this.filesData[indexcalled].base = Math.floor(
                (CHUNK_SIZE / this.filesData[indexcalled].file.size) * 100
            );
            this.filesData[indexcalled].progressMultiplier = 1;
            this.filesData[indexcalled].progresBarClass =
                ' progressBar slds-col slds-size_5-of-12 ';
            this.filesData[indexcalled].error = false;
            var fromPos = 0;
            var toPos = Math.min(
                this.filesData[indexcalled].filecontentafterRead.length,
                fromPos + CHUNK_SIZE
            );
            this.toggleUploadButton();
            this.uploadChunk(
                this.filesData[indexcalled].file,
                this.filesData[indexcalled].filecontentafterRead,
                fromPos,
                toPos,
                this.filesData[indexcalled].fileContentVerId,
                '',
                indexcalled
            );
        } catch (error) {
            console.log('>>error>>' + error);
        }
    }

    stopBlurEvent(event) {
        event.preventDefault();
    }

    fileNameTooLong = false;

    totalfileNameerror = 0;
    totalfileNameEmpty = 0;
    previewLinks;

    validateandsaveFileName(event) {
        let indexcalled = event.currentTarget.dataset.key;
        let fileNameUpdated = event.target.value;
        this.fileNameTooLong = false;
        if (fileNameUpdated.trim()) {
            if (fileNameUpdated.trim().length > 250) {
                if (!this.filesData[indexcalled].fileNameTooLong) {
                    this.totalfileNameerror = this.totalfileNameerror + 1;
                    this.filesData[indexcalled].fileNameTooLong = true;
                }
                if(this.filesData[indexcalled].isNameEmptyorNotValid)
                {
                this.totalfileNameEmpty = this.totalfileNameEmpty - 1;
                this.filesData[indexcalled].isNameEmptyorNotValid = false;
                }
                this.isRenameOpen = true;
                let lightninginputatindex = this.template.querySelector("lightning-input[data-key='"+indexcalled+"']"); 
                let lightningInputcss = lightninginputatindex.classList.value; 
        
                lightninginputatindex.classList.add('errornameboxred'); 
                let imgnamediv = this.template.querySelector(".imgNamedesk[data-key='"+indexcalled+"']");
             
                imgnamediv.classList.add('renameinputclassdiv'); 
                imgnamediv.classList.remove('imgname'); 

                this.fileNameTooLong = true;
                this.isNameEmptyorNotValid = false;
                this.toggleUploadButton();  
                return;
            }
            if(this.filesData[indexcalled].fileNameTooLong)
            {
                this.totalfileNameerror = this.totalfileNameerror - 1;
                this.filesData[indexcalled].fileNameTooLong = false;
            }
            if(this.filesData[indexcalled].isNameEmptyorNotValid)
            {
                this.totalfileNameEmpty = this.totalfileNameEmpty - 1;
                this.filesData[indexcalled].isNameEmptyorNotValid = false;
            }
            this.filesData[indexcalled].isNameEmptyorNotValid = false; 
            let extension_index = this.filesData[indexcalled].fileName.lastIndexOf('.');
            let extension = this.filesData[indexcalled].fileName.slice(extension_index + 1);
            let filenamewitoutextension = this.filesData[indexcalled].fileName.slice(0, extension_index);
            if(filenamewitoutextension != fileNameUpdated)
            {
                this.template.querySelector('c-custom-toast-files-p-p').showToast('success',this.label.PP_Filerenamedsuccesfully,'utility:success',3000);

                this.filesData[indexcalled].fileName = fileNameUpdated.trim() + '.' + extension ;
            }
            let imgnamediv = this.template.querySelector(".imgNamedesk[data-key='"+indexcalled+"']");
             
                imgnamediv.classList.remove('renameinputclassdiv'); 
                imgnamediv.classList.add('imgname'); 
            this.filesData[indexcalled].isNameReadOnly = true;
            this.isRenameOpen = false;
            this.filesData[indexcalled].isNameEmptyorNotValid = false;   
            this.filesData[indexcalled].fileNameTooLong = false;

        }
        else {

            if(!this.filesData[indexcalled].isNameEmptyorNotValid)
            {
                this.totalfileNameEmpty = this.totalfileNameEmpty + 1;
                this.filesData[indexcalled].isNameEmptyorNotValid = true;
               // this.filesData[indexcalled].fileNameTooLong = false;
            }
            if(this.filesData[indexcalled].fileNameTooLong)
            {
                this.filesData[indexcalled].fileNameTooLong = false;
                this.totalfileNameerror = this.totalfileNameerror - 1;

            }

            let imgnamediv = this.template.querySelector(
                ".imgNamedesk[data-key='" + indexcalled + "']"
            );

            imgnamediv.classList.add('renameinputclassdiv');
            imgnamediv.classList.remove('imgname');
            this.isRenameOpen = true;
            this.isNameEmptyorNotValid = true;
            let lightninginputatindex = this.template.querySelector(
                "lightning-input[data-key='" + indexcalled + "']"
            );
            let lightningInputcss = lightninginputatindex.classList.value;

            lightninginputatindex.classList.add('errornameboxred');

            this.filesData[indexcalled].isNameReadOnly = false;
        }
        this.toggleUploadButton();
    }
    displayErrorFilesPopupWarning = false;
    iscancelButtonClick = false;
    uploadFiles() {
        if (this.totalInvalidFile > 0) {
            this.displayErrorFilesPopupWarning = true;
        } else {
            this.uploadFilesToserver();
        }
    }
    cancelFiles() {
        this.cancelmodalisOpen = true;
    }
    backtoUploadClick() {
        this.cancelmodalisOpen = false;
        this.iscancelButtonClick = false;
    }
    ContinuetoDeleteFiles() {
        this.FileUploadPending = true;
        this.isSaving = true;
        this.cancelmodalisOpen = false;
        this.iscancelButtonClick = true;
        this.ShowuploadSection = false;
        DeleteAlldraftFiles({
            perId: this.getData.pe.Id
        })
            .then((result) => {
                this.filesData = [];
                this.filesUploaded = [];
                this.totalfilesUploaded = 0;
                this.totalValidFile = 0;
                this.totalInvalidFile = 0;
                this.totalValidFileProcessed = 0;
                this.Nofilesupload = true;
                this.isSaving = false;
                this.iscancelButtonClick = false;
            })
            .catch((error) => {
                this.isSaving = false;
                this.cancelmodalisOpen = false;
                this.Nofilesupload = true;
                this.filesData = [];
            });
    }

    uploadFilesToserver() {
        this.isSaving = true;
        this.Nofilesupload = true;
        this.ShowuploadSection=false;
        for (var i = 0; i < this.filesData.length; i++) {
            this.filesData[i].filecontentafterRead = '';
            this.filesData[i].file = '';
            // this.filesData[i].fileSize = '';
            // this.filesData[i].fileRemaining = '';
            this.filesData[i].progressWidth = '';
            this.filesData[i].progresBarClass = '';
            this.filesData[i].progress = '';
        }
        uploadFiles({
            strFileData: JSON.stringify(this.filesData),
            perId: this.getData.pe.Id
        })
            .then((result) => {
                this.filesData = [];
                this.filesUploaded = [];
                this.totalfilesUploaded = 0;
                this.totalValidFile = 0;
                this.totalInvalidFile = 0;
                this.totalValidFileProcessed = 0;
                this.displayErrorFilesPopupWarning = false;
                this.Nofilesupload = true;
                this.template.querySelector('c-ppdocment-view-page').stopSpinner = false;
                this.template.querySelector('c-ppdocment-view-page').getTableFilesData();
                this.isSaving = false;
                this.iscancelButtonClick = false;
                this.FileUploadPending = true;
                this.template.querySelector('c-custom-toast-files-p-p').showToast('success', this.label.PP_UploadSuccess,'utility:success',3000);
            })
            .catch((error) => {
                this.isSaving = false;
                this.displayErrorFilesPopupWarning = false;
                // this.Nofilesupload = false;
                console.log('>>exception is>>' + error.message);
                console.log('>>exception is>>', error);
                console.log('>>exception is>>' + JSON.stringify(error));
            });
    }

    handleCancelwarning() {
        this.displayErrorFilesPopupWarning = false;
    }

    toggleUploadButton() {
        if (this.totalfileNameerror > 0 || this.totalfileNameEmpty > 0 || this.isRenameOpen) {
            this.FileUploadPending = true;
            return;
        }
        if (this.totalValidFile > 0) {
            if (this.totalValidFileProcessed == this.totalValidFile) {
                this.FileUploadPending = false;
            } else {
                this.FileUploadPending = true;
            }
        } else {
            this.FileUploadPending = true;
        }
    }
    tooltip = false;
    showToolTip(event) {
        let indexCalled = event.currentTarget.dataset.key;
        this.filesData[indexCalled].tooltip = true;
        this.tooltip = true;
    }
    HideToolTip() {
        for (var i = 0; i < this.filesData.length; i++) {
            this.filesData[i].tooltip = false;
        }
    }
}