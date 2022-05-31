import { LightningElement, api, track } from "lwc";
import pirResources from "@salesforce/resourceUrl/pirResources";
import { label } from "c/pir_label";
export default class Pir_participantSubStatus extends LightningElement {
  @api groupname = "";
  @api groupstatus = "";
  @api groupdate = "";
  @api groupicon = "";
  @api index = "";
  @api non_enrollment_reason = "";
  @api disabled = false;
  @track utilLabels = label;
  @api consussessreason = '';@api isinitialvisit;
  @api isrtl = false;
  maindivcls;
  checkIcon = pirResources + "/pirResources/icons/status-good.svg";
  minusIcon = pirResources + "/pirResources/icons/status-negative.svg";
  noneIcon = pirResources + "/pirResources/icons/circle.svg";
  backArrow = pirResources + "/pirResources/icons/triangle-left.svg";
  failureIcon = pirResources + "/pirResources/icons/close-circle.svg";
  @api reasons = new Map([
    ["Other", "PWS_Picklist_Value_Other"],
    ["Call Back", "PIR_Call_Back"],
    ["Transportation Issues", "PWS_Picklist_Value_Transportation_Issues"],
    ["Childcare Issues", "PWS_Picklist_Value_Childcare_Issues"],
    ["Left a Message", "PIR_Left_a_Message"],
    ["Inadequate Documentation", "PIR_Inadequate_Documentation"],
    ["Does Not Meet Eligibility Criteria", "PIR_Does_Not_Meet_Eligibility_Criteria"],
    ["Not Ready to Schedule", "PIR_Not_Ready_to_Schedule"],
    ["Participant Not Interested", "PWS_Picklist_Value_Participant_Not_Interested"],
    ["Declined Practitioner", "PIR_Declined_Practitioner"],
    ["PI Decision", "PIR_PI_Decision"],
    ["Didn\'t Meet Pre-Screening Eligibility", "PIR_Didnt_Meet_Pre_Screening_Eligibility"],
    ["Did Not Meet Inclusion/Exclusion Criteria", "PIR_Did_Not_Meet_Inclusion_Exclusion_Criteria"],
    ["Did Not Attend Appointment", "PIR_Did_Not_Attend_Appointment"],
    ["Protocol Concerns", "PWS_Picklist_Value_Protocol_Concerns"],
    ["Visit Out Of Window", "PIR_Visit_Out_Of_Window"]
  ]);
  connectedCallback() {
    if(this.isrtl) {
      this.maindivcls = 'rtl';
    }else{
      this.maindivcls = 'ltr';
    }
  }
  get checkGroupName() {
    if (this.groupicon == "success") {
      if (this.groupstatus != undefined) {
          if(this.index == 2 && this.isinitialvisit){
                 return this.utilLabels['PWS_Initial_Visit_Card_Name'];
          }else{
        return this.utilLabels[this.groupstatus];}
      } else {
        return this.utilLabels[this.groupname];
      }
    } else if (this.groupicon == "failure") {
      if (this.groupstatus != undefined) {
        return this.utilLabels[this.groupstatus];
      } else {
        return this.utilLabels[this.groupname];
      }
    } else if (this.groupicon == "inProgress") {
      if (this.groupstatus != undefined) {
        if (
          this.groupstatus == "Not Contacted Yet" ||
          this.groupstatus == "Not Verified" ||
          this.groupstatus == "Not Screened" ||
          this.groupstatus == "Not Randomized" ||
          this.groupstatus == "Not Enrolled"
        ) {
          return this.utilLabels[this.groupname];
        } else {
          if(this.index == 2 && this.isinitialvisit){
              return this.utilLabels['PWS_Initial_Visit_Card_Name'];
           }else{
              return this.utilLabels[this.groupstatus];
           }
        }
      } else {
        return this.utilLabels[this.groupname];
      }
    } else {
      return this.utilLabels[this.groupname];
    }
  }
  get isInitialVisit(){
      if(this.groupname == "PWS_Initial_Visit_Card_Name"){
        return true;
      }else{
        return false;
      }
  }
  get checkGroupIcon() {
    if (this.groupicon == "success") {
      return this.checkIcon;
    } else if (this.groupicon == "failure") {
      return this.failureIcon;
    } else if (this.groupicon == "inProgress") {
      return this.minusIcon;
    } else {
      return this.noneIcon;
    }
  }
  get checkGroupMode() {
    if (this.groupicon == "success") {
      return false;
    } else if (this.groupicon == "failure") {
      return false;
    } else if (this.groupicon == "inProgress") {
      return false;
    } else {
      return true;
    }
  }
  get checkGroupStatus() {
    if (this.groupicon == "success"){
          if(this.groupname == "PWS_Contact_Name"){
              if(this.consussessreason){
                return this.consussessreason;
              }else{  return '';}
          }else{
            return "";
          }
    } else if (this.groupicon == "failure") {
      if(this.non_enrollment_reason){
        let reasonvalue = this.reasons.get(this.non_enrollment_reason);
        if(reasonvalue != undefined){
          return this.utilLabels[reasonvalue];
        }else{
          return this.non_enrollment_reason;
        }
      }else{  return '';}
    } else if (this.groupicon == "inProgress") {
      if (this.groupstatus != undefined) {
          if (this.groupstatus == "Not Contacted Yet") {
            return this.utilLabels.PWS_Contact_No_Outcome;
          }else if(this.groupstatus == "Not Randomized"){
            return this.utilLabels.PWS_Randomization_No_Outcome;
          }else if (this.groupstatus == "Not Enrolled") {
            return this.utilLabels.PWS_Enrolled_No_Outcome;
          }else if (this.groupstatus == "Not Verified") {
            return this.utilLabels.PWS_Eligibility_No_Outcome;
          }else if (this.groupstatus == "Not Screened") {
            return this.utilLabels.PWS_Screening_No_Outcome;
          }else if(this.non_enrollment_reason){
              return this.non_enrollment_reason;
            }else{  return '';}
      } else {
        return "";
      }
    } else {
      if (this.groupstatus == "Not Randomized") {
        return this.utilLabels.PWS_Randomization_No_Outcome;
      } else if (this.groupstatus == "Not Contacted Yet") {
        return this.utilLabels.PWS_Contact_No_Outcome;
      } else if (this.groupstatus == "Not Screened") {
        return this.utilLabels.PWS_Screening_No_Outcome;
      } else if (this.groupstatus == "Not Enrolled") {
        return this.utilLabels.PWS_Enrolled_No_Outcome;
      } else if (this.groupstatus == "Not Verified") {
        return this.utilLabels.PWS_Eligibility_No_Outcome;
      } else {
        return "";
      }
    }
  }
  changeStatusGroup() {
    const selectedEvent = new CustomEvent("statuschange", {
      detail: {
        index: this.index,
        groupName: this.groupname,
        grpIcon: this.groupicon
      }
      //detail: this.groupname
    });
    this.dispatchEvent(selectedEvent);
  }
}