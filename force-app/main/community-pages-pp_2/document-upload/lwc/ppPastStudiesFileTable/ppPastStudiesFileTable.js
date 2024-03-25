import { LightningElement, track, api } from 'lwc';
import formFactor from '@salesforce/client/formFactor';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import fetchUploadedFiles from '@salesforce/apex/PpPastStudiesFilesController.fetchUploadedFiles';
import fetchMessageFiles from "@salesforce/apex/ppFileUploadController.fetchMessageFiles";
import deleteFile from '@salesforce/apex/PpPastStudiesFilesController.deleteFile';
import No_Documents_Available from '@salesforce/label/c.No_Documents_Available';
import PP_DeletedSucesfully from '@salesforce/label/c.PP_DeletedSucesfully';
import PP_Resource_Documents from '@salesforce/label/c.PP_Resource_Documents';
import Resource_Title from '@salesforce/label/c.Resource_Title';
import PP_Sort from '@salesforce/label/c.PP_Sort';
import File_Type from '@salesforce/label/c.File_Type';
import PP_UploadDate from '@salesforce/label/c.PP_UploadDate';
import TV_TH_Date from '@salesforce/label/c.TV_TH_Date';
import PIR_Download from '@salesforce/label/c.PIR_Download';
import pir_Delete_Btn from '@salesforce/label/c.pir_Delete_Btn';
import PP_DeleteFile from '@salesforce/label/c.PP_DeleteFile';
import PP_DeleteConfirmation from '@salesforce/label/c.PP_DeleteConfirmation';
import BTN_Cancel from '@salesforce/label/c.BTN_Cancel';
import profileTZ from "@salesforce/i18n/timeZone";
import Sort_By from "@salesforce/label/c.Sort_By";
import PP_Sort_Title_Desc from "@salesforce/label/c.PP_Sort_Title_Desc";
import PP_Sort_Title_Asc from "@salesforce/label/c.PP_Sort_Title_Asc";
import PP_Sort_Type_Asc from "@salesforce/label/c.PP_Sort_Type_Asc";
import PP_Sort_Type_Desc from "@salesforce/label/c.PP_Sort_Type_Desc";
import PP_Sort_Date_Desc from "@salesforce/label/c.PP_Sort_Date_Desc";
import PP_Sort_Date_Asc from "@salesforce/label/c.PP_Sort_Date_Asc";
import Sort_Detail_By from "@salesforce/label/c.Sort_Detail_By";

export default class PpPastStudiesFileTable extends LightningElement {
    downloadIcon = pp_icons + '/' + 'download.svg';
    deleteIcon = pp_icons + '/' + 'delete.svg';
    noDocumentAvailable = pp_icons + '/' + 'noDocumentAvailable.svg';
    uploadNewDocuments = pp_icons + '/' + 'uploadNewDocuments.svg';
    sort = pp_icons + "/" + "sort.svg";
    noRecords = false;
    @api pageNumber = 1;
    isFile = true;
    isDelegate = false;
    totalRecord;
    isMobile = false;
    isDesktop;
    selectedmenu = 'Uploaded';
    selectedsortOption = 'Sort By';
    @api selectedStudyId;
    fileList;
    deleteFileID;
    saving;
    @api stopSpinner = false;
    isSpinnerRunning = false;
    sortOn = 'CreatedDate';
    sortType = 'DESC';
    @api isInitial;
    arrowDownDate = true; //desc
    arrowUpDate = false;
    arrowDownTitle = false; //desc
    arrowUpTitle = false;
    arrowDownType = false; //desc
    arrowUpType = false;
    firstClick = false;
    resetPagination = false;
    filePreview = '../apex/MedicalHistoryPreviewVF?resourceId=+';
    totalSize;
    curentSize;

  sortOnMsg = "ContentDocument.CreatedDate";
  sortTypeMsg = "DESC";
  @api isInitialMsg;
  arrowDownDateMsg = true; //desc
  arrowUpDateMsg = false;
  arrowDownTitleMsg = false; //desc
  arrowUpTitleMsg = false;
  arrowDownTypeMsg = false; //desc
  arrowUpTypeMsg = false;
  firstClickMsg = false;
  resetPaginationMsg = false;
  cvListMsg;
  totalRecordMsg;
  noMsgRecords = true;
  @api pageNumberMsg = 1;
  sharedFiles = false;
  @api peId;

  label={ PP_DeletedSucesfully,
        No_Documents_Available,
        PP_Resource_Documents,
        Resource_Title,
        PP_Sort,
        File_Type,
        PP_UploadDate,
        TV_TH_Date,
        PIR_Download,
        pir_Delete_Btn,
        PP_DeleteFile,
        PP_DeleteConfirmation,
        BTN_Cancel,
        Sort_By,
        PP_Sort_Title_Desc,
        PP_Sort_Title_Asc,
        PP_Sort_Type_Asc,
        PP_Sort_Type_Desc,
        PP_Sort_Date_Desc,
        PP_Sort_Date_Asc,
        Sort_Detail_By
    }

    connectedCallback() {
       if (formFactor === 'Small' || formFactor === 'Medium') {
            this.isMobile = true;
            this.isDesktop=false;
        } else {
            this.isMobile = false;
            this.isDesktop=true;
        }

        if (communityService.getCurrentCommunityMode().currentDelegateId) {
            this.isDelegate = true;
        }
        if (!communityService.isDummy()) {
            this.communityTemplate = communityService.getCurrentCommunityTemplateName();
            if (this.isDelegate) {
                this.contID = communityService.getCurrentCommunityMode().currentDelegateId; //participant contact id
            } else {
                this.contID = communityService.getParticipantData().currentContactId; //part contact id
            }
        }
        this.isInitial = true;
        this.isInitialMsg = true;
        this.getTableFiles();
    }
    get timeZone() {
        return profileTZ;
    }
    handleFiles() {
        this.arrowDownDate = true; //desc
        this.arrowUpDate = false;
        this.arrowDownTitle = false; //desc
        this.arrowUpTitle = false;
        this.arrowDownType = false; //desc
        this.arrowUpType = false;
        this.firstClick = false;
        this.stopSpinner=false;
    
        this.sortOn = "CreatedDate";
        this.sortType = "DESC";
    
        this.pageNumber = 1;
        this.isInitial = true;
        this.resetPagination = true;
    
    
        this.getTableFiles();
        this.sharedFiles = false;
        const tabChangedEvent = new CustomEvent("tabchange", { 
            detail: "filestab"
          });
        this.dispatchEvent(tabChangedEvent);
    }
    handleMessageFiles() { 
        this.sharedFiles= true;
        this.pageNumberMsg = 1;
        this.sortOnMsg = "ContentDocument.CreatedDate";
        this.sortTypeMsg = "DESC";
        this.isInitialMsg = true;
        this.firstClickMsg = false;
    
        this.arrowDownDateMsg = true; 
        this.arrowUpDateMsg = false;
        this.arrowDownTitleMsg = false; 
        this.arrowUpTitleMsg = false;
        this.arrowDownTypeMsg = false; 
        this.arrowUpTypeMsg = false;
        this.firstClickMsg = false;
        this.resetPaginationMsg = true;
        this.stopSpinner=false;
    
        this.getTableMsgFiles();
        const tabChangedEvent = new CustomEvent("tabchange", {
            detail: "sharetab"
          });
        this.dispatchEvent(tabChangedEvent);
      }
    @api resetPage() {
        this.arrowDownDate = true; //desc
        this.arrowUpDate = false;
        this.arrowDownTitle = false; //desc
        this.arrowUpTitle = false;
        this.arrowDownType = false; //desc
        this.arrowUpType = false;
        this.firstClick = false;
        
    }
    @api resetPageMsg() { 
        this.arrowDownDateMsg = true; //desc
        this.arrowUpDateMsg = false;
        this.arrowDownTitleMsg = false; //desc
        this.arrowUpTitleMsg = false;
        this.arrowDownTypeMsg = false; //desc
        this.arrowUpTypeMsg = false;
        this.firstClickMsg = false;
    }

    @api getTableFiles() {
        this.sharedFiles = false;
        if (!this.stopSpinner) {
            this.saving = true;
            this.isSpinnerRunning = true;
        }
            fetchUploadedFiles({
                contID: this.contID,
                pageNumber: this.pageNumber,
                selectedStudyId: this.selectedStudyId,
                sortOn: this.sortOn,
                sortType: this.sortType,
                isInitial: this.isInitial,
                firstClick: this.firstClick
            })
                .then((result) => {
                    this.fileList = result.cvList;
                    this.totalRecord = result.totalCount;
                    this.totalSize = this.fileList.length;
                    this.curentSize = 0;
                    var linkMap = new Map();
                    if (result.previewLinks != undefined && result.previewLinks != null) {
                        for (var key in result.previewLinks) {
                            linkMap.set(key, result.previewLinks[key]);
                        }
                    }
                    for (var i = 0; i < this.fileList.length; i++) {
                        this.fileList[i].ContentDocumentId = this.fileList[i].ContentDocumentId;
                        if (linkMap.has(this.fileList[i].ContentDocumentId)) {
                            this.fileList[i].previewUrl = linkMap.get(
                                this.fileList[i].ContentDocumentId
                            );
                        }
                    }

                    const selectEvent = new CustomEvent('gettotalrecord', {
                        detail: this.totalRecord
                    });
                    this.dispatchEvent(selectEvent);

                    if (this.resetPagination) {
                        const selectEventnew = new CustomEvent('resetpagination', {
                            detail: ''
                        });
                        this.dispatchEvent(selectEventnew);
                    }

                    this.resetPagination = false;
                    if (this.fileList.length > 0) {
                        this.noRecords = false;
                    } else {
                        if (this.isDelete) {
                            const selectEventnew = new CustomEvent('resetondelete', {
                                detail: ''
                            });
                            this.dispatchEvent(selectEventnew);
                        } else {
                            this.noRecords = true;
                        }
                    }

                    this.isDelete = false;
                    if (this.isSpinnerRunning) {
                        this.saving = false;
                        this.isSpinnerRunning = false;
                        this.stopSpinner = true;
                    }
                })
                .catch((error) => {
                    this.saving = true;
                    console.error('Error:', error);
                });
        
       
    }
    
    @api getTableMsgFiles() {
        this.sharedFiles = true;
        if (!this.stopSpinner) {
            this.saving = true;
            this.isSpinnerRunning = true;
        }
          fetchMessageFiles({
            perId: this.peId,
            pageNumber: this.pageNumberMsg,
            sortOn: this.sortOnMsg,
            sortType: this.sortTypeMsg,
            isInitial: this.isInitialMsg,
            firstClick: this.firstClickMsg
          })
            .then((result) => {
              this.cvListMsg = result.cdlList;
      
            var linkMap = new Map();
            if(result.previewLinks != undefined && result.previewLinks != null){
              for (var key in result.previewLinks) {
                linkMap.set(key, result.previewLinks[key]);
              }
            }
            if (this.cvListMsg !=null) {
              for (var i = 0; i < this.cvListMsg.length; i++) {
                this.cvListMsg[i].ContentUrl =
                  "../sfc/servlet.shepherd/document/download/" +
                  this.cvListMsg[i].ContentDocumentId;
                let title = this.cvListMsg[i].ContentDocument.Title;
                this.cvListMsg[i].ContentDocument.Title = title.substring(
                  0,
                  title.lastIndexOf(".")
                );
      
                if (linkMap.has(this.cvListMsg[i].ContentDocumentId)) {
                    this.cvListMsg[i].previewUrl = linkMap.get(
                      this.cvListMsg[i].ContentDocumentId
                    );
                }
              }
            }
      
              this.totalRecordMsg = result.totalCount;
      
              const selectEvent = new CustomEvent("gettotalrecordmsg", {
                detail: this.totalRecordMsg
              });
              this.dispatchEvent(selectEvent);
      
              if (this.resetPaginationMsg) {
                const selectEventnew = new CustomEvent("resetpaginationmsg", {
                  detail: ""
                });
                this.dispatchEvent(selectEventnew);
              }
              this.resetPaginationMsg = false;
              if (this.cvListMsg !=null && this.cvListMsg.length > 0) {
                this.noMsgRecords = false;
              } else {
                this.noMsgRecords = true;
              }
      
              if (this.isSpinnerRunning) {
                this.saving = false;
                this.isSpinnerRunning = false;
                this.stopSpinner = true;
              }
            })
            .catch((error) => {
              this.saving = true;
              console.error("Error:", error);
            });
    }

    handleLazyLoading(event) {
        var scrollTop = event.target.scrollTop;
        var offsetHeight = event.target.offsetHeight;
        var scrollHeight = event.target.scrollHeight;
        this.counter = this.counter + 1;

        this.rowOffSet = this.rowOffSet + this.rowLimit;

        if (offsetHeight + scrollTop + 10 >= scrollHeight) {
            this.pageNumber = this.counter;
            this.getTableFiles();
        }
    }

    filesListToShow;
    counter = 0;
    rowLimit = 20;
    rowOffSet = 0;
    getMoreFiles() {
        if (this.curentSize < this.totalSize) {
            var tempAccRec = [];
            var tempSize =
                this.curentSize + 10 < this.totalSize ? this.curentSize + 10 : this.totalSize;
            for (var i = 0; i < tempSize; i++) {
                tempAccRec.push(this.fileList[i]);
                
            }
            this.rowOffSet = this.rowOffSet + this.rowLimit;
            this.getTableFiles();
            this.filesListToShow = tempAccRec;
            this.curentSize = this.filesListToShow.length;
        }
    }

    showArrow = false;
    showArrowMsg = false;
    
    openmodel = false;
    modalHeaderFilePage = false;
    previewHeader;
    deleteFileIDPreview;
    isPreview = false;
    onPreview(event) {
       
        var y = window.outerHeight / 2 + window.screenY - ( 500 / 2);
        var x = window.outerWidth / 2 + window.screenX - ( 600 / 2);
        window.open(event.currentTarget.dataset.id,'popup','toolbar=no,scrollbars=no,resizable=no,top=' + y + ',left=' + x +',width=600,height=500'); 
        return false; 
    }
    closeModal() {
        this.openmodel = false;
        this.modalHeaderFilePage = false;
        this.isPreview = false;
    }
    get isDocAvailable(){
        if(this.sharedFiles){
          if(this.noMsgRecords){
              return true;
          }else{
            return false;
          }
        }else{
          if(this.noRecords){
             return true;
          }else{
            return false;
          }
        }
      }
    sortByTitle(event) {
        this.arrowUpDate = this.arrowDownDate = this.arrowUpType = this.arrowDownType = false;
        this.isInitial = false;
        this.firstClick = !this.firstClick; //true meaning desc title
        this.arrowUpTitle = this.firstClick; // up true asc
        this.arrowDownTitle = !this.firstClick; // down desc

        if (this.sortOn != 'Title') {
            this.firstClick = true; // true
            this.arrowUpTitle = true;
            this.arrowDownTitle = false;
        }

        this.sortOn = 'Title';
        this.pageNumber = 1;
        this.stopSpinner = false;
        this.resetPagination = true;
        this.getTableFiles();
    }
    get isFileNameSorted() {
        if (this.arrowUpTitle || this.arrowDownTitle) {
          return "boldfont table-Header-Sorted";
        } else {
          return "boldfont";
        }
      }

    sortByMsgTitle(event) {
       
        this.arrowUpDateMsg = this.arrowDownDateMsg = this.arrowUpTypeMsg = this.arrowDownTypeMsg = false;
        this.isInitialMsg = false;
        this.firstClickMsg = !this.firstClickMsg; //true meaning desc title
        this.arrowUpTitleMsg = this.firstClickMsg; // up true asc
        this.arrowDownTitleMsg = !this.firstClickMsg; // down desc

        if (this.sortOnMsg != 'ContentDocument.Title') {
            this.firstClickMsg = true; // true
            this.arrowUpTitleMsg = true;
            this.arrowDownTitleMsg = false;
        }
       
        this.sortOnMsg = 'ContentDocument.Title';
        this.pageNumberMsg = 1;
        this.stopSpinner = false;
        this.resetPaginationMsg = true;
        this.getTableMsgFiles();
    }
    get isMessageTitleSorted() {
        if (this.arrowUpTitleMsg || this.arrowDownTitleMsg) {
          return "boldfont table-Header-Sorted";
        } else {
          return "boldfont";
        }
      }

    sortByDate(event) {
        this.arrowUpTitle = this.arrowDownTitle = this.arrowUpType = this.arrowDownType = false;

        this.isInitial = false;
        this.firstClick = !this.firstClick; //true meaning desc title
        this.arrowUpDate = this.firstClick; // up true asc
        this.arrowDownDate = !this.firstClick; // down desc

        if (this.sortOn != 'CreatedDate') {
            this.firstClick = true; // true
            this.arrowDownDate = false;
            this.arrowUpDate = true;
        }

        this.sortOn = 'CreatedDate';
        this.pageNumber = 1;
        this.stopSpinner = false;
        this.resetPagination = true;
        this.getTableFiles();
    }
    get isSortedByDate() {
        if (this.arrowUpDate || this.arrowDownDate) {
          return "boldfont table-Header-Sorted";
        } else {
          return "boldfont";
        }
      }
    

    sortByMsgDate(event) {

        this.arrowUpTitleMsg = this.arrowDownTitleMsg = this.arrowUpTypeMsg = this.arrowDownTypeMsg = false;

        this.isInitialMsg = false;
        this.firstClickMsg = !this.firstClickMsg; //true meaning desc title
        this.arrowUpDateMsg = this.firstClickMsg; // up true asc
        this.arrowDownDateMsg = !this.firstClickMsg; // down desc

        if (this.sortOnMsg != 'ContentDocument.CreatedDate') {
            this.firstClickMsg = true; // true
            this.arrowDownDateMsg = false;
            this.arrowUpDateMsg = true;
        }
       
        this.sortOnMsg = 'ContentDocument.CreatedDate';
        //this.sortType='CreatedDate';
        this.pageNumberMsg = 1;
        this.stopSpinner = false;
        this.resetPaginationMsg = true;
        this.getTableMsgFiles();
    }
    get isMsgDateSorted() {
        if (this.arrowUpDateMsg || this.arrowDownDateMsg) {
          return "boldfont table-Header-Sorted";
        } else {
          return "boldfont";
        }
      }

    sortByType(event) {
        this.arrowUpTitle =
            this.arrowDownTitle =
            this.arrowUpDate =
            this.arrowDownDate =
            this.showArrow =
                false;
        this.isInitial = false;
        this.firstClick = !this.firstClick; //true meaning desc title //false
        this.arrowUpType = this.firstClick; // up true asc //false
        this.arrowDownType = !this.firstClick; // down desc //true

        //asc meanin first click true meaning u up arrow true
        if (this.sortOn != 'FileType') {
            this.firstClick = true; // true
            this.arrowUpType = true;
            this.arrowDownType = false;
        }

        this.sortOn = 'FileType';
        this.pageNumber = 1;
        this.stopSpinner = false;
        this.resetPagination = true;
        this.getTableFiles();
    }
    get isTypeSorted() {
        if (this.arrowUpType || this.arrowDownType) {
          return "boldfont table-Header-Sorted";
        } else {
          return "boldfont";
        }
      }

    sortByMsgType(event) { 
       
        this.arrowUpTitleMsg =
            this.arrowDownTitleMsg =
            this.arrowUpDateMsg =
            this.arrowDownDateMsg =
            this.showArrowMsg =
                false;
        this.isInitialMsg = false;
        this.firstClickMsg = !this.firstClickMsg; //true meaning desc title //false
        this.arrowUpTypeMsg = this.firstClickMsg; // up true asc //false
        this.arrowDownTypeMsg = !this.firstClickMsg; // down desc //true

        //asc meanin first click true meaning u up arrow true
        if (this.sortOnMsg != 'ContentDocument.FileExtension') {
            this.firstClickMsg = true; // true
            this.arrowUpTypeMsg = true;
            this.arrowDownTypeMsg = false;
        }

        this.sortOnMsg = 'ContentDocument.FileExtension';
        this.pageNumberMsg = 1;
        this.stopSpinner = false;
        this.resetPaginationMsg = true;
        this.getTableMsgFiles();
    }
    get isMessageTypeSorted() {
        if (this.arrowUpTypeMsg || this.arrowDownTypeMsg) {
          return "boldfont table-Header-Sorted";
        } else {
          return "boldfont";
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
    openDeleteModel = false;
    onDelete(event) {
        this.openDeleteModel = true;
        this.deleteFileID = event.currentTarget.dataset.id;
    }

    handleCancelModel(event) {
        this.openDeleteModel = false;
    }
    isDelete = false;
    handleContinueModel(event) {
        this.openDeleteModel = false;
        this.saving = true;
        deleteFile({
            fileID: this.deleteFileID
        })
            .then((result) => {
                this.saving = false;
                this.stopSpinner = false;
                this.openmodel = false;
                this.modalHeaderFilePage = false;
                this.isPreview = false;
                this.isDelete = true;
                this.getTableFiles();
                this.template.querySelector('c-custom-toast-files-p-p').showToast('success',this.label.PP_DeletedSucesfully ,'utility:success',1000);
            })
            .catch((error) => {
                console.error('Error:', error);
            });
    }
    get optionsSort() {
        return [
            { label: this.label.PP_Sort_Title_Asc, value: "titleasc" },
            { label: this.label.PP_Sort_Title_Desc, value: "titledesc" },
            { label: this.label.PP_Sort_Type_Asc, value: "filetypeasc" },
            { label: this.label.PP_Sort_Type_Desc, value: "filetypedesc" },
            { label: this.label.PP_Sort_Date_Desc, value: "datedesc" },
            { label: this.label.PP_Sort_Date_Asc, value: "dateasc" }
        ];
    }

    opendropdown(event) {
        this.template.querySelectorAll('.D').forEach(function (L) {
            L.classList.toggle('slds-is-open');
        });
    }
    handleonblur(event) {
        let classListforUploaded = this.template.querySelector('.D').classList;

        if (classListforUploaded.contains('slds-is-open')) {
            this.template.querySelectorAll('.D').forEach(function (L) {
                L.classList.remove('slds-is-open');
            });
        }
        let classListforSort = this.template.querySelector('.Sort').classList;
        if (classListforSort.contains('slds-is-open')) {
            this.template.querySelectorAll('.Sort').forEach(function (L) {
                L.classList.remove('slds-is-open');
            });
        }
    }
    handlenewOnSelect(event) {
        this.selectedmenu = event.target.dataset.title;
        if(this.selectedmenu=='Uploaded'){
            this.pageNumber = 1;
            this.stopSpinner = false;
            this.resetPagination = true;
            const tabChangedEvent = new CustomEvent("tabchange", { 
                detail: "filestab"
              });
            this.dispatchEvent(tabChangedEvent);

            this.isInitial = true;
            this.firstClick=true;
            this.sortOn = "CreatedDate";
            this.selectedsortOption = this.label.Sort_By;

            this.getTableFiles();
        }
        else{
            this.pageNumberMsg = 1;
            this.stopSpinner = false;
            this.resetPaginationMsg = true;
            const tabChangedEvent = new CustomEvent("tabchange", {
                detail: "sharetab"
              });
            this.dispatchEvent(tabChangedEvent);
            
            this.isInitialMsg = true;
            this.firstClickMsg=true;
            this.sortOnMsg = "ContentDocument.CreatedDate";
            this.selectedsortOption = this.label.Sort_By;

            this.getTableMsgFiles();
        }
        this.handleonblur();
    }
    get isUploadedTab(){
        if(this.selectedmenu=='Uploaded'){
            return true;
        }else{
            return false;
        }
    }
    handlenewOnSelectSort(event) {
        this.selectedsortOption = this.label.Sort_Detail_By + " "  + event.target.dataset.title;
        this.template.querySelectorAll('.fBold').forEach(function (L) {
            L.classList.add('fw-550');
        });
        if( event.target.dataset.id=='titleasc'){
            this.isInitial = false;
            this.firstClick=true;
            this.sortOn = "Title";
            this.pageNumber = 1;
            this.stopSpinner = false;
            this.resetPagination = true;
            this.getTableFiles();
          }
          if( event.target.dataset.id=='titledesc'){
            this.isInitial = false;
            this.firstClick=false;
            this.sortOn = "Title";
            this.pageNumber = 1;
            this.stopSpinner = false;
            this.resetPagination = true;
            this.getTableFiles();
          }
          if( event.target.dataset.id=='filetypeasc'){
            this.isInitial = false;
            this.firstClick=true;
            this.sortOn = "FileType";
            this.pageNumber = 1;
            this.stopSpinner = false;
            this.resetPagination = true;
            this.getTableFiles();
          }
          if( event.target.dataset.id=='filetypedesc'){
            this.isInitial = false;
            this.firstClick=false;
            this.sortOn = "FileType";
            this.pageNumber = 1;
            this.stopSpinner = false;
            this.resetPagination = true;
            this.getTableFiles();
          }
          if( event.target.dataset.id=='datedesc'){
            this.isInitial = false;
            this.firstClick=false;
            this.sortOn = "CreatedDate";
            this.pageNumber = 1;
            this.stopSpinner = false;
            this.resetPagination = true;
            this.getTableFiles();
          }
          if( event.target.dataset.id=='dateasc'){
            this.isInitial = false;
            this.firstClick=true;
            this.sortOn = "CreatedDate";
            this.pageNumber = 1;
            this.stopSpinner = false;
            this.resetPagination = true;
            this.getTableFiles();
          }
          this.handleonblur();
    }
    handlenewOnSelectSortMsg(event) {
        this.selectedsortOption = this.label.Sort_Detail_By + " "  + event.target.dataset.title;
        this.template.querySelectorAll('.fBold').forEach(function (L) {
            L.classList.add('fw-550');
        });
        if( event.target.dataset.id=='titleasc'){
            this.isInitialMsg = false;
            this.firstClickMsg=true;
            this.sortOnMsg = 'ContentDocument.Title';
            this.pageNumberMsg = 1;
            this.stopSpinner = false;
            this.resetPaginationMsg = true;
            this.getTableMsgFiles();
          }
          if( event.target.dataset.id=='titledesc'){
            this.isInitialMsg = false;
            this.firstClickMsg=false;
            this.sortOnMsg = 'ContentDocument.Title';
            this.pageNumberMsg = 1;
            this.stopSpinner = false;
            this.resetPaginationMsg = true;
            this.getTableMsgFiles();
          }
          if( event.target.dataset.id=='filetypeasc'){
            this.isInitialMsg = false;
            this.firstClickMsg=true;
            this.sortOnMsg = 'ContentDocument.FileExtension';
            this.pageNumberMsg = 1;
            this.stopSpinner = false;
            this.resetPaginationMsg = true;
            this.getTableMsgFiles();
          }
          if( event.target.dataset.id=='filetypedesc'){
            this.isInitialMsg = false;
            this.firstClickMsg=false;
            this.sortOnMsg = 'ContentDocument.FileExtension';
            this.pageNumberMsg = 1;
            this.stopSpinner = false;
            this.resetPaginationMsg = true;
            this.getTableMsgFiles();
          }
          if( event.target.dataset.id=='datedesc'){
            this.isInitialMsg = false;
            this.firstClickMsg=false;
            this.sortOnMsg = 'ContentDocument.CreatedDate';
            this.pageNumberMsg = 1;
            this.stopSpinner = false;
            this.resetPaginationMsg = true;
            this.getTableMsgFiles();
          }
          if( event.target.dataset.id=='dateasc'){
            this.isInitialMsg = false;
            this.firstClickMsg=true;
            this.sortOnMsg =  'ContentDocument.CreatedDate';
            this.pageNumberMsg = 1;
            this.stopSpinner = false;
            this.resetPaginationMsg = true;
            this.getTableMsgFiles();
          }
          this.handleonblur();
    }
    opendropdownSort(event) {
        this.template.querySelectorAll('.Sort').forEach(function (L) {
            L.classList.toggle('slds-is-open');
        });
    }
}