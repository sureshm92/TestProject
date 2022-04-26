import { LightningElement, api, wire } from "lwc";
import getStudyStudySite from "@salesforce/apex/PIR_HomepageController.getStudyStudySite";

import { getPicklistValues } from "lightning/uiObjectInfoApi";
import ethinicity_field from "@salesforce/schema/Participant__c.Ethnicity__c";
import RH_Ethnicity from "@salesforce/label/c.RH_Ethnicity";

export default class Filtertest extends LightningElement {
  @api
  filterClass = 'filter-area';
  @api
  loaded = false;
  studylist;
  studyToStudySite;
  studySiteList;
  @api urlstudyid;
  @api urlsiteid;
  defaultStudy;
  defaultSite;
  selectedStudy;
  selectedSite;
  statusoptions;
  defaultStatus;
  selectedActiveInactive = 'Active';
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

  activeStatusList = [
    "Received",
    "Pre-review Passed",
    "Contact Attempted",
    "Successfully Contacted",
    "Screening In Progress",
    "Screening In Progress - Wash Out Period",
    "Screening Passed",
    "Enrollment Success",
    "Eligibility Passed",
    "Ready to Screen",
    "Randomization Success"
  ];
  inactiveStatusList = [
    "Pre-review Failed",
    "Unable to Reach",
    "Contacted - Not Suitable",
    "Eligibility Failed",
    "Declined Consent",
    "Unable to Screen",
    "Withdrew Consent",
    "Screening Failed",
    "Withdrew Consent After Screening",
    "Enrollment Failed",
    "Randomization Failed",
    "Declined Final Consent"
  ];

  // connectedCallback() {
  filterFetched = false;
  @api
  get filters(){ return true;}
  set filters(value){
    console.log('fiter val : ',JSON.stringify(value));
    console.log( Object.keys(value).length === 0);
    var presetSellection = value;
    
    if(!this.filterFetched){
      this.filterFetched= true;
      var scList = [
        "Referring Provider",
        "Principal Investigator",
        "Digital Recruitment"
      ];
      this.filterWrapper.source = scList;
      getStudyStudySite()
        .then((result) => {
          // console.log("Result $$$$$$$$", result);
          if (result.ctpMap) {
            var conts = result.ctpMap;
            let options = [];
            options.push({ label: "All Study", value: "All Study" });
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
            // console.log(picklist_Value);
            var conts1 = this.studyToStudySite;
            let options1 = [];
            options1.push({ label: "All Study Site", value: "All Study Site" });
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
              this.defaultSite = options1[1].value;
            }
            this.selectedSite = this.defaultSite;
            this.filterWrapper.siteList=[];
            this.filterWrapper.siteList.push(this.defaultSite);
          }
          this.loaded = !this.loaded;
          this.filterWrapper.status = [];
          this.filterWrapper.status.push('Received');
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

      this.statusoptions = [
        { label: "All Statuses", value: "All Active Statuses" },
        { label: "Received", value: "Received" },
        { label: "Pre-review Passed", value: "Pre-review Passed" },
        { label: "Contact Attempted", value: "Contact Attempted" },
        { label: "Successfully Contacted", value: "Successfully Contacted" },
        { label: "Screening In Progress", value: "Screening In Progress" },
        {
          label: "Screening In Progress - Wash Out Period",
          value: "Screening In Progress - Wash Out Period"
        },
        { label: "Screening Passed", value: "Screening Passed" },
        { label: "Enrollment Success", value: "Enrollment Success" },
        { label: "Eligibility Passed", value: "Eligibility Passed" },
        { label: "Ready to Screen", value: "Ready to Screen" },
        { label: "Randomization Success", value: "Randomization Success" }
      ];

      this.defaultStatus = this.selectedstatusvalue;
      this.selectedStatus = this.selectedstatusvalue;
    }
  }
  @api
  presetWrapperSet(presetSellection){
    this.selectedActiveInactive = presetSellection.activeInactive;

    if(presetSellection.source.length == 1){
      this.defaultSource = presetSellection.source[0];
    }else{
      this.defaultSource = 'All Sources';
    }
    
    this.ageStartValue = presetSellection.ageTo;
    this.ageEndValue = presetSellection.ageFrom;
    this.defaultSex = presetSellection.sex;
    this.defaultHighRisk = presetSellection.highRisk;
    this.defaultHighPriority = presetSellection.highPriority;
    this.defaultComorbidities = presetSellection.comorbidities;
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
    options.push({ label: "All Study Site", value: "All Study Site" });
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

    if (presetSellection.activeInactive == "Active") {
      this.statusoptions = [
        { label: "All Statuses", value: "All Active Statuses" },
        { label: "Received", value: "Received" },
        { label: "Pre-review Passed", value: "Pre-review Passed" },
        { label: "Contact Attempted", value: "Contact Attempted" },
        { label: "Successfully Contacted", value: "Successfully Contacted" },
        { label: "Screening In Progress", value: "Screening In Progress" },
        {
          label: "Screening In Progress - Wash Out Period",
          value: "Screening In Progress - Wash Out Period"
        },
        { label: "Screening Passed", value: "Screening Passed" },
        { label: "Enrollment Success", value: "Enrollment Success" },
        { label: "Eligibility Passed", value: "Eligibility Passed" },
        { label: "Ready to Screen", value: "Ready to Screen" },
        { label: "Randomization Success", value: "Randomization Success" }
      ];

      if(presetSellection.status.length == 1){
        this.defaultStatus = presetSellection.status[0];
        this.selectedStatus = presetSellection.status[0];
      }else{
        this.defaultStatus = "All Active Statuses";
        this.selectedStatus = "All Active Statuses";
      }

    } else if (presetSellection.activeInactive == "Inactive") {
      this.statusoptions = [
        { label: "All Statuses", value: "All Inactive Statuses" },
        { label: "Pre-review Failed", value: "Pre-review Failed" },
        { label: "Unable to Reach", value: "Unable to Reach" },
        {
          label: "Contacted - Not Suitable",
          value: "Contacted - Not Suitable"
        },
        { label: "Eligibility Failed", value: "Eligibility Failed" },
        { label: "Declined Consent", value: "Declined Consent" },
        { label: "Unable to Screen", value: "Unable to Screen" },
        { label: "Withdrew Consent", value: "Withdrew Consent" },
        { label: "Screening Failed", value: "Screening Failed" },
        {
          label: "Withdrew Consent After Screening",
          value: "Withdrew Consent After Screening"
        },
        { label: "Enrollment Failed", value: "Enrollment Failed" },
        { label: "Randomization Failed", value: "Randomization Failed" },
        { label: "Declined Final Consent", value: "Declined Final Consent" }
      ];

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
      for(var i=0;i<sysVal.length;i++){
          this.template.querySelector("input[value='"+sysVal[i]+"']").checked = true;
          this.fcsEth = false;   
          this.setEthinicityList();        
          this.template.querySelector(".eBox").blur();
      }
    }
    else{
      this.removeAllE();
    }
    this.filterWrapper = JSON.parse(JSON.stringify(presetSellection));

  }

  studyhandleChange(event) {
    var picklist_Value = event.target.value;
    this.defaultStudy = picklist_Value;
    // console.log(picklist_Value);
    var conts = this.studyToStudySite;
    let options = [];
    options.push({ label: "All Study Site", value: "All Study Site" });
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
  }

  studysiteshandleChange(event) {
    this.selectedSite = event.target.value;
    this.defaultSite = event.target.value;
  }

  applyFilter() {
    this.filterPresetHandler();
    const selectEvent = new CustomEvent("applyfilterevent", {
      detail: this.filterWrapper
    });
    this.dispatchEvent(selectEvent);
  }

  createPreset() {
    this.filterPresetHandler();
    console.log("filterWrapper before child" + JSON.stringify(this.filterWrapper));
    this.shoulddisplaypopup  = true;
  }
  closepresetmodel(event){
    this.shoulddisplaypopup  = false;
  }

  filterPresetHandler() {
    console.log("study " + this.selectedStudy);
    console.log("site " + this.selectedSite);
    console.log("selectedStatus " + this.selectedStatus);
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
    console.log("study " + filterStudy);
    console.log("site " + filterSite);
    console.log("filterStatus " + filterStatus);
    this.filterWrapper.studyList = filterStudy;
    this.filterWrapper.siteList = filterSite;
    this.filterWrapper.ethnicityList = [];
    for(var j=0; j<this.selectedEthinicity.length; j++){
      this.filterWrapper.ethnicityList.push(this.selectedEthinicity[j].value);
    }

    if (filterStatus == "All Active Statuses") {
      this.filterWrapper.status = this.activeStatusList;
    } else if (filterStatus == "All Inactive Statuses") {
      this.filterWrapper.status = this.inactiveStatusList;
    } else {
      this.filterWrapper.status = [];
      this.filterWrapper.status.push(filterStatus);
    }
    console.log("filterWrapper: " + JSON.stringify(this.filterWrapper));
  }

  get activeoptions() {
    return [
      { label: "Active", value: "Active" },
      { label: "Inactive", value: "Inactive" }
    ];
  }

  activehandleChange(event) {
    var selectedMode = event.target.value;
    this.selectedActiveInactive = selectedMode;
    if (selectedMode == "Active") {
      this.statusoptions = [
        { label: "All Statuses", value: "All Active Statuses" },
        { label: "Received", value: "Received" },
        { label: "Pre-review Passed", value: "Pre-review Passed" },
        { label: "Contact Attempted", value: "Contact Attempted" },
        { label: "Successfully Contacted", value: "Successfully Contacted" },
        { label: "Screening In Progress", value: "Screening In Progress" },
        {
          label: "Screening In Progress - Wash Out Period",
          value: "Screening In Progress - Wash Out Period"
        },
        { label: "Screening Passed", value: "Screening Passed" },
        { label: "Enrollment Success", value: "Enrollment Success" },
        { label: "Eligibility Passed", value: "Eligibility Passed" },
        { label: "Ready to Screen", value: "Ready to Screen" },
        { label: "Randomization Success", value: "Randomization Success" }
      ];

      this.defaultStatus = "All Active Statuses";
      this.selectedStatus = "All Active Statuses";
    } else if (selectedMode == "Inactive") {
      this.statusoptions = [
        { label: "All Statuses", value: "All Inactive Statuses" },
        { label: "Pre-review Failed", value: "Pre-review Failed" },
        { label: "Unable to Reach", value: "Unable to Reach" },
        {
          label: "Contacted - Not Suitable",
          value: "Contacted - Not Suitable"
        },
        { label: "Eligibility Failed", value: "Eligibility Failed" },
        { label: "Declined Consent", value: "Declined Consent" },
        { label: "Unable to Screen", value: "Unable to Screen" },
        { label: "Withdrew Consent", value: "Withdrew Consent" },
        { label: "Screening Failed", value: "Screening Failed" },
        {
          label: "Withdrew Consent After Screening",
          value: "Withdrew Consent After Screening"
        },
        { label: "Enrollment Failed", value: "Enrollment Failed" },
        { label: "Randomization Failed", value: "Randomization Failed" },
        { label: "Declined Final Consent", value: "Declined Final Consent" }
      ];

      this.defaultStatus = "All Inactive Statuses";
      this.selectedStatus = "All Inactive Statuses";
    }
    this.filterWrapper.activeInactive = selectedMode;
  }

  statushandleChange(event) {
    this.selectedStatus = event.target.value;
    this.defaultStatus = event.target.value;
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
    }

    this.filterWrapper.initialVisit = event.target.value;
    this.ininialvisitScheduledOption = event.target.value;
  }

  handleInitialVisitStartDateChange(event) {
    this.initialvisitStart = event.target.value;
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
    this.template
      .querySelector('lightning-input[data-name="datestart"]')
      .reportValidity();
  }

  handleInitialVisitEndDateChange(event) {
    this.initialvisitEnd = event.target.value;
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
    this.template
      .querySelector('lightning-input[data-name="datestart"]')
      .reportValidity();
  }

  handleAgeStartChange(event) {
    this.ageStartValue = event.target.value;
    var a1 = this.ageStartValue;
    var a2 = this.ageEndValue;

    if (Number(a1) > Number(a2)) {
      this.template
        .querySelector('lightning-input[data-name="agestart"]')
        .setCustomValidity("Invalid Age Range");
      this.isbuttonenabled = true;
    } else {
      this.template
        .querySelector('lightning-input[data-name="agestart"]')
        .setCustomValidity("");
      this.isbuttonenabled = false;
      this.filterWrapper.ageTo = a1;
    }
    this.template
      .querySelector('lightning-input[data-name="agestart"]')
      .reportValidity();
  }

  handleAgeEndChange(event) {
    this.ageEndValue = event.target.value;
    var a1 = this.ageStartValue;
    var a2 = this.ageEndValue;
    if (Number(a1) > Number(a2)) {
      this.template
        .querySelector('lightning-input[data-name="agestart"]')
        .setCustomValidity("Invalid Age Range");
      this.isbuttonenabled = true;
    } else {
      this.template
        .querySelector('lightning-input[data-name="agestart"]')
        .setCustomValidity("");
      this.isbuttonenabled = false;
      this.filterWrapper.ageFrom = a2;
    }
    this.template
      .querySelector('lightning-input[data-name="agestart"]')
      .reportValidity();
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
  }

  sexatbirthhandleChange(event) {
    var sex = event.target.value;
    if (sex != "All") {
      this.filterWrapper.sex = sex;
      this.defaultSex = sex;
    }
  }

  handleHighRisk(event) {
    this.filterWrapper.highRisk = event.target.checked;
    this.defaultHighRisk = event.target.checked;
  }

  handleHighPriority(event) {
    this.filterWrapper.highPriority = event.target.checked;
    this.defaultHighPriority = event.target.checked;
  }

  handleComorbidities(event) {
    this.filterWrapper.comorbidities = event.target.checked;
    this.defaultComorbidities = event.target.checked;
  }

  get sourceoptions() {
    
    return [
      { label: "All Sources", value: "All Sources" },
      { label: "Referring Provider", value: "Referring Provider" },
      { label: "Principal Investigator", value: "Principal Investigator" },
      { label: "Digital Recruitment", value: "Digital Recruitment" }
    ];
  }

  get sexatbirthoptions() {
    return [
      { label: "All", value: "All" },
      { label: "Male", value: "M" },
      { label: "Female", value: "F" }
    ];
  }

  get initialvisitoptions() {
    return [
      { label: "All", value: "All" },
      { label: "Initial Visit Scheduled", value: "Initial Visit Scheduled" },
      {
        label: "Initial Visit Not Scheduled",
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
  }

  resetFilter(event){
    this.selectedActiveInactive = this.activeoptions[0].value;
    this.defaultStudy = this.studylist[1].value;
    this.selectedStudy = this.defaultStudy;
    var conts = this.studyToStudySite;
    let options = [];
    options.push({ label: "All Study Site", value: "All Study Site" });
      for (var key in conts) {
        if (key == this.defaultStudy) {
          var temp = conts[key];
          for (var j in temp) {
            options.push({ label: temp[j].Name, value: temp[j].Id });
          }
        }
      }

    this.studySiteList = options;
    this.defaultSite = this.studySiteList[1].value;
    this.selectedSite = this.defaultSite;

    this.statusoptions = [
      { label: "All Statuses", value: "All Active Statuses" },
      { label: "Received", value: "Received" },
      { label: "Pre-review Passed", value: "Pre-review Passed" },
      { label: "Contact Attempted", value: "Contact Attempted" },
      { label: "Successfully Contacted", value: "Successfully Contacted" },
      { label: "Screening In Progress", value: "Screening In Progress" },
      {
        label: "Screening In Progress - Wash Out Period",
        value: "Screening In Progress - Wash Out Period"
      },
      { label: "Screening Passed", value: "Screening Passed" },
      { label: "Enrollment Success", value: "Enrollment Success" },
      { label: "Eligibility Passed", value: "Eligibility Passed" },
      { label: "Ready to Screen", value: "Ready to Screen" },
      { label: "Randomization Success", value: "Randomization Success" }
    ];

    this.defaultStatus = this.statusoptions[1].value;
    this.selectedStatus = this.statusoptions[1].value;
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
    this.filterWrapper.source = ["Referring Provider", "Principal Investigator", "Digital Recruitment"];
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

  }
}