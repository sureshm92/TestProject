import { LightningElement,api,track } from 'lwc';
import checkDelegateDuplicate from '@salesforce/apex/ParticipantInformationRemote.checkDelegateDuplicate';
import connectDelegateToPatient from '@salesforce/apex/ParticipantInformationRemote.connectDelegateToPatient';
import { label } from "c/pir_label";
export default class Pir_participantEmancipatedDelegate extends LightningElement {
    @api emailAddress = '';
    @api firstName = '';
    @api lastName = '';
    @api participantid;
    @api isValid = false;
    @api participants; 
    @api delegateItem ={};
    @api studysiteid = '';
    @api siteid='';
    @api isvirtualsite = false; 
    @api connect = false;
    @api duplicateDelegateInfo;
    @api isDuplicate = false;
    @api isConnected = false;
    @api isDelegateConnected = false;
    @api indexVal = '';
    @api em = '';@api fn = '';@api ln = '';@api isconn = false;
    @api loading = false;
    @track utilLabels = label;
    @api maindivcls;
    checkFields(event){
        let datavalue = event.target.dataset.value;
        if(event.target.dataset.value === "firstName") {
            this.firstName = event.target.value;
          }else if(event.target.dataset.value === "email"){
            this.emailAddress = event.target.value;
            this.firstName = '';
            this.lastName = '';
          }else if(event.target.dataset.value === "lastName"){
            this.lastName = event.target.value;
          }
          this.checkValidation();
          const selectedEvent = new CustomEvent("progressvaluechange", {
            detail: {
                em:this.emailAddress,
                fn:this.firstName,
                ln:this.lastName,
                indx:this.indexVal,
                connect:this.isConnected
            }
          });
          this.dispatchEvent(selectedEvent);
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
    get doValid(){
        if(this.isValid){
            if(this.isDuplicate){
                return true;
            }else{
                return false;
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
                    if(this.connect){
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
                    this.isDuplicate = false;
                } 
                if(this.connect){
                    this.doConnectDelegate();
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
        this.doCheckContact();
    }
    doDisConnect(){
        this.doCheckContact();
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
            this.connect = false;
            this.isConnected = true;
            this.isDelegateConnected = result.isConnected;
            const selectedEvent = new CustomEvent("progressvaluechange", {
                detail: {
                    em:this.emailAddress,
                    fn:this.firstName,
                    ln:this.lastName,
                    indx:this.indexVal,
                    connect:true
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
    useDuplicateRecord(event){
        this.isDuplicate = false;
    }
}