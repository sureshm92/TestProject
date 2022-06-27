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
import PP_Communication_Pref_Outreach_consentA from '@salesforce/label/c.PP_Communication_Pref_Outreach_consentA';
import PP_Communication_Pref_Outreach_consentB from '@salesforce/label/c.PP_Communication_Pref_Outreach_consentB';
import PP_Communication_Pref_Outreach_consentC from '@salesforce/label/c.PP_Communication_Pref_Outreach_consentC';
import PP_Communication_Pref_Blank_Del from '@salesforce/label/c.PP_Communication_Pref_Blank_Del';
import PP_Communication_Pref_savechanges from '@salesforce/label/c.PP_Communication_Pref_savechanges';
//END TO DO

import getStudiesConsent from "@salesforce/apex/PreferenceManagementController.getStudiesConsent";
import getOutreachConsent from "@salesforce/apex/PreferenceManagementController.getOutreachConsent";
import saveConsent from "@salesforce/apex/PreferenceManagementController.saveConsent";
import getInitData from "@salesforce/apex/AccountSettingsController.getInitData";
import getisRTL from '@salesforce/apex/PreferenceManagementController.getIsRTL';

import { loadScript } from 'lightning/platformResourceLoader';
import rrCommunity from '@salesforce/resourceUrl/rr_community_js';


export default class CommunicationPreferences extends NavigationMixin(LightningElement) {

@api isDelegate;
@api participantState;
@api isDesktop;
@api consentPreferenceData;
@api userMode;
		
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
    PP_Communication_Pref_Blank_Del,
    PP_Communication_Pref_savechanges
  };

    @track studyDetails = [];
    @track outReachDetails= [];
  	@track consentPreferenceDataLocal = [];

    spinner = false;
    loaded = false;
    isPrivacyPolicy = false;
    showIQIVAOutreachConsentFlag = false;
    showStudyConsentFlag = false;
    hideConsentsForParticipantView = false;
    hideConsentsForDelegateView = false;
    isParticipantLoggedIn = false;
    isPrimaryDelegate = false;
    isDelegateSelfView = false;
    isAdultParticipant = false;
    isEmailAvailabelForParticipant = false;
    currentPERId = "";
    updatedPerRecord = {};
    commPrefForPrivacyPolicy = true;

    studyError = false;
		outreachError = false;

    debugger;
    //@track phoneSvg = rr_community_icons +'/'+'logo.svg';
    phoneSvg = rr_community_icons +'/'+'com-phone.svg'+'#'+'com-phone';
    emailSvg = rr_community_icons +'/'+'com-email.svg'+'#'+'com-email';
    smsSvg = rr_community_icons +'/'+'com-sms.svg'+'#'+'com-sms';
    dmailSvg = rr_community_icons +'/'+'com-dmail.svg'+'#'+'com-dmail';
    allSvg = rr_community_icons +'/'+'com-all.svg'+'#'+'com-all';

    @wire(getOutreachConsent)
    outReachConsent({ error, data }) {
        if (data) {
            this.outReachDetails = JSON.parse(data);
        } else if (error) {
            console.log(JSON.stringify(error));
        }
    }

    connectedCallback(){

      // Get Initial Load Data 
      this.spinner = true;

      getInitData({ userMode: this.userMode}) 
      .then((result) => {          
            this.spinner = false;
            let data = JSON.parse(result).consentPreferenceData;
            this.consentPreferenceDataLocal = data;
            this.consentPreferenceDataLocal.perList.forEach(function (study) {
              study["all"] = false;
            });
            this.updateALLFlag();
            this.setConsentVisibility();
      })
      .catch((error) => {
        communityService.showToast(
          'error',
          'error',
          'Failed To read the Data...',
            100
        );
        this.spinner = false;
      });
      
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
                console.error('Error RTL: ' + JSON.stringify(error));
            });
      }   
    }

    openPrivacyPolicy(){
        debugger;
        this.isPrivacyPolicy = true;
        this.commPrefForPrivacyPolicy = true;
    }

    closePrivacyPolicy(){
        debugger;
        this.isPrivacyPolicy = false;
    }

    redirectToProfileInfoTab(){
        window.history.replaceState(null, null, "?profileInformation");
        window.location.reload(true);
    }

    setConsentVisibility(){
      this.isParticipantLoggedIn =this.consentPreferenceDataLocal.isParticipantLoggedIn;
      this.isPrimaryDelegate = this.consentPreferenceDataLocal.isPrimaryDelegate;
      this.isDelegateSelfView = this.consentPreferenceDataLocal.isDelegateSelfView;
      this.isAdultParticipant = this.consentPreferenceDataLocal.isAdultParticipant;
      this.isEmailAvailabelForParticipant = this.consentPreferenceDataLocal.isEmailAvailabelForParticipant;

      //Check IQVIA Outreach Consent Visibility
      if(this.showIQVIAOutreachConsent()){
        this.showIQIVAOutreachConsentFlag=true;
      }
      //Check Study Consent Visibility
      if(this.showStudyConsent()){
        this.showStudyConsentFlag=true;
      }
      //Hide consents for Participant view
      /*if(!this.showIQIVAOutreachConsentFlag && !this.showStudyConsentFlag){
        if(this.isParticipantLoggedIn){
          this.hideConsentsForParticipantView = true;
        }else{
          this.hideConsentsForDelegateView = true;
        }       
      }
      */
      if(!this.showIQIVAOutreachConsentFlag && !this.showStudyConsentFlag){
        if(!this.isParticipantLoggedIn && !this.isDelegateSelfView){
          this.hideConsentsForParticipantView = true;
          console.log('Hide for participant View');
        }else if(!this.isParticipantLoggedIn && this.isDelegateSelfView){
          this.hideConsentsForDelegateView = true;
          console.log('Hide for Delegate self View');
        }       
      }
    }

    resetSpinner(){
      if(this.consentPreferenceDataLocal.perList.length == 0 || this.consentPreferenceDataLocal.perList.length ==0){
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
      debugger;
      this.updateStudyData(event.target.label, event.target.checked, event.target.name);         
    }

    selectIndividualOptions(event){
      this.updateStudyData(event.target.label, event.target.checked, event.target.name);  
    }

    updateStudyData(label, value, studyId){
      debugger;
      console.log("data in update study");
      this.currentPERId = studyId;
      console.log(this.consentPreferenceDataLocal)
      if(label == "All"){
          this.consentPreferenceDataLocal.perList.forEach(function (study) {
              debugger;             
              // opt IN/ opt Out Phone, Email, Direct Email, SMS at Study Level 
              if(study.Id == studyId){ // per id matching
                study.Permit_Voice_Text_contact_for_this_study__c = study.Permit_Mail_Email_contact_for_this_study__c = study.Study_Direct_Mail_Consent__c = study.Permit_SMS_Text_for_this_study__c = value;
              }
          });
      }
      else{
        this.consentPreferenceDataLocal.perList.forEach(function (study) {
          // If not clicked on All - Individual operaton
          debugger;
          console.log(study.Permit_Voice_Text_contact_for_this_study__c);
          (study.Id == studyId && label == "Phone" ? 
              study.Permit_Voice_Text_contact_for_this_study__c = value : 
              (study.Id == studyId && label == "Email" ? 
                study.Permit_Mail_Email_contact_for_this_study__c = value:
                (study.Id == studyId && label == "SMS" ? 
                study.Permit_SMS_Text_for_this_study__c = value:
                 (study.Id == studyId && label == "DMail" ?  
                   study.Study_Direct_Mail_Consent__c = value: ""))));        
        });
      } 
      this.updateALLFlag();
      debugger;
      this.doSaveCommunicationPref();    
    }

    // Helper Method : To Update ALL flag comparing phone, email, sms and direct email at study as well as sponsor level
    updateALLFlag(){
      debugger;
      this.consentPreferenceDataLocal.perList.forEach(function (study) {
        (study.Permit_Voice_Text_contact_for_this_study__c && study.Permit_Mail_Email_contact_for_this_study__c && study.Permit_SMS_Text_for_this_study__c && study.Study_Direct_Mail_Consent__c) ? study.all = true : study.all = false;
      });
    }

    // Save Communication Pref data
    doSaveCommunicationPref(){  
      debugger;
      this.spinner = true;
      let perObj = {};
      let perId = this.currentPERId;
      this.consentPreferenceDataLocal.perList.forEach(function (perRecord) {
              
        if(perRecord.Id == perId){      
            perObj.perId	= perRecord.Id;
            perObj.ParticipantContId	=	perRecord.Participant__r.Contact__c;
            perObj.participantOptInEmail = perRecord.Permit_Mail_Email_contact_for_this_study__c;
            perObj.participantOptInSMSText = perRecord.Permit_SMS_Text_for_this_study__c;
            perObj.participantOptInPhone = perRecord.Permit_Voice_Text_contact_for_this_study__c;
            perObj.participantOptInDirectEmail = perRecord.Study_Direct_Mail_Consent__c;
        }
      });
      //saveConsent({ studyData: perObj, outReachData: this.outReachDetails })
      saveConsent({ studyDataJSON: JSON.stringify(perObj), outReachData: this.outReachDetails }) //kk
        .then((result) => {          
              this.spinner = false;
              communityService.showToast(
                'success',
                'success',
                'Record Saved Successfully...',
								100
              );
        })
        .catch((error) => {
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
		
    //Set Visibility if IQVIA Outreach Consent
		 showIQVIAOutreachConsent() {
      //If IQVIA Outreach Consent is ON at CTP then only IQVIA Outreach Consent section should be visible.
      if(this.consentPreferenceDataLocal.isIQIVAOutrechToggleOnAtCTP){
        //If Participant Visit at Communication Preference tab at his Account setting.
        // Or Primary delegate visit Communication Preference tab at Participant's Account setting.
        //TODO: 1. What should happen  when the normal delegate of adult participant with email -   should be able to update the consents on behalf ?
        if(this.isParticipantLoggedIn || (this.isPrimaryDelegate && !this.isDelegateSelfView)){
          //this.showIQIVAOutreachConsentFlag=true;
          return true;
        }
        //If Delegate Visits Communication Preference tab of his own Account setting(self View).
        if(this.isDelegateSelfView){
          //If Delegate is not primary Delegate, then don't show IQVIA Outreach Consent to Delegate.
          if(this.isPrimaryDelegate){
            return true;
          }
          //If Delegate is primary Delegate of Minor Participant, then show IQVIA Outreach Consent to Delegate.
          /*if(isPrimaryDelegate && !isAdultParticipant){
            //this.showIQIVAOutreachConsentFlag=true;
            return true;
          }
          */
          //If Delegate is primary Delegate of Adult Participant but Adult Participant has no Email then show IQVIA Outreach Consent to Delegate.
          /*
          if(isPrimaryDelegate && isAdultParticipant){
            if(!isEmailAvailabelForParticipant){
              //this.showIQIVAOutreachConsentFlag=true;
              return true;
            }else{
              return false;
            }
          }
          */
        }
      }
      return false;
  }
  //Set Visibility of Study Consent
   showStudyConsent() {
    //If Participant Visit at Communication Preference tab at his Account setting.
    // Or Primary delegate visit Communication Preference tab at Participant's Account setting.
    //TODO: 1. What should happen  when the normal delegate of adult participant with email -   should be able to update the consents on behalf ?
    if(this.isParticipantLoggedIn || (this.isPrimaryDelegate && !this.isDelegateSelfView)){
      return true;
    }
    //If Delegate Visits Communication Preference tab of his own Account setting(self View), donw show study Consent. 
    if(this.isDelegateSelfView){
      return false;
    }
    return false;
  }
}