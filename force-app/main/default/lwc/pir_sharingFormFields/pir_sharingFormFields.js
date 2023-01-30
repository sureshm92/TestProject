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
import DelegateEmailLabel from '@salesforce/label/c.HealthCare_Delegates_Email';
import ProvidersEmailLabel from '@salesforce/label/c.HealthCare_Providers_Email';
import DelegateFirstNameLabel from '@salesforce/label/c.HealthCare_Delegates_First_Name';
import ProvidersFirstNameLabel from '@salesforce/label/c.HealthCare_Providers_First_Name';
import DelegatelastnameLabel from '@salesforce/label/c.HealthCare_Delegates_Last_Name';
import ProvidersLastnameLabel from '@salesforce/label/c.HealthCare_Providers_Last_Name';
import YearOfBirth from '@salesforce/label/c.RH_YearofBirth';
import DelegateAttestation from '@salesforce/label/c.RH_DelegateAttestation';
import DifferentHealthCareProvider from '@salesforce/label/c.Different_HealthCare_Provider';
import RH_StudyDelegateConsentEmail from '@salesforce/label/c.RH_StudyDelegateConsentEmail' ;
export default class Pir_sharingFormFields extends LightningElement {
    @api yob;
    @api pe;
    @api isValid;
    @api sharingObject;
    @api participantObject;
    @api selectedPer;
    value = [];
    communityTemplate ='';
    @api isAdultDelegate;
    isAdultDelegateUS=true;
    loading = false;
    isValidError = [];
    isDuplicateDelegate = false;
    duplicateDelegateInfo;
    isExistingDelegate = false;
    connectDisconnect;
    isHCPDelegate = false;
    gridCss='';
    yobOptions=[];
    isDisabled = false;
    isRpContact = false;
    isDelegate = false;
    isDisplayFormFields = false;
    isDisplay = false;
    @api delegateLevel;
    isSendNotification = false;
    @api rtlcss;
    
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
        StopSharing,
        DelegateEmailLabel,
        ProvidersEmailLabel,
        DelegateFirstNameLabel,
        ProvidersFirstNameLabel,
        DelegatelastnameLabel,
        ProvidersLastnameLabel,
        YearOfBirth,
        DelegateAttestation,
        DifferentHealthCareProvider,
        RH_StudyDelegateConsentEmail
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
        /*if(this.delegateLevel && (this.delegateLevel === 'Level 3' || this.delegateLevel === 'Level 2')) {
            this.isValid = true;
        } else {
            this.isValid = false;
        }*/
        
        if(this.sharingObject.sObjectType === 'Object') {
            if(this.delegateLevel && (this.delegateLevel === 'Level 3' || this.delegateLevel === 'Level 2')) {
                this.isValid = true;
            } else {
                this.isValid = false;
            }

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
            //if(this.delegateLevel && (this.delegateLevel === 'Level 3' || this.delegateLevel === 'Level 2')) {
                //this.isValid = false;
            //}
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
                    this.isValid = false;
                } else if(this.sharingObject.Status__c === 'No Sharing' && this.isExistingDelegate) {
                    this.connectDisconnect = this.label.ConnectPatient;
                    if(this.delegateLevel && (this.delegateLevel === 'Level 3' || this.delegateLevel === 'Level 2')) {
                        this.isValid = true;
                    } else {
                        this.isValid = false;
                    }
                }
            }
        } else {
            if(this.delegateLevel && (this.delegateLevel === 'Level 3' || this.delegateLevel === 'Level 2')) {
                this.isValid = true;
            } else {
                this.isValid = false;
            }
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
    isDisplayConsent=false;
    displayFormFields() {
        if(this.isExistingDelegate || this.isDisplayFormFields) {
            this.isDisplay = true;
        } else {
            this.isDisplay = false;
        }
        if( this.isExistingDelegate || this.isDisplayFormFields){
            this.isDisplayConsent = true;
        } else {
            this.isDisplayConsent = false;
        
        }
    }
    cssError=false;
    cssErrorUS=false;

    checkFields(event) {
        let obj = {};
        let mergedObj = {};
        if(event.currentTarget.dataset.name === 'email') { 
            if(this.sharingObject.sObjectType === 'Object') {
                this.handleDuplicate();
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
                this.handleDuplicate();
                obj = {"firstName": event.detail.value.trim()};
            } else {
                obj = {"First_Name__c": event.detail.value.trim()};
            }
            mergedObj = { ...this.sharingObject, ...obj };
            this.sharingObject = mergedObj;           
        }
        if(event.currentTarget.dataset.name === 'lastName') {
            if(this.sharingObject.sObjectType === 'Object') {
                this.handleDuplicate();
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

        if(event.currentTarget.dataset.name === 'attestCheckboxUS') {
            let inputField = this.template.querySelector('[data-name="attestCheckboxUS"]');
            inputField.reportValidity();
            this.cssError=event.target.checked;
            this.handleCSS();
        }
      
        this.validateForm();
   
    }

    handleDuplicate(){
        this.isDisplayFormFields = true;
        this.isAdultDelegateUS=true;
        if(this.isDuplicateAttestation){
        this.isDuplicateAttestation=false;
        }
        this.displayFormFields();
        if(this.duplicateDelegateInfo) {
            this.duplicateDelegateInfo = {};
            this.isDuplicateDelegate = false;
        }
        if(this.sharingObject.Birth_Year__c) {
            this.sharingObject.Birth_Year__c = '';
            this.template.querySelector('[data-name="attestCheckbox"]').checked = false;
            this.template.querySelector('[data-name="attestCheckboxUS"]').checked = false;
            this.isAdultDelegate = true;
            this.isAdultDelegateUS=true;
            //this.isDisabled = false;
        }                
        this.isDisabled = false;
    }
    handleCSS(){
        if(this.cssError == true){
            this.template.querySelectorAll(".errorcss").forEach(function (L) {
                L.classList.add("check-box-m-topUSNoError");
            });
            this.template.querySelectorAll(".errorcss").forEach(function (L) {
                L.classList.remove("check-box-m-topUSError");
            });
        }
        else {
            this.template.querySelectorAll(".errorcss").forEach(function (L) {
                L.classList.add("check-box-m-topUSError");
            });
            this.template.querySelectorAll(".errorcss").forEach(function (L) {
                L.classList.remove("check-box-m-topUSNoError");
            });
        }
       
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
                this.isAdultDelegateUS=false;
                 attestCheckbox.setCustomValidity('');
                attestCheckbox.reportValidity();
            } else {
                this.isAdultDelegate = true;
                this.isAdultDelegateUS=true;
                attestCheckbox.setCustomValidity(this.label.AttestedCheckboxError);                
                attestCheckbox.reportValidity();
            }
            this.validateForm();
            this.loading = false;    
        })
        .catch((error) => {
            console.log(error);
            this.isAdultDelegate = true;
            this.isAdultDelegateUS=true;
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
            if(!this.isDuplicateAttestation){
                if(this.isDisplayFormFields && isValidCount == 0) {
                    this.isValid = true;
                }else if(isValidCount == 0 && !this.isDisplayFormFields) {//validation successfull
                    let checkbox = this.template.querySelector('[data-name="attestCheckbox"]').checked;
                    let checkboxUS = this.template.querySelector('[data-name="attestCheckboxUS"]').checked;

                    if(!this.isAdultDelegate && checkbox && checkboxUS && !this.isDuplicateDelegate) {
                        this.isValid = false;
                    }
                } else {
                    this.isValid = true;
                }
            }
            else{
                let checkboxUS = this.template.querySelector('[data-name="attestCheckboxUS"]').checked;
                let emailDel=this.template.querySelector('[data-name="email"]').value;
                if(checkboxUS && emailDel!='') {
                    this.isValid = false;
                }
                else {
                    this.isValid = true;
                }
            }
        } 
        
        else {
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
            this.toggleParentComponent();//disable parent component for navigation
            inviteDelegate({ 
                participant: JSON.stringify(participant),
                delegateContact: JSON.stringify(this.sharingObject),
                delegateId: this.sharingObject.delegateId ? this.sharingObject.delegateId : null,
                ddInfo: dupObj,
                createUser: isDelegateInvited,
                YearOfBirth : this.sharingObject.Birth_Year__c != '' ? this.sharingObject.Birth_Year__c : '',
                perID: this.selectedPer.id
            })
            .then((result) => {
                this.updatePER();
                this.refreshComponent();
                this.loading = false;
                this.toggleParentComponent(); 
            })
            .catch((error) => {
                console.log(error);                
                this.loading = false;
                this.toggleParentComponent();
            });
        } else if(this.sharingObject.sObjectType == 'Healthcare_Provider__c'){
            this.connectHP();
        } else {
            this.connectRP();
        }
    }

    connectRP(){
        this.loading = true;
        this.toggleParentComponent();
        ConnectRP({ 
            peId: this.participantObject.Id
        })
        .then((result) => {
            this.updatePER();
            this.refreshComponent();
            this.loading = false;
            this.toggleParentComponent();            
        })
        .catch((error) => {
            console.log(error);            
            this.loading = false;
            this.toggleParentComponent();
        });
    }

    connectHP() {
        this.loading = true;
        this.toggleParentComponent();
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
            this.updatePER();
            this.refreshComponent();
            this.loading = false;
            this.toggleParentComponent();
        })
        .catch((error) => {
            console.log(error);            
            this.loading = false;
            this.toggleParentComponent();
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

        if(((email && email != '') || (firstname && firstname != '') || (lastname && lastname != '')) && !this.isSendNotification) { //fire an event to parent component
            this.isSendNotification = true;
            this.sendEditNotificationToParent();
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
    isDuplicateAttestation=false;
    useDuplicateRecord() {
        this.isDisplayConsent=false;
        this.isDuplicateAttestation=true;
        this.isAdultDelegateUS=false;
        this.isDuplicateDelegate = false;
        //this.isValid = false;
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
        this.toggleParentComponent();
        let params;
        if(this.sharingObject.sObjectType == 'Object') {
            params = {hpId:null, delegateId:this.sharingObject.delegateId};
        } else {
            params = {hpId:this.sharingObject.Id, delegateId:null};
        }
        disconnect(params)
        .then((result) => {
            this.updatePER();
            this.refreshComponent();
            this.loading = false; 
            this.toggleParentComponent();
        })
        .catch((error) => {
            console.log(error);            
            this.loading = false;
            this.toggleParentComponent();
        });

    }

    sendEditNotificationToParent() {
        this.dispatchEvent(new CustomEvent('formedit', { bubbles: true, composed: true,detail:{'isFormEdit':true} }));

    }

    toggleParentComponent() {
        this.dispatchEvent(new CustomEvent('toggleclick',{ bubbles: true, composed: true}));
    }

    updatePER() {
        this.dispatchEvent(new CustomEvent('updateper',{ bubbles: true, composed: true}));
    }

}
