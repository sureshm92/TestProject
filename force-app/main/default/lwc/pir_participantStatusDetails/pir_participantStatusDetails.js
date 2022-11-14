import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import pirResources from '@salesforce/resourceUrl/pirResources';
import eConsentResource from '@salesforce/resourceUrl/eConsentResource';
import getStatusDetail from '@salesforce/apex/PIR_StatusDetailController.getStatusDetail';
import getPERdetails from '@salesforce/apex/PIR_StatusDetailController.getPERdetails';
import getoutcomeToReasonMap from '@salesforce/apex/PIR_StatusDetailController.getoutcomeToReasonMap';
import getBubbleStatus from '@salesforce/apex/PIR_StatusDetailController.getBubbleStatus';
import isSuccessfullyReEngaged from "@salesforce/apex/PIR_StatusDetailController.isSuccessfullyReEngaged";
import PWS_Received_Name from '@salesforce/label/c.PWS_Received_Name';
import BTN_Back from '@salesforce/label/c.BTN_Back';
import Participant_Re_Consent from '@salesforce/label/c.Participant_Re_Consent';
import { NavigationMixin } from "lightning/navigation";
export default class Pir_participantStatusDetails extends NavigationMixin(LightningElement) {
    @api selectedPE_ID;
    @api peCardDetails;
    @api showBubbleMap = false;@api bubbleMapDetails;@api reason='';@api isInitialVisitRequired = false; @api isInitialVisitsPresent = false;
    @api per;@api initialVisitScheduledTime='';@api isFinalConsentRequired = false;@api isVisitPlanRequired = false;@api selectedPlan = '';
    @api saveSpinner = false; @api userDate;@api contSuccessReason ='';@api latestStatusGrp='';
    @api getisreengaged=false;@api Re_consent = false;
    e_consentConfigured=false;
    count = 0;
    checkIcon = pirResources+'/pirResources/icons/status-good.svg';
    minusIcon = pirResources+'/pirResources/icons/status-negative.svg';
    noneIcon = pirResources+'/pirResources/icons/circle.svg';
    backArrow = pirResources+'/pirResources/icons/triangle-left.svg';
    notification = pirResources+'/pirResources/icons/bell.svg';
    eConsentBell = eConsentResource+'/eConsentResource/Icon/bell_icon.svg';
    label = {
        PWS_Received_Name,
        BTN_Back,
        Participant_Re_Consent
    };

    peDetail = [
        {index : 0 },
        {index : 1 },
        {index : 2 },
        {index : 3 },
        {index : 4 },
    ];
    peRec={};
    outcomeToReasonMap = {};
    outcomeValue = {};
    visitPlan = {};
    showStatus = false;
    @api isrtl = false;
    maindivcls;

    curentMobileView = "list";
    mobileViewToggle(){
        if(this.curentMobileView=="list"){
            this.curentMobileView="detail";
            this.template.querySelectorAll(".D").forEach(function (D) {
                D.classList.remove("hideMobile");
            });
            this.template.querySelectorAll(".C").forEach(function (L) {
                L.classList.add("hideMobile");
            });
        }
        else{
            this.curentMobileView="list";
            this.template.querySelectorAll(".C").forEach(function (L) {
                L.classList.remove("hideMobile");
            });            
            this.template.querySelectorAll(".D").forEach(function (D) {
                D.classList.add("hideMobile");
            });
        }
        
    }
    redirecturl='';
    @api
    doSelectedPI(){
        
        if(this.isrtl){
            this.maindivcls = 'rtl';
        }else{
            this.maindivcls = 'ltr';
        }
       if(this.selectedPE_ID)
       { 
           this.count = this.count + 1;
           var internalCount = this.count;
            this.peDetail = [
                {index : 0 },
                {index : 1 },
                {index : 2 },
                {index : 3 },
                {index : 4 },
            ];
            this.peRec={};
            this.outcomeToReasonMap={};  
            this.outcomeValue={};
            this.visitPlan={};  
            this.showStatus = false;   
            this.showBubbleMap = false;
            this.reason = '';
            this.isInitialVisitRequired = false;
            var latestStatus = 0;
            this.per='';
            this.initialVisitScheduledTime = '';
            this.isVisitPlanRequired = false;
            this.latestStatusGrp = '';
            
            getStatusDetail({ perId: this.selectedPE_ID }) 
            .then((result) => {
                if(internalCount == this.count)
                { 
                    this.peCardDetails = result;               
                    var groupName = '';
                    var gpicon = '';
                    for(let i=0; i<this.peCardDetails.length; i++){
                        if(this.peCardDetails[i].groupIcon == 'success' || this.peCardDetails[i].groupIcon == 'failure' || this.peCardDetails[i].groupIcon == 'inProgress'){
                        latestStatus = i;
                        groupName = this.peCardDetails[i].groupName;
                        gpicon = this.peCardDetails[i].groupIcon;
                        }
                    }
                    this.selectedPeStatus = this.peDetail[latestStatus];
                    this.groupnme = groupName;
                    this.groupIcons = gpicon;
                    this.latestStatusGrp = this.groupnme;
               }
            }) 
            .then(() => {
              if(internalCount == this.count)
              {
                    getPERdetails({ perId: this.selectedPE_ID, status:latestStatus })
                    .then((result) => {
                        this.peRec = result.per;
                        this.per = result.per;
                        if(result.per.Re_consent__c == true){
                            this.Re_consent = true;
                        }else{
                            this.Re_consent = false;
                        } 
                        if(result.per.Study_Site__r.E_Consent_Vendor__c != null && result.per.Study_Site__r.E_Consent_Vendor__c !=''){
                            this.e_consentConfigured = true;
                            this.redirecturl=result.per.Study_Site__r.E_Consent_Vendor__r.Vendor_URL__c;
                        }else{
                            this.e_consentConfigured = false;
                            this.redirecturl=''; 
                        }
                        this.visitPlan = result.visitPlansList;
                        if(this.visitPlan.length != 0){
                            this.isVisitPlanRequired = true;
                            this.selectedPlan = '';
                            if(this.visitPlan.length > 1){
                                for(let i=0; i< this.visitPlan.length; i++){
                                    if(this.per.Visit_Plan__c == this.visitPlan[i].value){
                                        this.selectedPlan = this.visitPlan[i].value;
                                    }
                                }
                            }else{
                                    this.selectedPlan = this.visitPlan[0].value;
                            }
                            
                        }else{this.isVisitPlanRequired = false;}
                        this.isInitialVisitRequired = result.per.Clinical_Trial_Profile__r.Initial_Visit_Required__c;
                        this.isFinalConsentRequired = result.per.Clinical_Trial_Profile__r.Final_Consent_Required__c;
                        if(result.per.Non_Enrollment_Reason__c){
                            this.reason = result.per.Non_Enrollment_Reason__c;
                        }else{
                            this.reason = ' ';
                        }
                        if(result.per.Initial_visit_scheduled_date__c && (result.per.Initial_visit_scheduled_time__c || result.per.Initial_visit_scheduled_time__c == 0)){
                            this.isInitialVisitsPresent = true;
                        }else{
                            this.isInitialVisitsPresent = false;
                        }
                        if(result.per.Initial_visit_scheduled_time__c){
                            let s = result.per.Initial_visit_scheduled_time__c;
                            let ms = s % 1000;
                            s = (s - ms) / 1000;
                            let secs = s % 60;
                            s = (s - secs) / 60;
                            let mins = s % 60;
                            let hrs = (s - mins) / 60;
                            hrs = hrs < 10 ? '0' + hrs : hrs;
                            mins = mins < 10 ? '0' + mins : mins;
                            this.initialVisitScheduledTime =  hrs+':' + mins + ':00.000Z';
                            this.per.Initial_visit_scheduled_time__c =  hrs+':' + mins + ':00.000Z';
                        }
                        if(result.per.Initial_visit_scheduled_time__c == 0){
                            this.initialVisitScheduledTime =  '00:00:00.000';
                            this.per.Initial_visit_scheduled_time__c = '00:00:00.000';
                        }
                    })
                    .then(() => {
                        if(this.peRec.Participant_Status__c == 'Declined Consent'){
                            this.groupnme = 'PWS_Initial_Visit_Card_Name';
                        }
                        getoutcomeToReasonMap({stepName:this.groupnme })
                        .then((result) => {
                            this.outcomeToReasonMap = result.outcomeWithReason;
                            this.outcomeValue = result.outcomeWithValue;
                        }).then(() => {
                            getBubbleStatus( { perId:this.selectedPE_ID })
                            .then(result => {
                            this.showBubbleMap = result.isBubbleMapRequired;
                            if(this.showBubbleMap){
                                this.bubbleMapDetails = result.BubbleMaps;
                            }
                            this.saveSpinner = false;
                            this.userDate = result.userDt;
                            this.contSuccessReason = result.contSuccessReason;
                            const tabEvent = new CustomEvent("handletabs", {});
                            this.dispatchEvent(tabEvent);
                            }).catch(error => {
                                this.saveSpinner = false;
                            console.error('Error:', error);
                        });
                    })
                    .then(() => {
                            if(internalCount == this.count){
                                this.showStatus = true;
                            }
                        })
                    })
                }    
            }).catch((error) => {
                this.saveSpinner = false;
                this.error = error;
                console.log(error);
                console.log(error.stack);
                //this.showErrorToast(JSON.stringify(error.body.message));
            });
            isSuccessfullyReEngaged({ pe: this.selectedPE_ID })
                .then((result) => {
                this.getisreengaged= result;
                })
                .catch((error) => {
                    console.log('isSuccessfullyReEngaged',error);
                });
                    }  
    }
    
    @api
    doShowSpinneronSave(){
      this.saveSpinner = true;
    }
    checkStatus(event){
        return true;
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

    //D 
    selectedPeStatus = null;
    groupnme = '';
    groupIcons = '';
   /* rendered=false;
    renderedCallback(){
        if(!this.rendered){
            this.rendered=true; 
            //this.selectedPeStatus = this.peDetail[0];
        }            
    }*/
    hanldeStatusChange(event){
        this.mobileViewToggle();
        this.selectedPeStatus =this.peDetail[event.detail.index];
        this.groupnme = event.detail.groupName;
        this.groupIcons = event.detail.grpIcon;
       // this.latestStatusDetails(event.detail.index,this.groupnme);
    }
    
    @api
    callSaveMethod(){
        this.template.querySelector("c-pir_participant-sub-status-fields").checkFinalValidation();
    }
    handleSaveButton(event){
        const validatesave = new CustomEvent("validatesavebuttons", {
            detail: event.detail
        });
        this.dispatchEvent(validatesave); 
    }
    @api
    doCallEvent(){
        const selectEventHeaders = new CustomEvent('callpariticpantparent', {});
        this.dispatchEvent(selectEventHeaders);
    }
    @api 
    doCallParent(event){ 
          const valueChangeEvent = new CustomEvent("statusdetailsvaluechange", {
            detail: event.detail
          });
          this.dispatchEvent(valueChangeEvent);
    }
    handleConsentLogin(event) {
        if(this.redirecturl != null){
            let config = {
              type: 'standard__webPage',
              attributes: {
                  url: this.redirecturl
              }
            };
            this[NavigationMixin.Navigate](config);
        }    
      }
}