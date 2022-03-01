import { LightningElement, api } from 'lwc';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import verifyDelegateAge from '@salesforce/apex/ReferHealthcareProviderRemote.checkDelegateAge';
import AttestedCheckboxError from '@salesforce/label/c.RH_MinorDelegateErrMsg';
import inviteDelegate from '@salesforce/apex/ReferHealthcareProviderRemote.invitePatientDelegate';
import checkDuplicate from '@salesforce/apex/ReferHealthcareProviderRemote.checkDuplicate';
import StopSharing from '@salesforce/label/c.HealthCare_Provider_Stop_Sharing';
import ConnectPatient from '@salesforce/label/c.HealthCare_Provider_Connect';
import disconnect from '@salesforce/apex/ReferHealthcareProviderRemote.stopSharing';
import inviteHP from '@salesforce/apex/ReferHealthcareProviderRemote.inviteHP';
import yearOfBirth from '@salesforce/apex/PIR_SharingOptionsController.fetchYearOfBirth';

export default class Pir_sharingFormFields extends LightningElement {
    @api yob;
    @api pe;
    @api isValid;
    @api sharingObject;
    @api participantObject;
    value = [];
    communityTemplate ='';
    @api isAdultDelegate;
    loading = false;
    isValidError = [];
    isDuplicateDelegate = false;
    duplicateDelegateInfo;
    isExistingDelegate = false;
    connectDisconnect = false;
    isHCPDelegate = false;
    gridCss='';
    yobOptions=[];
    isDisabled = false;

    
    displayOptions1() {        
        yearOfBirth()
        .then((result) => {
            this.loading = true;
             
            result.sort();
            result.reverse();
            this.yobOptions = result;
            this.loading = false;
             
        })
        .catch((error) => {
            console.log(error);            
            this.loading = false;
        });
    }

    label = {
        AttestedCheckboxError,
        ConnectPatient,
        StopSharing
    }

    connectedCallback(){
        this.displayOptions1();
        loadScript(this, RR_COMMUNITY_JS)
        .then(() => {
            this.communityTemplate = communityService.getCurrentCommunityTemplateName();
        }).then(() => {
            this.fetchList(); 
        }).catch((error) => {
             console.log('Error: ' + error);
        });
        if(this.sharingObject.sObjectType === 'Object'){
           
            this.isHCPDelegate = true;
            this.isHCPDelegate = false;
            if(this.sharingObject.delegateId) {
                this.isExistingDelegate = true;
                this.gridCss='slds-p-around_small';    

            } else {
                this.gridCss='delegate-bg slds-p-around_small';
                this.isExistingDelegate = false;
            }
            if(this.sharingObject.status) {
                if(this.sharingObject.status === 'Active' && this.isExistingDelegate) {
                    this.connectDisconnect = this.label.StopSharing;
                } else if(this.sharingObject.status === 'Disconnected' && this.isExistingDelegate) {
                    this.connectDisconnect = this.label.ConnectPatient;
                }
            }
        } else {
            this.isHCPDelegate = true;
            if(this.sharingObject.Id) {
                this.isExistingDelegate = true;   
                this.isDisabled = true;             
                this.gridCss='slds-p-around_small';
            } else {
                this.isExistingDelegate = false; 
                this.isDisabled = false;                 
                this.gridCss='delegate-bg slds-p-around_small';
            }
            if(this.sharingObject.Status__c) {
                if(this.sharingObject.Status__c === 'Invited' && this.isExistingDelegate || this.isDuplicate) {
                    this.connectDisconnect = this.label.StopSharing;
                } else if(this.sharingObject.Status__c === 'No Sharing' && this.isExistingDelegate) {
                    this.connectDisconnect = this.label.ConnectPatient;
                }
            }
        }

    }

    checkFields(event) {
        let obj = {};
        let mergedObj = {};
        if(event.currentTarget.dataset.name === 'email') { 
            let emailElement = this.template.querySelector('[data-name="email"]');
            if(this.sharingObject.sObjectType === 'Object') {
                obj = {"email": event.detail.value.trim()};
            } else {
                obj = {"Email__c": event.detail.value.trim()};
            }
            mergedObj = { ...this.sharingObject, ...obj };
            this.sharingObject = mergedObj;
            
        }
        if(event.currentTarget.dataset.name === 'firstName') {
            if(this.sharingObject.sObjectType === 'Object') {
                obj = {"firstName": event.detail.value.trim()};
            } else {
                obj = {"First_Name__c": event.detail.value.trim()};
            }
            mergedObj = { ...this.sharingObject, ...obj };
            this.sharingObject = mergedObj;           
        }
        if(event.currentTarget.dataset.name === 'lastName') {
            if(this.sharingObject.sObjectType === 'Object') {
                obj = {"lastName": event.detail.value.trim()};
            } else {
                obj = {"Last_Name__c": event.detail.value.trim()};
            }
            mergedObj = { ...this.sharingObject, ...obj };
            this.sharingObject = mergedObj;  
        }
        this.validateForm();
    }

    checkDelegateAgeHandler(event) {
        
        this.loading = true;
        let obj = {};
        let mergedObj = {};
        let attestCheckbox =  this.template.querySelector('[data-name="yob"]');
        if(event.currentTarget.dataset.name === 'yob') {  
            obj = {"Birth_Year__c": event.detail.value.trim()};
            mergedObj = { ...this.sharingObject, ...obj };
            this.sharingObject = mergedObj;
        }

        verifyDelegateAge({ 
            participantJSON: JSON.stringify(this.participantObject.Participant__r),
            delegateParticipantJSON: JSON.stringify(this.sharingObject)
        })
        .then((result) => {
            if(result === 'true') {
                this.isAdultDelegate = false;
                 attestCheckbox.setCustomValidity('');
                attestCheckbox.reportValidity();
            } else {
                this.isAdultDelegate = true;
                attestCheckbox.setCustomValidity(this.label.AttestedCheckboxError);                
                attestCheckbox.reportValidity();
            }
            this.validateForm();
            this.loading = false;    
        })
        .catch((error) => {
            console.log(error);
            this.isAdultDelegate = true;
            this.loading = false;
        });
        
    }

    validateForm() {
        let isValidCount = 0;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                //inputField.reportValidity();
                isValidCount++;
            }
            
        });

        if(this.sharingObject.sObjectType === 'Object') {
            
            let checkbox = this.template.querySelector('[data-name="attestCheckbox"]').checked;
            if(isValidCount == 0 && !this.isAdultDelegate && checkbox && !this.isDuplicateDelegate) {//validation successfull
                this.isValid = false;
            } else {
                this.isValid = true;
            }
        } else {
            if(isValidCount == 0) {//validation successfull
                this.isValid = false;
            } else {
                this.isValid = true;
            }
        }
        
    }

    ConnectDelegate() {

        if(this.sharingObject.sObjectType == 'Object') {
            let isDelegateInvited = false;
            let pe = this.participantObject.Study_Site__r;
            let participant = this.participantObject.Participant__r;
            if (
                pe.Study_Site__r != undefined &&
                pe.Study_Site__r != null &&
                pe.Study_Site__r.Study_Site_Type__c != 'Virtual' &&
                pe.Study_Site__r.Study_Site_Type__c != 'Hybrid' &&
                pe.Study_Site__r.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c ==
                    false &&
                pe.Study_Site__r.Suppress_Participant_Emails__c == false &&                
                pe.Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c != 'Janssen' && 
                pe.Study_Site__r.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c == true
            ) {
                isDelegateInvited = true;
            }
            this.loading = true;
            inviteDelegate({ 
                participant: JSON.stringify(participant),
                delegateContact: JSON.stringify(this.sharingObject),
                delegateId: this.sharingObject.delegateId ? this.sharingObject.delegateId : null,
                //ddInfo: JSON.stringify(component.get('v.duplicateDelegateInfo')),
                ddInfo: null,
                createUser: isDelegateInvited,
                YearOfBirth : this.sharingObject.Birth_Year__c != '' ? this.sharingObject.Birth_Year__c : ''
            })
            .then((result) => {
                this.refreshComponent();
                this.loading = false;
                    
            })
            .catch((error) => {
                console.log(error);                
                this.loading = false;
            });
        } else {
            this.connectHP();
        }
    }

    connectHP() {
        this.loading = true;
        inviteHP({ 
            peId: this.participantObject.Id,
            hp: JSON.stringify(this.sharingObject),            
            ddInfo: null
        })
        .then((result) => {
            this.refreshComponent();
            this.loading = false;
        })
        .catch((error) => {
            console.log(error);            
            this.loading = false;
        });

    }

    refreshComponent() {

        this.dispatchEvent(new CustomEvent('refresh', { bubbles: true, composed: true }));
    }

    checkDelegateDuplicate(event) {
        let email = this.template.querySelector('[data-name="email"]');
        let firstname = this.template.querySelector('[data-name="firstName"]');
        let lastname = this.template.querySelector('[data-name="lastName"]');

       
        if(this.sharingObject.sObjectType == 'Object'){ 
            if(email.checkValidity() &&
            firstname.checkValidity() &&
            lastname.checkValidity() &&
            this.sharingObject.sObjectType == 'Object' &&
            this.sharingObject.firstName &&
            this.sharingObject.lastName &&
            this.sharingObject.email.trim()) {
                this.doCheckContact();

            }

        }
        else if(this.sharingObject.sObjectType == 'Healthcare_Provider__c'){
            
            if(firstname == undefined) {
                let obj={};
                let mergedObj = {};
                obj = {"First_Name__c": null};
                mergedObj = { ...this.sharingObject, ...obj };
                this.sharingObject = mergedObj; 
            } 
            if(lastname == undefined) {
                let obj={};
                let mergedObj = {};
                obj = {"Last_Name__c": event.detail.value.trim()};
                mergedObj = { ...this.sharingObject, ...obj };
                this.sharingObject = mergedObj;
            }
            if(email.checkValidity() &&
                firstname &&
                lastname &&
                this.sharingObject.sObjectType == 'Healthcare_Provider__c'
            ) {
                this.doCheckContact();
        }
            
        }

       
    }

    doCheckContact() {
        this.loading = true;
        checkDuplicate({ 
            peId: this.participantObject.Id,
            email: this.sharingObject.email ? this.sharingObject.email : this.sharingObject.Email__c ,
            firstName: this.sharingObject.firstName ? this.sharingObject.firstName : this.sharingObject.First_Name__c,
            lastName: this.sharingObject.lastName ? this.sharingObject.lastName : this.sharingObject.Last_Name__c,
            participantId: null
        })
        .then((result) => {
            
            this.isDuplicateDelegate = result.isDuplicateDelegate;
            if(result.isDuplicateDelegate) {
                this.duplicateDelegateInfo = result;
                var dupcomp = this.template.querySelector('.duplicatemsg');
                dupcomp.scrollIntoView();
            }
            if(this.sharingObject != 'Object') {
                this.isDuplicateDelegate = result.isDuplicate;
                if(result.isDuplicate) {                    
                    let obj={};
                    let mergedObj = {};
                    obj = {"First_Name__c": result.firstName,"Last_Name__c":result.lastName};
                    mergedObj = { ...this.sharingObject, ...obj };
                    this.sharingObject = mergedObj; 
                    this.isDisabled = true; 
                    this.isValid = true;
                } else {
                    let obj={};
                    let mergedObj = {};
                    obj = {"First_Name__c": '',"Last_Name__c":''};
                    mergedObj = { ...this.sharingObject, ...obj };
                    this.sharingObject = mergedObj; 
                    this.isDisabled = false; 
                    this.isValid = true;
                }
            }
            this.loading = false; 
        })
        .catch((error) => {
            console.log('>>error>>'+error);            
            this.loading = false;
        });

    }

    stopSharing() {
        if(this.sharingObject.sObjectType === 'Object') {
            if(this.sharingObject.status === 'Active') {
                this.doDisconnect();
            } else {
                this.ConnectDelegate();
            }
        } else {

            if(this.sharingObject.Status__c === 'Invited') {
                this.doDisconnect();
            } else {
                this.ConnectDelegate();
            }
        }

    }

    doDisconnect() {
        this.loading = true;
        let params;
        if(this.sharingObject.sObjectType == 'Object') {
            params = {hpId:null, delegateId:this.sharingObject.delegateId};
        } else {
            params = {hpId:this.sharingObject.Id, delegateId:null};
        }
        disconnect(params)
        .then((result) => {
            //this.isDuplicateDelegate = result.isDuplicateDelegate;
            this.refreshComponent();
            this.loading = false; 
        })
        .catch((error) => {
            console.log(error);            
            this.loading = false;
        });

    }

}