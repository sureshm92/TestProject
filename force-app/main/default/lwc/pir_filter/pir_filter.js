import { LightningElement, api, wire } from "lwc";
import getStudyStudySite from "@salesforce/apex/PIR_HomepageController.getStudyStudySite";

import { getPicklistValues } from "lightning/uiObjectInfoApi";
import ethinicity_field from "@salesforce/schema/Participant__c.Ethnicity__c";
import RH_Ethnicity from "@salesforce/label/c.RH_Ethnicity";
import Active_InActive from "@salesforce/label/c.PIR_Active_InActive";
import Study_Information from "@salesforce/label/c.PIR_Study_Information";
import Study from "@salesforce/label/c.CC_Study";
import Study_Sites from "@salesforce/label/c.PG_SW_Tab_Study_Sites";
import Status from "@salesforce/label/c.MO_Status";
import Source from "@salesforce/label/c.PE_Source";
import Demographics from "@salesforce/label/c.RH_Demographics";
import AgeIsBetween from "@salesforce/label/c.RH_AgeIsBetween";
import And from "@salesforce/label/c.RH_And";
import Clear_All from "@salesforce/label/c.RPR_Clear_All";
import SexAtBirth from "@salesforce/label/c.PIR_Sex_at_Birth";
import Others from "@salesforce/label/c.RH_Others";
import HighRisk from "@salesforce/label/c.High_Risk";
import HighPriority from "@salesforce/label/c.High_Priority";
import Comorbidities from "@salesforce/label/c.RH_Comorbidities";
import InitialVisit from "@salesforce/label/c.Initial_Visit";
import InitialVisitScheduledDate from "@salesforce/label/c.FD_PE_Field_Initial_Visit_Scheduled_Date";
import Reset from "@salesforce/label/c.RH_Reset";
import CreatePreset from "@salesforce/label/c.PIR_CreatePreset";
import ApplyFilters from "@salesforce/label/c.RH_ApplyFilters";
import UseEthnicityFilterText from "@salesforce/label/c.PIR_Use_the_ethnicity_filter";
import To_Text from "@salesforce/label/c.PP_To";
import ActiveLabel from "@salesforce/label/c.PG_VP_L_Active";
import InActiveLabel from "@salesforce/label/c.PG_VP_L_Inactive";
import AllStudy from "@salesforce/label/c.PIR_All_Study";
import AllStudySite from "@salesforce/label/c.PIR_All_Study_Site";
import ReceivedStatus from "@salesforce/label/c.PWS_Received_Name";
import PreReviewPassedStatus from "@salesforce/label/c.Pre_review_Passed";
import ContactAttemptedStatus from "@salesforce/label/c.Contact_Attempted";
import SuccessfullyContacted from "@salesforce/label/c.Successfully_Contacted";
import Successfully_Re_Engaged from '@salesforce/label/c.Successfully_Re_Engaged';
import ScreeningInProgress from "@salesforce/label/c.Screening_In_Progress";
import InWashOutPeriod from "@salesforce/label/c.In_Wash_Out_Period";
import ScreeningPassed from "@salesforce/label/c.Screening_Passed";
import SentToDCT from "@salesforce/label/c.Sent_to_Study_Hub";
import ReadytoScreen from "@salesforce/label/c.Ready_to_Screen";
import RandomizationSuccess from "@salesforce/label/c.Randomization_Success";
import EligibilityPassed from "@salesforce/label/c.Eligibility_Passed";
import EnrollmentSuccess from "@salesforce/label/c.Enrollment_Success";
import PrereviewFailed from "@salesforce/label/c.Pre_review_Failed";
import UnabletoReach from "@salesforce/label/c.Unable_to_Reach";
import ContactedNotSuitable from "@salesforce/label/c.Contacted_Not_Suitable";
import EligibilityFailed from "@salesforce/label/c.Eligibility_Failed";
import DeclinedConsent from "@salesforce/label/c.Declined_Consent";
import UnabletoScreen from "@salesforce/label/c.Unable_to_Screen";
import WithdrewConsent from "@salesforce/label/c.Withdrew_Consent";
import ScreeningFailed from "@salesforce/label/c.Screening_Failed";
import WithdrewConsentAfterScreening from "@salesforce/label/c.Withdrew_Consent_After_Screening";
import Randomization_Failed from "@salesforce/label/c.Randomization_Failed";
import DeclinedFinalConsent from "@salesforce/label/c.Declined_Final_Consent";
import Enrollment_Failed from "@salesforce/label/c.Enrollment_Failed";
import AllStatuses from "@salesforce/label/c.PG_MRR_L_All_Statuses";
import AllSources from "@salesforce/label/c.PG_MRR_L_All_sources";
import ReferringProvider from "@salesforce/label/c.Referring_Provider";
import PricipalInvestigator from "@salesforce/label/c.CC_TableHeader_PI";
import DigitalRecruitment from "@salesforce/label/c.Digital_Recruitment";
import AF_All from "@salesforce/label/c.AF_All";
import Male from "@salesforce/label/c.Gender_Male";
import Female from "@salesforce/label/c.Gender_Female";
import More from "@salesforce/label/c.PIR_more";
import pir_mm_dd_yyyy from "@salesforce/label/c.pir_mm_dd_yyyy";
import PP_To from "@salesforce/label/c.PP_To";
import PP_Scheduled from "@salesforce/label/c.PP_Scheduled";
import PIR_Not_Scheduled from "@salesforce/label/c.PIR_Not_Scheduled";
import Participant_No_Show from "@salesforce/label/c.Participant_No_Show";

export default class Filtertest extends LightningElement {
  @api maindivcls;
  label = {
    AF_All,
    More,
    Male,
    Female,
    Active_InActive,
    Study_Information,
    Study,
    Study_Sites,
    Status,
    Source,
    Demographics,
    AgeIsBetween,
    And,
    Clear_All,
    SexAtBirth,
    Others,
    HighRisk,
    HighPriority,
    Comorbidities,
    InitialVisit,
    InitialVisitScheduledDate,
    Reset,
    CreatePreset,
    ApplyFilters,
    UseEthnicityFilterText,
    To_Text,
    ActiveLabel,
    InActiveLabel,
    AllStudy,
    AllStudySite,
    ReceivedStatus,
    PreReviewPassedStatus,
    ContactAttemptedStatus,
    SuccessfullyContacted,
    Successfully_Re_Engaged,
    ScreeningInProgress,
    InWashOutPeriod,
    ScreeningPassed,
    SentToDCT,
    ReadytoScreen,
    RandomizationSuccess,
    EligibilityPassed,
    EnrollmentSuccess,
    PrereviewFailed,
    UnabletoReach,
    ContactedNotSuitable,
    EligibilityFailed,
    DeclinedConsent,
    UnabletoScreen,
    WithdrewConsent,
    ScreeningFailed,
    WithdrewConsentAfterScreening,
    Randomization_Failed,
    DeclinedFinalConsent,
    Enrollment_Failed,
    AllStatuses,
    AllSources,
    ReferringProvider,
    PricipalInvestigator,
    DigitalRecruitment,
    pir_mm_dd_yyyy,
    PP_To,
    PP_Scheduled,
    PIR_Not_Scheduled,
    Participant_No_Show
  };
  @api
  filterClass = 'filter-area';
  @api
  loaded = false;
  studylist;
  studyToStudySite;
  @api studySiteList;
  @api urlstudyid;
  @api urlsiteid;
  @api urlstatus;
  @api defaultStudy;
  @api defaultSite;
  selectedStudy;
  selectedSite;
  statusoptions;
  defaultStatus;
  selectedActiveInactive = "Active";
  defaultSource = "All Sources";
  defaultSex = "All";
  defaultHighRisk = false;
  defaultHighPriority = false;
  defaultComorbidities = false;
  selectedStatus;
  ininialvisitScheduledOption = "All";
  isInitialVisitSelected = true;
  initialvisitStart;
  initialvisitEnd;
  ageStartValue = 0;
  ageEndValue = 150;
  isbuttonenabled = false;
  shoulddisplaypopup = false;
  @api selectedstatusvalue;
  @api sponser;
  @api filterWrapper = {
    activeInactive: "Active",
    studyList: [],
    siteList: [],
    status: [],
    source: [],
    ageTo: "0",
    ageFrom: "150",
    ethnicityList: [],
    sex: "",
    highRisk: false,
    highPriority: false,
    comorbidities: false,
    initialVisit: "All",
    initialVisitStartDate: "",
    initialVisitEndDate: "",
    presetId: "",
    presetName:""
  };

  studyToPrmoteDCT;
  studyToFinalStep;
  isAnythingChangedForReset = false;

  filterFetched = false;
  @api
  get filters(){ return true;}
  set filters(value){
    var presetSellection = value;
    
    if(!this.filterFetched || this.urlstatus){
      this.filterFetched= true;
      let scList;
      if(this.sponser==='janssen'){
        scList = [
          "Principal Investigator",
          "Digital Recruitment"
        ];
      }else{
        scList = [
          "Referring Provider",
          "Principal Investigator",
          "Digital Recruitment"
        ];
      }
      this.filterWrapper.source = scList;
      getStudyStudySite()
        .then((result) => {
          if (result.ctpMap) {
            var conts = result.ctpMap;
            this.studyToPrmoteDCT = result.studyToPrmoteDCT;
            this.studyToFinalStep = result.studyToFinalStep;
            let options = [];
            options.push({ label: this.label.AllStudy, value: "All Study" });
            for (var key in conts) {
              options.push({ label: key, value: conts[key] });
            }
            this.studylist = options;
            if (this.urlstudyid != null) {
              this.defaultStudy = this.urlstudyid;
            } else {
              this.defaultStudy = options[1].value;
            }
            this.filterWrapper.studyList=[];
            this.filterWrapper.studyList.push(this.defaultStudy);
          }

          if (result.studySiteMap) {
            this.studyToStudySite = result.studySiteMap;
            var picklist_Value = this.defaultStudy;
            var conts1 = this.studyToStudySite;
            let options1 = [];
            options1.push({ label: this.label.AllStudySite, value: "All Study Site" });
            for (var key in conts1) {
              if (key == picklist_Value) {
                var temp = conts1[key];
                for (var j in temp) {
                  options1.push({ label: temp[j].Name, value: temp[j].Id });
                }
              }
            }
            this.studySiteList = options1;
            if (this.urlsiteid != null) {
              this.defaultSite = this.urlsiteid;
            } else {
              this.defaultSite = options1[0].value;
            }
            this.selectedSite = this.defaultSite;
            this.filterWrapper.siteList=[];
            //for Study site
            if (this.selectedSite != null && this.selectedSite == "All Study Site") {
              for (var i = 1; i < this.studySiteList.length; i++) {
                this.filterWrapper.siteList.push(this.studySiteList[i].value);
              }
            } else if (
              this.selectedSite != null &&
              this.selectedSite != "All Study Site"
            ) {
              this.filterWrapper.siteList.push(this.selectedSite);
            }
          }
          this.createStatusOption();
          this.defaultStatus = this.urlstatus ? this.urlstatus : this.selectedstatusvalue;
          if(this.urlstatus){
            this.urlstatus = undefined;
          }
          this.selectedStatus = this.selectedstatusvalue;
          if (this.selectedstatusvalue == "All Active Statuses") {
            this.filterWrapper.status = [];
            for (var i = 1; i < this.statusoptions.length; i++) {
              this.filterWrapper.status.push(this.statusoptions[i].value);
            }
          } else if (this.selectedstatusvalue == "All Inactive Statuses") {
            this.filterWrapper.status = [];
            for (var i = 1; i < this.statusoptions.length; i++) {
              this.filterWrapper.status.push(this.statusoptions[i].value);
            }
          } else {
            this.filterWrapper.status = [];
            this.filterWrapper.status.push(this.selectedstatusvalue);
          }
          if(!this.loaded){
            this.loaded = true;
          }
          const loadComplete = new CustomEvent("loadcomplete", {
            detail: true
          });
          this.dispatchEvent(loadComplete);
          
          if(!(Object.keys(value).length === 0)){
            this.presetWrapperSet(presetSellection);
          }
          //send filter wrapper to parent
          const setFilter = new CustomEvent("getdefaultfilter", {
            detail: this.filterWrapper
          });
          this.dispatchEvent(setFilter);
        })
        .catch((error) => {
          console.error("Error:", error);
        });


    }
  }
  @api
  presetWrapperSet(presetSellection){
    this.selectedActiveInactive = presetSellection.activeInactive;

    if(presetSellection.source && presetSellection.source.length == 1){
      this.defaultSource = presetSellection.source[0];
    }else{
      this.defaultSource = 'All Sources';
    }
    
    this.ageStartValue = presetSellection.ageTo;
    this.ageEndValue = presetSellection.ageFrom;
    this.defaultSex = presetSellection.sex;
    if(!presetSellection.sex){
      this.defaultSex="All";
    }
    this.defaultHighRisk = presetSellection.highRisk == 'true';
    this.defaultHighPriority = presetSellection.highPriority;
    this.defaultComorbidities = presetSellection.comorbidities == 'true';
    this.ininialvisitScheduledOption = presetSellection.initialVisit;

    if(presetSellection.initialVisit == 'All'){
      this.isInitialVisitSelected = true;
    }
    
    this.initialvisitStart = presetSellection.initialVisitStartDate;
    this.initialvisitEnd = presetSellection.initialVisitEndDate;
  
    if(presetSellection.studyList.length == 1){
      this.defaultStudy = presetSellection.studyList[0];
      this.selectedStudy = presetSellection.studyList[0];
    }else{
      this.defaultStudy = 'All Study';
      this.selectedStudy = 'All Study';
    }

    var picklist_Value = this.selectedStudy;
    var conts = this.studyToStudySite;
    let options = [];
    options.push({ label: this.label.AllStudySite, value: "All Study Site" });
    if (picklist_Value != "All Study") {
      for (var key in conts) {
        if (key == picklist_Value) {
          var temp = conts[key];
          for (var j in temp) {
            options.push({ label: temp[j].Name, value: temp[j].Id });
          }
        }
      }
    } else {
      for (var key in conts) {
        var temp = conts[key];
        for (var j in temp) {
          options.push({ label: temp[j].Name, value: temp[j].Id });
        }
      }
    }

    this.studySiteList = options;

    if(presetSellection.siteList.length == 1){
      this.defaultSite = presetSellection.siteList[0];
      this.selectedSite = presetSellection.siteList[0];
    }else{
      this.defaultSite = 'All Study Site';
      this.selectedSite = 'All Study Site';
    }

    this.createStatusOption();
    if (presetSellection.activeInactive == "Active") {
      if(presetSellection.status.length == 1){
        this.defaultStatus = presetSellection.status[0];
        this.selectedStatus = presetSellection.status[0];
      }else{
        this.defaultStatus = "All Active Statuses";
        this.selectedStatus = "All Active Statuses";
      }

    } else if (presetSellection.activeInactive == "Inactive") {
      if(presetSellection.status.length == 1){
        this.defaultStatus = presetSellection.status[0];
        this.selectedStatus = presetSellection.status[0];
      }else{
        this.defaultStatus = "All Inactive Statuses";
        this.selectedStatus = "All Inactive Statuses";
      }
      
    }

    if(presetSellection.ethnicityList){
      let sysVal = presetSellection.ethnicityList;
      this.removeAllE();
      for(var i=0;i<sysVal.length;i++){
          this.template.querySelector("input[value='"+sysVal[i]+"']").checked = true;
          this.fcsEth = false;   
      }      
      this.setEthinicityList();        
      this.template.querySelector(".eBox").blur();
    }
    else{
      this.removeAllE();
    }
    this.filterWrapper = JSON.parse(JSON.stringify(presetSellection));
    
    const updfilter = new CustomEvent("updfilter", {
      detail: {fw : this.filterWrapper,err:false}
      });
      this.dispatchEvent(updfilter);
  }

  studyhandleChange(event) {
    var picklist_Value = event.target.value;
    this.defaultStudy = picklist_Value;
    var conts = this.studyToStudySite;
    let options = [];
    options.push({ label: this.label.AllStudySite, value: "All Study Site" });
    if (picklist_Value != "All Study") {
      for (var key in conts) {
        if (key == picklist_Value) {
          var temp = conts[key];
          for (var j in temp) {
            options.push({ label: temp[j].Name, value: temp[j].Id });
          }
        }
      }
    } else {
      for (var key in conts) {
        var temp = conts[key];
        for (var j in temp) {
          options.push({ label: temp[j].Name, value: temp[j].Id });
        }
      }
    }

    this.studySiteList = options;
    this.selectedStudy = picklist_Value;
    this.defaultSite = "All Study Site";
    this.selectedSite = "All Study Site";
    this.createStatusOption();
    this.sendFilterUpdates();
  }

  studysiteshandleChange(event) {
    this.selectedSite = event.target.value;
    this.defaultSite = event.target.value;
    this.sendFilterUpdates();
  }
  @api
  applyFilter() {
    this.filterPresetHandler();
    const selectEvent = new CustomEvent("applyfilterevent", {
      detail: this.filterWrapper
    });
    this.dispatchEvent(selectEvent);
  }

  createPreset() {
    this.filterPresetHandler();
    this.shoulddisplaypopup  = true;
  }
  closepresetmodel(event){
    this.shoulddisplaypopup  = false;
    if(event.detail=='created'){
      const presetcreated = new CustomEvent("presetcreated");
      this.dispatchEvent(presetcreated); 
    }
  }

  filterPresetHandler() {
    var filterStudy = [];
    var filterSite = [];

    //for Study
    if (this.selectedStudy != null && this.selectedStudy == "All Study") {
      for (var i = 1; i < this.studylist.length; i++) {
        filterStudy.push(this.studylist[i].value);
      }
    } else if (
      this.selectedStudy != null &&
      this.selectedStudy != "All Study"
    ) {
      filterStudy.push(this.selectedStudy);
    } else {
      filterStudy.push(this.defaultStudy);
    }

    //for Study site
    if (this.selectedSite != null && this.selectedSite == "All Study Site") {
      for (var i = 1; i < this.studySiteList.length; i++) {
        filterSite.push(this.studySiteList[i].value);
      }
    } else if (
      this.selectedSite != null &&
      this.selectedSite != "All Study Site"
    ) {
      filterSite.push(this.selectedSite);
    }

    var filterStatus =
      this.selectedStatus != null ? this.selectedStatus : this.defaultStatus;
    this.filterWrapper.studyList = filterStudy;
    this.filterWrapper.siteList = filterSite;
    this.filterWrapper.ethnicityList = [];
    for(var j=0; j<this.selectedEthinicity.length; j++){
      this.filterWrapper.ethnicityList.push(this.selectedEthinicity[j].value);
    }

    if (filterStatus == "All Active Statuses") {
      this.filterWrapper.status = [];
      for (var i = 1; i < this.statusoptions.length; i++) {
        this.filterWrapper.status.push(this.statusoptions[i].value);
      }
    } else if (filterStatus == "All Inactive Statuses") {
      this.filterWrapper.status = [];
      for (var i = 1; i < this.statusoptions.length; i++) {
        this.filterWrapper.status.push(this.statusoptions[i].value);
      }
    } else {
      this.filterWrapper.status = [];
      this.filterWrapper.status.push(filterStatus);
    }
  }
  get getFirstSelecedEth(){
    if(this.selectedEthinicity){
      if(this.selectedEthinicity.length>0){
        return this.selectedEthinicity[0].label;
      }
    }
    return null;
  }
  get ethCount(){
    if(this.selectedEthinicity){
      if(this.selectedEthinicity.length>1){
        //return "+" + (this.selectedEthinicity.length-1)+" more" ;
        return "+" + (this.selectedEthinicity.length-1)+" "+this.label.More ;
      }
    }
    return "";
  }
  get activeoptions() {
    return [
      { label: this.label.ActiveLabel, value: "Active" },
      { label: this.label.InActiveLabel, value: "Inactive" }
    ];
  }

  activehandleChange(event) {
    var selectedMode = event.target.value;
    this.selectedActiveInactive = selectedMode;
    this.createStatusOption();
    if (selectedMode == "Active") {
      this.defaultStatus = "All Active Statuses";
      this.selectedStatus = "All Active Statuses";
    } else if (selectedMode == "Inactive") {
      this.defaultStatus = "All Inactive Statuses";
      this.selectedStatus = "All Inactive Statuses";
    }
    this.filterWrapper.activeInactive = selectedMode;
    this.sendFilterUpdates();
  }

  statushandleChange(event) {
    this.selectedStatus = event.target.value;
    this.defaultStatus = event.target.value;
    this.sendFilterUpdates();
  }

  initialvisithandleChange(event) {
    if (event.target.value == "Initial Visit Scheduled") {
      this.isInitialVisitSelected = false;
    } else {
      this.template.querySelector(
        'lightning-input[data-name="datestart"]'
      ).value = null;
      this.template.querySelector(
        'lightning-input[data-name="dateend"]'
      ).value = null;
      this.template
        .querySelector('lightning-input[data-name="datestart"]')
        .setCustomValidity("");
      this.template
        .querySelector('lightning-input[data-name="datestart"]')
        .reportValidity();
      this.isInitialVisitSelected = true;
      this.filterWrapper.initialVisitStartDate = '';
      this.filterWrapper.initialVisitEndDate = '';
      this.initialvisitStart = '';
      this.initialvisitEnd = '';
    }

    this.filterWrapper.initialVisit = event.target.value;
    this.ininialvisitScheduledOption = event.target.value;
    var temp = (this.template.querySelector('lightning-input[data-name="agestart"]').reportValidity() &&  this.template.querySelector('lightning-input[data-name="ageend"]').reportValidity() &&  this.template.querySelector('lightning-input[data-name="datestart"]').reportValidity());
      if(temp){
        this.isbuttonenabled = false;
      }else{
        this.isbuttonenabled = true;
      }
    this.sendFilterUpdates();
  }

  handleInitialVisitStartDateChange(event) {
    this.initialvisitStart = event.target.value;
    if(this.initialvisitStart == null){
      this.initialvisitStart = '';
      this.filterWrapper.initialVisitStartDate = '';
    }else{
      var d1 = new Date(this.initialvisitStart);
      var d2 = new Date(this.initialvisitEnd);
      if (d1 > d2) {
        this.template
          .querySelector('lightning-input[data-name="datestart"]')
          .setCustomValidity("Start Date cannot be greater than End Date");
        this.isbuttonenabled = true;
      } else {
        this.template
          .querySelector('lightning-input[data-name="datestart"]')
          .setCustomValidity("");
        this.isbuttonenabled = false;
        this.filterWrapper.initialVisitStartDate = d1.toISOString().split('T')[0];
      }
    }
    
    this.template
      .querySelector('lightning-input[data-name="datestart"]')
      .reportValidity();
    this.sendFilterUpdates();
  }

  handleInitialVisitEndDateChange(event) {
    this.initialvisitEnd = event.target.value;
    if(this.initialvisitEnd == null){
      this.initialvisitEnd = '';
      this.filterWrapper.initialVisitEndDate  = '';
    }else{
      var d1 = new Date(this.initialvisitStart);
      var d2 = new Date(this.initialvisitEnd);
      if (d1 > d2) {
        this.template
          .querySelector('lightning-input[data-name="datestart"]')
          .setCustomValidity("Start Date cannot be greater than End Date");
        this.isbuttonenabled = true;
      } else {
        this.template
          .querySelector('lightning-input[data-name="datestart"]')
          .setCustomValidity("");
        this.isbuttonenabled = false;
        this.filterWrapper.initialVisitEndDate = d2.toISOString().split('T')[0];
      }
    }
    
    this.template
      .querySelector('lightning-input[data-name="datestart"]')
      .reportValidity();
    this.sendFilterUpdates();
  }

  handleAgeStartChange(event) {
    this.ageStartValue = event.target.value;
    var a1 = this.ageStartValue;
    var a2 = this.ageEndValue;
    if (((a2 != '') && (Number(a1) > Number(a2) || (Number(a1) < 0 || Number(a1) > 150) || (Number(a2) < 0 ||  Number(a2) > 150))) || ((a2 == '') && (Number(a1) < 0 || Number(a1) > 150))) {
      this.template
        .querySelector('lightning-input[data-name="agestart"]')
        .setCustomValidity("Allowed range 0-150");
      this.isbuttonenabled = true;
    } else {
      this.template
        .querySelector('lightning-input[data-name="agestart"]')
        .setCustomValidity("");
      this.isbuttonenabled = false;
      this.filterWrapper.ageTo = a1 != '' ? (Number(a1).toFixed()) : '';
      this.filterWrapper.ageFrom = a2 != '' ? (Number(a2).toFixed()) : '';
    }
    var temp = (this.template.querySelector('lightning-input[data-name="agestart"]').reportValidity() &&  this.template.querySelector('lightning-input[data-name="ageend"]').reportValidity() &&  this.template.querySelector('lightning-input[data-name="datestart"]').reportValidity());
      if(temp){
        this.isbuttonenabled = false;
      }else{
        this.isbuttonenabled = true;
      }
    this.sendFilterUpdates();
  }

  handleAgeEndChange(event) {
    this.ageEndValue = event.target.value;
    var a1 = this.ageStartValue;
    var a2 = this.ageEndValue;
    if (((a2 != '') && (Number(a1) > Number(a2) || (Number(a2) < 0 ||  Number(a2) > 150) || (Number(a1) < 0 || Number(a1) > 150))) || ((a2 == '') && (Number(a1) < 0 || Number(a1) > 150))) {
      this.template
        .querySelector('lightning-input[data-name="agestart"]')
        .setCustomValidity("Allowed range 0-150");
      this.isbuttonenabled = true;
    } else {
      this.template
        .querySelector('lightning-input[data-name="agestart"]')
        .setCustomValidity("");
      this.isbuttonenabled = false;
      this.filterWrapper.ageTo = a1 != '' ? (Number(a1).toFixed()) : '';
      this.filterWrapper.ageFrom = a2 != '' ? (Number(a2).toFixed()) : '';
    }
    var temp = (this.template.querySelector('lightning-input[data-name="agestart"]').reportValidity() &&  this.template.querySelector('lightning-input[data-name="ageend"]').reportValidity() &&  this.template.querySelector('lightning-input[data-name="datestart"]').reportValidity());
      if(temp){
        this.isbuttonenabled = false;
      }else{
        this.isbuttonenabled = true;
      }
    this.sendFilterUpdates();
  }

  sourcehandleChange(event) {
    var source = event.target.value;
    this.defaultSource = source;
    if (source == "All Sources") {
      var scList = [
        "Referring Provider",
        "Principal Investigator",
        "Digital Recruitment"
      ];
      this.filterWrapper.source = scList;
    } else {
      this.filterWrapper.source = [];
      this.filterWrapper.source.push(source);
    }
    this.sendFilterUpdates();
  }

  sexatbirthhandleChange(event) {
    var sex = event.target.value;
    if (sex != "All") {
      this.filterWrapper.sex = sex;
      this.defaultSex = sex;
    }else{
      this.filterWrapper.sex = '';
    }
    this.sendFilterUpdates();
  }

  handleHighRisk(event) {
    this.filterWrapper.highRisk = event.target.checked;
    this.defaultHighRisk = event.target.checked;
    this.sendFilterUpdates();
  }

  handleHighPriority(event) {
    this.filterWrapper.highPriority = event.target.checked;
    this.defaultHighPriority = event.target.checked;
    this.sendFilterUpdates();
  }

  handleComorbidities(event) {
    this.filterWrapper.comorbidities = event.target.checked;
    this.defaultComorbidities = event.target.checked;
    this.sendFilterUpdates();
  }

  get sourceoptions() {
    if(this.sponser=='Janssen' ){
      return [
        { label: this.label.AllSources, value: "All Sources" },
      { label: this.label.PricipalInvestigator, value: "Principal Investigator" },
      { label: this.label.DigitalRecruitment, value: "Digital Recruitment" }
    ];
    }else{
      return [
        { label: this.label.AllSources, value: "All Sources" },
        { label: this.label.ReferringProvider, value: "Referring Provider" },
        { label: this.label.PricipalInvestigator, value: "Principal Investigator" },
        { label: this.label.DigitalRecruitment, value: "Digital Recruitment" }
      ];
    }
  }

  get sexatbirthoptions() {
    return [
      { label: this.label.AF_All, value: "All" },
      { label: this.label.Male, value: "M" },
      { label: this.label.Female, value: "F" }
    ];
  }

  get initialvisitoptions() {
    return [
      { label: this.label.AF_All, value: "All" },
      { label: this.label.PP_Scheduled, value: "Initial Visit Scheduled" },
      {
        label: this.label.PIR_Not_Scheduled,
        value: "Initial Visit Not Scheduled"
      }
    ];
  }

  get isJanssen(){
    if(this.sponser == 'Janssen'){
      return true;
    }else{
      return false;
    }
  }

  //Ethnicity start
  RH_Ethnicity = RH_Ethnicity;
  picklistValues;
  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA", //default rectype id
    fieldApiName: ethinicity_field
  })
  wiredEthVal({ error, data }) {
    if (data) {
      this.picklistValues = [];
      for (var i = 0; i < data.values.length; i++) {
        this.picklistValues.push({
          label: data.values[i].label.split("- ")[1],
          value: data.values[i].value
        });
      }
    } else if (error) {
      console.log("err");
    }
  }
  selectedEthinicity = [];
  ethListStr = "";
  divSetEth(event) {
    event.currentTarget.getElementsByTagName("input")[0].checked =
      !event.currentTarget.getElementsByTagName("input")[0].checked;
    this.setEthinicityList();
  }
  setEthinicityList() {
    let tempList = [];
    let ethElement = this.template.querySelector('[data-id="ethinicityBox"]');
    let opts = ethElement.getElementsByTagName("input");
    let ethOPts = [];
    for (var i = 0; i < opts.length; i++) {
      if (opts[i].checked) {
        tempList.push({ label: opts[i].name, value: opts[i].value });
        ethOPts.push(opts[i].value);
      }
    }
    this.ethListStr = ethOPts.join(";");
    this.selectedEthinicity = [];
    this.selectedEthinicity = this.selectedEthinicity.concat(tempList);
    this.template.querySelector(".eBox").focus();
    this.sendFilterUpdates();
  }
  openETH() {
    this.template.querySelector(".eBoxOpen").classList.add("slds-is-open");
  }
  closeETH() {
    this.template.querySelector(".eBoxOpen").classList.remove("slds-is-open");
  }
  removeE(event) {
    this.template.querySelector(
      "input[value='" + event.currentTarget.dataset.id + "']"
    ).checked = false;
    this.setEthinicityList();
  }
  removeAllE() {
    let ethElement = this.template.querySelector('[data-id="ethinicityBox"]');
    let opts = ethElement.getElementsByTagName("input");
    for (var i = 0; i < opts.length; i++) {
      opts[i].checked = false;
    }
    this.selectedEthinicity = [];
    this.ethListStr = "";
    this.setEthinicityList();
    this.template.querySelector(".eBox").blur();
  }
  @api
  resetFilter(event){
    
    this.selectedActiveInactive = this.activeoptions[0].value;
    this.defaultStudy = this.studylist[1].value;
    this.selectedStudy = this.defaultStudy;
    var conts = this.studyToStudySite;
    let options = [];
    options.push({ label: this.label.AllStudySite, value: "All Study Site" });
      for (var key in conts) {
        if (key == this.defaultStudy) {
          var temp = conts[key];
          for (var j in temp) {
            options.push({ label: temp[j].Name, value: temp[j].Id });
          }
        }
      }

    this.studySiteList = options;
    this.defaultSite = this.studySiteList[0].value;
    this.selectedSite = this.defaultSite;

    this.createStatusOption();

    this.defaultStatus = this.statusoptions[0].value;
    this.selectedStatus = this.statusoptions[0].value;
    this.defaultSource = this.sourceoptions[0].value;
    this.ageStartValue = 0;
    this.ageEndValue = 150;
    this.removeAllE();
    this.defaultSex = "All";
    this.defaultHighRisk = false;
    this.defaultHighPriority = false;
    this.defaultComorbidities = false;
    this.ininialvisitScheduledOption = "All";
    this.isInitialVisitSelected = true;
    this.initialvisitStart = '';
    this.initialvisitEnd = '';

    this.filterWrapper.activeInactive = this.selectedActiveInactive;
    this.filterWrapper.studyList = [];
    this.filterWrapper.studyList.push(this.defaultStudy);
    this.filterWrapper.siteList = [];
    this.filterWrapper.siteList.push(this.defaultSite);
    this.filterWrapper.status = [];
    this.filterWrapper.status.push(this.defaultStatus);
    this.filterWrapper.source = this.sponser=='janssen' ? ["Principal Investigator", "Digital Recruitment"] : ["Referring Provider", "Principal Investigator", "Digital Recruitment"];
    this.filterWrapper.ageTo = this.ageStartValue;
    this.filterWrapper.ageFrom = this.ageEndValue;
    this.filterWrapper.ethnicityList = [];
    this.filterWrapper.sex = "";
    this.filterWrapper.highRisk = false;
    this.filterWrapper.highPriority = false;
    this.filterWrapper.comorbidities = false;
    this.filterWrapper.initialVisit = "All";
    this.filterWrapper.initialVisitStartDate = "";
    this.filterWrapper.initialVisitEndDate = "";
    this.filterWrapper.presetId = "";
    this.filterWrapper.presetName = "";
    this.isAnythingChangedForReset = true;

    this.template
    .querySelector('lightning-input[data-name="agestart"]')
    .setCustomValidity("");
    var temp = this.template
    .querySelector('lightning-input[data-name="agestart"]')
    .reportValidity();
    this.template
    .querySelector('lightning-input[data-name="datestart"]')
    .setCustomValidity("");
    this.template
    .querySelector('lightning-input[data-name="datestart"]')
        .reportValidity();
      this.isbuttonenabled = false;
      window.clearTimeout(this.delayTimeout);
  
      this.delayTimeout = setTimeout(this.setAgeValidity.bind(this), 50);
      
  }
  setAgeValidity(){
    this.template
      .querySelector('lightning-input[data-name="agestart"]')
      .reportValidity();
    this.template
      .querySelector('lightning-input[data-name="ageend"]')
      .reportValidity();
  }
  sendFilterUpdates(){
    if(this.filterClass=="edit"){
      this.filterPresetHandler();
      const updfilter = new CustomEvent("updfilter", {
      detail: {fw : this.filterWrapper,err:this.isbuttonenabled}
      });
      this.dispatchEvent(updfilter);
    }
    this.isAnythingChangedForReset = false;
  }
  handleCloseFilter(){
      const closefilter = new CustomEvent("closefilter", {
      detail: ''
      });
      this.dispatchEvent(closefilter);
  }

  createStatusOption(){

    if(this.defaultStudy != 'All Study'){
      if(this.selectedActiveInactive == 'Active'){
        if(this.studyToPrmoteDCT[this.defaultStudy] && this.studyToFinalStep[this.defaultStudy] == 'Randomization'){
          this.statusoptions = [
            { label: this.label.AllStatuses, value: "All Active Statuses" },
            { label: this.label.ReceivedStatus, value: "Received" },
            { label: this.label.PreReviewPassedStatus, value: "Pre-review Passed" },
            { label: this.label.ContactAttemptedStatus, value: "Contact Attempted" },
            { label: this.label.SuccessfullyContacted, value: "Successfully Contacted" },
            { label: this.label.Successfully_Re_Engaged , value: "Successfully re-engaged" },
            { label: this.label.ScreeningInProgress, value: "Screening In Progress" },
            {label: this.label.InWashOutPeriod, value: "Screening In Progress - Wash Out Period" },
            { label: this.label.ScreeningPassed, value: "Screening Passed" },
            { label: this.label.EligibilityPassed, value: "Eligibility Passed" },
            { label: this.label.Participant_No_Show, value: "Participant No Show" },
            { label: this.label.SentToDCT, value: "Sent to DCT" },
            { label: this.label.ReadytoScreen, value: "Ready to Screen" },
            { label: this.label.RandomizationSuccess, value: "Randomization Success" }
          ];
        }else if(!this.studyToPrmoteDCT[this.defaultStudy] && this.studyToFinalStep[this.defaultStudy] == 'Randomization'){
          this.statusoptions = [
            { label: this.label.AllStatuses, value: "All Active Statuses" },
            { label: this.label.ReceivedStatus, value: "Received" },
            { label: this.label.PreReviewPassedStatus, value: "Pre-review Passed" },
            { label: this.label.ContactAttemptedStatus, value: "Contact Attempted" },
            { label: this.label.SuccessfullyContacted, value: "Successfully Contacted" },
            { label: this.label.Successfully_Re_Engaged , value: "Successfully re-engaged" },
            { label: this.label.ScreeningInProgress, value: "Screening In Progress" },
            {label: this.label.InWashOutPeriod, value: "Screening In Progress - Wash Out Period" },
            { label: this.label.ScreeningPassed, value: "Screening Passed" },
            { label: this.label.EligibilityPassed, value: "Eligibility Passed" },
            { label: this.label.Participant_No_Show, value: "Participant No Show" },
            { label: this.label.ReadytoScreen, value: "Ready to Screen" },
            { label: this.label.RandomizationSuccess, value: "Randomization Success" }
          ];
            if(this.defaultStatus == 'Sent to DCT'){
              this.defaultStatus = 'All Active Statuses';
              this.selectedStatus = "All Active Statuses";
            }
        }else if(this.studyToPrmoteDCT[this.defaultStudy] && this.studyToFinalStep[this.defaultStudy] == 'Enrollment'){
          this.statusoptions = [
            { label: this.label.AllStatuses, value: "All Active Statuses" },
            { label: this.label.ReceivedStatus, value: "Received" },
            { label: this.label.PreReviewPassedStatus, value: "Pre-review Passed" },
            { label: this.label.ContactAttemptedStatus, value: "Contact Attempted" },
            { label: this.label.SuccessfullyContacted, value: "Successfully Contacted" },
            { label: this.label.Successfully_Re_Engaged , value: "Successfully re-engaged" },
            { label: this.label.ScreeningInProgress, value: "Screening In Progress" },
            {label: this.label.InWashOutPeriod, value: "Screening In Progress - Wash Out Period" },
            { label: this.label.ScreeningPassed, value: "Screening Passed" },
            { label: this.label.EnrollmentSuccess, value: "Enrollment Success" },
            { label: this.label.EligibilityPassed, value: "Eligibility Passed" },
            { label: this.label.Participant_No_Show, value: "Participant No Show" },
            { label: this.label.SentToDCT, value: "Sent to DCT" },
            { label:this.label.ReadytoScreen, value: "Ready to Screen" }
          ];
        }else if(!this.studyToPrmoteDCT[this.defaultStudy] && this.studyToFinalStep[this.defaultStudy] == 'Enrollment'){
          this.statusoptions = [
            { label: this.label.AllStatuses, value: "All Active Statuses" },
            { label: this.label.ReceivedStatus, value: "Received" },
            { label: this.label.PreReviewPassedStatus, value: "Pre-review Passed" },
            { label: this.label.ContactAttemptedStatus, value: "Contact Attempted" },
            { label: this.label.SuccessfullyContacted, value: "Successfully Contacted" },
            { label: this.label.Successfully_Re_Engaged , value: "Successfully re-engaged" },
            { label: this.label.ScreeningInProgress, value: "Screening In Progress" },
            {label: this.label.InWashOutPeriod, value: "Screening In Progress - Wash Out Period" },
            { label: this.label.ScreeningPassed, value: "Screening Passed" },
            { label: this.label.EnrollmentSuccess, value: "Enrollment Success" },
            { label: this.label.EligibilityPassed, value: "Eligibility Passed" },
            { label: this.label.Participant_No_Show, value: "Participant No Show" },
            { label: this.label.ReadytoScreen, value: "Ready to Screen" }
          ];
            if(this.defaultStatus == 'Sent to DCT'){
              this.defaultStatus = 'All Active Statuses';
              this.selectedStatus = "All Active Statuses";
            }
        }

      }else  if(this.selectedActiveInactive == 'Inactive'){
        if(this.studyToFinalStep[this.defaultStudy] == 'Randomization'){
          this.statusoptions = [
            { label: this.label.AllStatuses, value: "All Inactive Statuses" },
            { label: this.label.PrereviewFailed, value: "Pre-review Failed" },
            { label: this.label.UnabletoReach, value: "Unable to Reach" },
            {label: this.label.ContactedNotSuitable, value: "Contacted - Not Suitable" },
            { label: this.label.EligibilityFailed, value: "Eligibility Failed" },
            { label: this.label.DeclinedConsent, value: "Declined Consent" },
            { label: this.label.UnabletoScreen, value: "Unable to Screen" },
            { label: this.label.WithdrewConsent, value: "Withdrew Consent" },
            { label: this.label.ScreeningFailed, value: "Screening Failed" },
            {label: this.label.WithdrewConsentAfterScreening, value: "Withdrew Consent After Screening" },
            { label: this.label.Randomization_Failed, value: "Randomization Failed" },
            { label: this.label.DeclinedFinalConsent, value: "Declined Final Consent" }
          ];
        }else if(this.studyToFinalStep[this.defaultStudy] == 'Enrollment'){
          this.statusoptions = [
            { label: this.label.AllStatuses, value: "All Inactive Statuses" },
            { label: this.label.PrereviewFailed, value: "Pre-review Failed" },
            { label: this.label.UnabletoReach, value: "Unable to Reach" },
            {label: this.label.ContactedNotSuitable, value: "Contacted - Not Suitable" },
            { label: this.label.EligibilityFailed, value: "Eligibility Failed" },
            { label: this.label.DeclinedConsent, value: "Declined Consent" },
            { label: this.label.UnabletoScreen, value: "Unable to Screen" },
            { label: this.label.WithdrewConsent, value: "Withdrew Consent" },
            { label: this.label.ScreeningFailed, value: "Screening Failed" },
            {label: this.label.WithdrewConsentAfterScreening, value: "Withdrew Consent After Screening" },
            { label: this.label.Enrollment_Failed, value: "Enrollment Failed" },
            { label: this.label.DeclinedFinalConsent, value: "Declined Final Consent" }
          ];
        }
      }
    }else{
      if(this.selectedActiveInactive == 'Active'){
        this.statusoptions = [
          { label: this.label.AllStatuses, value: "All Active Statuses" },
          { label: this.label.ReceivedStatus, value: "Received" }, 
          { label: this.label.PreReviewPassedStatus, value: "Pre-review Passed" },
          { label: this.label.ContactAttemptedStatus, value: "Contact Attempted" },
          { label: this.label.SuccessfullyContacted, value: "Successfully Contacted" },
          { label: this.label.Successfully_Re_Engaged , value: "Successfully re-engaged" },
          { label: this.label.ScreeningInProgress, value: "Screening In Progress" },
          {label: this.label.InWashOutPeriod, value: "Screening In Progress - Wash Out Period" },
          { label: this.label.ScreeningPassed, value: "Screening Passed" },
          { label: this.label.EnrollmentSuccess, value: "Enrollment Success" },
          { label: this.label.Participant_No_Show, value: "Participant No Show" },
          { label: this.label.EligibilityPassed, value: "Eligibility Passed" },
          { label: this.label.SentToDCT, value: "Sent to DCT" },
          { label: this.label.ReadytoScreen, value: "Ready to Screen" },
          { label: this.label.RandomizationSuccess, value: "Randomization Success" }
        ];
      }else  if(this.selectedActiveInactive == 'Inactive'){
        this.statusoptions = [
          { label: this.label.AllStatuses, value: "All Inactive Statuses" },
          { label: this.label.PrereviewFailed, value: "Pre-review Failed" },
          { label: this.label.UnabletoReach, value: "Unable to Reach" },
          { label: this.label.ContactedNotSuitable, value: "Contacted - Not Suitable" },
          { label: this.label.EligibilityFailed, value: "Eligibility Failed" },
          { label: this.label.DeclinedConsent, value: "Declined Consent" },
          { label: this.label.UnabletoScreen, value: "Unable to Screen" },
          { label: this.label.WithdrewConsent, value: "Withdrew Consent" },
          { label: this.label.ScreeningFailed, value: "Screening Failed" },
          {label: this.label.WithdrewConsentAfterScreening, value: "Withdrew Consent After Screening" },
          { label: this.label.Enrollment_Failed, value: "Enrollment Failed" },
          { label: this.label.Randomization_Failed, value: "Randomization Failed" },
          { label: this.label.DeclinedFinalConsent, value: "Declined Final Consent" }
        ];
      }
    }
    
  }
}