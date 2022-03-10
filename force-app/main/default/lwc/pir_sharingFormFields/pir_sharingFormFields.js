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
import ConnectRP from '@salesforce/apex/ReferHealthcareProviderRemote.showOrHideProvider';
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
    isRpContact = false;
    isDelegate = false;
    isDisplayFormFields = false;
    isDisplay = false;
    @api delegateLevel;

    
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
        }).catch((error) => {
             console.log('Error: ' + error);
        });
        this.loadinitialData();

    }

    loadinitialData() {
        if(this.delegateLevel && (this.delegateLevel === 'Level 3' || this.delegateLevel === 'Level 2')) {
            this.isValid = true;
        } else {
            this.isValid = false;
        }
        
        if(this.sharingObject.sObjectType === 'Object') {
            if(!this.isDelegate) {
                this.isDelegate = true;
            }

            if(this.sharingObject.delegateId) {
                this.isExistingDelegate = true;                
                this.isDisabled = true;                
                this.gridCss='delegate-border slds-p-around_small slds-m-top_medium';    
                this.displayFormFields();

            } else {
                this.gridCss='delegate-bg slds-p-around_small';
                this.isValid = true;
                this.isExistingDelegate = false;
                this.isDisplayFormFields = true;
                this.displayFormFields();
            }
            if(this.sharingObject.status) {
                if(this.sharingObject.status === 'Active' && this.isExistingDelegate) {
                    this.connectDisconnect = this.label.StopSharing;
                } else if(this.sharingObject.status === 'Disconnected' && this.isExistingDelegate) {
                    this.connectDisconnect = this.label.ConnectPatient;
                }
            }
        } else if(this.sharingObject.sObjectType === 'Healthcare_Provider__c'){
            
            if(!this.isHCPDelegate) {
                this.isHCPDelegate = true;
            }
            if(this.sharingObject.Id) {
                this.isExistingDelegate = true;
                this.isDisabled = true;             
                this.gridCss='delegate-border slds-p-around_small slds-m-top_medium';
            } else {
                this.isValid = true;
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
        } else {
            if(this.participantObject.Show_Referring_Provider__c) {
                this.connectDisconnect = this.label.StopSharing;
            } else {
                this.connectDisconnect = this.label.ConnectPatient;
            }
            if(!this.isRpContact) {
                this.isRpContact = true;
            }
            if(this.sharingObject.Id) {                
                this.isExistingDelegate = true;
                this.gridCss='delegate-border slds-p-around_small slds-m-top_medium';
            }
        }
    }

    displayFormFields() {
        if(this.isExistingDelegate || this.isDisplayFormFields) {
            this.isDisplay = true;
        } else {
            this.isDisplay = false;
        }
    }

    checkFields(event) {
        let obj = {};
        let mergedObj = {};
        if(event.currentTarget.dataset.name === 'email') { 
            if(this.sharingObject.sObjectType === 'Object') {
                this.isDisplayFormFields = true;
                this.displayFormFields();
                if(this.duplicateDelegateInfo) {
                    this.duplicateDelegateInfo = {};
                    this.isDuplicateDelegate = false;
                }
                if(this.sharingObject.Birth_Year__c) {
                    this.sharingObject.Birth_Year__c = '';
                    this.template.querySelector('[data-name="attestCheckbox"]').checked = false;
                    this.isAdultDelegate = true;
                    //this.isDisabled = false;
                }                
                this.isDisabled = false;
                obj = {"email": event.detail.value.trim()};
            } else {
                if(this.isDisabled) {                
                    obj = {"First_Name__c": '',"Last_Name__c":'',"Email__c": event.detail.value.trim()};
                } else {
                    obj = {"Email__c": event.detail.value.trim()};
                }
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

        if(event.currentTarget.dataset.name === 'attestCheckbox') {
            let inputField = this.template.querySelector('[data-name="attestCheckbox"]');
            inputField.reportValidity();
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
            if(this.isDisplayFormFields && isValidCount == 0) {
                this.isValid = true;
            }else if(isValidCount == 0 && !this.isDisplayFormFields) {//validation successfull
                let checkbox = this.template.querySelector('[data-name="attestCheckbox"]').checked;
                if(!this.isAdultDelegate && checkbox && !this.isDuplicateDelegate) {
                    this.isValid = false;
                }
            } else {
                this.isValid = true;
            }
        } else {
            if(isValidCount == 0 && !this.isDisabled) {//validation successfull
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
            let dupObj;
            if(this.duplicateDelegateInfo) {
                dupObj = this.duplicateDelegateInfo.contactId ? JSON.stringify(this.duplicateDelegateInfo) : null;
            } else {
                dupObj = null;
            }
            if (
                pe != undefined &&
                pe != null &&
                pe.Study_Site_Type__c != 'Virtual' &&
                pe.Study_Site_Type__c != 'Hybrid' &&
                pe.Clinical_Trial_Profile__r.Suppress_Participant_Emails__c ==
                    false &&
                pe.Suppress_Participant_Emails__c == false &&                
                pe.Clinical_Trial_Profile__r.CommunityTemplate__c != 'Janssen' && 
                pe.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c == true
            ) {
                isDelegateInvited = true;
            }
            this.loading = true;
            inviteDelegate({ 
                participant: JSON.stringify(participant),
                delegateContact: JSON.stringify(this.sharingObject),
                delegateId: this.sharingObject.delegateId ? this.sharingObject.delegateId : null,
                //ddInfo: JSON.stringify(component.get('v.duplicateDelegateInfo')),
                ddInfo: dupObj,
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
        } else if(this.sharingObject.sObjectType == 'Healthcare_Provider__c'){
            this.connectHP();
        } else {
            this.connectRP();
        }
    }

    connectRP(){
        this.loading = true;

        ConnectRP({ 
            peId: this.participantObject.Id
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

    connectHP() {
        this.loading = true;
        let dupObj;
        if(this.duplicateDelegateInfo) {
            dupObj = !this.duplicateDelegateInfo.isDuplicate ? JSON.stringify(this.duplicateDelegateInfo) : null;
        } else {
            dupObj = null;
        }
        inviteHP({ 
            peId: this.participantObject.Id,
            hp: JSON.stringify(this.sharingObject),            
            ddInfo: dupObj
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
            if (result.firstName) {
                if(this.sharingObject.sObjectType === 'Healthcare_Provider__c') {
                    this.isDuplicateDelegate = true;                                    
                    let obj={};
                    let mergedObj = {};
                    obj = {"First_Name__c": result.firstName,"Last_Name__c":result.lastName};
                    mergedObj = { ...this.sharingObject, ...obj };
                    this.sharingObject = mergedObj; 
                    this.isDisabled = true; 
                    this.duplicateDelegateInfo = result;
                    if(result.isDuplicate) {
                        this.isValid = true;
                    } else {
                        this.isValid = false;
                    }
                    
                    let dupcomp = this.template.querySelector('.duplicatemsg');
                    dupcomp.scrollIntoView();                    
                } else if(this.sharingObject.sObjectType === 'Object'){ 
                    this.isDisabled = true;
                    this.isDuplicateDelegate = true;              
                    this.duplicateDelegateInfo = result;                    
                    let dupcomp = this.template.querySelector('.duplicatemsg');
                    dupcomp.scrollIntoView();                    
                }
            } else {
                this.isDuplicateDelegate = false;
               
                if(this.sharingObject.sObjectType === 'Healthcare_Provider__c') {
                    let obj={};
                    let mergedObj = {};
                    obj = {"First_Name__c": '',"Last_Name__c":''};
                    mergedObj = { ...this.sharingObject, ...obj };
                    this.sharingObject = mergedObj; 
                    this.isDisabled = false; 
                    this.isValid = true;
                }
                if(this.sharingObject.sObjectType === 'Object'){
                    this.isDisplayFormFields = false;
                    this.displayFormFields();
                }
                
            }
            this.loading = false; 
        })
        .catch((error) => {
            console.log('>>error>>'+error);            
            this.loading = false;
        });

    }

    useDuplicateRecord() {
        this.isDuplicateDelegate = false;
        this.isValid = false;
        console.log('this.sharingObject:'+JSON.stringify(this.sharingObject));
    }

    stopSharing() {
        if(this.sharingObject.sObjectType === 'Object') {
            if(this.sharingObject.status === 'Active') {
                this.doDisconnect();
            } else {
                this.ConnectDelegate();
            }
        } else if(this.sharingObject.sObjectType == 'Healthcare_Provider__c'){

            if(this.sharingObject.Status__c === 'Invited') {
                this.doDisconnect();
            } else {
                this.ConnectDelegate();
            }
        } else {
            this.connectRP();
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

    disconnectPatient(params) {

    }

}