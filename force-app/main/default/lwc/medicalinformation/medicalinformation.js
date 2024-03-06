import { LightningElement, api, track } from "lwc";
import pirResources from "@salesforce/resourceUrl/pirResources";
import formFactor from "@salesforce/client/formFactor";
import pp_icons from "@salesforce/resourceUrl/pp_community_icons";

import getPEDetails from "@salesforce/apex/MedicalHistryTabController.getPEDetails";
import getMedicalHistory from "@salesforce/apex/MedicalHistryTabController.getMedicalHistory";
import saveParticipantData from "@salesforce/apex/MedicalHistryTabController.saveParticipantData";
import fetchfilterbiomarkerResult from "@salesforce/apex/MedicalHistryTabController.fetchfilterbiomarkerResult";
import requestAuthorizeMedicalRecords from "@salesforce/apex/MedicalHistryTabController.requestAuthorizeMedicalRecords";
import getEnrollmentRequestHistory from "@salesforce/apex/MedicalHistryTabController.getEnrollmentRequestHistory";
import deleteFileAttachment from "@salesforce/apex/MedicalHistryTabController.deleteFileAttachment";
import saveAttachmentPermission from "@salesforce/apex/MedicalHistryTabController.saveAttachmentPermission";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

import Medical_Preview_Error_Message from "@salesforce/label/c.Medical_Preview_Error_Message";
import RH_MedicalRetrive_Succces from "@salesforce/label/c.RH_MedicalRetrive_Succces";
import RH_MedicalRetrieve_EmailError from "@salesforce/label/c.RH_MedicalRetrieve_EmailError";
import RH_HumanAPIEmailError from "@salesforce/label/c.RH_HumanAPIEmailError";
import RH_MedicalRecordAuthorized from "@salesforce/label/c.RH_MedicalRecordAuthorized";
import RH_HumanAPIError from "@salesforce/label/c.RH_HumanAPIError";
import pir_Medical_General from "@salesforce/label/c.pir_Medical_General";
import pir_Medical_Search_Commorbidity from "@salesforce/label/c.pir_Medical_Search_Commorbidity";
import pir_MedicalHistory from "@salesforce/label/c.pir_MedicalHistory";
import Biomarkers_Header from "@salesforce/label/c.Biomarkers_Header";
import RH_MedicalRecordProvider from "@salesforce/label/c.RH_MedicalRecordProvider";
import pir_Assesment_Date_Time from "@salesforce/label/c.pir_Assesment_Date_Time";
import pir_Screener from "@salesforce/label/c.pir_Screener";
import High_Risk from "@salesforce/label/c.High_Risk";
import High_Priority from "@salesforce/label/c.High_Priority";
import BMI from "@salesforce/label/c.BMI";
import RH_Comorbidities from "@salesforce/label/c.RH_Comorbidities";
import Participant_Medical_History from "@salesforce/label/c.Participant_Medical_History";
import BulkImport_File_Name from "@salesforce/label/c.BulkImport_File_Name";
import No_records_to_display from "@salesforce/label/c.No_records_to_display";
import RH_RequestMedicalBtn from "@salesforce/label/c.RH_RequestMedicalBtn";
import pir_MedicalImport_header from "@salesforce/label/c.pir_MedicalImport_header";
import pir_BMI_Error from "@salesforce/label/c.pir_BMI_Error";
import pir_BmiHelptext from "@salesforce/label/c.pir_BmiHelptext";
import RH_MedicalRecords_NoPermitEmail from "@salesforce/label/c.RH_MedicalRecords_NoPermitEmail";
import PIR_Download from "@salesforce/label/c.PIR_Download";
import RH_RP_Record_Saved_Successfully from '@salesforce/label/c.PIR_Record_Save'; 
import Prescreener_Name from "@salesforce/label/c.Prescreener_Name";
import MRR_Screener_Name from "@salesforce/label/c.MRR_Screener_Name";
import EPR_Screener_Name from "@salesforce/label/c.EPR_Screener_Name";
import General_Screener_Name from "@salesforce/label/c.General_Screener_Name";
import RH_FileNameRequired from "@salesforce/label/c.RH_FileNameRequired";
import PP_LimitCharacters from "@salesforce/label/c.PP_LimitCharacters";
import PP_Sort from "@salesforce/label/c.PP_Sort";
import RH_FileName from "@salesforce/label/c.RH_FileName";
import RH_Share from "@salesforce/label/c.RH_Share";
import RH_Date from "@salesforce/label/c.RH_Date";
import RH_Sharing_Label from "@salesforce/label/c.RH_Sharing_Label";
import PP_Rename from "@salesforce/label/c.PP_Rename";
import pir_Delete_Btn from "@salesforce/label/c.pir_Delete_Btn";
import RH_Share_to_Patient_Portal from "@salesforce/label/c.RH_Share_to_Patient_Portal";
import PIR_Save_Changes from '@salesforce/label/c.PIR_Save_Changes';
import PIR_Unsaved_Changes from '@salesforce/label/c.PIR_Unsaved_Changes';
import BTN_Save from '@salesforce/label/c.BTN_Save';
import PIR_Discard from '@salesforce/label/c.PIR_Discard';
import PP_Sort_Title_Desc from "@salesforce/label/c.PP_Sort_Title_Desc";
import PP_Sort_Title_Asc from "@salesforce/label/c.PP_Sort_Title_Asc";
import PP_Sort_Date_Desc from "@salesforce/label/c.PP_Sort_Date_Desc";
import PP_Sort_Date_Asc from "@salesforce/label/c.PP_Sort_Date_Asc";
import Sort_Detail_By from "@salesforce/label/c.Sort_Detail_By";
import PP_Preview from "@salesforce/label/c.PP_Preview";
import RH_PermissionAcessMessage from "@salesforce/label/c.RH_PermissionAcessMessage";

import LOCALE from "@salesforce/i18n/locale";

export default class Medicalinformation extends LightningElement {
  upload = pirResources + "/pirResources/icons/upload.svg";
  download = pirResources + "/pirResources/icons/download.svg";
  deleteIcon = pirResources + "/pirResources/icons/trash-delete.svg";
  sort = pp_icons + "/" + "sort.svg";
  threedots_imgUrl = pp_icons + '/' + 'three_dots.png';
  threedots_vertical_imgUrl = pirResources + "/pirResources/icons/three_dots_vertical.svg";

  label = {
    High_Risk,
    High_Priority,
    BMI,
    RH_Comorbidities,
    Participant_Medical_History,
    pir_Medical_General,
    pir_Medical_Search_Commorbidity,
    pir_MedicalHistory,
    Biomarkers_Header,
    RH_MedicalRecordProvider,
    pir_Assesment_Date_Time,
    pir_Screener,
    BulkImport_File_Name,
    No_records_to_display,
    Medical_Preview_Error_Message,
    RH_MedicalRetrive_Succces,
    RH_MedicalRetrieve_EmailError,
    RH_HumanAPIEmailError,
    RH_HumanAPIError,
    RH_MedicalRecordAuthorized,
    RH_RequestMedicalBtn,
    pir_MedicalImport_header,
    pir_BMI_Error,
    pir_BmiHelptext,
    RH_MedicalRecords_NoPermitEmail,
    PIR_Download,
    RH_RP_Record_Saved_Successfully,
    Prescreener_Name,
    MRR_Screener_Name,
    EPR_Screener_Name,
    General_Screener_Name,
    RH_FileNameRequired,
    PP_LimitCharacters,
    PP_Sort,
    RH_Sharing_Label,
    RH_FileName,
    RH_Share,
    RH_Date,
    PP_Rename,
    pir_Delete_Btn,
    RH_Share_to_Patient_Portal,
    PIR_Save_Changes,
    PIR_Unsaved_Changes,
    BTN_Save,
    PIR_Discard,
    PP_Sort_Title_Desc,
    PP_Sort_Title_Asc,
    PP_Sort_Date_Desc,
    PP_Sort_Date_Asc,
    Sort_Detail_By,
    PP_Preview,
    RH_PermissionAcessMessage
  };

  ampm = false;
  @api selectedPe;
  @api returnpervalue;
  value = [];
  isMedicalDataLoaded = false;
  @track
  medicalHistoryRecord;
  openfileUrl;
  openmodel;
  filterasseseddatetime;
  isbiomarkerResultAvail = false;
  bioMarkerResultData;
  isReportAvailable;
  highlightsReport;
  detailedReport;
  lstEnrollmenthistry;
  decodeResult;
  decodeMRRResult;
  decodePreScreenerResult;
  decodeResultGizmo;
  decodeMRRResultGizmo;
  decodePreScreenerResultGizmo;
  loadSurvey;
  isRequestHistrySuccess;
  ismodelPopup = false;
  ismodelDeletePopup = false;
  isfileAvailable = false;
  isFilesRetrieved;
  filterRecord;
  isComorbidityLoad = true;
  commorbityshowresult;
  fileName;
  fileDownloadLink;
  lstCommorbitiesToInsert = [];
  lstCommorbitiesToDelete = [];
  lstExistingCommorbidity;
  ismediaFileAvailable = false ;
  lstmediafiles ; 
  isBiomarkerRetriveSuccess = true;
  existingBMI ;
  existingHighRisk ;
  existinexistingHighPriority ;
  isBmiValueChanged;
  isHighRiskChanged;
  isHighPriorityChanged;
  isComorbidityyChanged = false;
  isBMIError = false;
  @api isrtl = false;
  maindivcls;
  popupcls;
  isDeleteAllowed = false;
  deleteId;
  fileDownloadableLink;
  currentDatasetId;
  FileErrorMessage;
  attachmentFileName = [];
  arrowUpTitle = false;
  arrowDownTitle = false; //desc
  arrowDownDate = true; //desc
  arrowUpDate = false;
  firstClick = false;
  @api isInitial;
  sortOn = "CreatedDate";
  @api hasMedicalRecordChanges = false;
  @api isModalOpen = false;
  isMobile;
  selectedsortOption = "Sort By";
  medicalHistoryAttachmentExisting = [];
  disablebtn = false;
  isrequirerefreshtable = false;
  @api isModalOpenUnsaved = false;

  get optionsSort() {
    return [
      { label: this.label.PP_Sort_Title_Asc, value: "titleasc" },
      { label:this.label.PP_Sort_Title_Desc, value: "titledesc" },
      { label: this.label.PP_Sort_Date_Desc, value: "datedesc" },
      { label: this.label.PP_Sort_Date_Asc, value: "dateasc" }
    ];
  }

  opendropdownSort(event) {
    if (!this.fileNameErr) {
      this.template.querySelectorAll(".Sort").forEach(function (L) {
        L.classList.toggle("slds-is-open");
      });
    }
  }

  get isFileNameSorted() {
    if (this.arrowUpTitle || this.arrowDownTitle) {
      return "boldfont table-Header-Sorted";
    } else {
      return "boldfont table-Header actnColumn";
    }
  }

  get isDateSorted() {
    if (this.arrowUpDate || this.arrowDownDate) {
      return "boldfont table-Header-Sorted";
    } else {
      return "boldfont table-Header actnColumn";
    }
  }

  handlenewOnSelectSort(event) {
    this.handleonblur();
    this.selectedsortOption = this.label.Sort_Detail_By + " " + event.target.dataset.title;
    this.template.querySelectorAll(".fBold").forEach(function (L) {
      L.classList.add("fw-550");
    });
    if (event.target.dataset.id == "titleasc") {
      this.isInitial = false;
      this.firstClick = true;
      this.sortOn = "Title";

      console.log("Sort by Title ASC");
      console.log(
        "Records-->  " + JSON.stringify(this.medicalHistoryRecord.attachments)
      );
      let medicalrec = this.medicalHistoryRecord.attachments;
      console.log("SORTED  -->" + JSON.stringify(medicalrec));
      // sort by name
      medicalrec.sort((a, b) => {
        const nameA = a.attachment.Title.toUpperCase(); // ignore upper and lowercase
        console.log("SORTED ARRAY nameA -->" + nameA);
        const nameB = b.attachment.Title.toUpperCase(); // ignore upper and lowercase
        if (nameA < nameB) {
          return -1;
        }
        if (nameA > nameB) {
          return 1;
        }
        return 0;
      });
      
    }
    if (event.target.dataset.id == "titledesc") {
      this.isInitial = false;
      this.firstClick = false;
      this.sortOn = "Title"; 
      let medicalrec = this.medicalHistoryRecord.attachments;
      console.log("SORTED  -->" + JSON.stringify(medicalrec));
      // sort by name
      medicalrec.sort((a, b) => {
        const nameA = a.attachment.Title.toUpperCase(); // ignore upper and lowercase
        console.log("SORTED ARRAY nameA -->" + nameA);
        const nameB = b.attachment.Title.toUpperCase(); // ignore upper and lowercase
        if (nameA > nameB) {
          return -1;
        }
        if (nameA < nameB) {
          return 1;
        }

        return 0;
      });

    }
    if (event.target.dataset.id == "datedesc") {
      this.isInitial = false;
      this.firstClick = false;
      this.sortOn = "CreatedDate";

      let medicalrec = this.medicalHistoryRecord.attachments;

      medicalrec.sort(function (a, b) {
        return (
          new Date(b.attachment.CreatedDate) -
          new Date(a.attachment.CreatedDate)
        );
      });
    }
    if (event.target.dataset.id == "dateasc") {
      this.isInitial = false;
      this.firstClick = true;
      this.sortOn = "CreatedDate";
      
      let medicalrec = this.medicalHistoryRecord.attachments;

      medicalrec.sort(function (a, b) {
        return (
          new Date(a.attachment.CreatedDate) -
          new Date(b.attachment.CreatedDate)
        );
      });
    }
  }
  handleonblur(event) { 
    let classListforSort = this.template.querySelector(".Sort").classList;
    if (classListforSort.contains("slds-is-open")) {
      this.template.querySelectorAll(".Sort").forEach(function (L) {
        L.classList.remove("slds-is-open");
      });
    }
  }
  sortByTitle(event) {
    if (!this.fileNameErr) {
      this.arrowUpDate = this.arrowDownDate = false;

      this.isInitial = false;
      this.firstClick = !this.firstClick; //true meaning desc title
      this.arrowUpTitle = this.firstClick; // up true asc
      this.arrowDownTitle = !this.firstClick; // down desc

      if (this.sortOn != "Title") {
        console.log("sortontitle");
        this.firstClick = true; // true
        this.arrowUpTitle = true;
        this.arrowDownTitle = false;
      }

      this.sortOn = "Title";
      console.log("Sort by Title");
      if (this.arrowUpTitle) {
        console.log("Sort by Title ASC");
        console.log(
          "Records-->  " + JSON.stringify(this.medicalHistoryRecord.attachments)
        );
        let medicalrec = this.medicalHistoryRecord.attachments;
        console.log("SORTED  -->" + JSON.stringify(medicalrec));
        // sort by name
        medicalrec.sort((a, b) => {
          const nameA = a.attachment.Title.toUpperCase(); // ignore upper and lowercase
          console.log("SORTED ARRAY nameA -->" + nameA);
          const nameB = b.attachment.Title.toUpperCase(); // ignore upper and lowercase
          if (nameA < nameB) {
            return -1;
          }
          if (nameA > nameB) {
            return 1;
          }

          return 0;
        });

        
      }
      if (this.arrowDownTitle) {
        let medicalrec = this.medicalHistoryRecord.attachments;
        console.log("SORTED  -->" + JSON.stringify(medicalrec));
        // sort by name
        medicalrec.sort((a, b) => {
          const nameA = a.attachment.Title.toUpperCase(); // ignore upper and lowercase
          
          const nameB = b.attachment.Title.toUpperCase(); // ignore upper and lowercase
          if (nameA > nameB) {
            return -1;
          }
          if (nameA < nameB) {
            return 1;
          }

          // names must be equal
          return 0;
        });
      }
    }
  }

  sortByDate(event) {
    if (!this.fileNameErr) {
      this.arrowUpTitle = this.arrowDownTitle = false;

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
     
      if (this.arrowUpDate) {
        
        let medicalrec = this.medicalHistoryRecord.attachments;

        medicalrec.sort(function (a, b) {
          return (
            new Date(a.attachment.CreatedDate) -
            new Date(b.attachment.CreatedDate)
          );
        });
        
      }
      if (this.arrowDownDate) {
        
        let medicalrec = this.medicalHistoryRecord.attachments;

        medicalrec.sort(function (a, b) {
          return (
            new Date(b.attachment.CreatedDate) -
            new Date(a.attachment.CreatedDate)
          );
        });
        
      }
    }
  }

  showTaskActionMenu(event) {
    this.currentDatasetId = event.currentTarget.dataset.id;
    this.fileDownloadableLink =
      this.medicalHistoryRecord.baseURL +
      "/sfc/servlet.shepherd/document/download/" +
      event.currentTarget.dataset.id +
      "?operationContext=S1";

    var taskId = event.currentTarget.dataset.popup;
    
    this.popUpTaskId = taskId;
    let radioTask = this.template.querySelector(
      '[data-popup="' + taskId + '"]'
    );
    let cl = radioTask.classList.value;
    let selectedTask;
    if (!cl.includes("slds-is-open")) radioTask.classList.add("slds-is-open");
    if (cl.includes("slds-is-open")) radioTask.classList.remove("slds-is-open");
  }
  closeActionMenu() {
    console.log("close on blur" + this.template.querySelectorAll(".D"));

    this.template.querySelectorAll(".D").forEach(function (L) {
      L.classList.remove("slds-is-open");
    });
  }
  renameFile(event) {
    this.hasMedicalRecordChanges = true;
    let indexcalled = event.currentTarget.dataset.index;
    
    let fileName =
      this.medicalHistoryRecord.attachments[indexcalled].attachment.Title;
    let extension_index = fileName.lastIndexOf(".");
    let filenamewitoutextension = fileName.slice(0, extension_index);
    this.medicalHistoryRecord.attachments[indexcalled].fileNameForEdit =
      filenamewitoutextension.trim();
    this.medicalHistoryRecord.attachments[indexcalled].isNameReadOnly = false;
    this.focusInput(indexcalled);
  }
  event1;
  focusInput(indexcalled) {
    clearTimeout(this.event1);
    this.event1 = setTimeout(() => {
      this.template
        .querySelector("lightning-input[data-index='" + indexcalled + "']")
        .focus();
    }, 600);
  }
  @api fileNameErr = false;
  isFileRenamed = false;
  lstFileNameUpdated = [];
  validateandsaveFileName(event) {
    let indexcalled = event.currentTarget.dataset.index;
    let fileNameUpdated = event.target.value;

    let data_filter = this.medicalHistoryAttachmentExisting.filter(
      (element) => element.attachment.Id == event.currentTarget.dataset.id
    );
    
    let existingFileName = data_filter[0].attachment.Title;
    let attachmentid = event.currentTarget.dataset.id;
    this.isFileRenamed = false;

    let extension_index = existingFileName.lastIndexOf(".");
    let extension = existingFileName.slice(extension_index + 1);
    let filenamewitoutextension = existingFileName.slice(0, extension_index);

    if (fileNameUpdated.trim()) {
      if (fileNameUpdated.trim().length > 250) {
        //show error
        let lightninginputatindexlongName = this.template.querySelector(
          "lightning-input[data-index='" + indexcalled + "']"
        );
        let lightningInputcssClasslongname =
          lightninginputatindexlongName.classList.value;

        if (!lightningInputcssClasslongname.includes("errornameboxred")) {
          lightninginputatindexlongName.classList.add("errornameboxred");
        }
        this.medicalHistoryRecord.attachments[indexcalled].FileErrorMsg =
          this.label.PP_LimitCharacters;
        this.medicalHistoryRecord.attachments[indexcalled].hasNameError = true;
        if (!this.lstFileNameUpdated.includes(attachmentid)) {
          this.lstFileNameUpdated.push(attachmentid);
        }
      } else {
        if (filenamewitoutextension != fileNameUpdated.trim()) {
          this.medicalHistoryRecord.attachments[indexcalled].attachment.Title =
            fileNameUpdated.trim() + "." + extension;
          this.medicalHistoryRecord.attachments[
            indexcalled
          ].isNameUpdated = true;
          // this.isFileRenamed = true;
          if (!this.lstFileNameUpdated.includes(attachmentid)) {
            this.lstFileNameUpdated.push(attachmentid);
          }
          //check if that attachment is already renamed and already added in wrapper then update its title
          let existingupdatedattachment = this.attachmentFileName.find(
            (obj) => {
              return obj.cntnDocId === attachmentid;
            }
          );
          if (existingupdatedattachment !== undefined) {
            existingupdatedattachment.title =
              this.medicalHistoryRecord.attachments[
                indexcalled
              ].attachment.Title;
          } else {
            // else initiate a new wrapper with id and title
            this.attachmentFileName.push({
              cntnDocId: attachmentid,
              title:
                this.medicalHistoryRecord.attachments[indexcalled].attachment
                  .Title
            });
          }
        } else if (filenamewitoutextension == fileNameUpdated) {
          
          this.medicalHistoryRecord.attachments[indexcalled].attachment.Title =
            fileNameUpdated.trim() + "." + extension;
          this.medicalHistoryRecord.attachments[
            indexcalled
          ].isNameUpdated = false;
          if (this.lstFileNameUpdated.includes(attachmentid)) {
            
            let indexOfattachmentid =
              this.lstFileNameUpdated.indexOf(attachmentid);
            this.lstFileNameUpdated.splice(indexOfattachmentid, 1);
            
          }
        }
        if (this.medicalHistoryRecord.attachments[indexcalled].hasNameError) {
          let lightninginputatindex = this.template.querySelector(
            "lightning-input[data-index='" + indexcalled + "']"
          );
          let lightningInputcssClass = lightninginputatindex.classList.value;

          if (lightningInputcssClass.includes("errornameboxred")) {
            lightninginputatindex.classList.remove("errornameboxred");
          }
          this.medicalHistoryRecord.attachments[
            indexcalled
          ].hasNameError = false;
          this.medicalHistoryRecord.attachments[indexcalled].FileErrorMsg = "";
        }

        this.medicalHistoryRecord.attachments[
          indexcalled
        ].isNameReadOnly = true;
      }
    } else {
      let lightninginputatindex = this.template.querySelector(
        "lightning-input[data-index='" + indexcalled + "']"
      );
      let lightningInputcssClass = lightninginputatindex.classList.value;

      if (!lightningInputcssClass.includes("errornameboxred")) {
        lightninginputatindex.classList.add("errornameboxred");
      }

      this.medicalHistoryRecord.attachments[indexcalled].FileErrorMsg =
        this.label.RH_FileNameRequired;
      this.medicalHistoryRecord.attachments[indexcalled].hasNameError = true;
      if (!this.lstFileNameUpdated.includes(attachmentid)) {
        this.lstFileNameUpdated.push(attachmentid);
      }
    } 
    let fileHasErr = false;
    this.fileNameErr = false;
    for (var i = 0; i < this.medicalHistoryRecord.attachments.length; i++) {
      if (this.medicalHistoryRecord.attachments[i].hasNameError) {
         
        const validatemedicaltable = new CustomEvent("validatemedicaltable", {
          detail: true
        });
        this.dispatchEvent(validatemedicaltable);
        fileHasErr = true;
        break;
      }
    }
    if (this.lstFileNameUpdated.length > 0) {
      this.isFileRenamed = true;
    } 
     
    if (!fileHasErr) {
      this.fileNameErr = false;
      const validatemedicaltable = new CustomEvent("validatemedicaltable", {
        detail: false
      });
      this.dispatchEvent(validatemedicaltable);
      if (this.isBMIError) {
        
        var BMIErrorParams = { isBMIError: true, disabledSave: false };
        this.fireSaveMedicalBtnEvnt(BMIErrorParams);
      } else if (
        this.isBmiValueChanged ||
        this.isHighRiskChanged ||
        this.isHighPriorityChanged ||
        this.isComorbidityyChanged ||
        this.ispermissionChanged ||
        this.isFileRenamed
      ) {
        
        this.fireSaveMedicalBtnEvnt(true);
      } else {
        
        this.fireSaveMedicalBtnEvnt(false);
      }
    } else {
      this.fileNameErr = true;
      this.fireSaveMedicalBtnEvnt(true);
    }
    
  }

  @api addPermission = [];
  @api revokePermission = [];
  lstPermissionAddedorRemoved = [];
  ispermissionChanged = false;

  sharePermission(event) {
    
    let indexcalled = event.currentTarget.dataset.index;
    

    
    
    var data_filter = this.medicalHistoryAttachmentExisting.filter(
      (element) => element.attachment.Id == event.currentTarget.dataset.id
    );
    this.hasMedicalRecordChanges = true;
    this.ispermissionChanged = false;
    if (event.target.checked) {
      
      this.addPermission.push(event.currentTarget.dataset.id);
      
      if (this.revokePermission.includes(event.currentTarget.dataset.id)) {
        
        let index = this.revokePermission.indexOf(
          event.currentTarget.dataset.id
        );
        this.revokePermission.splice(index, 1);
      }
      
      if (data_filter[0].hasPermission == true) {
       
        if (
          this.lstPermissionAddedorRemoved.includes(
            event.currentTarget.dataset.id
          )
        ) {
          let indexofaddedId = this.lstPermissionAddedorRemoved.indexOf(
            event.currentTarget.dataset.id
          );
          
          this.lstPermissionAddedorRemoved.splice(indexofaddedId, 1);
          let indexval = this.addPermission.indexOf(event.currentTarget.dataset.id);
          this.addPermission.splice(indexval, 1);

        }
      } else {
        this.lstPermissionAddedorRemoved.push(event.currentTarget.dataset.id);
      }
    } else {
      this.revokePermission.push(event.currentTarget.dataset.id);
      if (this.addPermission.includes(event.currentTarget.dataset.id)) {
        let index = this.addPermission.indexOf(event.currentTarget.dataset.id);
        this.addPermission.splice(index, 1);
      }
     
      if (data_filter[0].hasPermission == false) {
       
        if (
          this.lstPermissionAddedorRemoved.includes(
            event.currentTarget.dataset.id
          )
        ) {
          
          let indexofaddedId = this.lstPermissionAddedorRemoved.indexOf(
            event.currentTarget.dataset.id
          );
          this.lstPermissionAddedorRemoved.splice(indexofaddedId, 1);
          
          let indexval = this.revokePermission.indexOf(
            event.currentTarget.dataset.id
          );
          
          this.revokePermission.splice(indexval, 1);

        }
      } else {
        this.lstPermissionAddedorRemoved.push(event.currentTarget.dataset.id);
      }
    }
    if (this.lstPermissionAddedorRemoved.length > 0) {
      this.ispermissionChanged = true;
    }
    if (this.isBMIError) {
      var BMIErrorParams = { isBMIError: true, disabledSave: false };
      this.fireSaveMedicalBtnEvnt(BMIErrorParams);
    } else if (
      this.isBmiValueChanged ||
      this.isHighRiskChanged ||
      this.isHighPriorityChanged ||
      this.isComorbidityyChanged ||
      this.ispermissionChanged ||
      this.isFileRenamed
    ) {
      
      this.fireSaveMedicalBtnEvnt(true);
    } else {
      
      this.fireSaveMedicalBtnEvnt(false);
    }
  }
  get sortingHover() {
    if (this.fileNameErr) {
      return "slds-truncate";
    } else {
      return "slds-truncate cuPointer";
    }
  }
  connectedCallback() {
    if (this.isrtl) {
      this.maindivcls = "rtl";
    } else {
      this.maindivcls = "ltr";
    }
    if (formFactor === "Small" || formFactor === "Medium") {
      this.isMobile = true;
      
    } else {
      this.isMobile = false;
      
    }
    
    this.popupcls = this.maindivcls + ' processBody';
    this.doSelectedPI();
  }
  @api isPPEnabled = false;
  @api
  doSelectedPI() {
    if(this.isrtl) {
      this.maindivcls = 'rtl';      
    }else{
        this.maindivcls = 'ltr';
    }
    this.loadSurvey = false;
    this.isMedicalDataLoaded = false;
    this.openmodel = false;
    this.filterasseseddatetime = [];
    this.isbiomarkerResultAvail = false;
    this.bioMarkerResultData = [];
    this.highlightsReport = "";
    this.detailedReport = "";
    this.ismodelPopup = false;
    this.ismodelDeletePopup = false;
    this.isfileAvailable = false;
    this.filterRecord = null;
    this.isComorbidityLoad = true;
    this.commorbityshowresult = false;
    this.ismediaFileAvailable = false;
    this.lstmediafiles = [];
    this.isBmiValueChanged = false;
    this.isHighRiskChanged = false;
    this.isHighPriorityChanged = false;
    this.isComorbidityyChanged = false;
    this.isBMIError = false;
    this.ispermissionChanged = false;
    this.isFileRenamed = false;
    this.fileNameErr = false;

    getPEDetails({ peid: this.selectedPe })
      .then((result) => {
        this.lstCommorbitiesToInsert = [];
        this.lstCommorbitiesToDelete = [];
        this.lstExistingCommorbidity = [];
        this.lstPermissionAddedorRemoved = [];
        this.lstFileNameUpdated = [];
        this.addPermission = [];
        this.revokePermission = [];
        this.lstEnrollmenthistry = [];
        this.lstFileNameUpdated = [];
        this.returnpervalue = result;
        this.fileNameErr = false;
        this.arrowUpTitle = false;
        this.arrowDownTitle = false; //desc
        this.arrowDownDate = true; //desc
        this.arrowUpDate = false;
        this.lstExistingCommorbidity = JSON.parse(
          JSON.stringify(result.lstComorbidities)
        );
        let detailedReportTemp = [];
        this.existingBMI = this.returnpervalue.BMI ;
        this.existingHighRisk = this.returnpervalue.HighRisk ;
        this.existingHighPriority = this.returnpervalue.Highpriority ;

        if (
          this.returnpervalue.selectedPER.Clinical_Trial_Profile__r
            .Patient_Portal_Enabled__c
        ) {
          
          this.isPPEnabled = true;
          
        } else {
          this.isPPEnabled = false;
        }
        
        const options = {
          year: "numeric",
          month: "short",
          day: "2-digit",
          hour: "numeric",
          minute: "numeric",
          second: "numeric",
          hour12: false,
        };

        if (result.MedicalreportList && result.MedicalreportList.reportList) {
          for (var i = 0; i < result.MedicalreportList.reportList.length; i++) {
            if (
              result.MedicalreportList.reportList[i].reportName ==
              "Highlights Report"
            ) {
              this.highlightsReport = result.MedicalreportList.reportList[i];
            } else {
              let dt_report = new Date(
                result.MedicalreportList.reportList[i].createdAt
              );
              result.MedicalreportList.reportList[i].createdAt =
                new Intl.DateTimeFormat(LOCALE, options).format(dt_report);
              detailedReportTemp.push(result.MedicalreportList.reportList[i]);
            }
          }
          this.detailedReport = detailedReportTemp;
          this.isReportAvailable = true;
        } else {
          this.isReportAvailable = false;
        }
        this.lstEnrollmenthistry = result.lstParticipantEnrollmentHstry;
        if (result.citizenRecords) {
          this.medicalHistoryRecord = result.citizenRecords;
          this.isfileAvailable = true;
          for (
            var i = 0;
            i < this.medicalHistoryRecord.attachments.length;
            i++
          ) {
            let dt = new Date(
              this.medicalHistoryRecord.attachments[i].attachment.CreatedDate
            );
            let flExtension =
              this.medicalHistoryRecord.attachments[i].attachment.FileExtension;
            let flTitle = this.medicalHistoryRecord.attachments[i].attachment.Title;
            if (!flTitle.includes(flExtension)) {
              this.medicalHistoryRecord.attachments[i].attachment.Title =
                flTitle + "." + flExtension;
            }
            this.medicalHistoryRecord.attachments[i].attachment.CreatedDate =
              new Intl.DateTimeFormat(LOCALE, options).format(dt);
          }
        }

        if (result.citizenRecords)
          this.medicalHistoryAttachmentExisting = JSON.parse(
            JSON.stringify(this.medicalHistoryRecord.attachments)
          );

        if (result.biomarkerdata && result.biomarkerdata.dateTimeLabelValue) {
          this.filterasseseddatetime =
            result.biomarkerdata.dateTimeLabelValue[0].value;
          if (result.biomarkerdata.mapBiomarkerKeyValue) {
            if (result.biomarkerdata.mapBiomarkerKeyValue.length != 0)
              this.isbiomarkerResultAvail = true;
            this.bioMarkerResultData =
              result.biomarkerdata.mapBiomarkerKeyValue;
          }
          if(result.lstbioMarkerMediaFiles && result.lstbioMarkerMediaFiles.length != 0){
            this.lstmediafiles = result.lstbioMarkerMediaFiles;
            this.isbiomarkerResultAvail = true;
            this.ismediaFileAvailable = true;
          }
        }
        if(result.surveyResponses && result.surveyResponses.length > 0) {

          for (var i = 0; i < result.surveyResponses.length; i++) {

            this.returnpervalue.surveyResponses[i].accordianbg = 'slds-accordion__summary ' + result.surveyResponses[i].Id + 'Bg';
            this.returnpervalue.surveyResponses[i].accordianHide = result.surveyResponses[i].Id + ' slds-hide';
            this.returnpervalue.surveyResponses[i].accordianDiv = 'slds-m-top_small '+ result.surveyResponses[i].Id +' slds-hide';
            this.returnpervalue.surveyResponses[i].screenerDiv = 'screener'+ result.surveyResponses[i].Id;

            if(this.returnpervalue.surveyResponses[i].PreScreener_Survey__c) {
              
              this.returnpervalue.surveyResponses[i].screenerName = this.returnpervalue.surveyResponses[i].PreScreener_Survey__r.Survey_Name__c;
            } else {
              var ctpName = '';
              if(this.returnpervalue.surveyResponses[i].Participant_enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c) {
                ctpName = this.returnpervalue.surveyResponses[i].Participant_enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c;
              }
              if(this.returnpervalue.surveyResponses[i].MRR_EPR__c) {
                this.returnpervalue.surveyResponses[i].screenerName = this.label.EPR_Screener_Name + (ctpName ? '_' + ctpName : '');
              } else if(this.returnpervalue.surveyResponses[i].MRR__c){
                this.returnpervalue.surveyResponses[i].screenerName =  (ctpName ? ctpName + '_' : '') + this.label.MRR_Screener_Name;
              } else if(this.returnpervalue.surveyResponses[i].Prescreener__c) {
                this.returnpervalue.surveyResponses[i].screenerName =  (ctpName ? ctpName + '_' : '') + this.label.Prescreener_Name;
              } else {
                this.returnpervalue.surveyResponses[i].screenerName =  (ctpName ? ctpName + '_' : '') + this.label.General_Screener_Name;
              }
            }

            this.returnpervalue.surveyResponses[i].screenerTitle = 
              this.returnpervalue.surveyResponses[i].screenerName + ' ' 
              + new Date(this.returnpervalue.surveyResponses[i].Completed_Date__c).toLocaleDateString(LOCALE, { year: 'numeric', month: '2-digit', day: '2-digit' });
          }

          for (var i = 0; i < result.surveyResponses.length; i++) {

            let response = this.formatgizmoresponse(result.surveyResponses[i].Screener_Response__c);
            this.returnpervalue.surveyResponses[i].decodePreScreenerResultGizmo = response.data;
            this.returnpervalue.surveyResponses[i].decodePreScreenerResult = response.decodeResult;
          }
        }
        this.loadSurvey = true;
        this.isMedicalDataLoaded = true;
        this.isFilesRetrieved = true;
        this.isRequestHistrySuccess = true;
      })
      .catch((error) => {
        console.log(">>error while retreive init>>>" + JSON.stringify(error));
        this.isFilesRetrieved = true;
        this.isMedicalDataLoaded = true;
        this.isRequestHistrySuccess = true;

      });
  }
  
  get displaySurveyResult (){
    return this.returnpervalue.surveyResponses && this.returnpervalue.surveyResponses.length > 0;
  }

  /*Method for HighRisk and High Priority */
  handlevalueupdateRisk(event) {
    
    this.isHighRiskChanged = false ;

    if(event.target.checked != this.existingHighRisk)
        {
          this.isHighRiskChanged = true ;
        }
        this.returnpervalue.HighRisk = event.target.checked; 
    if(this.isBMIError)
    { 
      var BMIErrorParams = {isBMIError :true , disabledSave : false};
      this.fireSaveMedicalBtnEvnt(BMIErrorParams);
    } else if (
      this.isBmiValueChanged ||
      this.isHighRiskChanged ||
      this.isHighPriorityChanged ||
      this.isComorbidityyChanged ||
      this.ispermissionChanged ||
      this.isFileRenamed
    ) {
       
      this.fireSaveMedicalBtnEvnt(true);
    } else {
      this.fireSaveMedicalBtnEvnt(false);
    }
  }

  handlevalueupdatePriority(event){

    this.isHighPriorityChanged = false ;

    if(event.target.checked != this.existingHighPriority)
        {
          this.isHighPriorityChanged = true ;
        }
        this.returnpervalue.Highpriority = event.target.checked; 
    if(this.isBMIError)
    { 
      var BMIErrorParams = {isBMIError :true , disabledSave : false};
      this.fireSaveMedicalBtnEvnt(BMIErrorParams);
    } else if (
      this.isBmiValueChanged ||
      this.isHighRiskChanged ||
      this.isHighPriorityChanged ||
      this.isComorbidityyChanged ||
      this.ispermissionChanged ||
      this.isFileRenamed
    ) {
      this.fireSaveMedicalBtnEvnt(true);
    } else {
      this.fireSaveMedicalBtnEvnt(false);
    }
  }

  DownloadFiles(event) {  
    window.open(this.fileDownloadableLink, "_self");
  }

  DownloadFile(event) {
    this.fileDownloadLink =
      this.medicalHistoryRecord.baseURL +
      "/sfc/servlet.shepherd/document/download/" +
      event.currentTarget.dataset.id +
      "?operationContext=S1";
  }

  deleteAndCloseModal(event) {
    this.ismodelDeletePopup = false;
    this.deleteId = undefined;
    if (event.detail.deleteAttachment == true) {
      let start = Date.now();
      this.isFilesRetrieved = false;
      this.isfileAvailable = false;
      var asc = false;
      var bydate = false;
      if (!this.arrowUpDate && !this.arrowDownDate){
        if(this.arrowUpTitle) {
          bydate=false;
          asc = true;
        }else{
          bydate=false;
          asc = false;
        }
      }else{
        if(this.arrowUpDate) {
          bydate=true;
          asc = true;
        }else{
          bydate=true;
          asc = false;
        }
      }  
      deleteFileAttachment({
        contentDocumentToDeleteId: event.detail.docid,
        participantId: this.returnpervalue.selectedPER.Participant__c,
        perid: this.selectedPe,
        bydate: bydate,
        ascending: asc
      })
        .then((result) => { 
          if (result.attachments.length <= 0) {
            this.isfileAvailable = false;
          } else {
            this.isfileAvailable = true;
          }

          this.medicalHistoryRecord = result;
 
   
          const options = {
            year: "numeric",
            month: "short",
            day: "2-digit",
            hour: "numeric",
            minute: "numeric",
            second: "numeric",
            hour12: false
          };

          for (
            var i = 0;
            i < this.medicalHistoryRecord.attachments.length;
            i++
          ) {
            let dt = new Date(
              this.medicalHistoryRecord.attachments[i].attachment.CreatedDate
            );
            this.medicalHistoryRecord.attachments[i].attachment.CreatedDate =
              new Intl.DateTimeFormat(LOCALE, options).format(dt);
          }  
          this.isFileRenamed = false;
          this.ispermissionChanged = false;
          this.lstFileNameUpdated = [];
          this.lstPermissionAddedorRemoved = [];
          this.addPermission = [];
          this.revokePermission = [];
          this.fileNameErr = false; 
           
          this.isFilesRetrieved = true;
          this.fileNameErr = false; 
        })
        .catch((error) => {
          console.log(">>error in retrive files>>>" + JSON.stringify(error));
          this.isFilesRetrieved = true;
        });
    } else {
      this.isModalOpen = false;
      this.hasMedicalRecordChanges = false; 
      if(event.detail.shouldRefreshDeleteTable == "success"){
      this.renderTableModel();
      }
      else { 
        this.isFileRenamed = false;
        this.ispermissionChanged = false;
        this.lstFileNameUpdated = [];
        this.lstPermissionAddedorRemoved = [];
        this.addPermission = [];
        this.revokePermission = [];
        this.fileNameErr = false;
        this.isrequirerefreshtable = false;
      }
    }
  }
  closeDeleteModal() {
    this.ismodelDeletePopup = false;
  }

  DeleteFile(event){
    this.deleteId = event.currentTarget.dataset.id;
    this.ismodelDeletePopup = true;
  }

  DeleteFiles(event) {
    this.deleteId = this.currentDatasetId;
    this.isrequirerefreshtable = false;
    this.disablebtn = false;
    if (this.ispermissionChanged || this.isFileRenamed) { 
      if (this.fileNameErr) {
        this.disablebtn = true;
      }
      this.isrequirerefreshtable = true;
      this.isModalOpenUnsaved = true;
    } else {
      this.ismodelDeletePopup = true;
    }
  }

  dosavemedicalTableUnsaved() { 
    this.isfileAvailable = false;
    this.disablebtn = true;
    saveAttachmentPermission({
      PerId: this.selectedPe,
      addPermission: JSON.stringify(this.addPermission),
      revokePermission: JSON.stringify(this.revokePermission),
      UpdateNamelist: JSON.stringify(this.attachmentFileName)
    })
      .then((result) => { 
        this.ispermissionChanged = false;
        this.isFileRenamed = false;
        this.disablebtn = false;
        this.lstFileNameUpdated = [];
        this.lstPermissionAddedorRemoved = [];

        this.addPermission = [];
        this.revokePermission = [];
        this.fileNameErr = false; 
        this.isModalOpenUnsaved = false; 
        const evt = new ShowToastEvent({
          title: this.label.RH_RP_Record_Saved_Successfully,
          message: this.label.RH_RP_Record_Saved_Successfully,
          variant: "success",
          mode: "dismissible"
        });
        this.dispatchEvent(evt);   
        const validatemedicaltable = new CustomEvent("validatemedicaltable", {
          detail: false
        });
        this.dispatchEvent(validatemedicaltable);
        if (this.isBMIError) {
          var BMIErrorParams = { isBMIError: true, disabledSave: false };
          this.fireSaveMedicalBtnEvnt(BMIErrorParams);
        } else if (
          this.isBmiValueChanged ||
          this.isHighRiskChanged ||
          this.isHighPriorityChanged ||
          this.isComorbidityyChanged
        ) {
           
          this.fireSaveMedicalBtnEvnt(true);
        } else {
           
          this.fireSaveMedicalBtnEvnt(false);
        }

        this.isfileAvailable = true;
        this.ismodelDeletePopup = true;
        
      })
      .catch((error) => {
        let errorMessage = '';
        let variantlocal = "Error";
        if (error.body.message) { 
          let ErrBdyMsz = error.body.message;
          if(ErrBdyMsz.toLowerCase().includes('is already linked') || ErrBdyMsz.includes('DUPLICATE_VALUE'))
          {
            errorMessage = this.label.RH_PermissionAcessMessage;
          }
          else {
          errorMessage = error.body.message;
          }
        }
        if(error.body.fieldErrors){
          errorMessage =  this.label.RH_PermissionAcessMessage;
          
        }
        const event = new ShowToastEvent({
          title: "Error",
          message: errorMessage,
          variant: variantlocal,
          mode: "sticky",
        });
        this.dispatchEvent(event);
        console.log(">>error in save permission>>>" + error);
        console.log(">>error in save permission>>>" + JSON.stringify(error));
      });
  }

  /* get the filter record of commordity*/
  @api
  getFilterRecord(event) {
    this.filterRecord = null;
    this.commorbityshowresult = false;
    if (event.target.value.length > 2) {
      this.commorbityshowresult = true;
      let allcommorbities = this.returnpervalue.lstAllComorbidities;
      let filterrecord = allcommorbities.filter((commo) =>
        commo.Comorbidity_Name__c.toLowerCase().includes(
          event.target.value.toLowerCase()
        )
      );
      this.filterRecord = filterrecord;
    }
  }
  /*hide the search result */
  hideFilterRecord() {
    window.clearTimeout(this.delayTimeout);
    this.delayTimeout = setTimeout(this.toggleCB.bind(this), 500);
  }
  temptg = true;
  toggleCB() {
    if (this.temptg) {
      this.commorbityshowresult = false;
      this.template.querySelector(
        'lightning-input[data-name="searchcomm"]'
      ).value = null;
    }
    this.temptg = true;
  }

  /*This method will called when we select any comorbidity and update the list of insertion or deletion of commorbidity */
  @api
  onSelect(event) {
    this.temptg = false;
    this.isComorbidityyChanged = false;
    if (event.currentTarget.dataset.key) {
      var index = this.filterRecord.findIndex(
        (x) => x.Id === event.currentTarget.dataset.key
      );
      var existingCommordityIndex = this.lstExistingCommorbidity.findIndex(
        (x) => x.Id === event.currentTarget.dataset.key
      );
      let DeleteCommordityIndex = -1;
      if (this.lstCommorbitiesToDelete)
        DeleteCommordityIndex = this.lstCommorbitiesToDelete.findIndex(
          (x) => x.Id === event.currentTarget.dataset.key
        );
      if (index != -1) {
        this.commorbityshowresult = false;
        this.returnpervalue.lstComorbidities.push(this.filterRecord[index]);
        this.returnpervalue.lstAllComorbidities =
          this.returnpervalue.lstAllComorbidities.filter(
            (commo) =>
              commo.Comorbidity_Name__c.toLowerCase() !=
              this.filterRecord[index].Comorbidity_Name__c.toLowerCase()
          );
        if (existingCommordityIndex != -1) {
          if (DeleteCommordityIndex != -1) {
            this.lstCommorbitiesToDelete = this.lstCommorbitiesToDelete.filter(
              (commo) =>
                commo.Comorbidity_Name__c.toLowerCase() !=
                this.filterRecord[index].Comorbidity_Name__c.toLowerCase()
            );
          }
        } else {
          this.lstCommorbitiesToInsert.push(this.filterRecord[index]);
        }

        this.template.querySelector(
          'lightning-input[data-name="searchcomm"]'
        ).value = null;
        this.filterRecord = null;
      }

      if (
        this.lstCommorbitiesToDelete.length != 0 ||
        this.lstCommorbitiesToInsert.length != 0
      ) {
        this.isComorbidityyChanged = true;
      }

      if(this.isBMIError) {
        var BMIErrorParams = {isBMIError:true, disabledSave: false };
        this.fireSaveMedicalBtnEvnt(BMIErrorParams);
      } else if (
        this.isBmiValueChanged ||
        this.isHighRiskChanged ||
        this.isHighPriorityChanged ||
        this.isComorbidityyChanged ||
        this.ispermissionChanged ||
        this.isFileRenamed
      ) {
        this.fireSaveMedicalBtnEvnt(true);
      } else {
        this.fireSaveMedicalBtnEvnt(false);
      }
      //event to enable the save button handled in pir_participantstatusDetail
      /* const validateMedicalsavebtn = new CustomEvent(
        "validatemedicalsavebutton",
        {
          detail: true,
        }
      );
      this.dispatchEvent(validateMedicalsavebtn); */
    }
  }
  /*This method will called when we remove any comorbidity and update the list of insertion or deletion of commorbidity */
  @api
  removecomorbidity(event) {
    this.isComorbidityLoad = false;
    this.isComorbidityyChanged = false;
    if (event.currentTarget.dataset.key) {
      var index = this.returnpervalue.lstComorbidities.findIndex(
        (x) => x.Id === event.currentTarget.dataset.key
      );
      var existingCommordityIndex = this.lstExistingCommorbidity.findIndex(
        (x) => x.Id === event.currentTarget.dataset.key
      );
      let comorToInsertIndex = -1;
      if (this.lstCommorbitiesToInsert)
        comorToInsertIndex = this.lstCommorbitiesToInsert.findIndex(
          (x) => x.Id === event.currentTarget.dataset.key
        );
      if (index != -1) {
        this.returnpervalue.lstAllComorbidities.push(
          this.returnpervalue.lstComorbidities[index]
        );
        if (comorToInsertIndex != -1) {
          this.lstCommorbitiesToInsert = this.lstCommorbitiesToInsert.filter(
            (commo) =>
              commo.Comorbidity_Name__c.toLowerCase() !=
              this.returnpervalue.lstComorbidities[
                index
              ].Comorbidity_Name__c.toLowerCase()
          );
        } else if (existingCommordityIndex != -1) {
          this.lstCommorbitiesToDelete.push(
            this.returnpervalue.lstComorbidities[index]
          );
        }
        this.returnpervalue.lstComorbidities =
          this.returnpervalue.lstComorbidities.filter(
            (commo) =>
              commo.Comorbidity_Name__c.toLowerCase() !=
              this.returnpervalue.lstComorbidities[
                index
              ].Comorbidity_Name__c.toLowerCase()
          );
        this.isComorbidityLoad = true;
      }
      if (
        this.lstCommorbitiesToDelete.length != 0 ||
        this.lstCommorbitiesToInsert.length != 0
      ) {
        this.isComorbidityyChanged = true;
      }
      if (this.isBMIError) {
        var BMIErrorParams = { isBMIError: true, disabledSave: false };
        this.fireSaveMedicalBtnEvnt(BMIErrorParams);
      } else if (
        this.isBmiValueChanged ||
        this.isHighRiskChanged ||
        this.isHighPriorityChanged ||
        this.isComorbidityyChanged ||
        this.ispermissionChanged ||
        this.isFileRenamed
      ) {
        this.fireSaveMedicalBtnEvnt(true);
      } else {
        this.fireSaveMedicalBtnEvnt(false);
      }

      //event to enable the save button handled in pir_participantstatusDetail
    }
  }

  @api
  openModelpopup(event) {
    if (event.currentTarget.dataset.content < 11534336) {
      //In Bytes(in binary)
      if (event.currentTarget.dataset.name)
        this.fileName = event.currentTarget.dataset.name;

      this.openfileUrl =
        "/apex/MedicalHistoryPreviewVF?resourceId=" +
        event.currentTarget.dataset.id;
      this.openmodel = true;
    } else {
      this.openmodel = false;
      const event = new ShowToastEvent({
        title: "Error",
        message: this.label.Medical_Preview_Error_Message,
        variant: "warning",
      });
      this.dispatchEvent(event);
    }
  }

  uploadDocs() {
   
    this.disablebtn = false;
    this.isrequirerefreshtable = false;
    if (this.ispermissionChanged || this.isFileRenamed) {
      
      if (this.fileNameErr) {
        this.disablebtn = true;
      }
      this.isrequirerefreshtable = true;
      this.isModalOpen = true;
    } else { 
      this.renderModel();
    }
  }
  doDiscard() {
    this.isModalOpen = false;
    this.hasMedicalRecordChanges = false;
    const validatemedicaltable = new CustomEvent("validatemedicaltable", {
      detail: false
    });
    this.dispatchEvent(validatemedicaltable);
    if (this.isBMIError) {
       
      var BMIErrorParams = { isBMIError: true, disabledSave: false };
      this.fireSaveMedicalBtnEvnt(BMIErrorParams);
    } else if (
      this.isBmiValueChanged ||
      this.isHighRiskChanged ||
      this.isHighPriorityChanged ||
      this.isComorbidityyChanged
    ) {
       
      this.fireSaveMedicalBtnEvnt(true);
    } else {
      
      this.fireSaveMedicalBtnEvnt(false);
    }
    
    this.renderModel();
  }
  //close the model
  doDiscardModal() {
    this.isModalOpen = false;
  }
  doDiscardModalUnsaved() {
    this.isModalOpenUnsaved = false;
    const validatemedicaltable = new CustomEvent("validatemedicaltable", {
      detail: false
    });
    this.dispatchEvent(validatemedicaltable);
    if (this.isBMIError) {
       
      var BMIErrorParams = { isBMIError: true, disabledSave: false };
      this.fireSaveMedicalBtnEvnt(BMIErrorParams);
    } else if (
      this.isBmiValueChanged ||
      this.isHighRiskChanged ||
      this.isHighPriorityChanged ||
      this.isComorbidityyChanged
    ) {
       
      this.fireSaveMedicalBtnEvnt(true);
    } else {
       
      this.fireSaveMedicalBtnEvnt(false);
    }
    this.ismodelDeletePopup = true;
  }
  doCloseModalUnsaved() {
    this.isModalOpenUnsaved = false;
  }

  @api
  renderModel(event) {
    this.ismodelPopup = !this.ismodelPopup;
    if (event.detail == "success") {
      this.isFilesRetrieved = false;
      this.isfileAvailable = false;
      getMedicalHistory({
        cdls: null,
        participantId: this.returnpervalue.selectedPER.Participant__c,
        perid: this.selectedPe
      })
        .then((result) => {
           
          let newvalue = JSON.parse(JSON.stringify(result));
          this.medicalHistoryRecord = newvalue;
          this.medicalHistoryAttachmentExisting = JSON.parse(
            JSON.stringify(this.medicalHistoryRecord.attachments)
          );
          this.isfileAvailable = true;

          const options = {
            year: "numeric",
            month: "short",
            day: "2-digit",
            hour: "numeric",
            minute: "numeric",
            second: "numeric",
            hour12: false,
          };

          for (
            var i = 0;
            i < this.medicalHistoryRecord.attachments.length;
            i++
          ) {
            let dt = new Date(
              this.medicalHistoryRecord.attachments[i].attachment.CreatedDate
            );
            this.medicalHistoryRecord.attachments[i].attachment.CreatedDate =
              new Intl.DateTimeFormat(LOCALE, options).format(dt);
          }
  
          this.isFileRenamed = false;
          this.ispermissionChanged = false;
          this.lstFileNameUpdated = [];
          this.lstPermissionAddedorRemoved = [];
          this.addPermission = [];
          this.revokePermission = [];

          this.fileNameErr = false; 
           
          if (!this.arrowUpDate && !this.arrowDownDate) {
            if (!this.fileNameErr) {
              this.arrowUpDate = this.arrowDownDate = false;

              this.sortOn = "Title";
              
              if (this.arrowUpTitle) {  
                let medicalrec = this.medicalHistoryRecord.attachments;
                 
                // sort by name
                medicalrec.sort((a, b) => {
                  const nameA = a.attachment.Title.toUpperCase(); // ignore upper and lowercase
                   
                  const nameB = b.attachment.Title.toUpperCase(); // ignore upper and lowercase
                  if (nameA < nameB) {
                    return -1;
                  }
                  if (nameA > nameB) {
                    return 1;
                  }

                  // names must be equal
                  return 0;
                });

                 
              }
              if (this.arrowDownTitle) { 
                let medicalrec = this.medicalHistoryRecord.attachments;
                 
                // sort by name
                medicalrec.sort((a, b) => {
                  const nameA = a.attachment.Title.toUpperCase(); // ignore upper and lowercase
                   
                  const nameB = b.attachment.Title.toUpperCase(); // ignore upper and lowercase
                  if (nameA > nameB) {
                    return -1;
                  }
                  if (nameA < nameB) {
                    return 1;
                  }

                  // names must be equal
                  return 0;
                });
              }
            }
          } else {
            if (!this.fileNameErr) {
              this.arrowUpTitle = this.arrowDownTitle = false;

              this.sortOn = "CreatedDate";
               
              if (this.arrowUpDate) {
                
                let medicalrec = this.medicalHistoryRecord.attachments;

                medicalrec.sort(function (a, b) {
                  return (
                    new Date(a.attachment.CreatedDate) -
                    new Date(b.attachment.CreatedDate)
                  );
                }); 
              }
              if (this.arrowDownDate) {
                 
                let medicalrec = this.medicalHistoryRecord.attachments;

                medicalrec.sort(function (a, b) {
                  return (
                    new Date(b.attachment.CreatedDate) -
                    new Date(a.attachment.CreatedDate)
                  );
                });
                 
              }
            }
          } 
          // this.doSelectedPI();
          
          this.isFilesRetrieved = true;
        })
        .catch((error) => {
          
          let errorMessage = '';
          let variantlocal = "Error";
          if (error.body.message) { 
            let ErrBdyMsz = error.body.message;
            if(ErrBdyMsz.toLowerCase().includes('is already linked') || ErrBdyMsz.includes('DUPLICATE_VALUE'))
            {
              errorMessage = this.label.RH_PermissionAcessMessage;
            }
            else {
            errorMessage = error.body.message;
            }
          }
          if(error.body.fieldErrors){
            errorMessage =  this.label.RH_PermissionAcessMessage;
          }
          const event = new ShowToastEvent({
            title: "Error",
            message: errorMessage,
            variant: variantlocal,
            mode: "sticky",
          });
          this.dispatchEvent(event);
          this.isFilesRetrieved = true;
          console.log(">>error in retrive files>>>" + JSON.stringify(error));
        });
    }
  }

  @api
  renderTableModel() { 
    this.isFilesRetrieved = false;
    this.isfileAvailable = false;
    getMedicalHistory({
      cdls: null,
      participantId: this.returnpervalue.selectedPER.Participant__c,
      perid: this.selectedPe
    })
      .then((result) => { 
        let newvalue = JSON.parse(JSON.stringify(result));
        this.medicalHistoryRecord = newvalue;
        this.medicalHistoryAttachmentExisting = JSON.parse(
          JSON.stringify(this.medicalHistoryRecord.attachments)
        );
        this.isfileAvailable = true;
         
        const options = {
          year: "numeric",
          month: "short",
          day: "2-digit",
          hour: "numeric",
          minute: "numeric",
          second: "numeric",
          hour12: false
        };

        for (var i = 0; i < this.medicalHistoryRecord.attachments.length; i++) {
          let dt = new Date(
            this.medicalHistoryRecord.attachments[i].attachment.CreatedDate
          );
          this.medicalHistoryRecord.attachments[i].attachment.CreatedDate =
            new Intl.DateTimeFormat(LOCALE, options).format(dt);
        } 

        this.isFileRenamed = false;
        this.ispermissionChanged = false;
        this.lstFileNameUpdated = [];
        this.lstPermissionAddedorRemoved = [];
        this.addPermission = [];
        this.revokePermission = [];
        this.fileNameErr = false;
        this.isrequirerefreshtable = false;
        

        //this.selectedsortOption = "Sort By";
        if (!this.arrowUpDate && !this.arrowDownDate) {
          if (!this.fileNameErr) {
            this.arrowUpDate = this.arrowDownDate = false;

            this.sortOn = "Title";
             
            if (this.arrowUpTitle) { 
               
              let medicalrec = this.medicalHistoryRecord.attachments;
              // sort by name
              medicalrec.sort((a, b) => {
                const nameA = a.attachment.Title.toUpperCase(); // ignore upper and lowercase
                const nameB = b.attachment.Title.toUpperCase(); // ignore upper and lowercase
                if (nameA < nameB) {
                  return -1;
                }
                if (nameA > nameB) {
                  return 1;
                }

                // names must be equal
                return 0;
              });

            }
            if (this.arrowDownTitle) { 
              let medicalrec = this.medicalHistoryRecord.attachments;
              // sort by name
              medicalrec.sort((a, b) => {
                const nameA = a.attachment.Title.toUpperCase(); // ignore upper and lowercase
                const nameB = b.attachment.Title.toUpperCase(); // ignore upper and lowercase
                if (nameA > nameB) {
                  return -1;
                }
                if (nameA < nameB) {
                  return 1;
                }

                // names must be equal
                return 0;
              });
            }
          }
        } else {
          if (!this.fileNameErr) {
            this.arrowUpTitle = this.arrowDownTitle = false;

            this.sortOn = "CreatedDate";
             
            if (this.arrowUpDate) {
               
              let medicalrec = this.medicalHistoryRecord.attachments;

              medicalrec.sort(function (a, b) {
                return (
                  new Date(a.attachment.CreatedDate) -
                  new Date(b.attachment.CreatedDate)
                );
              });
            }
            if (this.arrowDownDate) {
              let medicalrec = this.medicalHistoryRecord.attachments;

              medicalrec.sort(function (a, b) {
                return (
                  new Date(b.attachment.CreatedDate) -
                  new Date(a.attachment.CreatedDate)
                );
              });
            }
          }
        }

        this.isFilesRetrieved = true;
      })
      .catch((error) => {
        this.isFilesRetrieved = true;
        console.log(">>error in retrive files>>>" + JSON.stringify(error));
      });
  }

  @api
  updatefilterbiomarkerresult(event) {
    this.isBiomarkerRetriveSuccess = false;
    this.isbiomarkerResultAvail = false;
    this.ismediaFileAvailable = false;
    fetchfilterbiomarkerResult({
      strAssesDateTime: event.detail.value,
      perId: this.selectedPe,
    })
      .then((result) => {
        if (result.lstBiomarkerResultWrapper.length != 0) {
          this.isbiomarkerResultAvail = true;
        }
        if(result.lstbioMarkerMediaFiles.length !=0)
        {
          this.isbiomarkerResultAvail = true;
          this.ismediaFileAvailable = true;
          this.lstmediafiles  = result.lstbioMarkerMediaFiles;
        }
        this.bioMarkerResultData = result.lstBiomarkerResultWrapper;
        this.isBiomarkerRetriveSuccess = true;
      })
      .catch((error) => {
        console.log(">>errorbiomark>>>" + JSON.stringify(error));
        this.isbiomarkerResultAvail = true;
        this.isBiomarkerRetriveSuccess = true;
      });
  }

  @api
  closeModal() {
    this.openmodel = false;
  }

  @api
  handleauthorze() {
    this.isRequestHistrySuccess = false;
    requestAuthorizeMedicalRecords({ perid: this.selectedPe })
      .then((result) => {
        switch (result.strRequestMedicalReturn) {
          case "true": {
            const event = new ShowToastEvent({
              title: "Requested Successfully",
              message: this.label.RH_MedicalRetrive_Succces,
              variant: "success",
            });
            this.dispatchEvent(event);
            getEnrollmentRequestHistory({ perid: this.selectedPe })
              .then((result) => {
                this.lstEnrollmenthistry = result;
                this.isRequestHistrySuccess = true;
              })
              .catch((error) => {
                this.isRequestHistrySuccess = true;
                console.log(">>error histry>>>" + JSON.stringify(error));
              });

            break;
          }
          case "EmailError": {
            const event = new ShowToastEvent({
              title: "Requested Not Completed",
              message: this.label.RH_MedicalRetrieve_EmailError,
              variant: "Error",
            });
            this.dispatchEvent(event);
            this.isRequestHistrySuccess = true;
            break;
          }
          case "EmailNotCorrect": {
            const event = new ShowToastEvent({
              title: "Requested Not Completed",
              message: this.label.RH_HumanAPIEmailError,
              variant: "Error",
            });
            this.dispatchEvent(event);
            this.isRequestHistrySuccess = true;
            break;
          }
          case 'NoPermitEmail' : {
            const event = new ShowToastEvent({
              title: "Requested Not Completed",
              message: this.label.RH_MedicalRecords_NoPermitEmail,
              variant: "Error",
              mode : "sticky",
            });
            this.dispatchEvent(event);
            this.isRequestHistrySuccess = true;
            break; 
        }
          default: {
            const event = new ShowToastEvent({
              title: "Requested Not Completed",
              message: this.label.RH_HumanAPIError,
              variant: "Error",
            });
            this.dispatchEvent(event);
            this.isRequestHistrySuccess = true;
          }
        }
      })
      .catch((error) => {
        console.log(">>Error in sending request>>>" + JSON.stringify(error));
        this.isRequestHistrySuccess = true;
      });
  }

  @api
  formatgizmoresponse(GizmoResult) {

    let result = {data : undefined, decodeResult : false};
    
    if (!GizmoResult.includes("http")) {
      var Base64 = {
        _keyStr:
          "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
        decode: function (e) {
          var t = "";
          var n, r, i;
          var s, o, u, a;
          var f = 0;
          e = e.replace(/\\+\\+[++^A-Za-z0-9+/=]/g, "");
          while (f < e.length) {
            s = this._keyStr.indexOf(e.charAt(f++));
            o = this._keyStr.indexOf(e.charAt(f++));
            u = this._keyStr.indexOf(e.charAt(f++));
            a = this._keyStr.indexOf(e.charAt(f++));
            n = (s << 2) | (o >> 4);
            r = ((o & 15) << 4) | (u >> 2);
            i = ((u & 3) << 6) | a;
            t = t + String.fromCharCode(n);
            if (u != 64) {
              t = t + String.fromCharCode(r);
            }
            if (a != 64) {
              t = t + String.fromCharCode(i);
            }
          }
          t = Base64._utf8_decode(t);
          return t;
        },
        _utf8_decode: function (e) {
          var t = "";
          var n = 0;
          var r = 0;
          var c1 = 0;
          var c2 = 0;
          var c3 = 0;
          while (n < e.length) {
            r = e.charCodeAt(n);
            if (r < 128) {
              t += String.fromCharCode(r);
              n++;
            } else if (r > 191 && r < 224) {
              c2 = e.charCodeAt(n + 1);
              t += String.fromCharCode(((r & 31) << 6) | (c2 & 63));
              n += 2;
            } else {
              c2 = e.charCodeAt(n + 1);
              c3 = e.charCodeAt(n + 2);
              t += String.fromCharCode(
                ((r & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63)
              );
              n += 3;
            }
          }
          return t;
        },
      };
      var data = Base64.decode(GizmoResult).toString();
      data = data.replace("<h1>", '<h1 class="hide-survey-header">');
      result = {data : data, decodeResult : true};
    }
    return result;
  }

  //Accordian contact
  toggleAccordian(event) {
    this.template
      .querySelectorAll("." + event.currentTarget.dataset.name)
      .forEach(function (L) {
        L.classList.toggle("slds-hide");
      });
    this.template
      .querySelectorAll("." + event.currentTarget.dataset.name + "Bg")
      .forEach(function (L) {
        L.classList.toggle("bg-white");
      });

    if (
      this.returnpervalue.surveyResponses &&
      this.returnpervalue.surveyResponses.length > 0
    ) {
      for (var i = 0; i < this.returnpervalue.surveyResponses.length; i++) {
        if (
          event.currentTarget.dataset.name ==
          this.returnpervalue.surveyResponses[i].Id
        ) {
          this.template.querySelector(
            ".screener" + this.returnpervalue.surveyResponses[i].Id
          ).innerHTML =
            this.returnpervalue.surveyResponses[i].decodePreScreenerResultGizmo;
        }
      }
    }
  }

  handlevalueupdateBMI(event) {
    var specialCharregex = /^(([0-9]{1,4})(\.[0-9]{1,2})?)$/;

    var getBMI = event.target.value;
    let isValueChanged = false;
    this.isBmiValueChanged = false;
    this.isBMIError = false;
    this.returnpervalue.BMI = getBMI;
    const ShowErrorevent = new ShowToastEvent({
      title: "Error",
      message: this.label.pir_BMI_Error,
      variant: "Error",
    });

    if (getBMI.trim()) {
      if (!isNaN(getBMI)) {
        let updatedBMI = getBMI;
        let getSepartaeValue = updatedBMI.toString().split(".");
        let IntegerPart = getSepartaeValue[0];
        let decimalPart = getSepartaeValue[1];
        if (IntegerPart) {
          IntegerPart = IntegerPart.replace(/^0+/, "");
          if (IntegerPart.length === 0) {
            IntegerPart = "0";
          }

          updatedBMI = IntegerPart;
          if (decimalPart) {
            updatedBMI = IntegerPart + "." + decimalPart;
            if (decimalPart.length > 2) {
              updatedBMI = IntegerPart + "." + decimalPart.substr(0, 2);
            }
          }
        }

        if (specialCharregex.test(updatedBMI)) {
          event.target.value = updatedBMI;
          if (updatedBMI != this.existingBMI) {
                isValueChanged = true;
          }
          this.returnpervalue.BMI = updatedBMI;
        }  else {
          this.isBMIError = true;
          this.dispatchEvent(ShowErrorevent);
         // return;
        } 
      } else {
        this.isBMIError = true;
        this.dispatchEvent(ShowErrorevent);
        //return;
      }
    } else if (this.existingBMI == 0 || this.existingBMI) {
       
      isValueChanged = true;
      event.target.value = '';
      this.returnpervalue.BMI = '';
    }
     
    if (this.isBMIError) {
      var BMIErrorParams = { isBMIError: true, disabledSave: false };
      this.fireSaveMedicalBtnEvnt(BMIErrorParams);
    } else if (
      isValueChanged ||
      this.isHighRiskChanged ||
      this.isHighPriorityChanged ||
      this.isComorbidityyChanged ||
      this.ispermissionChanged ||
      this.isFileRenamed
    ) {
      this.isBmiValueChanged = isValueChanged;
      this.fireSaveMedicalBtnEvnt(true);
      console.log("fire save mediceve true");
    } else {
      this.fireSaveMedicalBtnEvnt(false);
    }
  }

  fireSaveMedicalBtnEvnt(boolcheckvaluechange) {
    const validateMedicalsavebtn = new CustomEvent(
      "validatemedicalsavebutton",
      {
        detail: boolcheckvaluechange
      }
    );
    this.dispatchEvent(validateMedicalsavebtn);
  }

  dosavemedicalTable() {
    // this.isFilesRetrieved = false;
    this.isfileAvailable = false;
    this.disablebtn = true;
    saveAttachmentPermission({
      PerId: this.selectedPe,
      addPermission: JSON.stringify(this.addPermission),
      revokePermission: JSON.stringify(this.revokePermission),
      UpdateNamelist: JSON.stringify(this.attachmentFileName)
    })
      .then((result) => {  
        this.ispermissionChanged = false;
        this.isFileRenamed = false;

        this.lstFileNameUpdated = [];
        this.lstPermissionAddedorRemoved = [];

        this.addPermission = [];
        this.revokePermission = [];
        this.fileNameErr = false; 

        this.disablebtn = false;
        

        this.isModalOpen = false;
         
        const evt = new ShowToastEvent({
          title: this.label.RH_RP_Record_Saved_Successfully,
          message: this.label.RH_RP_Record_Saved_Successfully,
          variant: "success",
          mode: "dismissible"
        });
        this.dispatchEvent(evt);
        const validatemedicaltable = new CustomEvent("validatemedicaltable", {
          detail: false
        });
        this.dispatchEvent(validatemedicaltable);
        if (this.isBMIError) {
           
          var BMIErrorParams = { isBMIError: true, disabledSave: false };
          this.fireSaveMedicalBtnEvnt(BMIErrorParams);
        } else if (
          this.isBmiValueChanged ||
          this.isHighRiskChanged ||
          this.isHighPriorityChanged ||
          this.isComorbidityyChanged
        ) {
          
          this.fireSaveMedicalBtnEvnt(true);
        } else {
           
          this.fireSaveMedicalBtnEvnt(false);
        }

        
        this.isfileAvailable = true;
        this.renderModel();
      })
      .catch((error) => {
        let errorMessage = '';
        let variantlocal = "Error";
        if (error.body.message) { 
          let ErrBdyMsz = error.body.message;
          if(ErrBdyMsz.toLowerCase().includes('is already linked') || ErrBdyMsz.includes('DUPLICATE_VALUE'))
          {
            errorMessage = this.label.RH_PermissionAcessMessage;
          }
          else {
          errorMessage = error.body.message;
          }
        }
        if(error.body.fieldErrors){
          errorMessage =  this.label.RH_PermissionAcessMessage;
        }
        const event = new ShowToastEvent({
          title: "Error",
          message: errorMessage,
          variant: variantlocal,
          mode: "sticky",
        });
        this.dispatchEvent(event);
        console.log(">>error in save permission>>>" + error);
        console.log(">>error in save permission>>>" + JSON.stringify(error));
        
      });
  }

  @api
  dosaveMedicalInfo() {
    this.isMedicalDataLoaded = false;
    let BMIvalue = "";
   

    if (this.returnpervalue.BMI) {
      BMIvalue = this.returnpervalue.BMI;
    }
    saveParticipantData({
      strBMI: BMIvalue,
      boolHighRisk: this.returnpervalue.HighRisk,
      boolHighPrority: this.returnpervalue.Highpriority,
      strComorbityToInsert: JSON.stringify(this.lstCommorbitiesToInsert),
      strComorbiditiestoDelete: JSON.stringify(this.lstCommorbitiesToDelete),
      PerId: this.selectedPe,
      addPermission: JSON.stringify(this.addPermission),
      revokePermission: JSON.stringify(this.revokePermission),
      UpdateNamelist: JSON.stringify(this.attachmentFileName)
    })
      .then((result) => {
        this.returnpervalue.BMI = result.BMI;
        this.returnpervalue.HighRisk = result.HighRisk;
        this.returnpervalue.Highpriority = result.Highpriority;
        this.returnpervalue.lstComorbidities = result.lstComorbidities;
        this.returnpervalue.lstAllComorbidities = result.lstAllComorbidities;
        this.lstExistingCommorbidity = JSON.parse(
          JSON.stringify(result.lstComorbidities)
        );
        this.lstCommorbitiesToInsert = [];
        this.lstCommorbitiesToDelete = [];
        this.existingHighRisk = result.HighRisk;
        this.existingHighPriority = result.Highpriority;
        this.existingBMI = result.BMI;

        this.isBmiValueChanged = false;
        this.isHighRiskChanged = false;
        this.isHighPriorityChanged = false;
        this.isComorbidityyChanged = false;
        this.ispermissionChanged = false;
        this.isFileRenamed = false;

        this.lstFileNameUpdated = [];
        this.lstPermissionAddedorRemoved = [];
        this.fileNameErr = false;

        this.addPermission = [];
        this.revokePermission = [];
        this.hasMedicalRecordChanges = false;
        this.isModalOpen = false;
        this.doSelectedPI();

        const evt = new ShowToastEvent({
          title: this.label.RH_RP_Record_Saved_Successfully,
          message: this.label.RH_RP_Record_Saved_Successfully,
          variant: "success",
          mode: "dismissable"
        });
        this.dispatchEvent(evt);
        this.isMedicalDataLoaded = true;
        const tabEvent = new CustomEvent("handletabs", {});
        this.dispatchEvent(tabEvent);
      })
      .catch((error) => {
        console.log(">>error in save>>>" + JSON.stringify(error));
        let errorMessage = "";
        let variantlocal = "Error";
        if (error.body.message) { 
          let ErrBdyMsz = error.body.message;
          if(ErrBdyMsz.toLowerCase().includes('is already linked') || ErrBdyMsz.includes('DUPLICATE_VALUE'))
          {
            errorMessage = this.label.RH_PermissionAcessMessage;
          }
          else {
          errorMessage = error.body.message;
          }
        }
        if(error.body.fieldErrors){
          errorMessage =  this.label.RH_PermissionAcessMessage; 
        }
        const event = new ShowToastEvent({
          title: "Error",
          message: errorMessage,
          variant: variantlocal,
          mode: "sticky",
        });
        this.dispatchEvent(event);
        this.isMedicalDataLoaded = true;
      });
  }
}