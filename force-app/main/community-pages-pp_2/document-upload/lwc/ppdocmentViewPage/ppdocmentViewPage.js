import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import pp_icons from "@salesforce/resourceUrl/pp_community_icons";
import fetchUploadedFiles from "@salesforce/apex/ppFileUploadController.fetchUploadedFiles";
import fetchMessageFiles from "@salesforce/apex/ppFileUploadController.fetchMessageFiles";
import deleteFile from "@salesforce/apex/ppFileUploadController.deleteFile";
import PP_Resource_Documents from "@salesforce/label/c.PP_Resource_Documents";
import Resource_Title from "@salesforce/label/c.Resource_Title";
import PP_Sort from "@salesforce/label/c.PP_Sort";
import File_Type from "@salesforce/label/c.File_Type";
import PP_UploadDate from "@salesforce/label/c.PP_UploadDate";
import TV_TH_Date from "@salesforce/label/c.TV_TH_Date";
import PIR_Download from "@salesforce/label/c.PIR_Download";
import pir_Delete_Btn from "@salesforce/label/c.pir_Delete_Btn";
import PP_DeleteFile from "@salesforce/label/c.PP_DeleteFile";
import PP_DeleteConfirmation from "@salesforce/label/c.PP_DeleteConfirmation";
import BTN_Cancel from "@salesforce/label/c.BTN_Cancel";
import No_Documents_Available from "@salesforce/label/c.No_Documents_Available";
import PP_SharedwithmeMessage from "@salesforce/label/c.PP_SharedwithmeMessage";
import Uploaded from "@salesforce/label/c.Uploaded";
import Shared_with_Me from "@salesforce/label/c.Shared_with_Me";
import Sort_By from "@salesforce/label/c.Sort_By";
import PP_DeletedSucesfully from "@salesforce/label/c.PP_DeletedSucesfully";
import formFactor from "@salesforce/client/formFactor";
import profileTZ from "@salesforce/i18n/timeZone";

export default class ppdocmentViewPage extends NavigationMixin(
  LightningElement
) {
  noDocumentAvailable = pp_icons + "/" + "noDocumentAvailable.svg";
  uploadNewDocuments = pp_icons + "/" + "uploadNewDocuments.svg";
  infocheck = pp_icons + "/" + "infocopy.svg";
  sort = pp_icons + "/" + "sort.svg";

  value = "inProgress";
  noRecords = true;
  noMsgRecords = true;
  @api pageNumber = 1;
  @api pageNumberMsg = 1;
  isFile = true;
  isDelegate = false;
  cvList;
  cvListMsg;
  totalRecord;
  totalRecordMsg;
  isMobile = false;
  isDesktop;
  selectedmenu = "Uploaded";
  selectedsortOption = "Sort By";
  @api isctpenableUpload;
  isSaving = false;
  @api stopSpinner = false;
  isSpinnerRunning = false;
  sortOn = "CreatedDate";
  sortType = "DESC";
  @api isInitial;
  arrowDownDate = true; //desc
  arrowUpDate = false;
  arrowDownTitle = false; //desc
  arrowUpTitle = false;
  arrowDownType = false; //desc
  arrowUpType = false;
  firstClick = false;
  resetPagination = false;
  filePreview = "../apex/MedicalHistoryPreviewVF?resourceId=+";
  sharedFiles = false;
  maincssclass='';
  get timeZone() {
    return profileTZ;
  }

  label = {
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
    pir_Delete_Btn,
    No_Documents_Available,
    Uploaded,
    Shared_with_Me,
    Sort_By,
    PP_DeletedSucesfully,
    PP_SharedwithmeMessage

  };

  connectedCallback() {
    if (formFactor === "Small" || formFactor === "Medium") {
      this.isMobile = true;
      this.isDesktop = false;
    } else {
      this.isMobile = false;
      this.isDesktop = true;
    }
    this.maincssclass = 'document-boxDesk pir-parent pp-doc';

    this.isSaving = true;
    if (!communityService.isDummy()) {
      this.getData = communityService.getParticipantData();
      if (communityService.getCurrentCommunityMode().currentDelegateId) {
        this.isDelegate = true;
      }
      this.isInitial = true;
      this.isInitialMsg = true;
      this.getTableFilesData();
      this.sharedFiles = false;
    }
  }
  get isDocAvailable() {
    if (this.sharedFiles) {
      if (this.noMsgRecords) {
        return true;
      } else {
        return false;
      }
    } else {
      if (this.noRecords) {
        return true;
      } else {
        return false;
      }
    }
  }
  get timeZone() {
    return profileTZ;
  }
  @api getTableFilesData() {
    if (!this.stopSpinner) {
      this.isSaving = true;
      this.isSpinnerRunning = true;
    }

    fetchUploadedFiles({
      perId: this.getData.pe.Id,
      pageNumber: this.pageNumber,
      isDelegate: this.isDelegate,
      sortOn: this.sortOn,
      sortType: this.sortType,
      isInitial: this.isInitial,
      firstClick: this.firstClick
    })
      .then((result) => {
        this.cvList = result.cvList;
        this.totalRecord = result.totalCount;
        var linkMap = new Map();
        if (result.previewLinks != undefined && result.previewLinks != null) {
          for (var key in result.previewLinks) {
            linkMap.set(key, result.previewLinks[key]);
          }
        }

        for (var i = 0; i < this.cvList.length; i++) {
          this.cvList[i].ContentDocumentId = this.cvList[i].ContentDocumentId;
          if (linkMap.has(this.cvList[i].ContentDocumentId)) {
            this.cvList[i].previewUrl = linkMap.get(
              this.cvList[i].ContentDocumentId
            );
          }
        }
        const selectEvent = new CustomEvent("gettotalrecord", {
          detail: this.totalRecord
        });
        this.dispatchEvent(selectEvent);
        if (this.resetPagination) {
          const selectEventnew = new CustomEvent("resetpagination", {
            detail: ""
          });
          this.dispatchEvent(selectEventnew);
        }
        this.resetPagination = false;
        if (this.cvList.length > 0) {
          this.noRecords = false;
          this.maincssclass = 'document-boxDesk pir-parent pp-doc';
        } else {
          if (this.isDelete) {
            const selectEventnew = new CustomEvent("resetondelete", {
              detail: ""
            });
            this.dispatchEvent(selectEventnew);
          }
          if (this.totalRecord == 0) {
            this.noRecords = true;
            this.maincssclass = 'document-boxDesk pir-parent pp-doc nopagination';
          }
        }
        this.isDelete = false;
        if (this.isSpinnerRunning) {
          this.isSaving = false;
          this.isSpinnerRunning = false;
          this.stopSpinner = true;
        }
      })
      .catch((error) => {
        this.isSaving = true;
        console.error("Error:", error);
      });
  }
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
  handleMessageFiles() {
    this.sharedFiles = true;
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
    this.stopSpinner = false;

    this.getTableMsgFilesData();
    const tabChangedEvent = new CustomEvent("tabchange", {
      detail: "sharetab"
    });
    this.dispatchEvent(tabChangedEvent);
  }

  handleFiles() {
    this.arrowDownDate = true; //desc
    this.arrowUpDate = false;
    this.arrowDownTitle = false; //desc
    this.arrowUpTitle = false;
    this.arrowDownType = false; //desc
    this.arrowUpType = false;
    this.firstClick = false;
    this.stopSpinner = false;

    this.sortOn = "CreatedDate";
    this.sortType = "DESC";

    this.pageNumber = 1;
    this.isInitial = true;
    this.resetPagination = true;

    this.getTableFilesData();
    this.sharedFiles = false;
    const tabChangedEvent = new CustomEvent("tabchange", {
      detail: "filestab"
    });
    this.dispatchEvent(tabChangedEvent);
  }

  @api getTableMsgFilesData() {
    if (!this.stopSpinner) {
      this.isSaving = true;
      this.isSpinnerRunning = true;
    }
    fetchMessageFiles({
      perId: this.getData.pe.Id,
      pageNumber: this.pageNumberMsg,
      sortOn: this.sortOnMsg,
      sortType: this.sortTypeMsg,
      isInitial: this.isInitialMsg,
      firstClick: this.firstClickMsg
    })
      .then((result) => {
        this.isSaving = false;
        this.cvListMsg = result.cdlList;
        console.log('>>>result>>'+JSON.stringify(result));
        var linkMap = new Map();
        if (result.previewLinks != undefined && result.previewLinks != null) {
          for (var key in result.previewLinks) {
            linkMap.set(key, result.previewLinks[key]);
          }
        }
        if (this.cvListMsg != null) {
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
        if (this.cvListMsg != null && this.cvListMsg.length > 0) {
          this.noMsgRecords = false;
          this.maincssclass = 'document-boxDesk pir-parent pp-doc';
        } else {
          this.noMsgRecords = true;
          this.maincssclass = 'document-boxDesk pir-parent pp-doc nopagination';
        }

        if (this.isSpinnerRunning) {
          this.isSaving = false;
          this.isSpinnerRunning = false;
          this.stopSpinner = true;
        }
      })
      .catch((error) => {
        this.isSaving = true;
        console.error("Error:", error);
      });
  }

  renderedCallback() {}
  @api resetPage() {
    this.arrowDownDate = true; //desc
    this.arrowUpDate = false;
    this.arrowDownTitle = false; //desc
    this.arrowUpTitle = false;
    this.arrowDownType = false; //desc
    this.arrowUpType = false;
    this.firstClick = false;
  }
  showArrowType = false;
  showArrowTitle = false;
  showArrowDate = false;

  showArrowTypeMsg = false;
  showArrowTitleMsg = false;
  showArrowDateMsg = false;
  handleHoverMsg(event) {
    this.template.querySelectorAll(".bgc-msg").forEach(function (L) {
      L.classList.add("iconColor");
    });

    if (
      !this.arrowUpTypeMsg &&
      !this.arrowDownTypeMsg &&
      event.target.dataset.id == "fileType"
    ) {
      this.showArrowTypeMsg = true;
    } else if (
      !this.arrowUpTitleMsg &&
      !this.arrowDownTitleMsg &&
      event.target.dataset.id == "title"
    ) {
      this.showArrowTitleMsg = true;
    } else if (
      !this.arrowUpDateMsg &&
      !this.arrowDownDateMsg &&
      event.target.dataset.id == "createdDate"
    ) {
      this.showArrowDateMsg = true;
    }
  }

  hanldeRemoveHoverMsg(event) {
    this.template.querySelectorAll(".bgc-msg").forEach(function (L) {
      L.classList.remove("iconColor");
    });
    this.showArrowTypeMsg = false;
    this.showArrowTitleMsg = false;
    this.showArrowDateMsg = false;
  }

  openmodel = false;
  previewHeader;
  deleteFileIDPreview;
  isPreview = false;
  onPreview(event) {
    var y = window.outerHeight / 2 + window.screenY - 500 / 2;
    var x = window.outerWidth / 2 + window.screenX - 600 / 2;
    window.open(
      event.currentTarget.dataset.id,
      "popup",
      "toolbar=no,scrollbars=no,resizable=no,top=" +
        y +
        ",left=" +
        x +
        ",width=600,height=500"
    );
    return false;
  }
  handlePreview(event) {
    var y = window.outerHeight / 2 + window.screenY - 500 / 2;
    var x = window.outerWidth / 2 + window.screenX - 600 / 2;
    window.open(
      event.currentTarget.dataset.id,
      "popup",
      "toolbar=no,scrollbars=no,resizable=no,top=" +
        y +
        ",left=" +
        x +
        ",width=600,height=500"
    );
    return false;
  }
  onPreviewmob(event) {
    this[NavigationMixin.Navigate](
      {
        type: "standard__webPage",
        attributes: {
          url: "https://quintilesimscmo--pi3alpha.sandbox.my.salesforce.com/sfc/p/5E000000AAal/a/5E0000002ubz/Ap5c9TOBRhIWY4mxVE4oH_4vWIABJVIitRISBu239zs"
        }
      },
      false
    );
  }
  closeModal() {
    this.openmodel = false;
    this.isPreview = false;
  }
  sortByTitle(event) {
    this.arrowUpDate =
      this.arrowDownDate =
      this.arrowUpType =
      this.arrowDownType =
        false;
    this.isInitial = false;
    this.firstClick = !this.firstClick; //true meaning desc title
    this.arrowUpTitle = this.firstClick; // up true asc
    this.arrowDownTitle = !this.firstClick; // down desc

    if (this.sortOn != "Title") {
      this.firstClick = true; // true
      this.arrowUpTitle = true;
      this.arrowDownTitle = false;
    }

    this.sortOn = "Title";
    this.pageNumber = 1;
    this.stopSpinner = false;
    this.resetPagination = true;
    this.getTableFilesData();
  }

  sortByDate(event) {
    this.arrowUpTitle =
      this.arrowDownTitle =
      this.arrowUpType =
      this.arrowDownType =
        false;

    this.isInitial = false;
    this.firstClick = !this.firstClick; //true meaning desc title
    this.arrowUpDate = this.firstClick; // up true asc
    this.arrowDownDate = !this.firstClick; // down desc

    if (this.sortOn != "CreatedDate") {
      this.firstClick = true; // true
      this.arrowDownDate = false;
      this.arrowUpDate = true;
    }
    this.sortOn = "CreatedDate";
    this.pageNumber = 1;
    this.stopSpinner = false;
    this.resetPagination = true;
    this.getTableFilesData();
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
    if (this.sortOn != "FileType") {
      this.firstClick = true; // true
      this.arrowUpType = true;
      this.arrowDownType = false;
    }
    this.sortOn = "FileType";
    this.pageNumber = 1;
    this.stopSpinner = false;
    this.resetPagination = true;
    this.getTableFilesData();
  }
  sortByMsgDate(event) {
    this.arrowUpTitleMsg =
      this.arrowDownTitleMsg =
      this.arrowUpTypeMsg =
      this.arrowDownTypeMsg =
        false;

    this.isInitialMsg = false;
    this.firstClickMsg = !this.firstClickMsg; //true meaning desc title
    this.arrowUpDateMsg = this.firstClickMsg; // up true asc
    this.arrowDownDateMsg = !this.firstClickMsg; // down desc

    if (this.sortOnMsg != "ContentDocument.CreatedDate") {
      this.firstClickMsg = true; // true
      this.arrowDownDateMsg = false;
      this.arrowUpDateMsg = true;
    }
    this.sortOnMsg = "ContentDocument.CreatedDate";
    this.pageNumberMsg = 1;
    this.stopSpinner = false;
    this.resetPaginationMsg = true;
    this.getTableMsgFilesData();
  }
  sortByMsgType(event) {
    this.arrowUpTitleMsg =
      this.arrowDownTitleMsg =
      this.arrowUpDateMsg =
      this.arrowDownDateMsg =
      this.showArrow =
        false;
    this.isInitialMsg = false;
    this.firstClickMsg = !this.firstClickMsg; //true meaning desc title //false
    this.arrowUpTypeMsg = this.firstClickMsg; // up true asc //false
    this.arrowDownTypeMsg = !this.firstClickMsg; // down desc //true

    //asc meanin first click true meaning u up arrow true
    if (this.sortOnMsg != "ContentDocument.FileExtension") {
      this.firstClickMsg = true; // true
      this.arrowUpTypeMsg = true;
      this.arrowDownTypeMsg = false;
    }
    this.sortOnMsg = "ContentDocument.FileExtension";
    this.pageNumberMsg = 1;
    this.stopSpinner = false;
    this.resetPaginationMsg = true;
    this.getTableMsgFilesData();
  }
  sortByMsgTitle(event) {
    this.arrowUpDateMsg =
      this.arrowDownDateMsg =
      this.arrowUpTypeMsg =
      this.arrowDownTypeMsg =
        false;
    this.isInitialMsg = false;
    this.firstClickMsg = !this.firstClickMsg; //true meaning desc title
    this.arrowUpTitleMsg = this.firstClickMsg; // up true asc
    this.arrowDownTitleMsg = !this.firstClickMsg; // down desc

    if (this.sortOnMsg != "ContentDocument.Title") {
      this.firstClickMsg = true; // true
      this.arrowUpTitleMsg = true;
      this.arrowDownTitleMsg = false;
    }

    this.sortOnMsg = "ContentDocument.Title";
    this.pageNumberMsg = 1;
    this.stopSpinner = false;
    this.resetPaginationMsg = true;
    this.getTableMsgFilesData();
  }
  openDeleteModel = false;
  deleteFileID;
  onDelete(event) {
    this.openDeleteModel = true;
    this.deleteFileID = event.target.dataset.id;
  }

  handleCancelModel(event) {
    this.openDeleteModel = false;
  }
  isDelete = false;
  handleContinueModel(event) {
    this.openDeleteModel = false;
    this.isSaving = true;
   deleteFile({
      fileId: this.deleteFileID
    })
      .then((result) => {
        this.isSaving = false;
        this.stopSpinner = false;
        this.isDelete = true;
        this.openmodel = false;
        this.isPreview = false;
        this.getTableFilesData();
        this.template
          .querySelector("c-custom-toast-files-p-p")
          .showToast(
            "success",
            PP_DeletedSucesfully,
            "utility:success",
            3000
          );
      })
      .catch((error) => {
        console.error("Error:", error);
      });
  }

  showfileUplaodSection(event) {
    const showUplaodEvent = new CustomEvent("showuplaodsectionevent", {
      detail: ""
    });
    this.dispatchEvent(showUplaodEvent);
  }

  get optionstab() {
    return [
      { label: "Uploaded", value: "uploaded" },
      { label: "Shared with Me", value: "sharewithme" }
    ];
  }
  get optionsSort() {
    return [
      { label: "Title: A-Z", value: "titleasc" },
      { label: "Title: Z-A", value: "titledesc" },
      { label: "File Type: A-Z", value: "filetypeasc" },
      { label: "File Type: Z-A", value: "filetypedesc" },
      { label: "Date: Last Uploaded", value: "datedesc" },
      { label: "Date: First Uploaded", value: "dateasc" }
    ];
  }
  opendropdown(event) {
    this.template.querySelectorAll(".D").forEach(function (L) {
      L.classList.toggle("slds-is-open");
    });
  }
  handleonblur(event) {
    let classListforUploaded = this.template.querySelector(".D").classList;
    try {
    } catch (ex) {
      console.log(">>eddd>>" + ex);
    }
    if (classListforUploaded.contains("slds-is-open")) {
      this.template.querySelectorAll(".D").forEach(function (L) {
        L.classList.remove("slds-is-open");
      });
    }
    let classListforSort = this.template.querySelector(".Sort").classList;
    if (classListforSort.contains("slds-is-open")) {
      this.template.querySelectorAll(".Sort").forEach(function (L) {
        L.classList.remove("slds-is-open");
      });
    }
  }
  handlenewOnSelect(event) {
    this.selectedmenu = event.target.dataset.title;
    if (this.selectedmenu == "Uploaded") {
      this.pageNumber = 1;
      this.stopSpinner = false;
      this.resetPagination = true;
      const tabChangedEvent = new CustomEvent("tabchange", {
        detail: "filestab"
      });
      this.dispatchEvent(tabChangedEvent);

      this.isInitial = true;
      this.firstClick = true;
      this.sortOn = "CreatedDate";
      this.selectedsortOption = "Sort By";

      this.getTableFilesData();
    } else {
      this.pageNumberMsg = 1;
      this.stopSpinner = false;
      this.resetPaginationMsg = true;
      const tabChangedEvent = new CustomEvent("tabchange", {
        detail: "sharetab"
      });
      this.dispatchEvent(tabChangedEvent);

      this.isInitialMsg = true;
      this.firstClickMsg = true;
      this.sortOnMsg = "ContentDocument.CreatedDate";
      this.selectedsortOption = "Sort By";
      this.getTableMsgFilesData();
    }
    this.handleonblur();
  }
  get isUploadedTab() {
    if (this.selectedmenu == "Uploaded") {
      return true;
    } else {
      return false;
    }
  }
  handlenewOnSelectSort(event) {
    this.handleonblur();
    this.selectedsortOption = "By: " + event.target.dataset.title;
    this.template.querySelectorAll(".fBold").forEach(function (L) {
      L.classList.add("fw-550");
    });
    if (event.target.dataset.id == "titleasc") {
      this.isInitial = false;
      this.firstClick = true;
      this.sortOn = "Title";
      this.pageNumber = 1;
      this.stopSpinner = false;
      this.resetPagination = true;
      this.getTableFilesData();
    }
    if (event.target.dataset.id == "titledesc") {
      this.isInitial = false;
      this.firstClick = false;
      this.sortOn = "Title";
      this.pageNumber = 1;
      this.stopSpinner = false;
      this.resetPagination = true;
      this.getTableFilesData();
    }
    if (event.target.dataset.id == "filetypeasc") {
      this.isInitial = false;
      this.firstClick = true;
      this.sortOn = "FileType";
      this.pageNumber = 1;
      this.stopSpinner = false;
      this.resetPagination = true;
      this.getTableFilesData();
    }
    if (event.target.dataset.id == "filetypedesc") {
      this.isInitial = false;
      this.firstClick = false;
      this.sortOn = "FileType";
      this.pageNumber = 1;
      this.stopSpinner = false;
      this.resetPagination = true;
      this.getTableFilesData();
    }
    if (event.target.dataset.id == "datedesc") {
      this.isInitial = false;
      this.firstClick = false;
      this.sortOn = "CreatedDate";
      this.pageNumber = 1;
      this.stopSpinner = false;
      this.resetPagination = true;
      this.getTableFilesData();
    }
    if (event.target.dataset.id == "dateasc") {
      this.isInitial = false;
      this.firstClick = true;
      this.sortOn = "CreatedDate";
      this.pageNumber = 1;
      this.stopSpinner = false;
      this.resetPagination = true;
      this.getTableFilesData();
    }
  }
  handlenewOnSelectSortMsg(event) {
    this.handleonblur();
    this.selectedsortOption = "By: " + event.target.dataset.title;
    if (event.target.dataset.id == "titleasc") {
      this.isInitialMsg = false;
      this.firstClickMsg = true;
      this.sortOnMsg = "ContentDocument.Title";
      this.pageNumberMsg = 1;
      this.stopSpinner = false;
      this.resetPaginationMsg = true;
      this.getTableMsgFilesData();
    }
    if (event.target.dataset.id == "titledesc") {
      this.isInitialMsg = false;
      this.firstClickMsg = false;
      this.sortOnMsg = "ContentDocument.Title";
      this.pageNumberMsg = 1;
      this.stopSpinner = false;
      this.resetPaginationMsg = true;
      this.getTableMsgFilesData();
    }
    if (event.target.dataset.id == "filetypeasc") {
      this.isInitialMsg = false;
      this.firstClickMsg = true;
      this.sortOnMsg = "ContentDocument.FileExtension";
      this.pageNumberMsg = 1;
      this.stopSpinner = false;
      this.resetPaginationMsg = true;
      this.getTableMsgFilesData();
    }
    if (event.target.dataset.id == "filetypedesc") {
      this.isInitialMsg = false;
      this.firstClickMsg = false;
      this.sortOnMsg = "ContentDocument.FileExtension";
      this.pageNumberMsg = 1;
      this.stopSpinner = false;
      this.resetPaginationMsg = true;
      this.getTableMsgFilesData();
    }
    if (event.target.dataset.id == "datedesc") {
      this.isInitialMsg = false;
      this.firstClickMsg = false;
      this.sortOnMsg = "ContentDocument.CreatedDate";
      this.pageNumberMsg = 1;
      this.stopSpinner = false;
      this.resetPaginationMsg = true;
      this.getTableMsgFilesData();
    }
    if (event.target.dataset.id == "dateasc") {
      this.isInitialMsg = false;
      this.firstClickMsg = true;
      this.sortOnMsg = "ContentDocument.CreatedDate";
      this.pageNumberMsg = 1;
      this.stopSpinner = false;
      this.resetPaginationMsg = true;
      this.getTableMsgFilesData();
    }
  }
  opendropdownSort(event) {
    this.template.querySelectorAll(".Sort").forEach(function (L) {
      L.classList.toggle("slds-is-open");
    });
  }
  handleChange(event) {
    this.value = event.detail.value;
  }
}