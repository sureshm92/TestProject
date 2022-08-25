import { LightningElement,api,track,wire } from 'lwc';
import pirResources from '@salesforce/resourceUrl/pirResources';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getParticipantDelegates from '@salesforce/apex/ParticipantInformationRemote.getParticipantDelegates';
import updateParticipantAndDelegates from '@salesforce/apex/ParticipantInformationRemote.updateParticipantAndDelegates';
import getHCPData from '@salesforce/apex/PIR_SharingOptionsController.getHCPData';
import getpeData from '@salesforce/apex/PIR_SharingOptionsController.getpeData';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import { label } from "c/pir_label";
import PG_AC_Select from '@salesforce/label/c.PG_AC_Select';
import RH_RP_Record_Saved_Successfully from '@salesforce/label/c.RH_RP_Record_Saved_Successfully';
export default class Pir_participantEmancipated extends LightningElement {
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
    hcpDelegates = [];
    @api studySiteId = '';
    @api participant;
    @api siteid='';
    @api isvirtualsite = false;loading = false;
    @api participantMsgWithName = '';
    @api countryStateInfo=[];
    @api contactstates = [];
    @api countryList;
    @api phoneType = [];
    @api genderType = [];
    @api isValid = false;
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
    @api maindivcls;
    
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
        getParticipantDelegates({participantId: this.selectedPE.participantId })
        .then((result) => {
            for(let i = 0; i < result.length; i++) {
                result[i].isConnected = true;   
                result[i].selectedOption = '1';   
                result[i].continue = true;
                result[i].donotcontinue = false;
                if(!result[i].Phone_Type__c){
                    result[i].Phone_Type__c = 'Home';
                }
            }
            this.delegates = result;
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
        this.addDelegateListNew[indexvalue].isConnected = event.detail.connect;
        let partmsgname = this.utilLabels.PG_Ref_L_Delegate_continue_be_delegate;
        var partmsg = partmsgname.replace("##delegateName",event.detail.fn+' '+event.detail.ln);
        this.addDelegateListNew[indexvalue].continueDelegatenewMsg = partmsg;
    }
    handleDataChangeOfDelegates(event){
        this.delegates[event.detail.indexvalue].Phone__c = event.detail.phoneNumber;
        this.delegates[event.detail.indexvalue].Phone_Type__c = event.detail.phoneTypeValue;
        this.delegates[event.detail.indexvalue].Email__c = event.detail.email;
        this.delegates[event.detail.indexvalue].isCont = event.detail.iscont;
        this.delegates[event.detail.indexvalue].delegcont = event.detail.delegcont;
        
        let validationListDelegate = [];
        const emailRegex=/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        //logic to enable Next button based on continue / do not continue
        for(let i = 0; i < this.delegates.length; i++) {
            let iscont = this.delegates[i].isCont;
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
            this.isValid = true;
        }else{
            this.isValid = false;
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
            this.participant.Date_of_Birth__c = event.target.value;
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
             this.participant.Date_of_Birth__c != null && this.participant.Date_of_Birth__c != '' && this.participant.Date_of_Birth__c.length !=0 &&
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
    handleNext(){
        if(this.currentTab == "1"){
            this.currentTab = "2";
            let validationListDelegate = [];
            const emailRegex=/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            for(let i = 0; i < this.delegates.length; i++) {
                if(this.delegates[i].Phone__c != null && this.delegates[i].Phone__c != '' && this.delegates[i].Phone__c.trim() && this.delegates[i].Phone__c.length !=0 &&
                this.delegates[i].Email__c != null && this.delegates[i].Email__c != '' && this.delegates[i].Email__c.trim() && this.delegates[i].Email__c.length !=0
                ){
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
                this.isValid = true;
            }else{
                this.isValid = false;
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
        for(let i = 0; i < this.delegates.length; i++){
            if(this.delegates[i].isCont == "false" && this.delegates[i].Contact__c){
                doNotContinueIds.push(this.delegates[i].Contact__c);
            } 
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
                                         studySiteId: this.siteid
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
}