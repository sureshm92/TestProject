import { LightningElement, api, track } from "lwc";
import pirResources from "@salesforce/resourceUrl/pirResources";

import getPEDetails from "@salesforce/apex/MedicalHistryTabController.getPEDetails";
import getMedicalHistory from "@salesforce/apex/MedicalHistryTabController.getMedicalHistory";
import saveParticipantData from "@salesforce/apex/MedicalHistryTabController.saveParticipantData";
import fetchfilterbiomarkerResult from "@salesforce/apex/MedicalHistryTabController.fetchfilterbiomarkerResult";
import requestAuthorizeMedicalRecords from "@salesforce/apex/MedicalHistryTabController.requestAuthorizeMedicalRecords";
import getEnrollmentRequestHistory from "@salesforce/apex/MedicalHistryTabController.getEnrollmentRequestHistory";
import deleteFileAttachment from "@salesforce/apex/MedicalHistryTabController.deleteFileAttachment";

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
import Prescreener_Name from '@salesforce/label/c.Prescreener_Name';
import MRR_Screener_Name from '@salesforce/label/c.MRR_Screener_Name';
import EPR_Screener_Name from '@salesforce/label/c.EPR_Screener_Name';
import General_Screener_Name from '@salesforce/label/c.General_Screener_Name';

import LOCALE from "@salesforce/i18n/locale";

export default class Medicalinformation extends LightningElement {
  upload = pirResources + "/pirResources/icons/upload.svg";
  download = pirResources + "/pirResources/icons/download.svg";
  deleteIcon = pirResources + "/pirResources/icons/trash-delete.svg";

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
    General_Screener_Name
  };

  @api selectedPe;
  @api returnpervalue;
  value = [];
  isMedicalDataLoaded = false;
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
  connectedCallback() {
    if(this.isrtl) {
      this.maindivcls = 'rtl';      
    }else{
        this.maindivcls = 'ltr';
    }
    this.popupcls = this.maindivcls + ' processBody';
    this.doSelectedPI();
  }

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
    this.ismediaFileAvailable = false ;
    this.lstmediafiles = [];
    this.isBmiValueChanged = false;
    this.isHighRiskChanged = false;
    this.isHighPriorityChanged = false;
    this.isComorbidityyChanged = false;
    this.isBMIError = false;

    

    getPEDetails({ peid: this.selectedPe })
      .then((result) => {
        this.lstCommorbitiesToInsert = [];
        this.lstCommorbitiesToDelete = [];
        this.lstExistingCommorbidity = [];
        this.returnpervalue = result;
        this.lstExistingCommorbidity = JSON.parse(JSON.stringify(result.lstComorbidities));
        let detailedReportTemp = [];
        this.existingBMI = this.returnpervalue.BMI ;
        this.existingHighRisk = this.returnpervalue.HighRisk ;
        this.existingHighPriority = this.returnpervalue.Highpriority ;

        const options = {
          year: "numeric",
          month: "short",
          day: "numeric",
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
          this.lstEnrollmenthistry = result.lstParticipantEnrollmentHstry;
        }
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
                ctpName = this.returnpervalue.surveyResponses[i].Participant_enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c
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
    }

    if( this.isBmiValueChanged || this.isHighRiskChanged  || this.isHighPriorityChanged || this.isComorbidityyChanged)
    {
      this.fireSaveMedicalBtnEvnt(true); 
    }
    else{ 
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
      
    }

    else if( this.isBmiValueChanged || this.isHighRiskChanged  || this.isHighPriorityChanged || this.isComorbidityyChanged)
    {
      this.fireSaveMedicalBtnEvnt(true); 
    }
    else{ 
      this.fireSaveMedicalBtnEvnt(false);
    }


  }

  DownloadFile(event) {
    this.fileDownloadLink =
      this.medicalHistoryRecord.baseURL +
      "/sfc/servlet.shepherd/document/download/" +
      event.currentTarget.dataset.id +
      "?operationContext=S1";
  }

  deleteAndCloseModal(event){
    this.ismodelDeletePopup = false;
    this.deleteId = undefined;
    if (event.detail.deleteAttachment == true) {
    this.isFilesRetrieved = false;
    deleteFileAttachment({
      contentDocumentToDeleteId : event.detail.docid,
      participantId: this.returnpervalue.selectedPER.Participant__c
    })
      .then((result) => {
        this.medicalHistoryRecord = result;
        this.isFilesRetrieved = true;
      })
      .catch((error) => {
        console.log(">>error in retrive files>>>" + JSON.stringify(error));
        this.isFilesRetrieved = true;
      });
    }
  }

  DeleteFile(event){
    this.deleteId = event.currentTarget.dataset.id;
    this.ismodelDeletePopup = true;
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

      if(this.lstCommorbitiesToDelete.length != 0 || this.lstCommorbitiesToInsert.length != 0)
        {
        this.isComorbidityyChanged = true;
        }
      
      if(this.isBMIError)
    { 
      var BMIErrorParams = {isBMIError :true , disabledSave : false};
      this.fireSaveMedicalBtnEvnt(BMIErrorParams);
    }

    else if(this.isBmiValueChanged || this.isHighRiskChanged || this.isHighPriorityChanged || this.isComorbidityyChanged)
        {
        this.fireSaveMedicalBtnEvnt(true);
        }
      else { 
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
      if(this.lstCommorbitiesToDelete.length != 0 || this.lstCommorbitiesToInsert.length != 0)
      {
        this.isComorbidityyChanged = true;
      }
      if(this.isBMIError)
    { 
      var BMIErrorParams = {isBMIError :true , disabledSave : false};
      this.fireSaveMedicalBtnEvnt(BMIErrorParams);
    }

      else if(this.isBmiValueChanged || this.isHighRiskChanged || this.isHighPriorityChanged || this.isComorbidityyChanged)
    {
      this.fireSaveMedicalBtnEvnt(true);
    }
    else { 
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

  @api
  renderModel(event) {
    this.ismodelPopup = !this.ismodelPopup;
    if (event.detail == "success") {
      this.isFilesRetrieved = false;
      getMedicalHistory({
        cdls: null,
        participantId: this.returnpervalue.selectedPER.Participant__c,
      })
        .then((result) => {
          this.medicalHistoryRecord = result;
          this.isfileAvailable = true;

          const options = {
            year: "numeric",
            month: "short",
            day: "numeric",
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
          this.isFilesRetrieved = true;
        })
        .catch((error) => {
          this.isFilesRetrieved = true;
          console.log(">>error in retrive files>>>" + JSON.stringify(error));
        });
    }
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

    if(this.returnpervalue.surveyResponses && this.returnpervalue.surveyResponses.length > 0) {

      for (var i = 0; i < this.returnpervalue.surveyResponses.length; i++) {

        if (event.currentTarget.dataset.name == this.returnpervalue.surveyResponses[i].Id) {

          this.template.querySelector(".screener"+this.returnpervalue.surveyResponses[i].Id).innerHTML =
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
    }  else if(this.existingBMI == 0 || this.existingBMI) {
      isValueChanged = true;
      event.target.value = '';
      this.returnpervalue.BMI = '';
    } 

    if(this.isBMIError)
    { 
      var BMIErrorParams = {isBMIError :true , disabledSave : false};
      this.fireSaveMedicalBtnEvnt(BMIErrorParams);
    }
    else if(isValueChanged || this.isHighRiskChanged || this.isHighPriorityChanged || this.isComorbidityyChanged)
    {
      this.isBmiValueChanged = isValueChanged ;
      this.fireSaveMedicalBtnEvnt(true);
    }
    else{

      this.fireSaveMedicalBtnEvnt(false);

    }
  }


  fireSaveMedicalBtnEvnt(boolcheckvaluechange){
    const validateMedicalsavebtn = new CustomEvent(
      "validatemedicalsavebutton",
      {
        detail: boolcheckvaluechange,
      }
    );
    this.dispatchEvent(validateMedicalsavebtn);  
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
    })
      .then((result) => {
        this.returnpervalue.BMI = result.BMI;
        this.returnpervalue.HighRisk = result.HighRisk;
        this.returnpervalue.Highpriority = result.Highpriority;
        this.returnpervalue.lstComorbidities = result.lstComorbidities;
        this.returnpervalue.lstAllComorbidities = result.lstAllComorbidities;
        this.lstExistingCommorbidity = JSON.parse(JSON.stringify(result.lstComorbidities));
        this.lstCommorbitiesToInsert = [];
        this.lstCommorbitiesToDelete = [];
        this.existingHighRisk = result.HighRisk;
        this.existingHighPriority = result.Highpriority
        this.existingBMI = result.BMI;
        this.isBmiValueChanged = false;
        this.isHighRiskChanged = false;
        this.isHighPriorityChanged = false;
        this.isComorbidityyChanged = false;


        
        
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
        if (error.body.message) {
          errorMessage = error.body.message;
        }
        const event = new ShowToastEvent({
          title: "Error",
          message: errorMessage,
          variant: "Error",
          mode: "sticky",
        });
        this.dispatchEvent(event);
        this.isMedicalDataLoaded = true;
      });
  }
}
