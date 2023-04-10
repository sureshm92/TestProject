import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
//import saveTheChunkFile from '@salesforce/apex/nonReferedBulkUpload.saveTheChunkFile';  //Need to change the method
import saveTheChunkFile from '@salesforce/apex/ppFileUploadController.saveTheChunkFile'; //Need to change the method
import isUplaodAvailable from '@salesforce/apex/ppFileUploadController.isUplaodAvailable';
import PP_AcceptedFileformats from "@salesforce/label/c.PP_AcceptedFileformats";
import PP_acceptedformats from "@salesforce/label/c.PP_acceptedformats";
import PP_MaxFileSize from "@salesforce/label/c.PP_MaxFileSize";
import PP_FileFormatNotAccept from "@salesforce/label/c.PP_FileFormatNotAccept";
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
    getsize=12;

    fileName = '';
    progress = 0;
    noRecords=true;
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
    isFile=true;
    ShowuploadSection = false;
    isMobile;
    isSaving=false;

    renameObj = {
        name: 'Rename'  
    };
    Preview = {
        name: 'Preview' 
         
    };
    Delete = {
        name: 'Delete' 
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
        this.isSaving=true;
        if (!communityService.isDummy()) {
            if (formFactor === 'Small' || formFactor === 'Medium') {
                this.isMobile = true;
            } else {
                this.isMobile = false;
            }
            this.getData = communityService.getParticipantData();
            this.popupActionItems.push(this.renameObj);
            this.popupActionItems.push(this.Preview);
            this.popupActionItems.push(this.Delete);
            // if (this.getData.pe.Clinical_Trial_Profile__r.Document_Upload_Is_Available__c) {
            //     this.isCTPenableUpload = true;
            //     this.getsize=8;
            // }
            isUplaodAvailable({ 
                perId: this.getData.pe.Id
            })
            .then(result => {
                this.isSaving=false;
                this.isCTPenableUpload=result;
                if(this.isCTPenableUpload){
                    this.getsize=8;
                }
            }) 
            
            // if(this.getData.isDelegate){
            //     console.log('perID',this.getData.pe.Id);
            //     console.log('currentContactId',this.getData.currentContactId);
            //     checkifPrimary({
            //         perID: this.getData.pe.Id,
            //         currentContactId: this.getData.currentContactId
            //     })
            //     .then(result => {
            //         console.log('data result',result);
            //         this.getRseult=result;
            //         if(result){
            //             console.log('data this.isPrimary',this.isPrimary);
            //             this.isCTPenableUpload=true;
            //         }
            //     })

            // }
            // else{
            //     this.isCTPenableUpload=true;
            // }
            //}
        }
    }
    
     //pagination
     totalRecord;
     showZeroErr  = false;
     initialLoad = true;
     page;
     pageChanged(event) {
       console.log('>>page changed called>>>');
       this.page = event.detail.page;
       this.template.querySelector("c-ppview-files-page-new").pageNumber =this.page;
         if(!this.initialLoad){
           console.log('>>>fetch page called>>>');
           //this.template.querySelector("c-ppview-files-page-new").stopSpinner=false;
           //this.template.querySelector("c-ppview-files-page-new").updateInProgressOldData();
           //this.template.querySelector("c-ppview-files-page-new").fetchData();
         }
         this.initialLoad = false;
     }
     changePage(event) {
       let dir = event.detail;
       if (dir == "next") { 
         this.template.querySelector("c-pir_participant-pagination").nextPage();
       }
       if (dir == "prev") {
         this.template
           .querySelector("c-pir_participant-pagination")
           .previousPage();
       }
     }
     handleUpdate=false;
     handletotalrecord(event){
       this.totalRecord=event.detail;
       this.handleUpdate=true;
       this.handleresetpageonupdate();
       }
     isResetOnUpdate=false;
     isResetPagination=false;
     handleresetpageonupdate(){
       if( this.handleUpdate && !this.isResetPagination ){
         this.initialLoad=true;
         this.template.querySelector("c-pir_participant-pagination").totalRecords=this.totalRecord;
         //this.template.querySelector("c-pir_participant-pagination").updateInprogress();
         }
       this.handleUpdate=false;
       this.initialLoad=false; 
 
     }
     handleresetpagination(event){
       if(this.isResetPagination ){
         this.initialLoad = true;
         this.template.querySelector("c-pir_participant-pagination").totalRecords=this.totalRecord;
         this.template.querySelector("c-pir_participant-pagination").goToStart();
       }
       this.isResetPagination = false;  
     }

     showfileUplaodSection(){
         console.log('>>>calling btuton>>');
         this.ShowuploadSection = true;
     }
  
    handleFilesChange(event) {
        if (event.target.files.length > 0) {
            this.Nofilesupload = false;
          //  this.filesUploaded.push(event.target.files);
          //  console.log('>>>>this.filesUploaded>>' + this.filesUploaded);
         //   console.log('>>>>this.filesUploaded>>' + JSON.stringify(this.filesUploaded));  
            for (var i = 0; i < event.target.files.length; i++) {
                console.log('>>>name is>>' + event.target.files[i].name);
                this.filesUploaded.push(event.target.files[i]);
            }
            this.progress = 0;
            this.progressWidth = 'width :0%';
            this.base = 1;
            this.totalRecs = 0;
            this.progressMultiplier = 0;
            this.saveFile();
        }
    }

    saveFile() {
        console.log('>save file called>');
        this.progressWidth = 'width :2%';
        this.progress = 2;

        console.log('>>>124>>' + this.filesUploaded.length);
        let filestartindex = this.filesData.length;

        for (var i = 0 ; i < this.filesUploaded.length; i++) { 
            console.log('>>>188');
            let index = this.filesData.findIndex((x) => x.index === i);
            console.log('>>>190>>?'+index);
            if(index != -1)
            continue;
            var fileCon = this.filesUploaded[i]; 
            this.base = Math.floor((CHUNK_SIZE / fileCon.size) * 100); 
            let fileSize = this.formatBytes(fileCon.size, 2);
            console.log('>>>file at index>>'+fileCon.name+'>>index is>>'+i);
            let fileRemaining = '';
            var fs = fileSize.split(' ');
            var fu = ((fs[0] * this.progress) / 100).toFixed(2);
            if (fs[0] / fu == 1) {
                fileRemaining = fileSize;
            } else {
                fileRemaining = fu + ' ' + fs[1] + ' of ' + fileSize;
            }
           let extension_index = fileCon.name.lastIndexOf('.');
           let extension =   fileCon.name.slice(extension_index + 1); 
           let filenamewitoutextension = fileCon.name.slice(0,extension_index); 
           if (extension.toLowerCase() != 'jpg' && extension.toLowerCase() != 'pdf' && extension.toLowerCase() != 'jpeg' 
            && extension.toLowerCase() != 'gif'  && extension.toLowerCase() != 'png')
            {
                this.filesData.push({'fileName':fileCon.name, 'fileSize': fileSize, 'progress':this.progress,'index':i,'isValid' : false,
                                     'isNameReadOnly': true ,'ErrorMessage' : this.label.PP_FileFormatNotAccept
                                      ,'fileRemaining' : fileRemaining, 'progressWidth' : this.progressWidth,'UploadCompleted' : true });
                continue;
            }
            else if(fileCon.size > MAX_FILE_SIZE) {
                this.filesData.push({'fileName':fileCon.name, 'fileSize': fileSize, 'progress':this.progress,'index':i,'isValid' : false,'isNameReadOnly': true ,'ErrorMessage' : this.label.PP_MaxFileSize
                                     ,'fileRemaining' : fileRemaining, 'progressWidth' : this.progressWidth,'UploadCompleted' : true });
                continue;

            }
            else {
            this.filesData.push({'fileName':fileCon.name, 'fileSize': fileSize, 'progress':this.progress,'index':i,'isValid' : true,'isNameReadOnly': true ,'ErrorMessage' : '',
                                 'fileRemaining' : fileRemaining, 'progressWidth' : this.progressWidth,'UploadCompleted' : false });
                this.setupReader(fileCon, i); 
            }
        }
    }
    setupReader(fileCon, indexoffile) {
        console.log('>>>152>>' + indexoffile);
        var reader = new FileReader();
        var self = this;

        self.progressWidth = 'width :10%';
        self.progress = 10;

        console.log('>>>132111>>');
        reader.onload = function () {
            console.log('>>>134>>' + indexoffile + '>>filecon>>' + fileCon.name);
            var fileContents = reader.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            fileContents = fileContents.substring(dataStart);
            let index = self.filesData.findIndex((x) => x.index === indexoffile);
            self.filesData[index].progressWidth = self.progressWidth;
            self.filesData[index].progress = self.progress;

            console.log('>>>self.filesData[index].progress>>'+index+'>>progresswidth>>'+self.filesData[index].progress);
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
        this.uploadChunk(file, fileContents, fromPos, toPos, '', indexoffile);
    }
    uploadChunk(file, fileContents, fromPos, toPos, attachId, indexoffile) {
        var chunk = fileContents.substring(fromPos, toPos);
        console.log('>>>205>>');
        let index = this.filesData.findIndex((x) => x.index === indexoffile);
        console.log('>>>index>>' + index);
        if (index >= 0) {
            saveTheChunkFile({
                parentId: this.getData.pe.Id,
                fileName: file.name,
                base64Data: encodeURIComponent(chunk),
                contentType: file.type,
                fileId: attachId
            })
                .then((result) => {
                    console.log('>>>214>>');
                    this.fileId = result;
                    attachId = result;
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
                            this.progressMultiplier++;
                            if (this.base * this.progressMultiplier < 100) {
                                this.filesData[index].progress =
                                    this.base * this.progressMultiplier;
                                console.log('>>227>>' + this.filesData);
                                // this.progress = this.base * this.progressMultiplier;
                            } else {
                                this.filesData[index].progress = 99;
                                // this.progress = 99;
                            }
                            this.filesData[index].progressWidth =
                                'width :' + this.filesData[index].progress + '%';
                            var fs = this.filesData[index].fileSize.split(' ');
                            var fu = ((fs[0] * this.filesData[index].progress) / 100).toFixed(2);
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
                                '%;background-color: #00C221;';
                            var fs = this.filesData[index].fileSize.split(' ');
                            var fu = ((fs[0] * this.filesData[index].progress) / 100).toFixed(2);
                            if (fs[0] / fu == 1) {
                                this.filesData[index].fileRemaining =
                                    this.filesData[index].fileSize;
                            } else {
                                this.filesData[index].fileRemaining =
                                    fu + ' ' + fs[1] + ' of ' + this.filesData[index].fileSize;
                            }
                            this.filesData[index].UploadCompleted = true;
                            //  this.progressWidth = 'width :'+this.progress+'%;background-color: #00C221;';
                            //   this.showdata = true;
                            // this.isLoading = false;
                            // this.isFileAdded = true;
                        }
                    }
                })
                .catch((error) => {
                    console.error('Error: ', error);
                })
                .finally(() => {});
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

    removeFiles(event){
        console.log('>>remove claled with index>>'+event.currentTarget.dataset.key);
    }

    showActionMenu(event){
        console.log('>>>method is getting called>>');
        let index =  event.currentTarget.dataset.key;
        console.log('>>>index is>>'+index);
        console.log('>>>tog>>'+this.template.querySelector("[data-key='"+index+"']"));
        console.log('>>>tog>>'+this.template.querySelector("[data-key='"+index+"']").classList);
        this.template.querySelector("[data-key='"+index+"']").classList.add("slds-is-open");
    }

    showfileOption(event){
        console.log('>>>click on11 dott>>');
       let index =  event.currentTarget.dataset.key;
                    
       console.log('>>index>>'+index);
       
       console.log('>>data set>>'+this.template.querySelector("[data-key='"+index+"']"));

       this.template.querySelector("[data-key='"+index+"']").classList.add("slds-is-open");
       
        // this.template.querySelectorAll(".D").forEach(function (L) {
        //     L.classList.toggle("slds-is-open");
        // });
       // this.showactionmenu = !this.showactionmenu;
    }

    handleOnBlurIcon(){
        console.log('>>>blue called>>');
        this.template.querySelectorAll(".D").forEach(function (L) {
            L.classList.remove("slds-is-open");
        });
            
    }
    renameClick(){
        let index = this.filesData.findIndex(x => x.index === indexoffile); 
       
        console.log('>>rename click on file>>'+ this.filesData[index].fileName);
    }

    closeMenu(){
        console.log('>>>blue called>>');
        this.template.querySelectorAll(".D").forEach(function (L) {
            L.classList.remove("slds-is-open");
        });
            
    }
    callMethod(event){
        console.log('>>>methdo called>>');
        
        let methodNameCalled = event.currentTarget.dataset.method;
        let indexcalled = event.currentTarget.dataset.key;
        console.log('>>>called menu is>>'+methodNameCalled+'>>at index>>>'+indexcalled);
        if(methodNameCalled == 'Rename')
        {
            console.log('>>coming inseide if>>'); 
            this.filesData[indexcalled].isNameReadOnly = false;
            console.log('>>>filesdat>>'+JSON.stringify(this.filesData));
        }

    }
    stopBlurEvent(event){
        event.preventDefault();
    }
    validateandsaveFileName(event){
        let indexcalled = event.currentTarget.dataset.key;
        console.log('>>value is>>'+event.target.value);
        let updatefileName = event.target.value;
        this.filesData[indexcalled].isNameReadOnly = false;
        
    }
}