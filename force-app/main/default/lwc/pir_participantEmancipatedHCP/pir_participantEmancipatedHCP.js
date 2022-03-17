import { LightningElement,api } from 'lwc';
import checkDuplicate from '@salesforce/apex/ReferHealthcareProviderRemote.checkDuplicate';
import inviteHP from '@salesforce/apex/ReferHealthcareProviderRemote.inviteHP';
import HealthCare_Providers_Last_Name from '@salesforce/label/c.HealthCare_Providers_Last_Name';
import HealthCare_Providers_Email from '@salesforce/label/c.HealthCare_Providers_Email';
import HealthCare_Providers_First_Name from '@salesforce/label/c.HealthCare_Providers_First_Name';
import HealthCare_Provider_Connect from '@salesforce/label/c.HealthCare_Provider_Connect';
import HealthCare_Provider_Stop_Sharing from '@salesforce/label/c.HealthCare_Provider_Stop_Sharing';
import Different_HealthCare_Provider from '@salesforce/label/c.Different_HealthCare_Provider';
import HealthCare_Provider_Found from '@salesforce/label/c.HealthCare_Provider_Found';
export default class Pir_participantEmancipatedHCP extends LightningElement {
    @api emailAddress = '';
    @api firstName = '';
    @api lastName = '';
    @api isValid = false;
    @api perid = ''; 
    @api duplicateDelegateInfo;
    @api sharingObject = {};
    @api connect = false;
    @api isDuplicate = false;
    loading = false;

    label = {
        HealthCare_Providers_Last_Name,
        HealthCare_Providers_Email,
        HealthCare_Providers_First_Name,
        HealthCare_Provider_Connect,
        HealthCare_Provider_Stop_Sharing,
        Different_HealthCare_Provider,
        HealthCare_Provider_Found
    }

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
                    this.isValid = false;
                }
           }else{
            this.isValid = false;
           }
    }
    doCheckContact(){
            this.loading = true;
            checkDuplicate({ peId: this.perid,
                email: this.emailAddress,
                firstName: null,
                lastName: null,
                participantId: null })
            .then((result) => { 
                if(!result.isDuplicate && !result.isDuplicateDelegate){
                    this.isDuplicate = false;
                    this.duplicateDelegateInfo = null;
                    this.sharingObject = {
                        sObjectType:"Healthcare_Provider__c",
                        Email__c:this.emailAddress,
                        First_Name__c:this.firstName,
                        Last_Name__c:this.lastName
                    }
                }
                if(result.isDuplicateDelegate || result.isDuplicate){
                    this.isDuplicate = true;
                    this.firstName = result.firstName;
                    this.lastName = result.lastName;
                }
                if(this.connect){
                    this.doConnectHCP();
                }else{
                    this.loading = false;
                }
            }).catch((error) => {
                console.log(error);
                this.loading = false;
            });
        //}
    }
    doConnect(){
        this.connect = true;
        this.doCheckContact();
    }
    doConnectHCP(){
        this.loading = true;
        inviteHP({ peId: this.perid,
                   hp: JSON.stringify(this.sharingObject),
                   ddInfo:  JSON.stringify(this.duplicateDelegateInfo)
        })
        .then((result) => {
            this.connect = false;
            const selectedEvent = new CustomEvent("updatehcp", {});
            this.dispatchEvent(selectedEvent);
            this.loading = false;
        }).catch((error) => {
            console.log(error);
            this.connect = false;
            this.loading = false;
        });
       
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
}