import { LightningElement,api,track,wire } from 'lwc';
import pirResources from '@salesforce/resourceUrl/pirResources';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getParticipantDelegates from '@salesforce/apex/ParticipantInformationRemote.getParticipantDelegates';
import getParticipantPDER from '@salesforce/apex/ParticipantInformationRemote.getParticipantPDER';
import updateParticipantAndDelegates from '@salesforce/apex/ParticipantInformationRemote.updateParticipantAndDelegates';
import getHCPData from '@salesforce/apex/PIR_SharingOptionsController.getHCPData';
import getpeData from '@salesforce/apex/PIR_SharingOptionsController.getpeData';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import { label } from "c/pir_label";
import PG_AC_Select from '@salesforce/label/c.PG_AC_Select';
import RH_RP_Record_Saved_Successfully from '@salesforce/label/c.RH_RP_Record_Saved_Successfully';
import RH_MOB from '@salesforce/label/c.RH_MOB';
import RH_YOB from '@salesforce/label/c.RH_YearofBirth';
import RH_DOB from '@salesforce/label/c.RH_DOB';
import Age from '@salesforce/label/c.Age';
import January from '@salesforce/label/c.January'
import February from '@salesforce/label/c.February'
import March from '@salesforce/label/c.March'
import April from '@salesforce/label/c.April'
import May from '@salesforce/label/c.May'
import June from '@salesforce/label/c.June'
import July from '@salesforce/label/c.July'
import August from '@salesforce/label/c.August'
import September from '@salesforce/label/c.September'
import October from '@salesforce/label/c.October'
import November from '@salesforce/label/c.November'
import December from '@salesforce/label/c.December'
import Dateofbirth from '@salesforce/label/c.Date_of_Birth';
import Monthyearofbirth from '@salesforce/label/c.Month_and_Year_of_Birth';
import Yearofbirth from '@salesforce/label/c.Year_of_Birth';
export default class Pir_participantEmancipated extends LightningElement {
    DOB = RH_DOB;
    YOB = RH_YOB;
    MOB = RH_MOB;
    labels = {
        Dateofbirth,
        Monthyearofbirth,
        Yearofbirth
    };
    Age = Age;
    @api openModal = false;
    @api currentTab = "0";
    @api selectedPE;
    @track utilLabels = label;
    addDelegateList = [];
    addDelegateListNew = [];
    addDelegate = 0;
    addHCPList = [];
    addHCPListNew = [];
    inviteOptions = false;
    delegates = [];
    delegatesConsents = [];
    hcpDelegates = [];
    @api studySiteId = '';
    @api participant;
    @api siteid='';
    @api iscountryus=false;
    @api isvirtualsite = false;loading = false;
    @api participantMsgWithName = '';
    @api countryStateInfo=[];
    @api contactstates = [];
    @api countryList;
    @api phoneType = [];
    @api genderType = [];
    @api isValid = false;
    @api isDelValid = false;
    @api isNewDelValid = false;
    isDelConsentValid = false;
    @api pathdetails = [];
    @api finalAgree = false;
    @api participantContact;
    @api showInvite = false;
    @api communityTemplate;
    @api siteSuppressEmail;
    @api studySuppressEmail;
    @api eligibleToInvite = false;
    @api isInvited = false;
    @api saving = false;
    @api participantload = false;
    @api isJanssen = false;statesByCountryMap;
    checkIcon = pirResources+'/pirResources/icons/status-good.svg';
    noneIcon = pirResources+'/pirResources/icons/circle.svg';
    nonecls = 'neutral';    
    
    //DOB
    isDayMandate = false;
    isMonthMandate = false;
    monthName;
    monthmap = new Map([
        ["01" ,January],["02", February], ["03", March],["04" ,April],
        ["05", May], ["06", June],["07" ,July],["08", August],
        ["09", September], ["10", October],["11", November], ["12", December]
    ]);
    @api maindivcls;
    @api alreadyconsentedrow;
    
    label = {
        PG_AC_Select,
        RH_RP_Record_Saved_Successfully
    };
    @api
    doExecute(){
        this.openModal = true;
        this.saving = true;
        loadScript(this, RR_COMMUNITY_JS)
        .then(() => {
            this.communityTemplate = communityService.getCurrentCommunityTemplateName();
            this.getInitialData();
        }).catch((error) => {
             console.log('Error: ' + error);
             this.saving = false;
             this.showErrorToast(error);
        });
      this.pathdetails = [];
       var path = {
          isStatusPassed : false,
          styleName:'slds-col width-basis vpi-state neutral current',
          styleName1:'slds-col width-basis vpi-line-div neutral',
          styleName2:'slds-col width-basis vpi-line-div neutral',
          pathName : this.utilLabels.PP_Participant
       }
       this.pathdetails.push(path);
       path = {};
       path = {
        isStatusPassed : false,
        styleName:'slds-col width-basis vpi-state neutral',
        styleName1:'slds-col width-basis vpi-line-div neutral',
        styleName2:'slds-col width-basis vpi-line-div neutral',
        pathName : this.utilLabels.PP_Delegate
       }
       this.pathdetails.push(path);
       path = {};
       path = {
        isStatusPassed : false,
        styleName:'slds-col width-basis vpi-state neutral',
        styleName1:'slds-col width-basis vpi-line-div neutral',
        styleName2:'slds-col width-basis vpi-line-div neutral',
        pathName : this.utilLabels.PP_Provider_Access
       }
       this.pathdetails.push(path);
       path = {};
       path = {
        isStatusPassed : false,
        styleName:'slds-col width-basis vpi-state neutral',
        styleName1:'slds-col width-basis vpi-line-div neutral',
        styleName2:'slds-col width-basis vpi-line-div neutral',
        pathName : this.utilLabels.PP_Review_and_Confirm
       }
       this.pathdetails.push(path);
    }
    get isAgreed(){
        if(this.finalAgree){
            return false;
        }else{
            return true;
        }
    }
    handleagree(event){
        this.finalAgree = event.target.checked;
    }
    @api mailingCountry;@api mailingState;
    getInitialData(){
        getParticipantPDER({participantId: this.selectedPE.participantId,perId: this.selectedPE.id })
        .then((result) => {
            for(let i = 0; i < result.ParticipantList.length; i++) {
                result.ParticipantList[i].isConnected = true;   
                result.ParticipantList[i].selectedOption = '1';   
                result.ParticipantList[i].continue = true;
                result.ParticipantList[i].donotcontinue = false;
                if(!result.ParticipantList[i].Phone_Type__c){
                    result.ParticipantList[i].Phone_Type__c = 'Home';
                }
                //delegateconsent
                for(let j = 0; j < result.ParticipantConsent.length; j++) {
                    if(result.ParticipantList[i].Id == result.ParticipantConsent[j].delgParticipantId){
                    result.ParticipantList[i].delgParticipantId = result.ParticipantConsent[j].delgParticipantId;
                    result.ParticipantList[i].Study_Email_Consent = result.ParticipantConsent[j].Study_Email_Consent;
                    result.ParticipantList[i].Study_info_storage_consent = result.ParticipantConsent[j].Study_info_storage_consent;
                    result.ParticipantList[i].Study_Phone_Consent = result.ParticipantConsent[j].Study_Phone_Consent;
                    result.ParticipantList[i].Study_SMS_Consent = result.ParticipantConsent[j].Study_SMS_Consent;
                    result.ParticipantList[i].partEnrollId = result.ParticipantConsent[j].partEnrollId;
                    }
                }        
            }
            this.delegates = result.ParticipantList;
            this.delegatesConsents = result.ParticipantConsent;
            for(let i=0; i < this.delegates.length;i++){
                let partmsgname = this.utilLabels.PG_Ref_L_Delegate_continue_be_delegate;
                var partmsg = partmsgname.replace("##delegateName",this.delegates[i].First_Name__c+' '+this.delegates[i].Last_Name__c);
                this.delegates[i].continueDelegateMsg=partmsg;
                if(!this.delegates[i].Phone_Type__c){
                    this.delegates[i].Phone_Type__c = 'Home';
                }
                this.delegates[i].index = i;
                this.delegates[i].isCont = "true";
                this.delegates[i].delegcont = this.utilLabels.Continue;
            }
        }).then(()=> {
            getHCPData({peId:this.selectedPE.id})
            .then((result) => {
                this.hcpDelegates = result;
            })
        }).then(()=> {
            getpeData({peId: this.selectedPE.id, participantId:this.selectedPE.participantId})
            .then((result) => { 
                this.countryList = result.countriesLVList;
                this.statesByCountryMap = result.statesByCountryMap;
                this.mailingCountry =  result.participant.Mailing_Country__c;
                this.mailingState =  result.participant.Mailing_State__c;
                delete result.participant.Mailing_Country__c;
                delete result.participant.Mailing_State__c;
                let participant = result.participant;
                this.contactstates=[];
                this.contactstates=this.statesByCountryMap[result.participant.Mailing_Country_Code__c];
                this.iscountryus=(result.participant.Mailing_Country_Code__c=='US'? true : false);
                Object.assign(participant, {
                    attributes: {
                        type: 'Participant__c'
                    }
                });
                this.participantMsgWithName = '';
                this.participant = participant;
                this.participant.Emancipation_in_progress__c = false;
                let partcontact = {
                    sObjectType: 'Contact',
                    Id: this.participant.Contact__c,
                    Consent_To_Inform_About_Study__c: false
                };
                this.participantContact = partcontact;
                this.isvirtualsite = result.isVirtualSite;
                this.siteid = result.studySiteId;
                this.showInvite = (!result.isVirtualSite && result.isPPEnabled);
                if(this.communityTemplate == 'Janssen'){
                    this.showInvite = false;  
                    this.isJanssen = true;
                }
                this.isInvited = result.isInvited;
                if(this.isInvited){
                    this.showInvite = false;
                }
                if(!result.siteSuppressEmail && !result.studySuppressEmail){
                    this.eligibleToInvite = true; 
                }
                this.phoneType = result.getphoneTypeLVList;
                this.genderType = result.getGenderList;
                let partmsgname = this.utilLabels.PG_Ref_L_Participant_require_invitation;
                var partmsg = partmsgname.replace("##participantName",this.participant.First_Name__c+' '+this.participant.Last_Name__c);
                this.participantMsgWithName = partmsg;
                if(!this.participant.Alternative_Phone_Type__c || !this.participant.Alternative_Phone_Number__c){
                    this.participant.Alternative_Phone_Type__c = 'Home';
                }
                this.studyDobFormat = result.dobconfig;
                if(participant.Birth_Day__c){
                    this.valueDD = participant.Birth_Day__c.toString();
                    console.log("participant.Birth_Day__c"+participant.Birth_Day__c);
                }
                if(participant.Birth_Month__c){
                console.log("participant.Birth_Month__c"+participant.Birth_Month__c);
                    this.monthName = this.monthmap.get(this.participant.Birth_Month__c);
                    this.valueMM = participant.Birth_Month__c.toString();
                }
                this.valueYYYY = participant.Birth_Year__c;
                if(participant.Age__c){
                    this.participantSelectedAge = participant.Age__c.toString();
                }
                if(result.dobconfig.includes("DD")){
                    this.isDayMandate=true;
                    this.calculateAge();
                }
                if(result.dobconfig.includes("MM")){
                    this.isMonthMandate=true;
                }
                //new change
                for(let i=0; i < this.delegates.length;i++){
                    if(this.iscountryus){
                        if(this.delegates[i].Study_Email_Consent == true &&
                           this.delegates[i].Study_info_storage_consent == true &&
                           this.delegates[i].Study_Phone_Consent == true && 
                           this.delegates[i].Study_SMS_Consent == true  )
                           {
                            this.delegates[i].alreadyConsented = true;
                            this.delegates[i].alreadyconsentedrow = false;
                           }else{
                            this.delegates[i].alreadyConsented = false;
                            this.delegates[i].alreadyconsentedrow = false;
                           }
                    }else{
                        if(this.delegates[i].Study_Email_Consent == true &&
                            this.delegates[i].Study_info_storage_consent == true &&
                            this.delegates[i].Study_Phone_Consent == true )
                            {
                             this.delegates[i].alreadyConsented = true;
                             this.delegates[i].alreadyconsentedrow = true;
                            }else{
                             this.delegates[i].alreadyConsented = false;
                             this.delegates[i].alreadyconsentedrow = false;
                            }
                    }
                   
                }

            }).then(()=> {
                this.currentTab = "1"; 
                this.customButtonValidation();
                this.saving = false;
            })
        }).catch((error) => {
            console.log(error);
            this.saving = false;
        });
    }
    get checkEligibility(){
        if(this.eligibleToInvite){
            return false;
        }else{
            return true;
        }
    }
    handleNewDelegate(){
        this.addDelegate = this.addDelegate + 1;
        let hcpDelegateList = [
            {
                em:'',
                fn:'',
                ln:'',
                continueDelegatenewMsg:'',
                indexNumber: this.addDelegate,
                isConnected:false
            }
        ];
        this.addDelegateListNew = [...this.addDelegateListNew, ...hcpDelegateList]; 
    }
    hanldeProgressValueChangeDelegates(event){
        let indexvalue = event.detail.indx - 1;
        this.addDelegateListNew[indexvalue].em = event.detail.em;
        this.addDelegateListNew[indexvalue].fn = event.detail.fn;
        this.addDelegateListNew[indexvalue].ln = event.detail.ln;
        this.addDelegateListNew[indexvalue].by = event.detail.by;
        this.addDelegateListNew[indexvalue].cb = event.detail.cb;
        this.addDelegateListNew[indexvalue].val = event.detail.val;
        this.addDelegateListNew[indexvalue].disp = event.detail.disp;
        this.addDelegateListNew[indexvalue].dispcon = event.detail.dispcon;
        this.addDelegateListNew[indexvalue].isadultdel = event.detail.isadultdel;
        this.addDelegateListNew[indexvalue].usingdupdel = event.detail.usingdupdel;
        this.addDelegateListNew[indexvalue].isConnected = event.detail.connect;
        this.addDelegateListNew[indexvalue].delegateId = event.detail.delegateId;
        this.addDelegateListNew[indexvalue].isConnectedOnce = event.detail.isConnectedOnce;
        this.addDelegateListNew[indexvalue].isDisconnected = event.detail.disconnect;
        this.addDelegateListNew[indexvalue].cbe = event.detail.cbe;
        let partmsgname = this.utilLabels.PG_Ref_L_Delegate_continue_be_delegate;
        var partmsg = partmsgname.replace("##delegateName",event.detail.fn+' '+event.detail.ln);
        this.addDelegateListNew[indexvalue].continueDelegatenewMsg = partmsg;
        var i = 0, len = this.addDelegateListNew.length;
        while (i < len) {
            let addDelNew = this.addDelegateListNew[i];
            let fnameIsValid = addDelNew.fn != undefined && addDelNew.fn != null && addDelNew.fn != '' && addDelNew.fn.length !=0;
            let lnameIsValid = addDelNew.ln != undefined && addDelNew.ln !=null && addDelNew.ln != '' && addDelNew.ln.length !=0;
            let emailIsValid = addDelNew.em != undefined && addDelNew.em != '' && addDelNew.em.length != 0;
            let birthYearIsValid = addDelNew.by != undefined && addDelNew.by != '' && addDelNew.by != '--' && addDelNew.by.length != 0;    
            if((!fnameIsValid && !lnameIsValid && !emailIsValid && !birthYearIsValid && addDelNew.cb != true && addDelNew.cbe != true) || addDelNew.isConnectedOnce === true){
            this.isNewDelValid = false;
           }else{
            this.isNewDelValid = true;
           }
            i++
        }
    }
    handleDataChangeOfDelegates(event){
        this.delegates[event.detail.indexvalue].Phone__c = event.detail.phoneNumber;
        this.delegates[event.detail.indexvalue].Phone_Type__c = event.detail.phoneTypeValue;
        this.delegates[event.detail.indexvalue].Email__c = event.detail.email;
        this.delegates[event.detail.indexvalue].isCont = event.detail.iscont;
        this.delegates[event.detail.indexvalue].delegcont = event.detail.delegcont;
        this.delegates[event.detail.indexvalue].consent = event.detail.consent;
        this.delegates[event.detail.indexvalue].consentrow = event.detail.consentrow;
        this.delegates[event.detail.indexvalue].consentsms = event.detail.consentsms;
        this.delegates[event.detail.indexvalue].Delegate_Consent_SMS__c = event.detail.consentsms;

        this.delegates[event.detail.indexvalue].Study_Email_Consent = event.detail.studyemailconsent;
        this.delegates[event.detail.indexvalue].Study_info_storage_consent = event.detail.studyinfostorageconsent;
        this.delegates[event.detail.indexvalue].Study_Phone_Consent = event.detail.studyphoneconsent;
        this.delegates[event.detail.indexvalue].Study_SMS_Consent = event.detail.studysmsconsent;


        
        let validationListDelegate = [];
        const emailRegex=/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        //logic to enable Next button based on continue / do not continue
        for(let i = 0; i < this.delegates.length; i++) {
            let iscont = this.delegates[i].isCont;
            let isPhoneEmpty = (this.delegates[i].Phone__c != null && this.delegates[i].Phone__c != '' && this.delegates[i].Phone__c.trim() && this.delegates[i].Phone__c.length !=0);
            let isEmailEmpty = (this.delegates[i].Email__c != null && this.delegates[i].Email__c != '' && this.delegates[i].Email__c.trim() && this.delegates[i].Email__c.length !=0);
            let isConsentEmpty; //= this.delegates[i].consent ;
            if(this.iscountryus){
                isConsentEmpty = this.delegates[i].consent ;
               
                if(this.delegates[i].Study_Email_Consent == true && this.delegates[i].Study_info_storage_consent == true && this.delegates[i].Study_Phone_Consent == true && this.delegates[i].Study_SMS_Consent == true){
                    if(iscont == "true")
                    {validationListDelegate.push(true);}
                }else{
                    if(iscont == "true")  
                    {validationListDelegate.push(false); console.log('consent failed');}}
            } 
            else{
                isConsentEmpty = this.delegates[i].consentrow ;
                if(this.delegates[i].Study_Email_Consent == true && this.delegates[i].Study_info_storage_consent == true && this.delegates[i].Study_Phone_Consent == true){
                    if(iscont == "true")
                    {validationListDelegate.push(true);}
                }else{  
                    if(iscont == "true")  
                    {validationListDelegate.push(false); console.log('consent failed');}}
            }
            if (
                (iscont == "true" && isPhoneEmpty && isEmailEmpty )
                || (iscont == "false" && isEmailEmpty )
            ) {
                validationListDelegate.push(true);
            }else{
                validationListDelegate.push(false);
            }

            let emailVal= this.delegates[i].Email__c;
            if(emailVal.match(emailRegex)){
                validationListDelegate.push(true);
            }else{
                validationListDelegate.push(false);
            }
        }
        if(validationListDelegate.includes(false)){ 
            this.isDelValid = true;
            this.isDelConsentValid=true;
        }else{
            this.isDelValid = false;
            this.isDelConsentValid=false;
        } 
    }
    handleNewHCP(){
        let hcpDelegateList = [];
        hcpDelegateList.push('1');
        this.addHCPListNew = [...this.addHCPListNew, ...hcpDelegateList]; 
    }
    handleInvite(event){
       if(event.target.dataset.value == "1"){
          this.inviteOptions = true;  
       }else{
          this.inviteOptions = false;  
       }
    }
    changeInputValue(event){
        let datavalue = event.target.dataset.value;
        if(event.target.dataset.value === "FirstName") {
            this.participant.First_Name__c = event.target.value;
        }else if(event.target.dataset.value === "MiddleName"){
            this.participant.Middle_Name__c = event.target.value;
        }else if(event.target.dataset.value === "LastName"){
            this.participant.Last_Name__c = event.target.value;
        }else if(event.target.dataset.value === "Suffix"){
            this.participant.Suffix__c = event.target.value;
        }else if(event.target.dataset.value === "Nickname"){
            this.participant.Nickname__c = event.target.value;
        }else if(event.target.dataset.value === "DOB"){
           // this.participant.Date_of_Birth__c = event.target.value;
        }else if(event.target.dataset.value === "Sex"){
            this.participant.Gender__c = event.target.value;
        }else if(event.target.dataset.value === "PhoneNumber"){
            this.participant.Phone__c = event.target.value;
        }else if(event.target.dataset.value === "PhoneType"){
            this.participant.Phone_Type__c = event.target.value;
        }else if(event.target.dataset.value === "Email"){
            this.participant.Email__c = event.target.value;
        }else if(event.target.dataset.value === "Country"){
            //this.participant.Mailing_Country__c = event.target.options.find(opt => opt.value === event.detail.value).label;
            this.mailingCountry = event.target.options.find(opt => opt.value === event.detail.value).label;
            this.participant.Mailing_Country_Code__c = event.target.value;
            this.participant.Mailing_State_Code__c ='';
            this.participant.Mailing_State__c ='';
            this.mailingState ='';
            this.setState();
            this.iscountryus=(this.participant.Mailing_Country_Code__c=='US'? true : false);
        }else if(event.target.dataset.value === "Province"){
            //this.participant.Mailing_State__c = event.target.options.find(opt => opt.value === event.detail.value).label;
            this.mailingState = event.target.options.find(opt => opt.value === event.detail.value).label;
            this.participant.Mailing_State_Code__c = event.target.value;
        }else if(event.target.dataset.value === "PostalCode"){
            this.participant.Mailing_Zip_Postal_Code__c = event.target.value;
        }else if(event.target.dataset.value === "AlternativePhoneNumber"){
            this.participant.Alternative_Phone_Number__c = event.target.value;
        }else if(event.target.dataset.value === "AlternativePhoneType"){
            this.participant.Alternative_Phone_Type__c = event.target.value;
        }
          
        this.customButtonValidation();
    }
    customButtonValidation(){
        let validationList = [];
          //1.
          if(this.participant.First_Name__c.trim() && this.participant.First_Name__c != null && this.participant.First_Name__c != '' && this.participant.First_Name__c.length !=0 &&
             this.participant.Last_Name__c.trim() && this.participant.Last_Name__c != null && this.participant.Last_Name__c != '' && this.participant.Last_Name__c.length !=0 &&
             this.participant.Gender__c != null && this.participant.Gender__c != '' && this.participant.Gender__c.length !=0 &&
             this.participant.Phone__c != null && this.participant.Phone__c != '' && this.participant.Phone__c.trim() && this.participant.Phone__c.length !=0 &&
             this.participant.Phone_Type__c != null && this.participant.Phone_Type__c != '' && this.participant.Phone_Type__c.length !=0 &&
             this.participant.Email__c != null && this.participant.Email__c != '' && this.participant.Email__c.trim() && this.participant.Email__c.length !=0 &&
             this.participant.Mailing_Country_Code__c != null && this.participant.Mailing_Country_Code__c != '' && this.participant.Mailing_Country_Code__c.length !=0 &&
             this.participant.Mailing_Zip_Postal_Code__c != null && this.participant.Mailing_Zip_Postal_Code__c != '' && this.participant.Mailing_Zip_Postal_Code__c.trim() && this.participant.Mailing_Zip_Postal_Code__c.length !=0
            ){
                validationList.push(true);
            }else{
                validationList.push(false);
            } 
            //2.
            if(this.participant.Email__c != null && this.participant.Email__c != '' && this.participant.Email__c.length !=0 ){
                const emailRegex=/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                let emailVal= this.participant.Email__c;
                if(emailVal.match(emailRegex)){
                    validationList.push(true);
                }else{
                    validationList.push(false);
            }}
            //3.
            if(this.contactstates.length != 0){
                if(this.participant.Mailing_State_Code__c != null && this.participant.Mailing_State_Code__c != '' && this.participant.Mailing_State_Code__c.length !=0){
                    validationList.push(true);
                }else{
                    validationList.push(false);
                }
            }
            // 4.DOB
            if(this.isDayMandate && this.valueDD == '--'){
                validationList.push(false);
            }
            if(this.isMonthMandate && this.valueMM == '--'){
                validationList.push(false);
            }
            if(this.valueYYYY == '----'){
                validationList.push(false);
            }
            if(this.participantSelectedAge==null){
                validationList.push(false);
            }

            if(validationList.includes(false)){ 
                this.isValid = true;
            }else{
                this.isValid = false;
            }
    }
    setState(){
        this.contactstates=[];
        this.contactstates=this.statesByCountryMap[this.participant.Mailing_Country_Code__c];
        if(this.contactstates.length == 0){
            Promise.resolve().then(() => {
                const inputEle = this.template.querySelector('.province');
                inputEle.reportValidity();
            });
        }
        if(this.contactstates.length<=0){
            if(this.currentTab == "2"){
                this.handleDataChangeOfDelegates();
            }
        }
    }
    get getAltPhoneNumber(){
        if(this.participant.Alternative_Phone_Number__c != null && this.participant.Alternative_Phone_Number__c != '' && this.participant.Alternative_Phone_Number__c.length !=0){
            return false;
        }else{
            return true;
        }
    }
    get checkStates(){
         if(this.contactstates.length == 0){
            return true;
         }else{
            return false;
         }
    }
    get checkStatesList(){
        if(this.contactstates.length == 0){
            return false;
        }else{
            return true;
        }
   }
    get checkInvite(){
       if(this.inviteOptions){
           return true;
       }else{
           return false;
       }
    }
    get checkNotInvite(){
        if(this.inviteOptions){
            return false;
        }else{
            return true;
        }
    }
    get handleParticipantTab(){
        if(this.currentTab == "1"){
            return true;
        }else{
            return false;
        }
    }
    get handleDelegateTab(){
        if(this.currentTab == "2"){
            return true;
        }else{
            return false;
        }
    }
    get handleHealthCareTab(){
        if(this.currentTab == "3"){
            return true;
        }else{
            return false;
        }
    }
    get handleFinalTab(){
        if(this.currentTab == "4"){
            return true;
        }else{
            return false;
        }
    }
    handleParticipant(){
        this.currentTab = "1";
        if(this.currentTab == "1"){
            var pathdetail = [];
            var path = {
                isStatusPassed : false,
                styleName:'slds-col width-basis vpi-state neutral current',
                styleName1:'slds-col width-basis vpi-line-div neutral',
                styleName2:'slds-col width-basis vpi-line-div neutral',
                pathName : this.utilLabels.PP_Participant
             }
             pathdetail.push(path);
             path = {};
             path = {
                isStatusPassed : false,
                styleName:'slds-col width-basis vpi-state neutral',
                styleName1:'slds-col width-basis vpi-line-div neutral',
                styleName2:'slds-col width-basis vpi-line-div neutral',
              pathName : this.utilLabels.PP_Delegate
             }
             pathdetail.push(path);
             path = {};
             path = {
                isStatusPassed : false,
                styleName:'slds-col width-basis vpi-state neutral',
                styleName1:'slds-col width-basis vpi-line-div neutral',
                styleName2:'slds-col width-basis vpi-line-div neutral',
              pathName : this.utilLabels.PP_Provider_Access
             }
             pathdetail.push(path);
             path = {};
             path = {
                isStatusPassed : false,
                styleName:'slds-col width-basis vpi-state neutral',
                styleName1:'slds-col width-basis vpi-line-div neutral',
                styleName2:'slds-col width-basis vpi-line-div neutral',
              pathName : this.utilLabels.PP_Review_and_Confirm
             }
             pathdetail.push(path);
             this.pathdetails = [];
             this.pathdetails = [...this.pathdetails, ...pathdetail]; 
        }
    }
    handleDelegate(){
        this.currentTab = "2";
        if(this.currentTab == "2"){
            var pathdetail = [];
            var path = {
                isStatusPassed : true,
                styleName:'slds-col width-basis vpi-state success',
                styleName1:'slds-col width-basis vpi-line-div success',
                styleName2:'slds-col width-basis vpi-line-div success',
                pathName : this.utilLabels.PP_Participant
             }
             pathdetail.push(path);
             path = {};
             path = {
              isStatusPassed : false,
              styleName:'slds-col width-basis vpi-state neutral current',
              styleName1:'slds-col width-basis vpi-line-div success',
              styleName2:'slds-col width-basis vpi-line-div neutral',
              pathName : this.utilLabels.PP_Delegate
             }
             pathdetail.push(path);
             path = {};
             path = {
              isStatusPassed : false,
              styleName:'slds-col width-basis vpi-state neutral',
              styleName1:'slds-col width-basis vpi-line-div neutral',
              styleName2:'slds-col width-basis vpi-line-div neutral',
              pathName : this.utilLabels.PP_Provider_Access
             }
             pathdetail.push(path);
             path = {};
             path = {
              isStatusPassed : false,
              styleName:'slds-col width-basis vpi-state neutral',
              styleName1:'slds-col width-basis vpi-line-div neutral',
              styleName2:'slds-col width-basis vpi-line-div neutral',
              pathName : this.utilLabels.PP_Review_and_Confirm
             }
             pathdetail.push(path);
             this.pathdetails = [];
             this.pathdetails = [...this.pathdetails, ...pathdetail]; 
        }

    }
    get isValidCheck(){
        if(this.currentTab == "2"){
            return this.isDelValid || this.isNewDelValid  || this.isDelConsentValid;
        }
        return this.isValid;
    }
    handleNext(){
        if(this.currentTab == "1"){
            this.currentTab = "2";
            let validationListDelegate = [];
            const emailRegex=/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            for(let i = 0; i < this.delegates.length; i++) {
                let iscont=this.delegates[i].isCont;
                let isConsentEmpty;
                if(this.iscountryus){
                    isConsentEmpty = this.delegates[i].consent ;
                    if(this.delegates[i].Study_Email_Consent == true && this.delegates[i].Study_info_storage_consent == true && this.delegates[i].Study_Phone_Consent == true && this.delegates[i].Study_SMS_Consent == true){
                        if(iscont == "true")
                        {validationListDelegate.push(true);}
                    }else{
                        if(iscont == "true")  
                        {validationListDelegate.push(false); console.log('consent failed');}}

                }
                else{
                    isConsentEmpty = this.delegates[i].consentrow ;
                    if(this.delegates[i].Study_Email_Consent == true && this.delegates[i].Study_info_storage_consent == true && this.delegates[i].Study_Phone_Consent == true){
                        if(iscont == "true")
                        {validationListDelegate.push(true);}
                    }else{  
                        if(iscont == "true")  
                        {validationListDelegate.push(false); }}

                }
            let isPhoneEmpty = (this.delegates[i].Phone__c != null && this.delegates[i].Phone__c != '' && this.delegates[i].Phone__c.trim() && this.delegates[i].Phone__c.length !=0);
            let isEmailEmpty = (this.delegates[i].Email__c != null && this.delegates[i].Email__c != '' && this.delegates[i].Email__c.trim() && this.delegates[i].Email__c.length !=0);
            if (
                (iscont == "true" && isPhoneEmpty && isEmailEmpty)
                || (iscont == "false" && isEmailEmpty)
            ) {
                validationListDelegate.push(true);
            }else{
                validationListDelegate.push(false);
            }

                let emailVal= this.delegates[i].Email__c;
                if(emailVal.match(emailRegex)){
                    validationListDelegate.push(true);
                }else{
                    validationListDelegate.push(false); 
                }
            }
            if(validationListDelegate.includes(false)){ 
                this.isDelValid = true;
            }else{
                this.isDelValid = false;
            } 
        }else if(this.currentTab == "2"){
            this.currentTab = "3";
            this.addHCPListNew = [];
        }else if(this.currentTab == "3"){
            this.currentTab = "4";
        }

        if(this.currentTab == "2"){
            var pathdetail = [];
            var path = {
                isStatusPassed : true,
                styleName:'slds-col width-basis vpi-state success',
                styleName1:'slds-col width-basis vpi-line-div success',
                styleName2:'slds-col width-basis vpi-line-div success',
                pathName : this.utilLabels.PP_Participant
             }
             pathdetail.push(path);
             path = {};
             path = {
              isStatusPassed : false,
              styleName:'slds-col width-basis vpi-state neutral current',
              styleName1:'slds-col width-basis vpi-line-div success',
              styleName2:'slds-col width-basis vpi-line-div neutral',
              pathName : this.utilLabels.PP_Delegate
             }
             pathdetail.push(path);
             path = {};
             path = {
              isStatusPassed : false,
              styleName:'slds-col width-basis vpi-state neutral',
              styleName1:'slds-col width-basis vpi-line-div neutral',
              styleName2:'slds-col width-basis vpi-line-div neutral',
              pathName : this.utilLabels.PP_Provider_Access
             }
             pathdetail.push(path);
             path = {};
             path = {
              isStatusPassed : false,
              styleName:'slds-col width-basis vpi-state neutral',
              styleName1:'slds-col width-basis vpi-line-div neutral',
              styleName2:'slds-col width-basis vpi-line-div neutral',
              pathName : this.utilLabels.PP_Review_and_Confirm
             }
             pathdetail.push(path);
             this.pathdetails = [];
             this.pathdetails = [...this.pathdetails, ...pathdetail]; 
        }
        if(this.currentTab == "3"){
            var pathdetail = [];
            var path = {
                isStatusPassed : true,
                styleName:'slds-col width-basis vpi-state success',
                styleName1:'slds-col width-basis vpi-line-div success',
                styleName2:'slds-col width-basis vpi-line-div success',
                pathName : this.utilLabels.PP_Participant
             }
             pathdetail.push(path);
             path = {};
             path = {
              isStatusPassed : true,
              styleName:'slds-col width-basis vpi-state success',
              styleName1:'slds-col width-basis vpi-line-div success',
              styleName2:'slds-col width-basis vpi-line-div success',
              pathName : this.utilLabels.PP_Delegate
             }
             pathdetail.push(path);
             path = {};
             path = {
              isStatusPassed : false,
              styleName:'slds-col width-basis vpi-state neutral current',
              styleName1:'slds-col width-basis vpi-line-div success',
              styleName2:'slds-col width-basis vpi-line-div neutral',
              pathName : this.utilLabels.PP_Provider_Access
             }
             pathdetail.push(path);
             path = {};
             path = {
              isStatusPassed : false,
              styleName:'slds-col width-basis vpi-state neutral',
              styleName1:'slds-col width-basis vpi-line-div neutral',
              styleName2:'slds-col width-basis vpi-line-div neutral',
              pathName : this.utilLabels.PP_Review_and_Confirm
             }
             pathdetail.push(path);
             this.pathdetails = [];
             this.pathdetails = [...this.pathdetails, ...pathdetail]; 
        }
        if(this.currentTab == "4"){
            var pathdetail = [];
            var path = {
                isStatusPassed : true,
                styleName:'slds-col width-basis vpi-state success',
                styleName1:'slds-col width-basis vpi-line-div success',
                styleName2:'slds-col width-basis vpi-line-div success',
                pathName : this.utilLabels.PP_Participant
             }
             pathdetail.push(path);
             path = {};
             path = {
              isStatusPassed : true,
              styleName:'slds-col width-basis vpi-state success',
              styleName1:'slds-col width-basis vpi-line-div success',
              styleName2:'slds-col width-basis vpi-line-div success',
              pathName : this.utilLabels.PP_Delegate
             }
             pathdetail.push(path);
             path = {};
             path = {
              isStatusPassed : true,
              styleName:'slds-col width-basis vpi-state success',
              styleName1:'slds-col width-basis vpi-line-div success',
              styleName2:'slds-col width-basis vpi-line-div success',
              pathName : this.utilLabels.PP_Provider_Access
             }
             pathdetail.push(path);
             path = {};
             path = {
              isStatusPassed : false,
              styleName:'slds-col width-basis vpi-state neutral current',
              styleName1:'slds-col width-basis vpi-line-div success',
              styleName2:'slds-col width-basis vpi-line-div neutral',
              pathName : this.utilLabels.PP_Review_and_Confirm
             }
             pathdetail.push(path);
             this.pathdetails = [];
             this.pathdetails = [...this.pathdetails, ...pathdetail]; 
        }
        
    }
    handleBack(){
        if(this.currentTab == "4"){
            this.currentTab = "3";
            this.addHCPListNew = [];
        }else if(this.currentTab == "3"){
            this.currentTab = "2";
        }else if(this.currentTab == "2"){
            this.currentTab = "1";
            this.isValid = false;
        }

        if(this.currentTab == "2"){
            var pathdetail = [];
            var path = {
                isStatusPassed : true,
                styleName:'slds-col width-basis vpi-state success',
                styleName1:'slds-col width-basis vpi-line-div success',
                styleName2:'slds-col width-basis vpi-line-div success',
                pathName : this.utilLabels.PP_Participant
             }
             pathdetail.push(path);
             path = {};
             path = {
              isStatusPassed : false,
              styleName:'slds-col width-basis vpi-state neutral current',
              styleName1:'slds-col width-basis vpi-line-div success',
              styleName2:'slds-col width-basis vpi-line-div neutral',
              pathName : this.utilLabels.PP_Delegate
             }
             pathdetail.push(path);
             path = {};
             path = {
              isStatusPassed : false,
              styleName:'slds-col width-basis vpi-state neutral',
              styleName1:'slds-col width-basis vpi-line-div neutral',
              styleName2:'slds-col width-basis vpi-line-div neutral',
              pathName : this.utilLabels.PP_Provider_Access
             }
             pathdetail.push(path);
             path = {};
             path = {
              isStatusPassed : false,
              styleName:'slds-col width-basis vpi-state neutral',
              styleName1:'slds-col width-basis vpi-line-div neutral',
              styleName2:'slds-col width-basis vpi-line-div neutral',
              pathName : this.utilLabels.PP_Review_and_Confirm
             }
             pathdetail.push(path);
             this.pathdetails = [];
             this.pathdetails = [...this.pathdetails, ...pathdetail]; 
        }
        if(this.currentTab == "3"){
            var pathdetail = [];
            var path = {
                isStatusPassed : true,
                styleName:'slds-col width-basis vpi-state success',
                styleName1:'slds-col width-basis vpi-line-div success',
                styleName2:'slds-col width-basis vpi-line-div success',
                pathName : this.utilLabels.PP_Participant
             }
             pathdetail.push(path);
             path = {};
             path = {
              isStatusPassed : true,
              styleName:'slds-col width-basis vpi-state success',
              styleName1:'slds-col width-basis vpi-line-div success',
              styleName2:'slds-col width-basis vpi-line-div success',
              pathName : this.utilLabels.PP_Delegate
             }
             pathdetail.push(path);
             path = {};
             path = {
              isStatusPassed : false,
              styleName:'slds-col width-basis vpi-state neutral current',
              styleName1:'slds-col width-basis vpi-line-div success',
              styleName2:'slds-col width-basis vpi-line-div neutral',
              pathName : this.utilLabels.PP_Provider_Access
             }
             pathdetail.push(path);
             path = {};
             path = {
              isStatusPassed : false,
              styleName:'slds-col width-basis vpi-state neutral',
              styleName1:'slds-col width-basis vpi-line-div neutral',
              styleName2:'slds-col width-basis vpi-line-div neutral',
              pathName : this.utilLabels.PP_Review_and_Confirm
             }
             pathdetail.push(path);
             this.pathdetails = [];
             this.pathdetails = [...this.pathdetails, ...pathdetail]; 
        }
        if(this.currentTab == "1"){
            var pathdetail = [];
            var path = {
                isStatusPassed : false,
                styleName:'slds-col width-basis vpi-state neutral current',
                styleName1:'slds-col width-basis vpi-line-div neutral',
                styleName2:'slds-col width-basis vpi-line-div neutral',
                pathName : this.utilLabels.PP_Participant
             }
             pathdetail.push(path);
             path = {};
             path = {
                isStatusPassed : false,
                styleName:'slds-col width-basis vpi-state neutral',
                styleName1:'slds-col width-basis vpi-line-div neutral',
                styleName2:'slds-col width-basis vpi-line-div neutral',
              pathName : this.utilLabels.PP_Delegate
             }
             pathdetail.push(path);
             path = {};
             path = {
                isStatusPassed : false,
                styleName:'slds-col width-basis vpi-state neutral',
                styleName1:'slds-col width-basis vpi-line-div neutral',
                styleName2:'slds-col width-basis vpi-line-div neutral',
              pathName : this.utilLabels.PP_Provider_Access
             }
             pathdetail.push(path);
             path = {};
             path = {
                isStatusPassed : false,
                styleName:'slds-col width-basis vpi-state neutral',
                styleName1:'slds-col width-basis vpi-line-div neutral',
                styleName2:'slds-col width-basis vpi-line-div neutral',
              pathName : this.utilLabels.PP_Review_and_Confirm
             }
             pathdetail.push(path);
             this.pathdetails = [];
             this.pathdetails = [...this.pathdetails, ...pathdetail]; 
        }
    }
    get isLastTab(){
        if(this.currentTab == "4"){
            return true;
        }else{
            return false;
        }
    }
    get checkTab(){
        if(this.currentTab == "1"){
            return true;
        }else{
            return false;
        } 
    }
    get isParticipantTab(){
        if(this.currentTab == "1"){
            return true;
        }else{
            return false;
        }
    }
    get participantName(){
        let partmsgname = this.utilLabels.PG_Ref_L_Participant_require_invitation;
        var partmsg = partmsgname.replace("##participantName",this.participant.First_Name__c+' '+this.participant.Last_Name__c);
        return partmsg;
    }
    @api
    handleClick(){
        this.openModal = true;
        this.currentTab = "1";
    }
    handleClose(){
        this.openModal = false;
        this.currentTab = "0";
        this.pathdetails = [];
    }
    handleHCP(event){
        this.loading = true;
        this.addHCPListNew = [];
        this.hcpDelegates = [];
        getHCPData({peId:this.selectedPE.id})
        .then((result) => {
            this.hcpDelegates = result;
            this.loading = false;
        }).catch((error) => {
            this.loading = false;
            console.log(error);
        });
    }
    handleConsent(event){
        this.participantContact.Consent_To_Inform_About_Study__c = event.target.checked;
    }
    handleSave(){
        this.saving = true;
        let doNotContinueIds = [];
        let delegateToProceedItems = [];
        let delegateConsentItems = [];
        for(let i = 0; i < this.delegates.length; i++){
            if(this.delegates[i].isCont == "false" && this.delegates[i].Contact__c){
                doNotContinueIds.push(this.delegates[i].Contact__c);
            } 
            delegateConsentItems.push({
                delgParticipantId:this.delegates[i].delgParticipantId,
                Study_Email_Consent:this.delegates[i].Study_Email_Consent,
                Study_info_storage_consent:this.delegates[i].Study_info_storage_consent,
                Study_Phone_Consent:this.delegates[i].Study_Phone_Consent,
                Study_SMS_Consent:this.delegates[i].Study_SMS_Consent
            });
            delete this.delegates[i].delgParticipantId;
            delete this.delegates[i].Study_Email_Consent;
            delete this.delegates[i].Study_info_storage_consent;
            delete this.delegates[i].Study_Phone_Consent;
            delete this.delegates[i].Study_SMS_Consent;
            delete this.delegates[i].alreadyConsented;
            delete this.delegates[i].alreadyconsentedrow;

            delete this.delegates[i].isConnected;
            delete this.delegates[i].selectedOption;
            delete this.delegates[i].continue;
            delete this.delegates[i].donotcontinue;
            delete this.delegates[i].continueDelegateMsg;
            delete this.delegates[i].index;
            delete this.delegates[i].isCont;
            delete this.delegates[i].delegcont;

            delegateToProceedItems.push(this.delegates[i]);
        }
        if(this.participant.Mailing_State_Code__c == '' || this.participant.Mailing_State_Code__c == null){
            this.participant.Mailing_State__c = '';
        }else{
            delete this.participant.Mailing_State__c;
        }
         updateParticipantAndDelegates({ peId: this.selectedPE.id, 
                                         participantS: JSON.stringify(this.participant),
                                         participantContactS: JSON.stringify(this.participantContact),
                                         delegatesS: JSON.stringify(this.delegates),
                                         doNotContinueIds: doNotContinueIds,
                                         needsInvite: this.inviteOptions,
                                         studySiteId: this.siteid,
                                         delegateConsentItems:JSON.stringify(delegateConsentItems)
                                        })
        .then((result) => {
          this.saving = false;
          this.showSuccessToast(this.label.RH_RP_Record_Saved_Successfully);
          const selectedEvent = new CustomEvent("emancipation", {});
          this.dispatchEvent(selectedEvent);
        })
        .catch((error) => {
          console.error("Error:", error);
          this.showErrorToast('Emancipation process failed! Description:'+error);
          this.saving = false;
        });
    }
    showSuccessToast(Message) {
        const evt = new ShowToastEvent({
          title: Message,
          message: Message,
          variant: "success",
          mode: "dismissible"
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
    valueDD = '--';
    valueYYYY = '----';
    valueMM = '--';
    lastDay = 31;
    firstYear = 1900;
    lastYear = parseInt(new Date().getFullYear());
    participantSelectedAge ;
    studyDobFormat;
    get optionsDD() {
        var opt = [];
        for(var i = 1 ; i<=this.lastDay ;i++){
            var x = i.toString();
            if(i<10)
                x='0'+x;
            opt.push({label: x, value: x });
        }
        return opt;
    }
    get optionsMM() {
        var opt = [];
        opt.push({label: January, value:'01' });
        opt.push({label: February, value:'02' });
        opt.push({label: March, value:'03' });
        opt.push({label: April, value:'04' });
        opt.push({label: May, value:'05' });
        opt.push({label: June, value:'06' });
        opt.push({label: July, value:'07' });
        opt.push({label: August, value:'08' });
        opt.push({label: September, value:'09' });
        opt.push({label: October, value:'10' });
        opt.push({label: November, value:'11' });
        opt.push({label: December, value:'12' });       
        return opt;
    }
    get optionsYYYY() {
        var opt = [];
        for(var i = this.firstYear ; i<=this.lastYear ;i++){
            opt.push({label: i.toString(), value: i.toString() });
        }
        return opt;
    }
    handleDDChange(event) {
        this.valueDD = event.detail.value;  
        this.participant.Birth_Day__c = event.detail.value;     
        this.dateChanged();
    }
    handleMMChange(event) {
        this.valueMM = event.detail.value;        
        this.participant.Birth_Month__c = event.detail.value;  
        var maxDayMonths = ['01','03','05','07','08','10','12'];
        var minDayMonths = ['04','06','09','11'];
        this.monthName = this.monthmap.get(this.participant.Birth_Month__c);
        if(maxDayMonths.includes(this.valueMM)){
            this.lastDay = 31;
        }
        else if(minDayMonths.includes(this.valueMM)){
            this.lastDay = 30;
        }
        else if(this.valueMM == '02'){
            if(this.valueYYYY =='----' || this.isLeapYear()){
                this.lastDay = 29;
            }     
            else{
                this.lastDay = 28;
            }                      
        }
        if( parseInt(this.valueDD) > this.lastDay){
            this.valueDD = this.lastDay.toString();
        }
        this.dateChanged();
    }
    handleYYYYChange(event) {
        this.valueYYYY = event.detail.value;        
        this.participant.Birth_Year__c = event.detail.value; 
        if(this.valueMM=='02'){
            if(this.isLeapYear() ){
                this.lastDay = 29;
            }
            else{
                this.lastDay = 28;
            }
        }
        if( parseInt(this.valueDD) > this.lastDay){
            this.valueDD = this.lastDay.toString();
        }
        this.dateChanged();
    }
    isLeapYear(){
        if(parseInt(this.valueYYYY)%400==0){
            return true;
        }
        if(parseInt(this.valueYYYY)%100==0){
            return false;
        }
        if(parseInt(this.valueYYYY)%4==0){
            return true;
        }
        return false;
    }
    dateChanged(){
        this.participantSelectedAge = null;
        this.calculateAge();   
        this.customButtonValidation();     
    }
    calculateAge(){
        if(this.studyDobFormat  == 'DD-MM-YYYY' && this.valueYYYY!='----' && this.valueMM!='--' && this.valueDD!='--'
               && this.valueYYYY!=undefined && this.valueMM!=undefined && this.valueDD!=undefined){
                var dob = new Date(this.valueYYYY+"-"+this.valueMM+"-"+this.valueDD);
                //calculate month difference from current date in time
                var month_diff = Date.now() - dob.getTime();
                //convert the calculated difference in date format
                var age_dt = new Date(month_diff); 
                //extract year from date    
                var year = age_dt.getUTCFullYear();
                //now calculate the age of the user
                var age = Math.abs(year - 1970);
                this.participantSelectedAge = age.toString();
                //this.pd['pe']['Participant__r']['Age__c'] = age;
            }
            this.participant.Age__c = this.participantSelectedAge;   
        return this.participantSelectedAge;
    }
    //dob changes
    get ageOptions(){
        var opt = [];
        let todayDate = new Date();
        let higherAge = (todayDate.getUTCFullYear()-this.valueYYYY).toString();
        let lowerAge = (higherAge-1).toString();
        let cMonth = todayDate.getMonth()+1;
        let cDay = todayDate.getDate();
        let cYear = parseInt(todayDate.getUTCFullYear());
        let addedValues = '';
        if((this.studyDobFormat == 'YYYY' || (this.studyDobFormat == 'MM-YYYY' && this.valueMM != '--' && this.valueMM >= cMonth ) 
        || (this.studyDobFormat == 'DD-MM-YYYY' && this.valueMM != '--' && this.valueDD != '--' && (this.valueMM > cMonth || (this.valueMM == cMonth && this.valueDD > cDay)))) 
        && this.valueYYYY!='--' && this.valueYYYY!=cYear){
            opt.push({label: lowerAge, value: lowerAge });
            addedValues += lowerAge+';';
        }
        if(this.studyDobFormat == 'YYYY' || (this.studyDobFormat == 'MM-YYYY' && this.valueMM != '--' && this.valueMM <= cMonth ) 
        || (this.studyDobFormat == 'DD-MM-YYYY' && this.valueMM != '--' && this.valueDD != '--' && (this.valueMM < cMonth || (this.valueMM == cMonth && this.valueDD <= cDay)))){
            opt.push({label: higherAge, value: higherAge });
            addedValues += higherAge+';';
        }
        if(!addedValues.includes(this.participantSelectedAge+';') && this.participantSelectedAge!=null){
            opt.push({label: this.participantSelectedAge, value: this.participantSelectedAge });
        }
        return opt;
    }
    handleAgeChange(event) {
        let ageVal = event.detail.value ;
        this.participantSelectedAge = event.detail.value ;
        this.participant.Age__c  = ageVal;       
        this.customButtonValidation(); 
    }
}