import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
//import saveTheChunkFile from '@salesforce/apex/nonReferedBulkUpload.saveTheChunkFile';  //Need to change the method
import saveTheChunkFile from '@salesforce/apex/ppFileUploadController.saveTheChunkFile'; //Need to change the method
import isUplaodAvailable from '@salesforce/apex/ppFileUploadController.isUplaodAvailable';
import PP_AcceptedFileformats from '@salesforce/label/c.PP_AcceptedFileformats';
import PP_acceptedformats from '@salesforce/label/c.PP_acceptedformats';
import PP_MaxFileSize from '@salesforce/label/c.PP_MaxFileSize';
import PP_FileFormatNotAccept from '@salesforce/label/c.PP_FileFormatNotAccept';
import formFactor from '@salesforce/client/formFactor';

const MAX_FILE_SIZE = 4500000; //2621440;// 4500000; max file size prog can handle
const CHUNK_SIZE = 750000; //9000;//750000; max chunk size prog can handle
const MAX_FILE_SIZE_mb = 4;

export default class PpfilesViewPage extends NavigationMixin(LightningElement) {
    noDocumentAvailable = pp_icons + '/' + 'noDocumentAvailable.svg';
    uploadNewDocuments = pp_icons + '/' + 'uploadNewDocuments.svg';
    threedots_imgUrl = pp_icons + '/' + 'three_dots.png';

    label = {
        PP_AcceptedFileformats,
        PP_acceptedformats,
        PP_MaxFileSize,
        PP_FileFormatNotAccept
    };

    value = 'inProgress';
    @track userId = Id;

    Nofilesupload = true;
    filesuploaded = false;
    isCTPenableUpload = false;
    getsize = 12;

    fileName = '';
    progress = 0;
    noRecords = true;
    progressWidth = 'width :0%';
    base = 1;
    progressMultiplier = 0;
    filesUploaded = [];
    fileSize;
    fileId = '';
    fileSize;
    fileId = '';
    csvData = '';
    totalRecs = 0;
    isPart;
    getData;
    popupActionItems = [];
    isFile = true;
    ShowuploadSection = false;
    isMobile;
    isSaving = false;
    openmodel = false;
    openfileUrl;
    isNameEmpty = false;
    isLoaded = false;

    progresBarClass = ' progressBar slds-col slds-size_5-of-12 ';
    // progresBarClass =' progressBarError slds-col slds-size_5-of-12 ';

    renameObj = {
        name: 'Rename'
    };
    Preview = {
        name: 'Preview'
    };
    removeobj = {
        name: 'Remove'
    };

    uploadonid; //perid

    @track
    filesData = [];

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
        if (formFactor === 'Small' || formFactor === 'Medium') {
            this.isMobile = true;
        } else {
            this.isMobile = false;
        }
        console.log('>>>connectedcallback>>');
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
                console.log('>>>result is>>>' + JSON.stringify(result));
                

                this.isCTPenableUpload = result.isUplaodAvailable;
                if (this.isCTPenableUpload) {
                    this.getsize = 8;
                }
                this.isSaving = false;
            });

        }
    }
    disconnectedCallback(event) {
        console.log('>>>disconnectedcallback>>');
    }
    beforeUnloadHandler(event) {
        alert('before unload handler has been called.');
    }

    showUploadSectiontoUser(event) {
        this.ShowuploadSection = true;
    }

    //pagination
    totalRecord;
    showZeroErr = false;
    initialLoad = true;
    page;
    pageChanged(event) {
        console.log('>>page changed called>>>');
        this.page = event.detail.page;
        this.template.querySelector('c-ppview-files-page-new').pageNumber = this.page;
        if (!this.initialLoad) {
            console.log('>>>fetch page called>>>');
            //this.template.querySelector("c-ppview-files-page-new").stopSpinner=false;
            //this.template.querySelector("c-ppview-files-page-new").updateInProgressOldData();
            //this.template.querySelector("c-ppview-files-page-new").fetchData();
        }
        this.initialLoad = false;
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
    handletotalrecord(event) {
        this.totalRecord = event.detail;
        this.handleUpdate = true;
        this.handleresetpageonupdate();
    }
    isResetOnUpdate = false;
    isResetPagination = false;
    handleresetpageonupdate() {
        if (this.handleUpdate && !this.isResetPagination) {
            this.initialLoad = true;
            this.template.querySelector('c-pir_participant-pagination').totalRecords =
                this.totalRecord;
            //this.template.querySelector("c-pir_participant-pagination").updateInprogress();
        }
        this.handleUpdate = false;
        this.initialLoad = false;
    }
    handleresetpagination(event) {
        if (this.isResetPagination) {
            this.initialLoad = true;
            this.template.querySelector('c-pir_participant-pagination').totalRecords =
                this.totalRecord;
            this.template.querySelector('c-pir_participant-pagination').goToStart();
        }
        this.isResetPagination = false;
    }

    showfileUplaodSection() {
        console.log('>>>calling btuton>>');
        this.ShowuploadSection = true;
    }
    totalfilesUploaded = 0;
    handleFilesChange(event) {
        if (event.target.files.length > 0) {
            this.Nofilesupload = false;
            //  this.filesUploaded.push(event.target.files);
            //  console.log('>>>>this.filesUploaded>>' + this.filesUploaded);
            //   console.log('>>>>this.filesUploaded>>' + JSON.stringify(this.filesUploaded));
            this.totalfilesUploaded = this.totalfilesUploaded + event.target.files.length;
            console.log('>>>targetfilescon>>' + JSON.stringify(event.target.files[0]));
            for (var i = 0; i < event.target.files.length; i++) {
                console.log('>>>name is>>' + event.target.files[i].name);
                this.filesUploaded.push(event.target.files[i]);
            }
            this.progress = 0;
            this.progressWidth = 'width :0%';
            // this.base = 1;
            // this.totalRecs = 0;
            // this.progressMultiplier = 0;
            this.saveFile();
        }
    }

    saveFile() {
        this.progressWidth = 'width :2%';
        this.progress = 2;


        for (var i = 0; i < this.filesUploaded.length; i++) {
            console.log('>>>188');
            let index = this.filesData.findIndex((x) => x.index === i);
            console.log('>>>190>>?' + index);
            if (index != -1) continue;
            var fileCon = this.filesUploaded[i];

            this.base = Math.floor((CHUNK_SIZE / fileCon.size) * 100);
            let fileSize = this.formatBytes(fileCon.size, 2);
            console.log(
                '>>>file at index>>' + fileCon.name + '>>index is>>' + i + '>>type>>' + fileCon.type
            );
            let fileRemaining = '';
            var fs = fileSize.split(' ');
            var fu = ((fs[0] * this.progress) / 100).toFixed(2);
            if (fs[0] / fu == 1) {
                fileRemaining = fileSize;
            } else {
                fileRemaining = fu + ' ' + fs[1] + ' of ' + fileSize;
            }
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
                    fileSize: fileSize,
                    progress: this.progress,
                    index: i,
                    isValid: false,
                    isNameReadOnly: true,
                    ErrorMessage: this.label.PP_FileFormatNotAccept,
                    fileRemaining: fileRemaining,
                    progressWidth: this.progressWidth,
                    UploadCompleted: true,
                    isDeleted: false,
                    isRetry: false,
                    isSuccessfullyDeleted: false,
                    fileContentVerId: '',
                    error: false
                });
                continue;
            } else if (fileCon.size > MAX_FILE_SIZE) {
                this.filesData.push({
                    progresBarClass: ' progressBar slds-col slds-size_5-of-12 ',
                    fileName: fileCon.name,
                    file: fileCon,
                    filecontentafterRead: '',
                    base: '',
                    progressMultiplier: '',
                    fileSize: fileSize,
                    progress: this.progress,
                    index: i,
                    isValid: false,
                    isNameReadOnly: true,
                    ErrorMessage: this.label.PP_MaxFileSize,
                    fileRemaining: fileRemaining,
                    progressWidth: this.progressWidth,
                    UploadCompleted: true,
                    isDeleted: false,
                    isRetry: false,
                    isSuccessfullyDeleted: false,
                    fileContentVerId: '',
                    error: false
                });
                continue;
            } else {
                this.filesData.push({
                    progresBarClass: ' progressBar slds-col slds-size_5-of-12 ',
                    fileName: fileCon.name,
                    file: fileCon,
                    filecontentafterRead: '',
                    base: '',
                    progressMultiplier: '',
                    fileSize: fileSize,
                    progress: this.progress,
                    index: i,
                    isValid: true,
                    isNameReadOnly: true,
                    ErrorMessage: '',
                    fileRemaining: fileRemaining,
                    progressWidth: this.progressWidth,
                    UploadCompleted: false,
                    isDeleted: false,
                    isRetry: false,
                    isSuccessfullyDeleted: false,
                    fileContentVerId: '',
                    error: false
                });
                this.setupReader(fileCon, i);
            }
        }
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

            //     let fileSize = self.formatBytes(fileCon.size, 2);
            //     let fileRemaining = '';
            //     var fs = fileSize.split(' ');
            //     var fu = ((fs[0] * self.progress) / 100).toFixed(2);
            //     if (fs[0] / fu == 1) {
            //         fileRemaining = fileSize;
            //     } else {
            //         fileRemaining = fu + ' ' + fs[1] + ' of ' + fileSize;
            //     }

            //    self.filesData.push({'fileName':fileCon.name, 'fileSize': fileSize, 'progress':self.progress,'index':indexoffile,
            //                             'fileRemaining' : fileRemaining, 'progressWidth' : self.progressWidth,'UploadCompleted' : false});
            // self.showdata = true;
            // self.filesData = JSON.stringify(self.filesData);

            // console.log('>>>141>>' + JSON.stringify(self.filesData));
            // this.upload(fileCon, fileContents);

            self.upload(fileCon, fileContents, indexoffile);
        };
        reader.readAsDataURL(fileCon);
    }
    upload(file, fileContents, indexoffile) {
        console.log('>>>163>>');

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

        try {
            let index = this.filesData.findIndex((x) => x.index == indexoffile);
            console.log('>>>index inside upload>>' + index);
            let shouldcallserver = true;
            if (this.filesData[index].isDeleted) {
                shouldcallserver = this.filesData[index].fileContentVerId
                    ? this.filesData[index].isSuccessfullyDeleted
                        ? false
                        : true
                    : false;
            }
            
            if (index >= 0 && shouldcallserver) {
                

                console.log('>>inside> attachId' + attachId);
                
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
                    Progress: this.filesData[index].progress
                })
                    .then((result) => {
                        let getresult = JSON.parse(result);
                        console.log('filecontentversion>>' + getresult.filecontentversion);
                        console.log('FileContentDocId>>' + getresult.FileContentDocId);
                        this.fileId = getresult.filecontentversion;
                        if (!getresult.filecontentversion && this.filesData[index].isDeleted) {
                            this.filesData[index].isSuccessfullyDeleted = true;
                        }
                        if (this.filesData[index].isRetry) {
                            this.filesData[index].isRetry = false;
                        }
                        // this.filesData[index].fileContentVerId = getresult.FileContentDocId;
                        this.filesData[index].fileContentVerId = getresult.filecontentversion;
                        attachId = getresult.filecontentversion;
                        strfileContentDocumentId = getresult.FileContentDocId;
                        console.log('FileContentDocId>>' + getresult.FileContentDocId);
                        fromPos = toPos;
                        console.log(
                            '>>indexoffile>>' +
                                indexoffile +
                                '>>filedata is>>' +
                                JSON.stringify(this.filesData)
                        );

                        console.log('>>index is>>' + index);
                        console.log('>>filesfata at index is>>' + this.filesData[index]);

                        // this.showdata = false;
                        if (index >= 0) {
                            toPos = Math.min(fileContents.length, fromPos + CHUNK_SIZE);
                            if (fromPos < toPos) {
                                this.filesData[index].progressMultiplier++;
                                // this.progressMultiplier++;
                                // if (this.base * this.progressMultiplier < 100) {
                                //     this.filesData[index].progress =
                                //         this.base * this.progressMultiplier;
                                //     console.log('>>227>>' + this.filesData);

                                //     // this.progress = this.base * this.progressMultiplier;
                                // }
                                if (
                                    this.filesData[index].base *
                                        this.filesData[index].progressMultiplier <
                                    100
                                ) {
                                    this.filesData[index].progress =
                                        this.filesData[index].base *
                                        this.filesData[index].progressMultiplier;
                                    console.log('>>227>>' + this.filesData);

                                    // this.progress = this.base * this.progressMultiplier;
                                } else {
                                    this.filesData[index].progress = 99;
                                    // this.progress = 99;
                                }
                                this.filesData[index].progressWidth =
                                    'width :' + this.filesData[index].progress + '%';
                                var fs = this.filesData[index].fileSize.split(' ');
                                var fu = ((fs[0] * this.filesData[index].progress) / 100).toFixed(
                                    2
                                );
                                if (fs[0] / fu == 1) {
                                    this.filesData[index].fileRemaining =
                                        this.filesData[index].fileSize;
                                } else {
                                    this.filesData[index].fileRemaining =
                                        fu + ' ' + fs[1] + ' of ' + this.filesData[index].fileSize;
                                }
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
                            } else {
                                console.log('>>files succesfully added>>');
                                //event call to child
                                // this.progress = 100;
                                this.filesData[index].progress = 100;
                                this.filesData[index].progressWidth =
                                    'width :' +
                                    this.filesData[index].progress +
                                    '%;background-color: #0768FD;'; //change 00C221 ths to 0768FD
                                var fs = this.filesData[index].fileSize.split(' ');
                                var fu = ((fs[0] * this.filesData[index].progress) / 100).toFixed(
                                    2
                                );
                                if (fs[0] / fu == 1) {
                                    this.filesData[index].fileRemaining =
                                        this.filesData[index].fileSize;
                                } else {
                                    this.filesData[index].fileRemaining =
                                        fu + ' ' + fs[1] + ' of ' + this.filesData[index].fileSize;
                                }
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
                                }
                                this.filesData[index].UploadCompleted = true;
                            }
                        }
                    })
                    .catch((error) => {
                        console.log('>>exception is>>' + error.message);
                        console.log('>>exception is>>', error);
                        console.log('>>exception is>>' + JSON.stringify(error));
                        let exceptionBody = error.body;
                        if (exceptionBody.message.includes('Disconnected or Canceled')) {
                            console.log('>>insdie if');
                            this.filesData[index].error = true;
                            this.filesData[index].progresBarClass =
                                'progressBarError slds-col slds-size_5-of-12 ';
                        }
                        console.log('>>exception is>>' + error.message);
                        console.log('>>exception is>>' + error);
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
        console.log('>>>method is getting called>>');
       /* let index = event.currentTarget.dataset.key;
        console.log('>>>index is>>' + index);
        console.log('>>>tog>>' + this.template.querySelector("[data-key='" + index + "']"));
        console.log(
            '>>>tog>>' + this.template.querySelector("[data-key='" + index + "']").classList
        );
        this.template.querySelector("[data-key='" + index + "']").classList.add('slds-is-open'); */
    }

    showfileOption(event) {
        console.log('>>>click on11 dott>>');
        // let index = event.currentTarget.dataset.key;

        // console.log('>>index>>' + index);

        // console.log('>>data set>>' + this.template.querySelector("[data-key='" + index + "']"));

        // this.template.querySelector("[data-key='" + index + "']").classList.add('slds-is-open');

        // this.template.querySelectorAll(".D").forEach(function (L) {
        //     L.classList.toggle("slds-is-open");
        // });
        // this.showactionmenu = !this.showactionmenu;
    }

    handleOnBlurIcon() {
        // console.log('>>>blue called>>');
        // this.template.querySelectorAll('.D').forEach(function (L) {
        //     L.classList.remove('slds-is-open');
        // });
    }
    renameClick() {
        // let index = this.filesData.findIndex((x) => x.index === indexoffile);

        // console.log('>>rename click on file>>' + this.filesData[index].fileName);
    }

    closeMenu() {
        // console.log('>>>blue called>>');
        // this.template.querySelectorAll('.D').forEach(function (L) {
        //     L.classList.remove('slds-is-open');
        // });
    }
    callMethod(event) {
        console.log('>>>methdo called>>');

      /*  let methodNameCalled = event.currentTarget.dataset.method;
        let indexcalled = event.currentTarget.dataset.key;
        console.log('>>>called menu is>>' + methodNameCalled + '>>at index>>>' + indexcalled);
        if (methodNameCalled == 'Rename') {
            console.log('>>coming inseide if>>');
            this.filesData[indexcalled].isNameReadOnly = false;
            console.log('>>>filesdat>>' + JSON.stringify(this.filesData));
        }
        if (methodNameCalled == 'Preview') {
            console.log('>>>fileconver>>' + this.filesData[indexcalled].fileContentVerId);
            this.openfileUrl =
                '../apex/MedicalHistoryPreviewVF?resourceId=' +
                this.filesData[indexcalled].fileContentVerId;
            //    this.openfileUrl =  "/apex/MedicalHistoryPreviewVF?resourceId=0695E000004TP1m";
            //    this.openfileUrl =  "/sfc/servlet.shepherd/document/download/0695E000004TP1m";
            console.log('>>>openfileUrl>>' + this.openfileUrl);
            this.openmodel = true;
            console.log('>>>filesdat>>' + JSON.stringify(this.filesData));
        } */
    }
    closeModal() {
        // this.openmodel = false;
    }

    removeFiles(event) {
        let indexcalled = event.currentTarget.dataset.key;
        this.filesData[indexcalled].isDeleted = true;
        this.totalfilesUploaded = this.totalfilesUploaded - 1;
        if (this.totalfilesUploaded == 0) {
            this.Nofilesupload = true;
        } 
    }
    retryFiles(event) {
        console.log('>>retry called>>' + event.currentTarget.dataset.key);
       /* let indexcalled = event.currentTarget.dataset.key;
        this.filesData[indexcalled].isRetry = true;
        try {
            console.log(
                '>>indexcalled find called>>' +
                    this.filesData.findIndex((x) => x.index == indexcalled)
            );
            console.log('>>size>>' + this.filesData[indexcalled].file.size);
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
            console.log('>>>6688>>' + JSON.stringify(this.filesData[indexcalled]));
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
        } */
    }

    stopBlurEvent(event) {
        event.preventDefault();
    }
    validateandsaveFileName(event) {
        console.log('>>>blurr called>>');
        let indexcalled = event.currentTarget.dataset.key;

        if (event.target.value) {
            this.isNameEmpty = false;
            this.filesData[indexcalled].isNameReadOnly = true;
            console.log('>>value available');
        } else {
            this.isNameEmpty = true;
            this.filesData[indexcalled].isNameReadOnly = false;
            console.log('>>emptyyyyyyyyyyyyyyyyyyyyy>>>');
        }
    }
}
