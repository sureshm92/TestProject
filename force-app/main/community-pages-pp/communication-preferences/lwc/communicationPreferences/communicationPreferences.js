import { LightningElement, track, api, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import rr_community_icons from '@salesforce/resourceUrl/rr_community_icons';
import PP_Communication_Pref from '@salesforce/label/c.PP_Communication_Pref';
import PP_Communication_Pref_Study from '@salesforce/label/c.PP_Communication_Pref_Study';
import PP_Communication_Pref_Study_consent from '@salesforce/label/c.PP_Communication_Pref_Study_consent';
import PP_Communication_Pref_Phone from '@salesforce/label/c.PP_Communication_Pref_Phone';
import PP_Communication_Pref_Email from '@salesforce/label/c.PP_Communication_Pref_Email';
import PP_Communication_Pref_SMS from '@salesforce/label/c.PP_Communication_Pref_SMS';
import PP_Communication_Pref_Dmail from '@salesforce/label/c.PP_Communication_Pref_Dmail';
import PP_Communication_Pref_All from '@salesforce/label/c.PP_Communication_Pref_All';
import PP_Communication_Pref_Outreach from '@salesforce/label/c.PP_Communication_Pref_Outreach';
import PP_Communication_Pref_Outreach_consent from '@salesforce/label/c.PP_Communication_Pref_Outreach_consent';
import PP_Communication_Pref_savechanges from '@salesforce/label/c.PP_Communication_Pref_savechanges';
//END TO DO

import getStudiesConsent from "@salesforce/apex/PreferenceManagementController.getStudiesConsent";
import getOutreachConsent from "@salesforce/apex/PreferenceManagementController.getOutreachConsent";
import saveConsent from "@salesforce/apex/PreferenceManagementController.saveConsent";
import getisRTL from '@salesforce/apex/PreferenceManagementController.getIsRTL';

import { loadScript } from 'lightning/platformResourceLoader';
import rrCommunity from '@salesforce/resourceUrl/rr_community_js';


export default class CommunicationPreferences extends NavigationMixin(LightningElement) {

  @api isDelegate;
	@api participantState;
	@api isDesktop;
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
    PP_Communication_Pref_Outreach_consent,
    PP_Communication_Pref_savechanges
  };

    @track studyDetails = [];
    @track outReachDetails= [];
		

    spinner = false;
    loaded = false;
    isPrivacyPolicy = false;

    debugger;
    //@track phoneSvg = rr_community_icons +'/'+'logo.svg';
    phoneSvg = rr_community_icons +'/'+'com-phone.svg'+'#'+'com-phone';
    emailSvg = rr_community_icons +'/'+'com-email.svg'+'#'+'com-email';
    smsSvg = rr_community_icons +'/'+'com-sms.svg'+'#'+'com-sms';
    dmailSvg = rr_community_icons +'/'+'com-dmail.svg'+'#'+'com-dmail';
    allSvg = rr_community_icons +'/'+'com-all.svg'+'#'+'com-all';

    
    @wire(getStudiesConsent)
    studyConsent({ error, data }) {
        if (data) {
            debugger;
            this.studyDetails = JSON.parse(data);
        } else if (error) {
            console.log(JSON.stringify(error));
        }
        this.resetSpinner();
    }
    @wire(getOutreachConsent)
    outReachConsent({ error, data }) {
        if (data) {
            this.outReachDetails = JSON.parse(data);
        } else if (error) {
            console.log(JSON.stringify(error));
        }
        this.resetSpinner();
    }

    connectedCallback(){
      this.resetSpinner()
      if (!this.loaded) {
        loadScript(this, rrCommunity).then(() => {
            if (communityService.isMobileSDK()) {
                debugger;
                this.isDesktop = false;
            }
        });
        getisRTL()
            .then((data) => {
                debugger;
                this.isRTL = data;
            })
            .catch(function (error) {
                console.error('Error: ' + JSON.stringify(error));
            });
        }
    }

    resetSpinner(){
      if(this.studyDetails.length == 0 || this.outReachDetails.length ==0){
        this.spinner = true;
      }
      else{
        this.spinner = false;
      }
    }

    get cardRTL() {
      return this.isRTL ? 'cardRTL' : '';
    }

    get borderStyle(){
      return this.isRTL ? 'study-paramters border-left' : 'study-paramters border-right'
    }

    renderedCallback(){
    }

    selectAllOptions(event){
      this.updateStudyData(event.target.label, event.target.checked, event.target.name, event.target.getAttribute("data-sponsor"));         
    }

    selectIndividualOptions(event){
      this.updateStudyData(event.target.label, event.target.checked, event.target.name, event.target.getAttribute("data-sponsor"));  
    }

    updateStudyData(label, value, studyId, sponsorId){
      debugger;
      if(label == "All"){
          this.studyDetails.forEach(function (study) {
              debugger;             
              // opt IN/ opt Out Phone, Email, Direct Email, SMS at Study Level 
              if(study.study_id == studyId){
                study.phone = study.email = study.dmail = study.sms = value;
              }
          });
      }
      else{
        this.studyDetails.forEach(function (study) {
          // If not clicked on All - Individual operaton
          (study.study_id == studyId && label == "Phone" ? 
              study.phone = value : 
              (study.study_id == studyId && label == "Email" ? 
                study.email = value:
                (study.study_id == studyId && label == "SMS" ? 
                study.sms = value:
                 (study.study_id == studyId && label == "DMail" ?  
                   study.dmail = value: ""))));        
        });
      } 
      this.updateALLFlag();
      this.doSaveCommunicationPref();    
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
      this.spinner = true;
      saveConsent({ studyData: this.studyDetails, outReachData: this.outReachDetails })
        .then((result) => {
            setTimeout(() => {
              this.spinner = false;
              // this.showCustomToast("Success", "Record Saved Successfully", "success");
              communityService.showToast(
                'success',
                'success',
                'Record Saved Successfully...',
								100
              );
            }, 1000); 
        })
        .catch((error) => {
          // this.showCustomToast("Error", "Failed To save the Record", "error");
          communityService.showToast(
            'error',
            'error',
            'Failed To save the Record...',
							100
          );
          this.spinner = false;
        });
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
      this.updateALLOutReachFlag();
      this.doSaveCommunicationPref(); 
    }

    updateALLOutReachFlag(){
      this.outReachDetails.forEach(function (out) {
        (out.phone && out.email && out.sms && out.dmail) ? out.all = true : out.all = false;
      });
    }
		//Return True if Delegate is logged in as self View
		get isDelegateSelfView() {
				//TODO: Cover this part as part of PEH-5844 - UI part in Iteration 3.2
				/*
				  if (this.participantState === 'ALUMNI' && !this.isDelegate){
						return true;
				}
				*/
				return false;
		}
}