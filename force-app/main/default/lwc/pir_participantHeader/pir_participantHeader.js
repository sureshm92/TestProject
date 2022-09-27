import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import rr_community_icons from '@salesforce/resourceUrl/rr_community_icons';
import getPEData from '@salesforce/apex/PIR_HomepageController.getPEData';
import updateParticipantDataSH from '@salesforce/apex/PIR_HomepageController.updateParticipantDataSH';
import createUserForPatientProtal from '@salesforce/apex/PIR_HomepageController.createUserForPatientProtal';
import PIR_Community_CSS from '@salesforce/resourceUrl/PIR_Community_CSS';
import { loadStyle } from 'lightning/platformResourceLoader';
import icon_printIcon from '@salesforce/resourceUrl/icon_printIcon';
import inviteToPP from '@salesforce/label/c.BTN_Create_User_on_PE_Info';
import preScreenParticipant from '@salesforce/label/c.BTN_Pre_Screen_Participant';
import Pdf_Not_Available from '@salesforce/label/c.Pdf_Not_Available';
import Janssen_Community_Template_Name from '@salesforce/label/c.Janssen_Community_Template_Name';
import RH_Send_to_DCT_Platform from '@salesforce/label/c.RH_Send_to_DCT_Platform';
import RH_Sent_to_DCT_Platform from '@salesforce/label/c.RH_Sent_to_DCT_Platform';
import PIR_Decentralized_Trials from '@salesforce/label/c.PIR_Decentralized_Trials';
import Records_sent_to_SH from '@salesforce/label/c.Records_sent_to_SH';
import Records_all_invited from '@salesforce/label/c.Records_all_invited';
import PG_MRR_R_Failed from '@salesforce/label/c.PG_MRR_R_Failed';
import PG_MRR_R_Passed from '@salesforce/label/c.PG_MRR_R_Passed';
import RH_Complete_Pre_Screener from '@salesforce/label/c.RH_Complete_Pre_Screener';
import PG_MRR_BTN_Back_to_My_Participant from '@salesforce/label/c.PG_MRR_BTN_Back_to_My_Participant';
import RH_Referred_by from '@salesforce/label/c.RH_Referred_by';
import RH_Pre_screen from '@salesforce/label/c.RH_Pre_screen'; 
import Invited_to_Patient_Portal from '@salesforce/label/c.Invited_to_Patient_Portal';
import Send_to_Dct_dob_error from '@salesforce/label/c.Send_to_Dct_dob_error';
export default class Pir_participantHeader extends LightningElement {
    @api partValid;
    printIcon = icon_printIcon;
    label = {
        inviteToPP,
        preScreenParticipant,
        Pdf_Not_Available,
        Janssen_Community_Template_Name,
        RH_Send_to_DCT_Platform,
        RH_Sent_to_DCT_Platform,
        Records_sent_to_SH,
        Records_all_invited,
        PG_MRR_R_Failed,
        PG_MRR_R_Passed,
        PG_MRR_BTN_Back_to_My_Participant,
        RH_Complete_Pre_Screener,
        RH_Referred_by,
        RH_Pre_screen,
        Invited_to_Patient_Portal,
        PIR_Decentralized_Trials
    };
    mrrPass = rr_community_icons +'/'+'icons.svg'+'#'+'icon-check-circle';
    mrrFail = rr_community_icons +'/'+'icons.svg'+'#'+'icon-close-circle';
    @api peId;
    @api firstName;
    @api lastName;
    @api refNumber;
    @api phoneNumber;
    @api studyName;
    @api siteName;
    @api referredBy;
    @api per;
    @api sendtoSH = false;
    @api isInvite = false;
    @api selectedPE;
    @api showAction = false;
    @api showActionbtnDisabled = false;
    @api showActionlabel ='';
    @api showActionName='';
    @api showActiondt = false;
    @api showActiondateTime = '';
    @api openMRR_Modal = false;
    @api openPreScreener_Modal = false;
    @api mrrLink = '';
    @api preScreenerLink = '';
    @api showPreScreener_Button = false;
    @api mrrResults = false;
    @api mrrPassed = false;
    @api preScreenerPassed = false;
    @api preScreenerCompleted = false;
    @api mrrCompleted = false;
    @api studySiteName = '';
    @api showPreScreen = false;
    @api participantName = '';
    @api btnToolTip = '';
    @api showPrinticon = false;
    @api isrtl = false;
    maindivcls;
    initialsName;

    connectedCallback() {
        loadStyle(this, PIR_Community_CSS)
    }

    @api
    doSelectedPI(){
        if(this.isrtl) {
            this.maindivcls = 'rtl';
        } else {
            this.maindivcls = 'ltr';
        }

        this.peId = this.selectedPE.id;
        this.firstName = this.selectedPE.firstName;
        this.lastName = this.selectedPE.lastName;
        this.initialsName = this.selectedPE.initialsName;
        this.refNumber = this.selectedPE.refId;
        this.phoneNumber = this.selectedPE.participantPhone;
        this.studyName = this.selectedPE.studyName;
        this.siteName = this.selectedPE.siteName;
        this.referredBy = this.selectedPE.source;
        this.studySiteName = this.selectedPE.studyName + ' - '+this.selectedPE.siteName;
        this.participantName = this.selectedPE.firstName + ' ' + this.selectedPE.lastName;// + ' ' +'('+this.selectedPE.refId+')';
        if(this.peId)
        {
             this.showPrinticon = true;
             getPEData({ peId: this.peId })
             .then((result) => {
                 this.preScreenerCompleted = false;
                 this.mrrCompleted = false;
                 this.per = result.per;
                 this.isAllowedForSH = result.isAllowedForSH;
                 this.mrrLink = this.per.Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c;
                 this.preScreenerLink = this.per.Clinical_Trial_Profile__r.Link_to_Pre_screening__c;
                    if(this.per.Participant__r.Adult__c == true && this.per.Participant__r.Email__c != null && this.per.Study_Site__r.Study_Site_Type__c == 'Traditional' && this.per.Clinical_Trial_Profile__r.CommunityTemplate__c != this.label.Janssen_Community_Template_Name && (this.per.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c || this.per.Study_Site__r.Suppress_Participant_Emails__c))
                    {
                        this.showAction = true;
                        this.showActionName = 'PP';
                        this.showActionbtnDisabled = true;
                        this.showActionlabel = this.label.inviteToPP;
                        this.showActiondt = false;
                        this.btnToolTip = this.label.inviteToPP;
                    }else if((this.per.Participant_Contact__r.Is_Patient_User_Created__c == false || this.per.Invited_To_PP_Date__c == null) && this.per.Clinical_Trial_Profile__r.CommunityTemplate__c != this.label.Janssen_Community_Template_Name &&
                              this.per.Participant__r.Adult__c == true && this.per.Participant__r.Email__c != null && this.per.Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c && this.per.Participant__r.Adult__c == true  &&  this.per.Participant__r.Email__c != null &&
                              this.per.Study_Site__r.Study_Site_Type__c != 'Virtual' && this.per.Study_Site__r.Study_Site_Type__c != 'Hybrid' && this.per.Participant__r.IsCountry_NOT_Eligible_for_Emails__c == false &&
                              this.per.Permit_IQVIA_to_contact_about_study__c)
                    {
                            this.showAction = true;
                            this.showActionName = 'PP';
                            this.showActionbtnDisabled = false;
                            this.showActionlabel = this.label.inviteToPP; 
                            this.showActiondt = false;  
                            this.btnToolTip = this.label.inviteToPP; 
                    }else if(this.per.Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c && this.per.Participant_Contact__r.Is_Patient_User_Created__c == true && this.per.Invited_To_PP_Date__c != undefined && this.per.Invited_To_PP_Date__c != null && this.per.Clinical_Trial_Profile__r.CommunityTemplate__c != this.label.Janssen_Community_Template_Name &&
                              this.per.Participant__r.Adult__c == true  &&  this.per.Participant__r.Email__c != null && this.per.Study_Site__r.Study_Site_Type__c != 'Virtual' && this.per.Study_Site__r.Study_Site_Type__c != 'Hybrid')  
                    {
                        this.showAction = true;
                        this.showActionName = 'PP';
                        this.showActionbtnDisabled = true;
                        this.showActionlabel = this.label.Invited_to_Patient_Portal; 
                        this.showActiondt = true;
                        this.showActiondateTime = this.per.Invited_To_PP_Date__c;
                        this.btnToolTip = this.label.Invited_to_Patient_Portal;
                    }else if(this.per.Clinical_Trial_Profile__r.Promote_to_SH__c && (this.per.Study_Site__r.Study_Site_Type__c == 'Hybrid' || this.per.Study_Site__r.Study_Site_Type__c == 'Virtual') && result.isAllowedForSH)
                    {
                        this.showAction = true;
                        this.showActionName = 'SH';
                        if(this.per.Clinical_Trial_Profile__r.Initial_Visit_Required__c && (this.per.Status_Order__c == '4' || this.per.Status_Order__c == '5')){
                            this.showActionbtnDisabled = false;
                        }else{
                            this.showActionbtnDisabled = false;
                        }
                        this.showActionlabel = this.label.RH_Send_to_DCT_Platform; 
                        this.showActiondt = false;
                        this.btnToolTip =  this.label.PIR_Decentralized_Trials;
                    }else if(this.per.Clinical_Trial_Profile__r.Promote_to_SH__c && (this.per.Study_Site__r.Study_Site_Type__c == 'Hybrid' || this.per.Study_Site__r.Study_Site_Type__c == 'Virtual') && !result.isAllowedForSH){
                        this.showAction = true;
                        this.showActionName = 'SH';
                        this.showActionbtnDisabled = true;
                        this.btnToolTip = this.label.PIR_Decentralized_Trials;
                        if(result.sendToSHDate != undefined){
                        this.showActionlabel = this.label.RH_Sent_to_DCT_Platform; 
                        this.showActiondt = true;
                        this.showActiondateTime = result.sendToSHDate;
                        }else{
                        this.showActionlabel = this.label.RH_Send_to_DCT_Platform; 
                        this.showActiondt = false;
                        }
                    }else{
                        this.showAction = false;
                        this.showActionName = 'NOPP';
                    }
                 if(((!this.per.MRR_Survey_Results_URL__c && 
                    this.per.Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c) ||
                    ((this.per.Pre_screening_Status__c!='Pass' && this.per.Pre_screening_Status__c !='Fail') &&
                        this.per.Clinical_Trial_Profile__r.Link_to_Pre_screening__c)) && 
                    result.preScreenAccess){
                        
                      this.showPreScreen = true;
                 }else{
                     this.showPreScreen = false;
                 }
                 if((this.per.Pre_screening_Status__c!='Pass' && this.per.Pre_screening_Status__c !='Fail') && 
                    this.per.Clinical_Trial_Profile__r.Link_to_Pre_screening__c){
                    this.showPreScreener_Button = true;
                 }else{
                    this.showPreScreener_Button = false;
                 }
 
             })
             .catch((error) => {
                 this.error = error;
                 console.log(error);
                 this.showErrorToast(JSON.stringify(error.body.message));
             });
 
         }  
        
    }

    doPrint(){
         if(communityService.isMobileSDK()){
             const evt = new ShowToastEvent({
                 title: '',
                 message: this.label.Pdf_Not_Available,
                 variant: 'info',
             });
             this.dispatchEvent(evt);
         }else{
            window.open('patient-info-pv?id=' + this.peId, '_blank', 'noopener');
         }
         
    }

    doPrescreen(){
        if(!this.per.MRR_Survey_Results_URL__c && 
            this.per.Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c && this.mrrCompleted === false){
        this.openMRR_Modal = true;
            }else if ((this.per.Pre_screening_Status__c!='Pass' && this.per.Pre_screening_Status__c !='Fail') && 
                this.per.Clinical_Trial_Profile__r.Link_to_Pre_screening__c && this.preScreenerCompleted === false){
                    this.openPreScreener_Modal = true;
                }
    }

    closeMRR_Modal(){
        this.openMRR_Modal = false;
        this.mrrResults = false;
    }


    
    pre_Eligibility(){
        this.mrrResults = false;
        this.openMRR_Modal = false;
        this.openPreScreener_Modal = true;
    }

    closePreScreener_Modal(){
        this.mrrResults = false;
        this.preScreenerResults = false;
        this.openPreScreener_Modal = false;
    }

    get checkAction(){
        if(this.showActionName == "PP"){
            return true;
        }else{
            return false;
        }
    }
    
    @api
    doMrrResult(event){
       this.mrrResults = true;
       if(event.detail.result == 'Pass'){
          this.mrrPassed = true;
       }else{
          this.mrrPassed = false;
       }
       if(event.detail.result == 'Pass' || event.detail.result == 'Fail'){
           this.mrrCompleted = true;
       }
       if((this.per.Pre_screening_Status__c!='Pass' && this.per.Pre_screening_Status__c !='Fail') && 
        this.per.Clinical_Trial_Profile__r.Link_to_Pre_screening__c && this.mrrCompleted && this.showPreScreen){
            this.showPreScreen = true;
        }
    }

    @api
    doPreScreenerResult(event){
       this.preScreenerResults = true;
       if(event.detail.result == 'Pass'){
          this.preScreenerPassed = true;
          this.showPreScreen = false;
          this.showPreScreener_Button = false;
       }else{
          this.preScreenerPassed = false;
          this.showPreScreen = false;
          this.showPreScreener_Button = false;
       }
       if(event.detail.result == 'Pass' || event.detail.result == 'Fail'){
        this.preScreenerCompleted = true;
    }
    }

    doAction(){
        if(this.showActionName == 'PP'){
            if(!this.mrrResults){
                const custEventSpinner = new CustomEvent(
                    'handlespinner', {
                        detail: true 
                    });
                this.dispatchEvent(custEventSpinner);
            }
            createUserForPatientProtal({ peId: this.peId })
            .then((result) => {
                this.showSuccessToast(this.label.Records_all_invited);
                this.showAction = true;
                this.showActionName = 'PP';
                this.showActionbtnDisabled = true;
                this.showActionlabel = this.label.Invited_to_Patient_Portal; 
                this.showActiondt = true;
                this.showActiondateTime = result;
            })
            .catch((error) => {
                console.log(error);
                this.showErrorToast(JSON.stringify(error.body.message));
            })
            .finally(() => {
                if(!this.mrrResults){
                    const custEventSpinner = new CustomEvent(
                        'handlespinner', {
                            detail: false 
                        });
                    this.dispatchEvent(custEventSpinner);
                }
            })
        }
        if(this.showActionName == 'SH'){
            if(this.per.Is_Participant_DOB_Valid__c){
                if(!this.mrrResults){
                    const custEventSpinner = new CustomEvent(
                        'handlespinner', {
                            detail: true 
                        });
                    this.dispatchEvent(custEventSpinner);
                }
                updateParticipantDataSH({ peId: this.peId })
                .then((result) => {
                    this.showSuccessToast(this.label.Records_sent_to_SH);
                    this.showActiondateTime = result;
                    this.showAction = true;
                    this.showActionName = 'SH';
                    this.showActionbtnDisabled = true;
                    this.showActionlabel = this.label.RH_Sent_to_DCT_Platform; 
                    this.showActiondt = true; 
                    const selectEventHeader = new CustomEvent('callparticipantparent', {});
                    this.dispatchEvent(selectEventHeader);
                })
                .catch((error) => {
                    this.showErrorToast(JSON.stringify(error.body.message));
                    console.log(error);
                })
                .finally(() => {
                    if(!this.mrrResults){
                        const custEventSpinner = new CustomEvent(
                            'handlespinner', {
                                detail: false 
                            });
                        this.dispatchEvent(custEventSpinner);
                    }
                })
            }
            else{
                const evt = new ShowToastEvent({
                    title: Send_to_Dct_dob_error,
                    message: Send_to_Dct_dob_error,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                this.dispatchEvent(new CustomEvent('gotodetail'));
            }
        }
    }

     showErrorToast(msg) {
         const evt = new ShowToastEvent({
             title: msg,
             message: msg,
             variant: 'error',
             mode: 'dismissible'
         });
         this.dispatchEvent(evt);
     }

     showSuccessToast(msg) {
        const evt = new ShowToastEvent({
            title: msg,
            message: msg,
            variant: 'success',
            mode: 'dismissible'
        });
        this.dispatchEvent(evt);
    }
}