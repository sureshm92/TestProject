import { LightningElement, api } from "lwc";
import getStudyStudySite from "@salesforce/apex/PIR_HomepageController.getStudyStudySite";

export default class Filtertest extends LightningElement {
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
  selectedStatus;
  @api selectedstatusvalue;

  connectedCallback() {
    getStudyStudySite()
      .then((result) => {
        // console.log("Result $$$$$$$$", result);
        if (result.ctpMap) {
          var conts = result.ctpMap;
          let options = [];
          for (var key in conts) {
            options.push({ label: key, value: conts[key] });
          }
          this.studylist = options;
          if(this.urlstudyid != null){
            this.defaultStudy = this.urlstudyid;
          }else{
            this.defaultStudy = options[0].value;
          }
          
        }

        if (result.studySiteMap) {
          this.studyToStudySite = result.studySiteMap;
          var picklist_Value = this.defaultStudy;
          // console.log(picklist_Value);
          var conts1 = this.studyToStudySite;
          let options1 = [];
          for (var key in conts1) {
            if (key == picklist_Value) {
              var temp = conts1[key];
              for (var j in temp) {
                options1.push({ label: temp[j].Name, value: temp[j].Id });
              }
            }
          }
          this.studySiteList = options1;
          this.defaultSite = this.urlsiteid;
        }
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
        { label: "Screening In Progress - Wash Out Period", value: "Screening In Progress - Wash Out Period" },
        { label: "Screening Passed", value: "Screening Passed" },
        { label: "Enrollment Success", value: "Enrollment Success" },
        { label: "Eligibility Passed", value: "Eligibility Passed" },
        { label: "Ready to Screen", value: "Ready to Screen" },
        { label: "Randomization Success", value: "Randomization Success" }
      ];

      this.defaultStatus = this.selectedstatusvalue;
      this.selectedStatus = this.selectedstatusvalue;
      
  }

  studyhandleChange(event) {
    var picklist_Value = event.target.value;
    // console.log(picklist_Value);
    var conts = this.studyToStudySite;
    let options = [];
    for (var key in conts) {
      if (key == picklist_Value) {
          var temp = conts[key];
        for (var j in temp) {
          options.push({ label: temp[j].Name, value: temp[j].Id });
        }
      }
    }
    this.studySiteList = options;
    this.selectedStudy = picklist_Value;
  }

  studysiteshandleChange(event){
    this.selectedSite = event.target.value;
  }

  applyFilter(){
      console.log('study ' +this.selectedStudy);
      console.log('site ' +this.selectedSite);
      console.log('selectedStatus ' +this.selectedStatus);
      var filterStudy = (this.selectedStudy != null ? this.selectedStudy : this.defaultStudy);
      var filterSite = (this.selectedSite != null ? this.selectedSite : this.defaultSite);
      var filterStatus = (this.selectedStatus != null ? this.selectedStatus : this.defaultStatus);
      console.log('study ' +filterStudy);
    const selectEvent = new CustomEvent('applyfilterevent', {
        detail: {
            selectedStudy : filterStudy,
            selectedSite : filterSite,
            selectedStatus : filterStatus
        }
    });
   this.dispatchEvent(selectEvent);
  }

  get activeoptions() {
    return [
      { label: "Active", value: "Active" },
      { label: "Inactive", value: "Inactive" }
    ];
  }

  activehandleChange(event){
    var selectedMode = event.target.value;
    if(selectedMode == 'Active'){
      this.statusoptions = [
        { label: "All Statuses", value: "All Active Statuses" },
        { label: "Received", value: "Received" },
        { label: "Pre-review Passed", value: "Pre-review Passed" },
        { label: "Contact Attempted", value: "Contact Attempted" },
        { label: "Successfully Contacted", value: "Successfully Contacted" },
        { label: "Screening In Progress", value: "Screening In Progress" },
        { label: "Screening In Progress - Wash Out Period", value: "Screening In Progress - Wash Out Period" },
        { label: "Screening Passed", value: "Screening Passed" },
        { label: "Enrollment Success", value: "Enrollment Success" },
        { label: "Eligibility Passed", value: "Eligibility Passed" },
        { label: "Ready to Screen", value: "Ready to Screen" },
        { label: "Randomization Success", value: "Randomization Success" }
      ];

      this.defaultStatus = 'All Active Statuses';
      this.selectedStatus = 'All Active Statuses';

    }else if(selectedMode == 'Inactive'){
      this.statusoptions = [
        { label: "All Statuses", value: "All Inactive Statuses" },
        { label: "Pre-review Failed", value: "Pre-review Failed" },
        { label: "Unable to Reach", value: "Unable to Reach" },
        { label: "Contacted - Not Suitable", value: "Contacted - Not Suitable" },
        { label: "Eligibility Failed", value: "Eligibility Failed" },
        { label: "Declined Consent", value: "Declined Consent" },
        { label: "Unable to Screen", value: "Unable to Screen" },
        { label: "Withdrew Consent", value: "Withdrew Consent" },
        { label: "Screening Failed", value: "Screening Failed" },
        { label: "Withdrew Consent After Screening", value: "Withdrew Consent After Screening" },
        { label: "Enrollment Failed", value: "Enrollment Failed" },
        { label: "Randomization Failed", value: "Randomization Failed" },
        { label: "Declined Final Consent", value: "Declined Final Consent" }
      ];

      this.defaultStatus = 'All Inactive Statuses';
      this.selectedStatus = 'All Inactive Statuses';
    }
  }

  statushandleChange(event){
    this.selectedStatus = event.target.value;
  }

  get sourceoptions() {
    return [
      { label: "All", value: "All" },
      { label: "Study 12351254", value: "Study 12351254" },
      { label: "Study 12351254745", value: "Study 12351254575" }
    ];
  }
  get ethnicityoptions() {
    return [
      { label: "All", value: "All" },
      { label: "Study 12351254", value: "Study 12351254" },
      { label: "Study 12351254745", value: "Study 12351254575" }
    ];
  }
  get sexatbirthoptions() {
    return [
      { label: "Male", value: "Male" },
      { label: "female", value: "female" }
    ];
  }
  get sexatbirthoptions() {
    return [
      { label: "All", value: "All" },
      { label: "Study 12351254", value: "Study 12351254" },
      { label: "Study 12351254745", value: "Study 12351254575" }
    ];
  }
  get initialvisitoptions() {
    return [
      { label: "All", value: "All" },
      { label: "Study 12351254", value: "Study 12351254" },
      { label: "Study 12351254745", value: "Study 12351254575" }
    ];
  }
}