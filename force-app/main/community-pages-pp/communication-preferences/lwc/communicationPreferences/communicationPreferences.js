import { LightningElement, track, api, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // TOBE: implemented through communityService
// TO DO : Replace all hardcoded text from html file with custom label's (cross check if already labels exist for ex. save changes is common used in multiple front end components)
import PP_Communication_Pref from '@salesforce/label/c.PP_Communication_Pref';
import PP_Communication_Pref_Study from '@salesforce/label/c.PP_Communication_Pref_Study';
import PP_Communication_Pref_Study_consent from '@salesforce/label/c.PP_Communication_Pref_Study_consent';
import PP_Communication_Pref_Phone from '@salesforce/label/c.PP_Communication_Pref_Phone';
import PP_Communication_Pref_Email from '@salesforce/label/c.PP_Communication_Pref_Email';
import PP_Communication_Pref_SMS from '@salesforce/label/c.PP_Communication_Pref_SMS';
import PP_Communication_Pref_Dmail from '@salesforce/label/c.PP_Communication_Pref_Dmail';
import PP_Communication_Pref_All from '@salesforce/label/c.PP_Communication_Pref_All';
import PP_Communication_Pref_Outreach from '@salesforce/label/c.PP_Communication_Pref_Outreach';
import PP_Communication_Pref_Outreach_consentA from '@salesforce/label/c.PP_Communication_Pref_Outreach_consentA';
import PP_Communication_Pref_Outreach_consentB from '@salesforce/label/c.PP_Communication_Pref_Outreach_consentB';
import PP_Communication_Pref_Outreach_consentC from '@salesforce/label/c.PP_Communication_Pref_Outreach_consentC';
import PP_Communication_Pref_savechanges from '@salesforce/label/c.PP_Communication_Pref_savechanges';
//END TO DO

import getStudiesConsent from "@salesforce/apex/PreferenceManagementController.getStudiesConsent";
import getOutreachConsent from "@salesforce/apex/PreferenceManagementController.getOutreachConsent";
import saveConsent from "@salesforce/apex/PreferenceManagementController.saveConsent";

export default class CommunicationPreferences extends LightningElement {

  @api
  label = {
    PP_Communication_Pref,
    PP_Communication_Pref_Study,
    PP_Communication_Pref_Study_consent,
    PP_Communication_Pref_Phone,
    PP_Communication_Pref_Email,
    PP_Communication_Pref_SMS,
    PP_Communication_Pref_Dmail,
    PP_Communication_Pref_All,
    PP_Communication_Pref_Outreach,
    PP_Communication_Pref_Outreach_consentA,
    PP_Communication_Pref_Outreach_consentB,
    PP_Communication_Pref_Outreach_consentC,
    PP_Communication_Pref_savechanges
  };

    @track studyDetails = [];
    @track outReachDetails= [];

    spinner = false;
    autoOptOutStudies = [];
    isDesktop = false;

    @wire(getStudiesConsent)
    studyConsent({ error, data }) {
        if (data) {
            this.studyDetails = JSON.parse(data);
        } else if (error) {
            console.log(JSON.stringify(error));
        }
    }
    @wire(getOutreachConsent)
    outReachConsent({ error, data }) {
        if (data) {
            this.outReachDetails = JSON.parse(data);
        } else if (error) {
            console.log(JSON.stringify(error));
        }
    }

    connectedCallback(){
      // TO DO: get init data from Controller
    }

    renderedCallback(){
    }

    selectAllOptions(event){
      this.updateStudyData(event.target.label, event.target.checked, event.target.name, event.target.getAttribute("data-sponsor"));         
    }

    selectIndividualOptions(event){
      this.updateStudyData(event.target.label, event.target.checked, event.target.name, event.target.getAttribute("data-sponsor"));  
    }

    updateStudyData(label, value, studyId, sponsorId, perId){
      debugger;
      if(label == "All"){
          let autoOptOutStudies = [];
          this.studyDetails.forEach(function (study) {
              debugger;             
              // Opt out SMS at sponser level
              if(study.sponsor_id == sponsorId && !value){                  
                  study.sms = value;
                  if(study.study_id != studyId){
                    autoOptOutStudies.push(study.study_name);
                  }
              }  
              // opt IN SMS at Study Level
              if(study.study_id == studyId && value){                  
                  study.sms = value;
              } 
              // opt IN Phone, Email, Direct Email at Study Level 
              if(study.study_id == studyId){
                study.phone = study.email = study.dmail = value;
              }
          });
          this.autoOptOutStudies = autoOptOutStudies;
          // update All Flag
          this.updateALLFlag();
      }
      else{
        this.studyDetails.forEach(function (study) {
          // If not clicked on All - Individual operaton 
          
          if(label == "SMS"){
            console.log("SMS Individual Handler");
            // Opt out SMS at sponser level
            if(study.sponsor_id == sponsorId && !value){                  
              study.sms = value;
              if(study.study_id != studyId){
                this.autoOptOutStudies.push(study.study_name);
              }
            }  
            // opt IN SMS at Study Level
            if(study.study_id == studyId && value){                  
                study.sms = value;
            } 
          }   
          else{
          (study.study_id == studyId && label == "Phone" ? 
              study.phone = value : 
              (study.study_id == studyId && label == "Email" ? 
                study.email = value:
                 (study.study_id == studyId && label == "DMail" ?  
                   study.dmail = value: "")));
          }    
        });
        this.updateALLFlag();
      }      
    }

    // Helper Method : To Update ALL flag comparing phone, email, sms and direct email at study as well as sponsor level
    updateALLFlag(){
      this.studyDetails.forEach(function (study) {
        (study.phone && study.email && study.sms && study.dmail) ? study.all = true : study.all = false;
      });
    }

    // Save Communication Pref data
    doSaveCommunicationPref(){
      debugger;
      let response = true;

      if(this.autoOptOutStudies.length > 0){
        let relatedStudies = this.autoOptOutStudies.toString();
        let message = `You will be automatically opted out from <b>${relatedStudies}</b> for the same sponsor. \n Are you sure you want to proceed further? `
        response = confirm(message);
      }
      if(response){
        this.spinner = true;
        saveConsent({ studyData: this.studyDetails, outReachData: this.outReachDetails })
        .then((result) => {
            console.log("Result of Save");
            console.log(result);
            setTimeout(() => {
              this.spinner = false;
              this.showCustomToast("Success", "Record Saved Successfully", "success");
            }, 3000); 
        })
        .catch((error) => {
          this.showCustomToast("Error", "Failed To save the Record", "error");
        });
       
      }
      else{
        this.spinner = false;
      }          
    } 

    // Helper Method: Toast Notification
    // To be replaced with community service helper method
    showCustomToast(title, message, varient){
      const toastEvent = new ShowToastEvent({
        title: title,
        message: message,
        variant: varient
      });
      this.dispatchEvent(toastEvent);
    }

    /* Outreach Handlers */

    selectAllOptionsOutreach(event){
      this.updateOutReachData(event.target.label, event.target.checked, event.target.name);

    }
    selectIndividualOptionsOutreach(event){
      this.updateOutReachData(event.target.label, event.target.checked, event.target.name);
    }

    updateOutReachData(label, value, outReachId){
      debugger;
      this.outReachDetails.forEach(function (out) {
        switch(label){
          case "All"  : out.phone = out.email = out.sms = out.dmail = value;
                        break;
          case "Phone": out.phone = value;
                        break;
          case "Email": out.email = value;
                        break;
          case "SMS"  : out.sms = value;
                        break;
          case "DMail": out.dmail = value;
                        break;
        }
      });
      this.updateALLOutReachFlag()    
    }

    updateALLOutReachFlag(){
      this.outReachDetails.forEach(function (out) {
        (out.phone && out.email && out.sms && out.dmail) ? out.all = true : out.all = false;
      });
    }
}
