import { LightningElement,api,track } from 'lwc';
import checkDelegateDuplicate from '@salesforce/apex/ParticipantInformationRemote.checkDelegateDuplicate';
import connectDelegateToPatient from '@salesforce/apex/ParticipantInformationRemote.connectDelegateToPatient';
import disconnectDelegateToPatient from '@salesforce/apex/ParticipantInformationRemote.disconnectDelegateToPatient';
import verifyDelegateAge from '@salesforce/apex/ReferHealthcareProviderRemote.checkDelegateAge';
import yearOfBirth from '@salesforce/apex/PIR_SharingOptionsController.fetchYearOfBirth';
import { label } from "c/pir_label";
import DelegateAttestation from '@salesforce/label/c.RH_DelegateAttestation';
import YearOfBirth from '@salesforce/label/c.RH_YearofBirth';

export default class Pir_participantEmancipatedDelegate extends LightningElement {
    @api emailAddress = '';
    @api firstName = '';
    @api lastName = '';
    @api birthYear = '';
    @api checkBox = false;
    @api isAdultDelegate = false;
    @api participantid;
    @api isValid = false;
    @api participants; 
    @api delegateItem ={};
    @api studysiteid = '';
    @api siteid='';
    @api isvirtualsite = false; 
    @api connect = false;
    @api disconnect = false;
    @api duplicateDelegateInfo;
    @api isDuplicate = false;
    @api isConnected = false;
    @api isDisconnected = false;
    @api isConnectedOnce = false;
    @api usingDuplicateDelegate = false;
    @api delegateId;
    @api isDelegateConnected = false;
    @api indexVal = '';
    @api em = '';@api fn = '';@api ln = '';@api isconn = false;
    @api loading = false;
    @track utilLabels = label;
    @api maindivcls;
    @api isDisplay = false;
    isDisplayFormFields = false;
    labels = {
        DelegateAttestation,
        YearOfBirth
    }
    connectedCallback(){
        this.displayOptions();
    }

    displayFormFields() {
        if(this.isDisplayFormFields) {
            this.isDisplay = true;
        } else {
            this.isDisplay = false;
        }
    }

    checkFields(event){
        this.usingDuplicateDelegate = false;
        let datavalue = event.target.dataset.value;
        if(event.target.dataset.value === "firstName") {
            this.firstName = event.target.value;
          }else if(event.target.dataset.value === "email"){
            this.emailAddress = event.target.value;
            this.firstName = '';
            this.lastName = '';
          }else if(event.target.dataset.value === "lastName"){
            this.lastName = event.target.value;
          }else if(event.currentTarget.dataset.name === 'attestCheckbox') {
            this.checkBox = this.template.querySelector('[data-name="attestCheckbox"]').checked;
          }
          this.checkValidation();
          const selectedEvent = new CustomEvent("progressvaluechange", {
            detail: {
                em:this.emailAddress,
                fn:this.firstName,
                ln:this.lastName,
                by:this.birthYear,
                cb:this.checkBox,
                val:this.isValid,
                disp:this.isDisplay,
                indx:this.indexVal,
                connect:this.isConnected,
                usingdupdel:this.usingDuplicateDelegate,
                disconnect:this.isDisconnected,
                delegateId:this.delegateId,
                isConnectedOnce:this.isConnectedOnce
            }
          });
          this.dispatchEvent(selectedEvent);
          if(this.loading){
            this.loading=false;
          }
    }
    checkValidation(){
        let fname = this.firstName.trim();
        let lname = this.lastName.trim();
        let email = this.emailAddress.trim();
        if(fname != null && fname != '' && fname.length !=0 &&
           lname !=null && lname != '' && lname.length !=0 &&
           email !=null && email != '' && email.length != 0)
           { 
                const emailRegex=/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                let emailVal= email;
                if(emailVal.match(emailRegex)){
                     this.isValid = true;
                }else{
                    this.isDuplicate = false;   
                    this.isValid = false;
                }
           }else{
            this.isDuplicate = false;   
            this.isValid = false;
           }
          
    }

    get isConnectedAtLeastOnce(){
        return this.isConnected || this.isConnectedOnce;
    }

    get doValid(){
       if(this.isValid){
           if(this.isConnected == true || this.isDisconnected == true || this.usingDuplicateDelegate ==true){
            return false;
           }else if(this.isDuplicate){
               return true;
           }else if(
                 (this.birthYear !=null && this.birthYear !=undefined && this.birthYear != ''  && this.birthYear != '--' && this.birthYear.length != 0 
                  && this.checkBox === true)
                ){
                    return false;
                }else{
                    return true;
                }
        }else{
           return true;
        }
    }

    doCheckContact(){
        if(this.isValid){
            this.loading = true;
            this.isDuplicate = false;
            this.duplicateDelegateInfo = null;
            checkDelegateDuplicate({ email: this.emailAddress,
                firstName: this.firstName,
                lastName: this.lastName,
                participantId: this.participantid })
            .then((result) => {
                if(result.firstName){
                    this.isDisplayFormFields = false;
                    this.displayFormFields();
                    if(this.connect || this.disconnect){
                        this.isDuplicate = false;
                    }else{
                        this.isDuplicate = true;
                    }
                    this.duplicateDelegateInfo = result;
                    this.delegateItem.isDuplicate = result.isDuplicateDelegate;
                    this.delegateItem.sObjectType = "Participant__c";
                    this.delegateItem.Mailing_State_Code__c = this.participants.Mailing_State_Code__c;
                    //this.delegateItem.Mailing_State__c = this.participants.Mailing_State__c;
                    this.delegateItem.Mailing_Country_Code__c = this.participants.Mailing_Country_Code__c;
                    //this.delegateItem.Mailing_Country__c = this.participants.Mailing_Country__c;
                    this.delegateItem.Phone_Type__c ="Home";
                    this.delegateItem.Adult__c = true;
                    this.delegateItem.Email__c = this.emailAddress;
                    this.delegateItem.First_Name__c = this.firstName;
                    this.delegateItem.Last_Name__c = this.lastName;
                }else{
                    this.duplicateDelegateInfo = result;
                    this.delegateItem.isDuplicate = result.isDuplicateDelegate;
                    this.delegateItem.sObjectType = "Participant__c";
                    this.delegateItem.Mailing_State_Code__c = this.participants.Mailing_State_Code__c;
                    //this.delegateItem.Mailing_State__c = this.participants.Mailing_State__c;
                    this.delegateItem.Mailing_Country_Code__c = this.participants.Mailing_Country_Code__c;
                    //this.delegateItem.Mailing_Country__c = this.participants.Mailing_Country__c;
                    this.delegateItem.Phone_Type__c ="Home";
                    this.delegateItem.Adult__c = true;
                    this.delegateItem.Email__c = this.emailAddress;
                    this.delegateItem.First_Name__c = this.firstName;
                    this.delegateItem.Last_Name__c = this.lastName;
                    this.delegateItem.Birth_Year__c = this.birthYear;
                    this.isDuplicate = false;
                    this.isDisplayFormFields = true;
                    this.displayFormFields();
                } 
                if(this.connect){
                    this.doConnectDelegate();
                }else if(this.disconnect){
                    this.doDisConnectDelegate();
                }else{
                    this.loading = false;
                }
            }).catch((error) => {
                console.log(error);
                this.loading=false;
            });
        }
    }
    doConnect(){
        this.connect = true;
        this.disconnect = false;
        this.doCheckContact();
    }
    doDisConnect(){
        this.connect = false;
        this.disconnect = true;
        this.doCheckContact();
    }

    displayOptions() {        
        yearOfBirth()
        .then((result) => {
            this.loading = true;
             
            result.sort();
            result.push('--');
            result.reverse();
            this.yobOptions = result;
            this.loading = false;
             
        })
        .catch((error) => {
            console.log(error);            
            this.loading = false;
        });
    }

    checkDelegateAgeHandler(event) {   
        this.loading = true;
        let obj = {};
        if(event.currentTarget.dataset.name === 'yob') {  
            obj = {"Birth_Year__c": (event.detail.value==null || event.detail.value == undefined)?'--':event.detail.value.trim()};
            this.birthYear = (event.detail.value==null || event.detail.value == undefined)?'--':event.detail.value.trim();
            if(this.birthYear == ''|| this.birthYear == '--' || this.birthYear == undefined || this.birthYear == null){
                this.checkBox = false;
            }
        }

        verifyDelegateAge({ 
            participantJSON: JSON.stringify(this.participants),
            delegateParticipantJSON: JSON.stringify(obj)
        })
        .then((result) => {
            if(result === 'true') {
                this.isAdultDelegate = false;
            } else {
                this.isAdultDelegate = true;
                this.checkBox = false;
            }
            const selectedEvent = new CustomEvent("progressvaluechange", {
                detail: {
                    em:this.emailAddress,
                    fn:this.firstName,
                    ln:this.lastName,
                    by:this.birthYear,
                    cb:this.checkBox,
                    isadultdel:this.isAdultDelegate,
                    val:this.isValid,
                    disp:this.isDisplay,
                    indx:this.indexVal,
                    connect:this.isConnected,
                    usingdupdel:this.usingDuplicateDelegate,
                    disconnect:this.isDisconnected,
                    delegateId:this.delegateId,
                    isConnectedOnce:this.isConnectedOnce
                }
              });
              this.dispatchEvent(selectedEvent);
            this.loading = false;    
        })
        .catch((error) => {
            console.log(error);
            this.isAdultDelegate = true;
            this.loading = false;
        });
        
    }

    doConnectDelegate(){
        connectDelegateToPatient({ participantS:  JSON.stringify(this.participants),
                                   delegateS: JSON.stringify(this.delegateItem),
                                   studySiteId: this.siteid,
                                   isConnected: this.isDelegateConnected,
                                   duplicateDelegateInfo:  JSON.stringify(this.duplicateDelegateInfo),
                                   NoInvite : this.isvirtualsite
        })
        .then((result) => {
            this.isConnected = true;
            this.connect = false;
            this.isDisplay = false;
            this.isDisconnected = false;
            this.isConnectedOnce = true;
            this.delegateId = result.delegateId;
            this.isDelegateConnected = result.isConnected;
            const selectedEvent = new CustomEvent("progressvaluechange", {
                detail: {
                    em:this.emailAddress,
                    fn:this.firstName,
                    ln:this.lastName,
                    by:this.birthYear,
                    cb:this.checkBox,
                    val:this.isValid,
                    disp:this.isDisplay,
                    indx:this.indexVal,
                    connect:true,
                    usingdupdel:this.usingDuplicateDelegate,
                    disconnect:this.isDisconnected,
                    delegateId:this.delegateId,
                    isConnectedOnce:this.isConnectedOnce
                }
              });
              this.dispatchEvent(selectedEvent);
              this.loading = false;
        }).catch((error) => {
            console.log(error);
            this.connect = false;
            this.loading = false;
        });
       
    }

    doDisConnectDelegate(){
        disconnectDelegateToPatient({ delegateId: this.delegateId })
        .then((result) => {
            this.isConnected = false;
            this.isDisconnected = true;
            this.connect = false;
            this.disconnect = false;
            this.isDisplay = false;
            this.isDelegateConnected = false;
            const selectedEvent = new CustomEvent("progressvaluechange", {
                detail: {
                    em:this.emailAddress,
                    fn:this.firstName,
                    ln:this.lastName,
                    by:this.birthYear,
                    cb:this.checkBox,
                    val:this.isValid,
                    disp:this.isDisplay,
                    indx:this.indexVal,
                    connect:false,
                    usingdupdel:this.usingDuplicateDelegate,
                    disconnect:this.isDisconnected,
                    delegateId:this.delegateId,
                    isConnectedOnce:this.isConnectedOnce
                }
              });
              this.dispatchEvent(selectedEvent);
              this.loading = false;
        }).catch((error) => {
            console.log(error);
            this.disconnect = false;
            this.loading = false;
        });
       
    }

    useDuplicateRecord(event){
        this.isDuplicate = false;
        this.usingDuplicateDelegate = true;
        const selectedEvent = new CustomEvent("progressvaluechange", {
            detail: {
                em:this.emailAddress,
                fn:this.firstName,
                ln:this.lastName,
                by:this.birthYear,
                cb:this.checkBox,
                val:this.isValid,
                disp:this.isDisplay,
                indx:this.indexVal,
                connect:this.isConnected,
                usingdupdel:this.usingDuplicateDelegate,
                disconnect:this.isDisconnected,
                delegateId:this.delegateId,
                isConnectedOnce:this.isConnectedOnce
            }
          });
          this.dispatchEvent(selectedEvent);
    }
}