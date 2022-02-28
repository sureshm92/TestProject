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

    get options() {
        return [
            { label: '2022', value: '2022' },
            { label: '2021', value: '2021' },
            { label: '2020', value: '2020' },
            { label: '2019', value: '2019' },
            { label: '1999', value: '1999' }           
          
        ];
    }

    label = {
        AttestedCheckboxError,
        ConnectPatient,
        StopSharing
    }

    connectedCallback(){
        loadScript(this, RR_COMMUNITY_JS)
        .then(() => {
            this.communityTemplate = communityService.getCurrentCommunityTemplateName();
        }).then(() => {
            this.fetchList(); 
        }).catch((error) => {
             console.log('Error: ' + error);
        });
        if(this.sharingObject.sObjectType === 'Object'){
            //options = eval(this.yob);
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
                this.gridCss='slds-p-around_small';
            } else {
                this.isExistingDelegate = false;                
                this.gridCss='delegate-bg slds-p-around_small';
            }
            if(this.sharingObject.Status__c) {
                if(this.sharingObject.Status__c === 'Invited' && this.isExistingDelegate) {
                    this.connectDisconnect = this.label.StopSharing;
                } else if(this.sharingObject.status === 'Disconnected' && this.isExistingDelegate) {
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
        /*if(event.currentTarget.dataset.name === 'attestCheckbox') {
            //this.sharingObject.Last_Name__c = event.detail.value.trim();
            let attestCheckbox = event.currentTarget.dataset.name;
            attestCheckbox.setCustomValidity('');
            attestCheckbox.reportValidity('');
        }  */  
        
        this.validateForm();
        console.log('this.sharingObject:'+JSON.stringify(this.sharingObject));
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
            console.log('>>>result>>'+result);
            //this.isAdultDelegate = result;
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
            //this.error = error;
            console.log(error);
            this.isAdultDelegate = true;
            this.loading = false;
            //this.showErrorToast(JSON.stringify(error.body.message));
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
            console.log('>>isDelegateInvited>>'+isDelegateInvited);
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
                console.log('>>>result>>'+result);
                this.refreshComponent();
                this.loading = false;
                    
            })
            .catch((error) => {
                //this.error = error;
                console.log(error);
                
                this.loading = false;
                //this.showErrorToast(JSON.stringify(error.body.message));
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
            console.log('>>>result>>'+result);
            this.refreshComponent();
            this.loading = false;
                
        })
        .catch((error) => {
            //this.error = error;
            console.log(error);
            
            this.loading = false;
            //this.showErrorToast(JSON.stringify(error.body.message));
        });

    }

    refreshComponent() {

        this.dispatchEvent(new CustomEvent('refresh', { bubbles: true, composed: true }));
    }

    checkDelegateDuplicate(event) {
        let email = this.template.querySelector('[data-name="email"]');
        let firstname = this.template.querySelector('[data-name="firstName"]');
        let lastname = this.template.querySelector('[data-name="lastName"]');

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

    doCheckContact() {
        this.loading = true;
        checkDuplicate({ 
            peId: this.participantObject.Id,
            email: this.sharingObject.email,
            firstName: this.sharingObject.firstName,
            lastName: this.sharingObject.lastName,
            participantId: null
        })
        .then((result) => {
            console.log('>>>result>>'+JSON.stringify(result));
            this.isDuplicateDelegate = result.isDuplicateDelegate;
            if(result.isDuplicateDelegate) {
                this.duplicateDelegateInfo = result;
            }
            this.loading = false; 
        })
        .catch((error) => {
            //this.error = error;
            console.log(error);
            
            this.loading = false;
            //this.showErrorToast(JSON.stringify(error.body.message));
        });

    }

    stopSharing() {
        if(this.sharingObject.status == 'Active') {
            this.doDisconnect();
        } else {
            this.ConnectDelegate();
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
            console.log('>>>result>>'+JSON.stringify(result));
            this.isDuplicateDelegate = result.isDuplicateDelegate;
            this.refreshComponent();
            this.loading = false; 
        })
        .catch((error) => {
            //this.error = error;
            console.log(error);            
            this.loading = false;
            //this.showErrorToast(JSON.stringify(error.body.message));
        });

    }

}