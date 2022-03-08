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
  @api consussessreason = '';
  checkIcon = pirResources + "/pirResources/icons/status-good.svg";
  minusIcon = pirResources + "/pirResources/icons/status-negative.svg";
  noneIcon = pirResources + "/pirResources/icons/circle.svg";
  backArrow = pirResources + "/pirResources/icons/triangle-left.svg";
  failureIcon = pirResources + "/pirResources/icons/close-circle.svg";

  get checkGroupName() {
    if (this.groupicon == "success") {
      if (this.groupstatus != undefined) {
        return this.utilLabels[this.groupstatus];
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
          return this.utilLabels[this.groupstatus];
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
        return this.non_enrollment_reason;
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