import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getRecievedHistory from "@salesforce/apex/PIR_StatusDetailController.getRecievedHistory";
import getContactHistory from "@salesforce/apex/PIR_StatusDetailController.getContactHistory";
import getInitialVisitHistory from "@salesforce/apex/PIR_StatusDetailController.getInitialVisitHistory";
import getEligibilityHistory from "@salesforce/apex/PIR_StatusDetailController.getEligibilityHistory";
import getScreeningHistory from "@salesforce/apex/PIR_StatusDetailController.getScreeningHistory";
import getEnrollmentHistory from "@salesforce/apex/PIR_StatusDetailController.getEnrollmentHistory";
import doSaveStatusDetails from "@salesforce/apex/PIR_StatusDetailController.doSaveStatusDetails";
import { label } from "c/pir_label";
export default class Pir_participantSubStatusFields extends LightningElement {
  @api index = "";
  @api outcomeToReasonMap = {};
  @api visitplanoptions = {};
  @api outcomeValues = {};
  @api groupStatus = "Received";
  @api currentitems;
  @api peid = "";
  @api historyResults = [];
  @track utilLabels = label;
  @api historyNull = false;
  @api groupname = "";
  @api isinitialvisit = false;
  @api grpicons = "";
  @api isinitialvisitpresent = false;
  @api pe_record;
  @api scduledtime;
  selectedOutcome = "";
  selectedOutcomeIV = "";
  @track selectedvisitplan;
  selectedreason = "";
  selectedreasonIV = "";
  @api initialvisitsctime = "";
  @api isfinalconsentrequired = false;
  @api isvprequired = false;
  @api selectedPlan = "";
  @api isModalOpen = false;
  @api isfovNull = false;
  @api reVisitDt = "";
  @api plan = "";
  @api currentuserdate = "";  

  changeInputValue(event) {
    let datavalue = event.target.dataset.value;

    if (event.target.dataset.value === "sitePreference") {
      this.participantrecord.Site_Communication_Preference__c =
        event.target.checked;
    } else if (event.target.dataset.value === "Reason") {
      if(event.target.value == null || event.target.value == ' '){
        this.participantrecord.Non_Enrollment_Reason__c = '';
        this.selectedreason = '';
        if (this.selectedOutcomeIV == "Declined_Consent") {
          if (this.selectedreason == "PWS_Picklist_Value_Other") {
            this.selectedreasonIV = "PWS_Picklist_Value_Other";
          } else {
            this.selectedreasonIV = event.target.value;
          }
        }
      }else{
        this.participantrecord.Non_Enrollment_Reason__c = event.target.value;
        this.selectedreason = event.target.value;
        if (this.selectedOutcomeIV == "Declined_Consent") {
          if (this.selectedreason == "PWS_Picklist_Value_Other") {
            this.selectedreasonIV = "PWS_Picklist_Value_Other"; 
          } else {
            this.selectedreasonIV = event.target.value;
          }
        }
      }
    } else if (event.target.dataset.value === "InitialVisitDate") {
      this.participantrecord.Initial_visit_scheduled_date__c =
        event.target.value;
    } else if (event.target.dataset.value === "InitialVisitTime") {
      this.participantrecord.Initial_visit_scheduled_time__c =
        event.target.value;
        this.customButtonValidation();
    } else if (event.target.dataset.value === "additionalNotes") {
      this.additionalNote = event.target.value;
      this.customButtonValidation();
    } else if (event.target.dataset.value === "additionalNotesIV") {
      this.additionalNoteIV = event.target.value;
      this.customButtonValidation();
    } else if (event.target.dataset.value === "screeningID") {
      this.participantrecord.IVRS_IWRS__c = event.target.value;
    } else if (event.target.dataset.value === "RevisitDate") {
      this.participantrecord.Revisit_Date__c = event.target.value;
      this.reVisitDt = event.target.value;
      this.customButtonValidation();
    } else if (event.target.dataset.value === "SignedDate") {
      this.participantrecord.Informed_Consent_Date__c = event.target.value;
      this.customButtonValidation();
    } else if (event.target.dataset.value === "AttentedDate") {
      this.participantrecord.Initial_visit_occurred_date__c =
        event.target.value;
    } else if (event.target.dataset.value === "RunInWashOut") {
      if (event.target.value == "Yes") {
        this.participantrecord.Washout_Run_In_Applies__c = true;
        this.runinwashout = "Yes";
        this.customButtonValidation();
      } else {
        this.participantrecord.Washout_Run_In_Applies__c = false;
        this.runinwashout = "No";
        this.reVisitDt = "";
        delete this.participantrecord.Revisit_Date__c;
        this.customButtonValidation();
      }
    } else if (event.target.dataset.value === "InitialVisitAttended") {
      if (event.target.value == "Yes") {
        this.participantrecord.Initial_visit_occurred_flag__c = true;
        this.initialvisitattended = "Yes";
        this.customFieldValidation(datavalue);
        //this.participantrecord.Initial_visit_occurred_date__c = this.todaydate();
        this.participantrecord.Initial_visit_occurred_date__c = this.currentuserdate;
        this.participantrecord.ParticipantNoShow__c = false;
        if (this.selectedOutcomeIV != "BTN_Yes") {
          this.customFieldValidation("Consent Signed");
        }
        if (
          this.participantrecord.Informed_Consent__c &&
          this.participantrecord.Initial_visit_scheduled_date__c != null &&
          this.participantrecord.Initial_visit_scheduled_date__c != "" &&
          this.pe_record.Participant_Status__c != "Ready to Screen"
        ) { 
          this.participantrecord.Participant_Status__c = "Ready to Screen";
          this.participantrecord.Non_Enrollment_Reason__c = ''; 
        }else{
          delete this.participantrecord.Participant_Status__c;  
        }
      } else {
        this.participantrecord.Initial_visit_occurred_flag__c = false;
        this.initialvisitattended = "No";
        this.customFieldValidation(datavalue);
        delete this.participantrecord.Initial_visit_occurred_date__c;
        if (this.selectedOutcomeIV != "BTN_Yes") {
          this.customFieldValidation("Consent Signed"); 
        }
        if(this.participantrecord.Participant_Status__c == "Ready to Screen"){
          delete this.participantrecord.Participant_Status__c;  
        }
      }
    } else if (event.target.dataset.value === "EnrollmentID") {
      this.participantrecord.Screening_ID__c = event.target.value;
      this.customButtonValidation();
    } else if (event.target.dataset.value === "RandomizationID") {
      this.participantrecord.Screening_ID__c = event.target.value;
      this.customButtonValidation();
    } else if (event.target.dataset.value === "FinalConsent") {
      this.participantrecord.Final_consent__c = event.target.checked;
      this.customButtonValidation();
      if (event.target.checked) {
        this.customFieldValidation("FinalConsent");
      }
    } else if (event.target.dataset.value === "VisitPlan") {
      this.participantrecord.Visit_Plan__c = event.target.value;
      this.plan = event.target.value;
      this.customButtonValidation();
      this.customFieldValidation("VisitPlan");
    } else if (event.target.dataset.value === "PartcipantNoShow") {
      this.participantrecord.ParticipantNoShow__c = event.target.checked;
      
    }
    this.isdataChanged();
  }

  customFieldValidation(dataValue) {
    let element = this.template.querySelector(
      '[data-value="' + dataValue + '"]'
    );
    let fieldValue = element.value;
    let fieldLabel = element.label;
    let fieldname = element.name;
    if (fieldname == "Initial Visit Attended") {
      if (this.initialvisitattended == "No") {
        element.setCustomValidity("Initial Visit required before Screening");
        element.reportValidity();
      } else {
        element.setCustomValidity("");
        element.reportValidity();
      }
    }
    if (fieldname == "ConsentSigned") {
      if (this.selectedOutcomeIV != "BTN_Yes") {
        if(!this.pe_record.Informed_Consent__c){
          element.setCustomValidity("Consent required before Screening");
          element.reportValidity();
        }
      } else {
        element.setCustomValidity("");
        element.reportValidity();
      }
    }
    if (fieldname == "FinalConsent") {
      if (this.participantrecord.Final_consent__c) {
        element.setCustomValidity("");
        element.reportValidity();
      }
    }
    if (fieldname == "VisitPlan") {
      if (this.plan != null && this.plan != "") {
        element.setCustomValidity("");
        element.reportValidity();
      }
    }
    if (fieldname == "ScreeningOutcome") {
      element.setCustomValidity(
        "On Initial Visit tab, update informed consent date (add a note if date is same as initial date of consent) and save to proceed with screening"
      );
      element.reportValidity();
    }
  }

  get isReceived() {
    if (this.currentitems.index == 0) {
      return true;
    } else {
      return false;
    }
  }

  get isContact() {
    if (this.currentitems.index == 1) {
      return true;
    } else {
      return false;
    }
  }

  get isInitialvist() {
    if (
      this.currentitems.index == 2 &&
      this.groupname != "PWS_Eligibility_Card_Name"
    ) {
      return true;
    } else {
      return false;
    }
  }

  get isEligibility() {
    if (
      this.currentitems.index == 2 &&
      this.groupname == "PWS_Eligibility_Card_Name"
    ) {
      return true;
    } else {
      return false;
    }
  }

  get isScreening() {
    if (this.currentitems.index == 3) {
      return true;
    } else {
      return false;
    }
  }

  get isEnrolled() {
    if (
      this.currentitems.index == 4 &&
      this.groupname != "PWS_Randomization_Card_Name"
    ) {
      return true;
    } else {
      return false;
    }
  }

  get isRandomized() {
    if (
      this.currentitems.index == 4 &&
      this.groupname == "PWS_Randomization_Card_Name"
    ) {
      return true;
    } else {
      return false;
    }
  }
  get isconsentSigned() {
    if (
      this.pe_record.Participant_Status__c == "Withdrew Consent" ||
      this.pe_record.Participant_Status__c == "Declined Consent"
    ) {
      return false;
    } else {
      return this.pe_record.Informed_Consent__c;
    }
  }
  get isconsentSignedPlaceholder() {
    if (this.pe_record.Participant_Status__c == "Withdrew Consent") {
      return " ";
    } else if (this.pe_record.Informed_Consent__c) {
      return this.utilLabels.BTN_Yes;
    } else {
      return " ";
    }
  }
  reasoneoptions = [];
  outcomeoptions = [];
  participantrecord;
  additionalNote = "";
  @api runinwashout = "";
  statusChanged = false;
  @api initialvisitattended = "";
  additionalNoteIV = "";
  @api consentSigned = false;
  notesNeeded = [];
  @api
  get setOpt() {
    return this.outcomeoptions;
  }
  set setOpt(value) {
    this.reasoneoptions = [];
    this.outcomeoptions = [];
    this.selectedOutcome = "";
    this.selectedOutcomeIV = "";
    this.selectedreason = "";
    this.selectedreasonIV = "";
    this.additionalNote = "";
    this.additionalNoteIV = "";
    this.notesNeeded = [];
    this.statusChanged = false;
    this.participantrecord = JSON.parse(JSON.stringify(this.pe_record));
    this.consentSigned = this.pe_record.Informed_Consent__c;
    this.reVisitDt = this.participantrecord.Revisit_Date__c;


    if (this.participantrecord.Washout_Run_In_Applies__c) {
      this.runinwashout = "Yes";
    } else {
      this.runinwashout = "No";
    }
    if (this.participantrecord.Initial_visit_occurred_flag__c) {
      this.initialvisitattended = "Yes";
    } else {
      this.initialvisitattended = "No";
    }

    this.setOutcomeOptions();
  }
  renderedCallback(){
    if(this.currentitems.index == 3){
      if(this.pe_record.Clinical_Trial_Profile__r.Initial_Visit_Required__c){
        if(this.pe_record.Participant_Status__c == "Withdrew Consent"){
          let datavalue = "ScreeningOutcome";
          let element = this.template.querySelector(
            '[data-value="' + datavalue + '"]'
          );
          element.setCustomValidity("On Initial Visit tab, update informed consent date(add a note if date is same as initial date of consent) and save to proceed with screening.");  
          element.reportValidity();
        }
        if(this.pe_record.Participant_Status__c == "Declined Consent"){
          let datavalue = "ScreeningOutcome";
          let element = this.template.querySelector(
            '[data-value="' + datavalue + '"]'
          );
          element.setCustomValidity("On Initial Visit tab, update informed consent to "+'"'+'Yes'+'"'+" and save to proceed with screening");  
          element.reportValidity();
        }
      }
    }
}
  get checkContactStatus() {
    if (this.grpicons == "success") {
      if (this.isinitialvisit) {
        if (this.isinitialvisitpresent || (this.pe_record.Informed_Consent__c && this.pe_record.Initial_visit_occurred_flag__c)) {
          return false;
        } else {
            if(this.pe_record.Participant_Status__c == 'Declined Consent'){
              return false;
            }else{
              return true;
            }
        }
      } else {
        return false;
      }
    } else if (this.grpicons == "failure") {
      return true;
    } else if (this.grpicons == "inProgress") {
      return true;
    } else {
      return false;
    }
  }
  get checkEligibilityStatus() {
    if (this.grpicons == "success") {
      return false;
    } else if (this.grpicons == "failure") {
      return true;
    } else if (this.grpicons == "inProgress") {
      return true;
    } else {
      return false;
    }
  }
  get checkScreeningStatus() {
    if (this.grpicons == "success") {
      return false;
    } else if (this.grpicons == "failure") {
      return true;
    } else if (this.grpicons == "inProgress") {
      return true;
    } else {
      return false;
    }
  }
  get disableRevisitdt() {
    if (this.runinwashout == "Yes") {
      return false;
    } else {
      return true;
    }
  }
  get disableAttendeddt() {
    if (this.initialvisitattended == "Yes") {
      return false;
    } else {
      return true;
    }
  }
  get consentSignedDate() {
    if (this.selectedOutcomeIV == "Withdrew_Consent") {
      return true;
    } else if (this.selectedOutcomeIV == "Declined_Consent") {
      return true;
    } else if (this.selectedOutcomeIV == "BTN_Yes") {
      return false;
    } else if (this.pe_record.Informed_Consent__c) {
      return false;
    } else {
      return true;
    }
  }
  get isinitialvisitattended() {
    if (this.initialvisitattended == "Yes") {
      return true;
    } else {
      return false;
    }
  }
  get isOnlyVisitPlan() {
    if (this.isvprequired && !this.isfinalconsentrequired) {
      return true;
    } else {
      return false;
    }
  }
  get isOnlyFinalConsent() {
    if (!this.isvprequired && this.isfinalconsentrequired) {
      return true;
    } else {
      return false;
    }
  }
  get isVisitPlanAndFinalConsentRequired() {
    if (this.isfinalconsentrequired && this.isvprequired) {
      return true;
    } else {
      return false;
    }
  }
  get isVisitPlanAndFinalConsentNotRequired() {
    if (!this.isfinalconsentrequired && !this.isvprequired) {
      return true;
    } else {
      return false;
    }
  }
  get screeningPlaceholder() {
    if (
      this.participantrecord.Clinical_Trial_Profile__r.Initial_Visit_Required__c
    ) {
      if(this.pe_record.Participant_Status__c == "Withdrew Consent"){
        return "Not Selected";  
      } else if (this.pe_record.Participant_Status__c == "Declined Consent") {
        return this.utilLabels.Declined_Consent;
      } else if(this.pe_record.Participant_Status__c == "Ready to Screen"){
        return this.utilLabels.Ready_to_Screen;
      }else{
        return "Not Selected";
      }
    } else {
      return "Not Selected";
    }

  }
  get checkOldStatus() {
    if(this.pe_record.Clinical_Trial_Profile__r.Initial_Visit_Required__c){
      if (
        this.pe_record.Participant_Status__c == "Withdrew Consent" ||
        this.pe_record.Participant_Status__c == "Declined Consent"
      ) {
        return true;
      } else {
        return false;
      }
    }else{
        // if (
        //   this.pe_record.Participant_Status__c == "Withdrew Consent" ||
        //   this.pe_record.Participant_Status__c == "Declined Consent"
        // ) {
        //   return false;
        // } else {
        //   return false;
        // }
        return false;
    }
    
  }
  get checkOutcome() {
    if (this.selectedOutcomeIV == "Declined_Consent") {
      return true;
    } else {
      return false;
    }
  }
  get signedReasonPlaceHolder() {
    if (this.selectedOutcomeIV == "Declined_Consent") {
      return "Select...";
    } else if (this.selectedOutcomeIV == "Withdrew_Consent") {
      if (this.selectedreasonIV == null || this.selectedreasonIV == "") {
        return " ";
      } else {
        return this.pe_record.Non_Enrollment_Reason__c;
      }
    } else {
      return " ";
    }
  }
  setOutcomeOptions() {
    let objKeys = Object.keys(this.outcomeToReasonMap);
    let opts = this.createopts(objKeys);
    /*if( this.selectedOutcome == '' && opts.length>0){
            this.selectedOutcome = objKeys[0];
            this.reasoneoptions = this.createopts(this.outcomeToReasonMap[this.selectedOutcome]);
            if(this.reasoneoptions.length > 0){
                 this.selectedreason = this.reasoneoptions[0].label;
            }
        } */
    let trans_opts = [];
    if(this.pe_record.Clinical_Trial_Profile__r.Initial_Visit_Required__c){
          if (this.pe_record.Participant_Status__c == "Withdrew Consent") {
          //this.customFieldValidation('ScreeningOutcome');
          trans_opts.push({
            label: this.utilLabels.PWS_Picklist_Value_Withdrew,
            value: "Withdrew_Consent"
          });
          trans_opts.push({ label: this.utilLabels.BTN_Yes, value: "BTN_Yes" });
          //this.selectedreason = this.pe_record.Non_Enrollment_Reason__c;
          let withdrewReasons = {'Transportation Issues':'PWS_Picklist_Value_Transportation_Issues',
                                  'Childcare Issues':'PWS_Picklist_Value_Childcare_Issues',
                                  'Protocol Concerns':'PWS_Picklist_Value_Protocol_Concerns',
                                  'Participant Not Interested':'PWS_Picklist_Value_Participant_Not_Interested',
                                  'Other':'PWS_Picklist_Value_Other'
                                };
          this.selectedreasonIV = withdrewReasons[this.pe_record.Non_Enrollment_Reason__c]; 
          this.selectedOutcomeIV = "Withdrew_Consent";
        } else if (this.pe_record.Participant_Status__c == "Declined Consent") {
          for (let i = 0; i < opts.length; i++) {
            if (opts[i].label === "BTN_Yes") {
              trans_opts.push({
                label: this.utilLabels.BTN_Yes,
                value: opts[i].value
              });
            } else if (opts[i].label === "Declined_Consent") {
              trans_opts.push({
                label: this.utilLabels.PIR_Declined,
                value: opts[i].value
              });
            }
          }
          this.selectedOutcomeIV = "Declined_Consent";
          let reasonopts = this.createopts(
            this.outcomeToReasonMap[this.selectedOutcomeIV]
          );
          let trans_reasonopts = [];
          for (let i = 0; i < reasonopts.length; i++) {
            let outcomeReasonLabel = reasonopts[i].label;
            let outcomeReasonValue = reasonopts[i].value;
            if (outcomeReasonValue.endsWith("*")) {
              outcomeReasonLabel = outcomeReasonLabel.substring(
                0,
                outcomeReasonLabel.length - 1
              );
              outcomeReasonValue = outcomeReasonValue.substring(
                0,
                outcomeReasonValue.length - 1
              );
                if(outcomeReasonLabel.length != 1){
                  this.notesNeeded.push(outcomeReasonValue);
                }else{
                  this.notesNeeded.push('BLANK');
                }
            }
            trans_reasonopts.push({
              label: this.utilLabels[outcomeReasonLabel],
              value: outcomeReasonValue
            });
          }
          this.reasoneoptions = trans_reasonopts;
          let declinedReasons = {'Transportation Issues':'PWS_Picklist_Value_Transportation_Issues',
            'Childcare Issues':'PWS_Picklist_Value_Childcare_Issues',
            'Protocol Concerns':'PWS_Picklist_Value_Protocol_Concerns',
            'Participant Not Interested':'PWS_Picklist_Value_Participant_Not_Interested',
            'Other':'PWS_Picklist_Value_Other'
          };
          this.selectedreasonIV = declinedReasons[this.pe_record.Non_Enrollment_Reason__c];
        } else {
          for (let i = 0; i < opts.length; i++) {
            if (opts[i].label === "Screening In Progress - Wash Out Period") {
              trans_opts.push({
                label: this.utilLabels.In_Wash_Out_Period,
                value: "Screening In Progress - Wash Out Period"
              });
            } else if (opts[i].label === "Declined_Consent") {
              trans_opts.push({
                label: this.utilLabels.PIR_Declined,
                value: opts[i].value
              });
            } else {
                if(opts[i].label === "Declined_Final_Consent"){
                  if(this.pe_record.Clinical_Trial_Profile__r.Final_Consent_Required__c){
                      trans_opts.push({
                        label: this.utilLabels[opts[i].label],
                        value: opts[i].value
                      });
                  }
              }
              else{
                    trans_opts.push({
                      label: this.utilLabels[opts[i].label],
                      value: opts[i].value
                    }); 
                  }
            }
          }
        } 
    }else{
        for (let i = 0; i < opts.length; i++) {
          if (opts[i].label === "Screening In Progress - Wash Out Period") {
            trans_opts.push({
              label: this.utilLabels.In_Wash_Out_Period,
              value: "Screening In Progress - Wash Out Period"
            });
          } else if (opts[i].label === "Declined_Consent") {
            trans_opts.push({
              label: this.utilLabels.PIR_Declined,
              value: opts[i].value
            });
          } else {
             if(opts[i].label === "Declined_Final_Consent"){
                if(this.pe_record.Clinical_Trial_Profile__r.Final_Consent_Required__c){
                    trans_opts.push({
                      label: this.utilLabels[opts[i].label],
                      value: opts[i].value
                    });
                }
             }
             else{
                  trans_opts.push({
                    label: this.utilLabels[opts[i].label],
                    value: opts[i].value
                  }); 
                }
            }
        }
    }
    
    this.outcomeoptions = trans_opts;
  }
  createopts(optList) {
    let options = [];
    for (let i = 0; i < optList.length; i++) {
      options.push({ label: optList[i], value: optList[i] });
    }
    return options;
  }
  outcomeHandleChange(event) {
    let datavalue = event.target.dataset.value;
    this.selectedOutcome = event.detail.value;
    if (datavalue === "Consent Signed") {
      if (this.selectedOutcome == "BTN_Yes") {
        this.participantrecord.Informed_Consent__c = true;
        delete this.participantrecord.Participant_Status__c;
      } else if (this.selectedOutcome == "Declined_Consent") {
        this.participantrecord.Participant_Status__c = "Declined Consent";
        this.participantrecord.Informed_Consent__c = false;
      } else {
        this.participantrecord.Informed_Consent__c = false;
        this.participantrecord.Informed_Consent_Date__c = "";
        delete this.participantrecord.Participant_Status__c;
      }
    } else {
      if (event.detail.value == "Screening In Progress - Wash Out Period") {
        this.participantrecord.Participant_Status__c =
          "Screening In Progress - Wash Out Period";
      } else {
        // this.participantrecord.Participant_Status__c = this.utilLabels[
        //   event.detail.value
        // ];
        this.participantrecord.Participant_Status__c = this.outcomeValues[event.detail.value];
      }
    }
    this.statusChanged = true;
    let reasonopts = this.createopts(
      this.outcomeToReasonMap[this.selectedOutcome]
    );
    let trans_reasonopts = [];
    for (let i = 0; i < reasonopts.length; i++) {
      let outcomeReasonLabel = reasonopts[i].label;
      let outcomeReasonValue = reasonopts[i].value;
      if (outcomeReasonValue.endsWith("*")) {
        outcomeReasonLabel = outcomeReasonLabel.substring(
          0,
          outcomeReasonLabel.length - 1
        );
        outcomeReasonValue = outcomeReasonValue.substring(
          0,
          outcomeReasonValue.length - 1
        );
          if(outcomeReasonLabel.length != 1){
            this.notesNeeded.push(outcomeReasonValue);
          }else{
            this.notesNeeded.push('BLANK');
          }
      }
      trans_reasonopts.push({
        label: this.utilLabels[outcomeReasonLabel],
        value: outcomeReasonValue
      });
    }
    this.reasoneoptions = trans_reasonopts;
    if (this.reasoneoptions.length > 0) {
      if (datavalue === "Consent Signed") {
        this.selectedreason = "";
        this.participantrecord.Non_Enrollment_Reason__c = "";
      } else {
        if(this.reasoneoptions[0].label == undefined){ 
          this.selectedreason = "";
          this.participantrecord.Non_Enrollment_Reason__c = "";
        }else{
          this.selectedreason = this.reasoneoptions[0].value;
          this.participantrecord.Non_Enrollment_Reason__c = this.reasoneoptions[0].value;
        }
      }
    } else {
      this.selectedreason = "";
      this.participantrecord.Non_Enrollment_Reason__c = "";
    }
    if (datavalue === "Consent Signed") {
      if (this.selectedOutcome != null && this.selectedOutcome != "") {
        this.customFieldValidation("InitialVisitAttended");
      }
      this.customFieldValidation("Consent Signed");
      this.customButtonValidation();
    }
    if(this.selectedOutcome == "Unable_to_Reach"){
      this.customButtonValidation();
    }
    // this.customFieldValidation('RandomizationID');
    // this.customFieldValidation('FinalConsent');
    this.isdataChanged();
  }
  outcomeHandleChangeIV(event) {
    let datavalue = event.target.dataset.value;
    this.selectedOutcomeIV = event.detail.value;
    if (this.selectedOutcomeIV == "BTN_Yes") {
      this.participantrecord.Informed_Consent__c = true;
      //delete this.participantrecord.Participant_Status__c;
      this.participantrecord.Participant_Status__c = "Ready to Screen";
      this.customFieldValidation("Consent Signed");
      if(this.initialvisitattended == "No"){
        this.customFieldValidation("InitialVisitAttended");
      }
    } else if (this.selectedOutcomeIV == "Declined_Consent") {
      this.participantrecord.Participant_Status__c = "Declined Consent";
      this.participantrecord.Informed_Consent__c = false;
    } else if (this.selectedOutcomeIV == "Withdrew_Consent") {
      this.participantrecord.Participant_Status__c = "Withdrew Consent";
      this.participantrecord.Informed_Consent__c = false;
    } else {
      this.participantrecord.Informed_Consent__c = false;
      //this.participantrecord.Informed_Consent_Date__c = '';
      delete this.participantrecord.Participant_Status__c;
    }

    this.statusChanged = true;
    let reasonopts = this.createopts(
      this.outcomeToReasonMap[this.selectedOutcomeIV]
    );
    let trans_reasonopts = [];
    if (this.pe_record.Participant_Status__c != "Withdrew Consent") {
      for (let i = 0; i < reasonopts.length; i++) {
        let outcomeReasonLabel = reasonopts[i].label;
        let outcomeReasonValue = reasonopts[i].value;
        if (outcomeReasonValue.endsWith("*")) {
          outcomeReasonLabel = outcomeReasonLabel.substring(
            0,
            outcomeReasonLabel.length - 1
          );
          outcomeReasonValue = outcomeReasonValue.substring(
            0,
            outcomeReasonValue.length - 1
          );
            if(outcomeReasonLabel.length != 1){
              this.notesNeeded.push(outcomeReasonValue);
            }else{
              this.notesNeeded.push('BLANK');
            }
        }
        trans_reasonopts.push({
          label: this.utilLabels[outcomeReasonLabel],
          value: outcomeReasonValue
        });
      }
    }
    this.reasoneoptions = trans_reasonopts;
    this.selectedreason = "";
    this.selectedreasonIV = "";
    this.participantrecord.Non_Enrollment_Reason__c = "";
    if (this.selectedOutcomeIV != null && this.selectedOutcomeIV != "") {
      this.customFieldValidation("InitialVisitAttended");
    }

    this.customFieldValidation("Consent Signed");
    this.customButtonValidation();
    this.isdataChanged();
  }
  get reasonDisabled() {
    return this.reasoneoptions == 0;
  }
  get screeningReasonDisabled() {
    if(this.pe_record.Clinical_Trial_Profile__r.Initial_Visit_Required__c){
      if (
        this.pe_record.Participant_Status__c == "Withdrew Consent" ||
        this.pe_record.Participant_Status__c == "Declined Consent"
      ) {
        return true;
      } else {
        return this.reasoneoptions == 0;
      }
    }else{
      return this.reasoneoptions == 0;
    }
  }

  get notesLabel() {
    //this.selectedreason == this.utilLabels.PIR_Other
    if(this.selectedOutcome == "Contacted_Not_Suitable" &&  this.selectedreason == ""){
          this.customButtonValidation(); 
          return this.utilLabels.PG_ACPE_L_Notes_Required;
    }else if(this.selectedOutcome == "Unable_to_Reach" &&  this.selectedreason == ""){
      this.customButtonValidation(); 
      return this.utilLabels.PG_ACPE_L_Notes_Required;
    }else{
      if (this.notesNeeded.includes(this.selectedreason)) {
        this.customButtonValidation();
        return this.utilLabels.PG_ACPE_L_Notes_Required;
       }else {
        this.customButtonValidation();
        return this.utilLabels.PG_ACPE_L_Notes_Optional;
      }
    }
  }
  get notesLabelIV() {
    if (
      this.pe_record.Participant_Status__c == "Withdrew Consent" ||
      this.pe_record.Participant_Status__c == "Declined Consent"
    ) {
      if (this.selectedOutcomeIV == "BTN_Yes") {
        this.customButtonValidation();
        return this.utilLabels.PG_ACPE_L_Notes_Required;
      } else if (
        this.selectedOutcomeIV == "Declined_Consent" &&
        this.selectedreason == "PWS_Picklist_Value_Other"
      ) {
        this.customButtonValidation();
        return this.utilLabels.PG_ACPE_L_Notes_Required;
      } else {
        this.customButtonValidation();
        return this.utilLabels.PG_ACPE_L_Notes_Optional;
      }
    } else {
      if (this.selectedreason == "PWS_Picklist_Value_Other"){
        this.customButtonValidation();
        return this.utilLabels.PG_ACPE_L_Notes_Required;
      } else {
        this.customButtonValidation();
        return this.utilLabels.PG_ACPE_L_Notes_Optional;
      }
    }
  }
  get notesRequiredIV() {
    if (
      this.pe_record.Participant_Status__c == "Withdrew Consent" ||
      this.pe_record.Participant_Status__c == "Declined Consent"
    ) {
      if (this.selectedOutcomeIV == "BTN_Yes") {
        return true;
      } else {
        return false;
      }
    } else {
      if (this.selectedreasonIV == "PWS_Picklist_Value_Other") {
        return true;
      } else {
        return false;
      }
    }
  }
  get signeddtRequiredIV() {
    if (
      this.pe_record.Participant_Status__c == "Withdrew Consent" ||
      this.pe_record.Participant_Status__c == "Declined Consent"
    ) {
      if (this.selectedOutcomeIV == "BTN_Yes") {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
  get checkPerStatus() {
    if (
      this.pe_record.Participant_Status__c == "Withdrew Consent" ||
      this.pe_record.Participant_Status__c == "Successfully Contacted" ||
      this.pe_record.Participant_Status__c == "Ready to Screen" ||
      this.pe_record.Participant_Status__c == "Declined Consent"
    ) {
      return false;
    } else {
      return true;
    }
  }
  customButtonValidation() {
    let notes = this.additionalNote.trim();
    let btnValidationSuccess = false;
    let validationList = [];
     
    //1.
    if (this.notesNeeded.includes(this.selectedreason)) {
      if ( this.notesNeeded.includes(this.selectedreasonIV)) {
        let noteIV = this.additionalNoteIV.trim();
        if (noteIV != null && noteIV != "" && noteIV.length != 0) {
          btnValidationSuccess = true;
          validationList.push(btnValidationSuccess);
        } else {
          btnValidationSuccess = false;
          validationList.push(btnValidationSuccess);
        }
      } else {
        if (notes != null && notes != "" && notes.length != 0) {
          btnValidationSuccess = true;
          validationList.push(btnValidationSuccess);
        } else {
          btnValidationSuccess = false;
          validationList.push(btnValidationSuccess);
        }
      }
    }

    //2.
    if (this.runinwashout == "Yes") {
      if (this.participantrecord.Revisit_Date__c) {
        btnValidationSuccess = true;
        validationList.push(btnValidationSuccess);
      } else {
        btnValidationSuccess = false;
        validationList.push(btnValidationSuccess);
      }
    } else {
      btnValidationSuccess = true;
      validationList.push(btnValidationSuccess);
    }
    //3.
    if (
        (this.selectedOutcome == "Randomization_Success" ||
        this.selectedOutcome == "PE_STATUS_ENROLLMENT_SUCCESS") ||
        ( this.selectedOutcome == "" && (this.pe_record.Participant_Status__c == 'Enrollment Success' || this.pe_record.Participant_Status__c == 'Randomization Success'))
    ) {
      let enrollment_or_randomizationid =
        this.participantrecord.Screening_ID__c == undefined
          ? ""
          : this.participantrecord.Screening_ID__c;
      let screeningids = enrollment_or_randomizationid.trim();
      if (this.isfinalconsentrequired) {
        if (this.participantrecord.Final_consent__c) {
          btnValidationSuccess = true;
          validationList.push(btnValidationSuccess);
        } else {
          btnValidationSuccess = false;
          validationList.push(btnValidationSuccess);
        }
      }
      if (
        screeningids != null &&
        screeningids != "" &&
        screeningids.length != 0
      ) {
        btnValidationSuccess = true;
        validationList.push(btnValidationSuccess);
      } else {
        btnValidationSuccess = false;
        validationList.push(btnValidationSuccess);
      }
      if (this.isvprequired) {
        if (this.plan != null && this.plan != "" && this.plan.length != 0) {
          btnValidationSuccess = true;
          validationList.push(btnValidationSuccess);
          this.participantrecord.Visit_Plan__c = this.plan;
        } else {
          btnValidationSuccess = false;
          validationList.push(btnValidationSuccess);
        }
      }
    }
    //4.
    if (
      this.selectedOutcomeIV == "Declined_Consent" &&
      this.selectedreasonIV == ""
    ) {
      btnValidationSuccess = false;
      validationList.push(btnValidationSuccess);
    } else {
      btnValidationSuccess = true;
      validationList.push(btnValidationSuccess);
    }
    //5.
    if (
      this.pe_record.Participant_Status__c == "Withdrew Consent" ||
      this.pe_record.Participant_Status__c == "Declined Consent"
    ) {
      let notesIV = this.additionalNoteIV.trim();
      if (this.selectedOutcomeIV == "BTN_Yes") {
        if (notesIV != null && notesIV != "" && notesIV.length != 0) {
          if (this.runinwashout == "Yes") {
            if (this.participantrecord.Revisit_Date__c) {
              btnValidationSuccess = true;
              validationList.push(btnValidationSuccess);
            } else {
              btnValidationSuccess = false;
              validationList.push(btnValidationSuccess);
            }
          } else {
            btnValidationSuccess = true;
            validationList.push(btnValidationSuccess);
          }
        } else {
          btnValidationSuccess = false;
          validationList.push(btnValidationSuccess);
        }
        if (
          this.participantrecord.Informed_Consent_Date__c != null &&
          this.participantrecord.Informed_Consent_Date__c != ""
        ) {
          btnValidationSuccess = true;
          validationList.push(btnValidationSuccess);
        } else {
          btnValidationSuccess = false;
          validationList.push(btnValidationSuccess);
        }
      }
    }

    //6.
    if((this.selectedOutcome == "Contacted_Not_Suitable" || this.selectedOutcome == "Unable_to_Reach") &&  this.participantrecord.Non_Enrollment_Reason__c == ''){
      if (notes != null && notes != "" && notes.length != 0) {
        btnValidationSuccess = true;
        validationList.push(btnValidationSuccess);
      } else {
        btnValidationSuccess = false;
        validationList.push(btnValidationSuccess);
      }
    }

    //7.
    if(this.participantrecord.Initial_visit_scheduled_time__c <= '04:59:00.000' || this.participantrecord.Initial_visit_scheduled_time__c >= '23:46:00.000'){
      btnValidationSuccess = false;
      validationList.push(btnValidationSuccess);
    }else{
      btnValidationSuccess = true;
      validationList.push(btnValidationSuccess);
    }

    if (validationList.includes(false)) {
      const validatesavebtn = new CustomEvent("validatesavebutton", {
        detail: true
      });
      this.dispatchEvent(validatesavebtn);
    } else {
      const validatesavebtn = new CustomEvent("validatesavebutton", {
        detail: false
      });
      this.dispatchEvent(validatesavebtn);
    }
  }

  get runinoptions() {
    return [
      { label: "No", value: "No" },
      { label: "Yes", value: "Yes" }
    ];
  }
  get initialVisitAttended() {
    return [
      { label: "No", value: "No" },
      { label: "Yes", value: "Yes" }
    ];
  }
  todaydate() {
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, "0");
    var mm = String(today.getMonth() + 1).padStart(2, "0");
    var yyyy = today.getFullYear();
    today = yyyy + "-" + mm + "-" + dd;
    return today;
  }
  //Accordian
  toggleAccordian(event) {
    this.template
      .querySelectorAll("." + event.currentTarget.dataset.name)
      .forEach(function (L) {
        L.classList.toggle("slds-hide");
      });
      this.template.querySelectorAll("."+event.currentTarget.dataset.name+"Bg").forEach(function (L) {
        L.classList.toggle("bg-white");
    });
  }

  getReceivedHistorySection(event) {
    this.historyResults = "";
    this.template
      .querySelectorAll("." + event.currentTarget.dataset.name)
      .forEach(function (R) {
        R.classList.toggle("slds-hide");
      });
      this.template.querySelectorAll("."+event.currentTarget.dataset.name+"Bg").forEach(function (L) {
        L.classList.toggle("bg-white");
    });
    getRecievedHistory({ pe: this.peid })
    .then((result) => {
      if (result.length == 0) {
        this.historyNull = true;
      } else {
        this.historyResults = result;
        this.historyNull = false;
      }
    })
    .catch((error) => {
      console.log(error);
      this.showErrorToast(JSON.stringify(error.body.message));
    });
    
  }

  getContactHistorySection(event) {
    this.historyResults = "";
    this.template
      .querySelectorAll("." + event.currentTarget.dataset.name)
      .forEach(function (R) {
        R.classList.toggle("slds-hide");
      });
      this.template.querySelectorAll("."+event.currentTarget.dataset.name+"Bg").forEach(function (L) {
        L.classList.toggle("bg-white");
    });
    getContactHistory({ pe: this.peid })
      .then((result) => {
        if (result == null || result.length == 0) {
          this.historyNull = true;
        } else {
          let contactHistory = result;
          var historyList = [];
          var obj = {};
          for (var i = 0; i < result.length; i++) {
            if (contactHistory[i].isAdditionalNote) {
              var str = contactHistory[i].noteDetailsdt;
              var month = str.substring(0, 3);
              month = month.trim();
              if (month == "Jan") {
                month = "01";
              } else if (month == "Feb") {
                month = "02";
              } else if (month == "Mar") {
                month = "03";
              } else if (month == "Apr") {
                month = "04";
              } else if (month == "May") {
                month = "05";
              } else if (month == "Jun") {
                month = "06";
              } else if (month == "Jul") {
                month = "07";
              } else if (month == "Aug") {
                month = "08";
              } else if (month == "Sep") {
                month = "09";
              } else if (month == "Oct") {
                month = "10";
              } else if (month == "Nov") {
                month = "11";
              } else if (month == "Dec") {
                month = "12";
              }

              var dt = str.substring(4, 7);

              var yr = str.substring(7, 11);

              var hr = str.substring(12, 15);

              var mn = str.substring(16, 18);

              var ampm = str.substring(18, 21);

              let ap = ampm;

              if (ap.includes("A")) {
                if (hr == "12") {
                  hr == "00";
                }
              } else {
                if (hr == "1" || hr == "01") {
                  hr = "13";
                } else if (hr == "2" || hr == "02") {
                  hr = "14";
                } else if (hr == "3" || hr == "03") {
                  hr = "15";
                } else if (hr == "4" || hr == "04") {
                  hr = "16";
                } else if (hr == "5" || hr == "05") {
                  hr = "17";
                } else if (hr == "6" || hr == "06") {
                  hr = "18";
                } else if (hr == "7" || hr == "07") {
                  hr = "19";
                } else if (hr == "8" || hr == "08") {
                  hr = "20";
                } else if (hr == "9" || hr == "09") {
                  hr = "21";
                } else if (hr == "10" || hr == "010") {
                  hr = "22";
                } else if (hr == "11" || hr == "011") {
                  hr = "23";
                }
              }
              var finaldt =
                yr + "-" + month + "-" + dt + "T" + hr + ":" + mn + ":00.000Z";
              finaldt = finaldt.replace(/ /g, "");
              obj.detailDate = finaldt;
              obj.createdBy = contactHistory[i].createdBy;
              obj.title = contactHistory[i].historyTitle;
              historyList.push(obj);
              obj = {};
            } else {
              let detailDate = "";
              let finalDtTim = "";
              let ampm = "";
              let hrs = "";
              let mns = "";
              let ms = "";
              detailDate = contactHistory[i].detailDate.substring(0, 11);

              ampm = contactHistory[i].detailDate.substring(20, 22);
              hrs = contactHistory[i].detailDate.substring(11, 13);
              mns = contactHistory[i].detailDate.substring(14, 16);
              ms = contactHistory[i].detailDate.substring(17, 19);
              if (ampm.includes("A")) {
                if (hrs == "12") {
                  hrs == "00";
                }
              } else {
                if (hrs == "1" || hrs == "01") {
                  hrs = "13";
                } else if (hrs == "2" || hrs == "02") {
                  hrs = "14";
                } else if (hrs == "3" || hrs == "03") {
                  hrs = "15";
                } else if (hrs == "4" || hrs == "04") {
                  hrs = "16";
                } else if (hrs == "5" || hrs == "05") {
                  hrs = "17";
                } else if (hrs == "6" || hrs == "06") {
                  hrs = "18";
                } else if (hrs == "7" || hrs == "07") {
                  hrs = "19";
                } else if (hrs == "8" || hrs == "08") {
                  hrs = "20";
                } else if (hrs == "9" || hrs == "09") {
                  hrs = "21";
                } else if (hrs == "10" || hrs == "010") {
                  hrs = "22";
                } else if (hrs == "11" || hrs == "011") {
                  hrs = "23";
                }
              }

              finalDtTim =
                detailDate + "T" + hrs + ":" + mns + ":" + ms + ".000Z";
              finalDtTim = finalDtTim.replace(/ /g, "");
              obj.detailDate = finalDtTim;
              obj.createdBy = contactHistory[i].createdBy;
              obj.title = contactHistory[i].historyTitle;
              historyList.push(obj);
              obj = {};
            }
          }

          historyList.sort(function (a, b) {
            return new Date(a.detailDate) - new Date(b.detailDate);
          });
        
          this.historyResults = historyList.reverse();
          this.historyNull = false;
        }
      })
      .catch((error) => {
        console.log(error);
        this.showErrorToast(JSON.stringify(error.body.message));
      });
  }

  getInitialVisitHistorySection(event) {
    this.historyResults = "";
    this.template
      .querySelectorAll("." + event.currentTarget.dataset.name)
      .forEach(function (R) {
        R.classList.toggle("slds-hide");
      });
      this.template.querySelectorAll("."+event.currentTarget.dataset.name+"Bg").forEach(function (L) {
        L.classList.toggle("bg-white");
    });

    getInitialVisitHistory({ pe: this.peid })
      .then((result) => {
        if (result == null || result.length == 0) {
          this.historyNull = true;
        } else {
          this.historyResults = result;
          this.historyNull = false;
        }
      })
      .catch((error) => {
        console.log(error);
        this.showErrorToast(JSON.stringify(error.body.message));
      });
  }

  getEligibilityHistorySection(event) {
    this.historyResults = "";
    this.template
      .querySelectorAll("." + event.currentTarget.dataset.name)
      .forEach(function (R) {
        R.classList.toggle("slds-hide");
      });
      this.template.querySelectorAll("."+event.currentTarget.dataset.name+"Bg").forEach(function (L) {
        L.classList.toggle("bg-white");
    });

    getEligibilityHistory({ pe: this.peid })
      .then((result) => {
        if (result == null || result.length == 0) {
          this.historyNull = true;
        } else {
          this.historyResults = result;
          this.historyNull = false;
        }
      })
      .catch((error) => {
        console.log(error);
        this.showErrorToast(JSON.stringify(error.body.message));
      });
  }

  getScreeningHistorySection(event) {
    this.historyResults = "";
    this.template
      .querySelectorAll("." + event.currentTarget.dataset.name)
      .forEach(function (R) {
        R.classList.toggle("slds-hide");
      });
      this.template.querySelectorAll("."+event.currentTarget.dataset.name+"Bg").forEach(function (L) {
        L.classList.toggle("bg-white");
    });

    getScreeningHistory({ pe: this.peid })
      .then((result) => {
        if (result == null || result.length == 0) {
          this.historyNull = true;
        } else {
          this.historyResults = result;
          this.historyNull = false;
        }
      })
      .catch((error) => {
        console.log(error);
        this.showErrorToast(JSON.stringify(error.body.message));
      });
  }

  getEnrollmentHistorySection(event) {
    this.historyResults = "";
    this.template
      .querySelectorAll("." + event.currentTarget.dataset.name)
      .forEach(function (R) {
        R.classList.toggle("slds-hide");
      });
      this.template.querySelectorAll("."+event.currentTarget.dataset.name+"Bg").forEach(function (L) {
        L.classList.toggle("bg-white");
    });

    getEnrollmentHistory({ pe: this.peid })
      .then((result) => {
        if (result == null || result.length == 0) {
          this.historyNull = true;
        } else {
          this.historyResults = result;
          this.historyNull = false;
        }
      })
      .catch((error) => {
        console.log(error);
        this.showErrorToast(JSON.stringify(error.body.message));
      });
  }

  get makerequiredfinalConsent() {
    if (
      this.selectedOutcome == "Randomization_Success" ||
      this.selectedOutcome == "PE_STATUS_ENROLLMENT_SUCCESS"
    ) {
      return true;
    } else if( this.selectedOutcome == "" && (this.pe_record.Participant_Status__c == 'Enrollment Success' || this.pe_record.Participant_Status__c == 'Randomization Success')) {
      return true;
    }else{
      return false;
    }
  }

  get makerequiredvisitplan() {
    if (
      this.selectedOutcome == "Randomization_Success" ||
      this.selectedOutcome == "PE_STATUS_ENROLLMENT_SUCCESS"
    ) {
      return true;
    } else if( this.selectedOutcome == "" && (this.pe_record.Participant_Status__c == 'Enrollment Success' || this.pe_record.Participant_Status__c == 'Randomization Success')) {
      return true;
    }else{
      return false;
    }
  }

  get makerequiredrandomizationid() {
    if (
      this.selectedOutcome == "Randomization_Success" ||
      this.selectedOutcome == "PE_STATUS_ENROLLMENT_SUCCESS"
    ) {
      return true;
    } else if( this.selectedOutcome == "" && (this.pe_record.Participant_Status__c == 'Enrollment Success' || this.pe_record.Participant_Status__c == 'Randomization Success')) {
      return true;
    }else{
      return false;
    }
  }

  get isvisitplanreadonly() {
    if (this.visitplanoptions.length <= 1) {
      return true;
    } else {
      return false;
    }
  }

  @api
  checkFinalValidation() {
    if (
      this.selectedOutcome == "Pre_review_Failed" ||
      this.selectedOutcome == "Contacted_Not_Suitable" ||
      this.selectedOutcome == "Unable_to_Reach"
    ) {
      if (
        this.participantrecord.Initial_visit_scheduled_date__c != null ||
        this.participantrecord.Initial_visit_scheduled_time__c != null
      ) {
        if (
          this.participantrecord.Initial_visit_scheduled_date__c != null &&
          this.participantrecord.Initial_visit_scheduled_time__c != null &&
          this.participantrecord.Initial_visit_scheduled_date__c != "" &&
          this.participantrecord.Initial_visit_scheduled_time__c != ""
        ) {
          this.isfovNull = false;
        } else {
          this.isfovNull = true;
        }
        this.isModalOpen = true;
      } else {
        this.getSaved();
      }
    } else {
      this.getSaved();
    }
  }

  isdataChanged(){
    let hasChanges = [];
    if(this.pe_record.Site_Communication_Preference__c != this.participantrecord.Site_Communication_Preference__c ||
       this.pe_record.Initial_visit_occurred_flag__c != this.participantrecord.Initial_visit_occurred_flag__c ||
       this.pe_record.Informed_Consent__c != this.participantrecord.Informed_Consent__c ||
       this.pe_record.Washout_Run_In_Applies__c != this.participantrecord.Washout_Run_In_Applies__c ||
       this.pe_record.Final_consent__c != this.participantrecord.Final_consent__c ||
       this.pe_record.ParticipantNoShow__c != this.participantrecord.ParticipantNoShow__c ||
       this.pe_record.Initial_visit_scheduled_date__c != this.participantrecord.Initial_visit_scheduled_date__c ||
       this.pe_record.Initial_visit_scheduled_time__c != this.participantrecord.Initial_visit_scheduled_time__c ||
       this.pe_record.Informed_Consent_Date__c != this.participantrecord.Informed_Consent_Date__c ||
       this.pe_record.IVRS_IWRS__c != this.participantrecord.IVRS_IWRS__c ||
       this.pe_record.Revisit_Date__c != this.participantrecord.Revisit_Date__c ||
       this.pe_record.Screening_ID__c != this.participantrecord.Screening_ID__c ||
       this.pe_record.Final_consent__c != this.participantrecord.Final_consent__c
      ){
        hasChanges.push(true);
      }else{
        hasChanges.push(false);
      }

     let notes = this.additionalNote.trim();
	   if (notes != null && notes != "" && notes.length != 0) {
        hasChanges.push(true);
     }else{
        hasChanges.push(false);
     }
     
     let notesIV = this.additionalNoteIV.trim();
	   if (notesIV != null && notesIV != "" && notesIV.length != 0) {
        hasChanges.push(true);
     }else{
        hasChanges.push(false);
     }
     
     if(this.selectedOutcome !='' && this.selectedOutcome !=null){
       hasChanges.push(true);
     }else{
       hasChanges.push(false);
     }

      if(hasChanges.includes(true)){ 
         const valueChangeEvent = new CustomEvent("statusdetailsvaluechange", {
          detail: true
        });
        this.dispatchEvent(valueChangeEvent);
      }else{
        const valueChangeEvent = new CustomEvent("statusdetailsvaluechange", {
          detail: false
        });
        this.dispatchEvent(valueChangeEvent);
      }

  }

  getSaved() {
    if (this.statusChanged) {
      if ((this.additionalNote != "") & (this.additionalNote != null)) {
        this.participantrecord.Last_Status_Changed_Notes__c = this.additionalNote;
      } else {
        this.participantrecord.Last_Status_Changed_Notes__c = this.additionalNoteIV;
      }
    } else {
      if ((this.additionalNote != "") & (this.additionalNote != null)) {
        this.participantrecord.Last_Status_Changed_Additional_Notes__c = this.additionalNote;
      } else {
        this.participantrecord.Last_Status_Changed_Additional_Notes__c = this.additionalNoteIV;
      }
    }
    if (!this.statusChanged) {
      if(this.participantrecord.Participant_Status__c != "Ready to Screen"){
        delete this.participantrecord.Participant_Status__c;
      }
    }
    if (
      this.selectedOutcome == "Successfully_Contacted" ||
      this.selectedOutcome == "Pre_review_Passed"
    ) {
      this.participantrecord.ParticipantNoShow__c = false;
    } else if (
      this.pe_record.ParticipantNoShow__c ==
      this.participantrecord.ParticipantNoShow__c
    ) {
      delete this.participantrecord.ParticipantNoShow__c;
    }
    if(this.participantrecord.ParticipantNoShow__c){ 
      this.participantrecord.Participant_Status__c = 'Unable to Reach';
      this.participantrecord.Non_Enrollment_Reason__c='Didnt Show For Initial Visit';
    }
   
    if (this.participantrecord.Participant_Status__c == "Ready to Screen") {
      if (
        this.participantrecord.Informed_Consent__c &&
        this.participantrecord.Initial_visit_occurred_flag__c &&
        this.participantrecord.Initial_visit_scheduled_date__c != null &&
        this.participantrecord.Initial_visit_scheduled_date__c != ""
      ) {
        this.participantrecord.Participant_Status__c = "Ready to Screen";
        this.participantrecord.Non_Enrollment_Reason__c = '';
      } else {
        delete this.participantrecord.Participant_Status__c;
      }
    }
    if(this.participantrecord.Participant_Status__c == "Declined Final Consent"){
      this.participantrecord.Final_consent__c = false;
    }
   
    let outcome = this.selectedOutcome;

    let occuredDt = this.participantrecord.Initial_visit_occurred_date__c;
    //let tdyDt = this.todaydate();
    let tdyDt = this.currentuserdate;
    if (tdyDt < occuredDt) {
      this.showErrorToast("Initial Visit Attended Date cannot be future date");
    } else {
      let visitPln = 'null';
      if(this.participantrecord.Visit_Plan__c){
        visitPln = this.participantrecord.Visit_Plan__c;
      }
      const selectedEvent = new CustomEvent("recordsave", {});
      this.dispatchEvent(selectedEvent);
      doSaveStatusDetails({ perRecord: this.participantrecord, visitPlan : visitPln })
        .then((result) => {
          this.showSuccessToast("Record Saved Successfully");
          const selectedEvent = new CustomEvent("saved", {});
          this.dispatchEvent(selectedEvent);
          if (outcome == "Eligibility_Passed") {
            const selectEventHeader = new CustomEvent(
              "callparticipantstatusdetail",
              {}
            );
            this.dispatchEvent(selectEventHeader);
          }
        })
        .catch((error) => {
          console.error("Error:", error);
          this.showErrorToast(JSON.stringify(error.body.message));
        });
    }
  }

  handleCloseModal() {
    this.isModalOpen = false;
  }
  handleCancelModal() {
    this.isModalOpen = false;
  }
  handleProceedModal() {
    this.participantrecord.Initial_visit_scheduled_time__c = "";
    this.participantrecord.Initial_visit_scheduled_date__c = "";
    this.isModalOpen = false;
    this.getSaved();
  }
  showSuccessToast(Message) {
    const evt = new ShowToastEvent({
      title: Message,
      message: Message,
      variant: "success",
      mode: "sticky"
    });
    this.dispatchEvent(evt);
  }
  showErrorToast(msg) {
    const evt = new ShowToastEvent({
      title: msg,
      message: msg,
      variant: "error",
      mode: "dismissible"
    });
    this.dispatchEvent(evt);
  }
}