import { LightningElement, api, track } from 'lwc';
import updatePeRecords from '@salesforce/apex/RPRecordReviewLogController.updatePeRecords';
import checkDelegateAge from '@salesforce/apex/RPRecordReviewLogController.checkDelegateAge';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Rp_DelegateTab extends LightningElement {
    @api
    get delegaterecordlist() {
        return this.delegaterecord;
    }
    set delegaterecordlist(value) {
        this.delegaterecord = JSON.parse(JSON.stringify(value));
    }

    @api todayDate;
    @api isLoading = false;
    @api delegaterecord;
    @api originaldelegaterecord = [];
    @api isUnsavedModalOpen = false;
    @api disableButton =false;
    @api requiredFieldList = ['First Name','Phone Number','Last Name','Birth Year','Birth Year Date','Email ID'];
    @api requiredFieldComboBoxList = ['Phone Type'];
    isInputValidated = false;
    isComboBoxValidated = false;

    connectedCallback() {
        if(this.delegaterecord[0].peRecord.Legal_Status__c == 'Yes'){
            this.delegaterecord[0].peRecord.Is_Delegate_Certify__c = true;
        }
        else{
            this.delegaterecord[0].peRecord.Is_Delegate_Certify__c = false;
        }
        var today = new Date();
        this.todayDate= today.toISOString();    
    }
    
    checkValidEmail(element) {
        var regexp = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([A-Za-z0-9a-À-ÖØ-öø-ÿÀÁÂÃÈÉÊÌÑÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưËẾăạảấầẩẫậắằẳẵÇặẹẻẽềềếểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ]+\.)+[A-Za-z0-9a-À-ÖØ-öø-ÿÀÁÂÃÈÉÊÌÑÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưËẾăạảấầẩẫậắằẳẵÇặẹẻẽềềếểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ]{2,}))$/;
        var regexpInvalid = new RegExp(/[\¡¿«»¢£¥€¤›]/);
        let emailValue = element.value;
        var invalidCheck = regexpInvalid.test(emailValue);
        if (invalidCheck == false) {
            element.setCustomValidity('');
            if (emailValue.match(regexp)) {
                element.setCustomValidity('');
            } else {
                element.setCustomValidity('You have entered an invalid format');
                this.isInputValidated = false;
            }
        } else {
            email.setCustomValidity('You have entered an invalid format');
            this.isInputValidated = false;
        }
        element.reportValidity();
    }
    
    fieldValidation(name){
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if(element.label == name) {
              if(!element.value) {
                    element.setCustomValidity(element.label  +' ' + 'is missing.');
                    element.reportValidity();
              }
              else if(element.label == 'Email ID'){
                this.checkValidEmail(element)
              }
             else {
                    element.setCustomValidity('');
                    element.reportValidity();
                }
            }    
        });

        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if(element.label == name) {
              if(!element.value) {
                    element.setCustomValidity(element.label  +' ' + 'is missing.');
                    element.reportValidity();
              }
             else {
                    element.setCustomValidity("");
                    element.reportValidity();
                }
            } 
        });
    }

    inputValidatedAll() {
        this.isInputValidated = false;

        let isValid = [...this.template.querySelectorAll('lightning-input')].reduce( (val, inp) => {
            let inpVal = true;
            let fieldLabel = inp.label;
            let fieldValue = inp.value;

            switch (fieldLabel) {
                case 'First Name':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                case 'Phone Number':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                case 'Last Name':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                case 'Birth Year':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                        inp.reportValidity();
                        inpVal = false;
                    }
                    if (fieldValue && fieldValue.length < 4){
                        inp.setCustomValidity(fieldLabel +' ' + 'Incorrect format.');
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                case 'Email ID':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                default:
                    if(fieldLabel != 'Birth Year Date' && fieldLabel != 'IsDelegateCertify'){
                        inpVal = true;
                        inp.setCustomValidity("");
                        inp.reportValidity();
                    }
                    break;
            }
            return val && inpVal;
        }, true);

        if (isValid) {
            this.isInputValidated = true;
        }
    }
    
    comboBoxValidatedAll() {
        this.isComboBoxValidated = false;
        var inputComboBoxField = this.template.querySelectorAll('lightning-combobox');
        for(let i = 0; i <inputComboBoxField.length; i++) {
             if(this.requiredFieldComboBoxList.includes(inputComboBoxField[i].label)){
                 if(!inputComboBoxField[i].value) {
                     inputComboBoxField[i].setCustomValidity(inputComboBoxField[i].label  +' ' + 'is missing.');
                     inputComboBoxField[i].reportValidity();
                     this.isComboBoxValidated = false;
                 }
                 else {
                        inputComboBoxField[i].setCustomValidity('');
                        inputComboBoxField[i].reportValidity();
                        this.isComboBoxValidated = true;
                }
             }   
         }
     }

    changeInputValue(event) {
        let fieldName = event.target.name;
        if(fieldName  && fieldName !=='IsDelegateCertify'){
            this.fieldValidation(fieldName);
        }
        let record = this.delegaterecord.find(ele  => ele.peRecord.Id === event.target.dataset.id);
        if(event.target.dataset.value === 'DelFirstName') {
            record.peRecord.Primary_Delegate_First_Name__c = event.target.value;
        }
        else if(event.target.dataset.value === 'DelPhoneNumber') {
            record.peRecord.Primary_Delegate_Phone_Number__c = event.target.value;
        }
        else if(event.target.dataset.value === 'DelPhoneType') {
            record.peRecord.Primary_Delegate_Phone_Type__c = event.target.value;
        }
        else if(event.target.dataset.value === 'DelLastName') {
            record.peRecord.Primary_Delegate_Last_Name__c = event.target.value;
        }
        else if(event.target.dataset.value === 'DelBirthYear') {
            record.peRecord.Primary_Delegate_YOB__c = event.target.value;
        }
        else if(event.target.dataset.value === 'DelBirthDateYear') {
            var dt = new Date(event.target.value);
            record.peRecord.Primary_Delegate_YOB__c = dt.getFullYear().toString();
            window.setTimeout(() => {
                const element = this.template.querySelector('[data-value="DelBirthYear"]');
                element.setCustomValidity('');
                element.reportValidity();
            }, 10);
        }
        else if(event.target.dataset.value === 'DelEmail') {
            record.peRecord.Primary_Delegate_Email__c = event.target.value;
        }
        else if(event.target.dataset.value === 'IsDelegateCertify') {
            record.peRecord.Is_Delegate_Certify__c = event.target.checked;
        }
        this.delegaterecord = [...this.delegaterecord];
    }

    cancelRecord(event) {
        let record = this.delegaterecord.find(ele  => ele.peRecord.Id === this.originaldelegaterecord[0].peRecord.Id);
        record.peRecord.Primary_Delegate_First_Name__c = this.originaldelegaterecord[0].peRecord.Primary_Delegate_First_Name__c;
        record.peRecord.Primary_Delegate_Phone_Number__c = this.originaldelegaterecord[0].peRecord.Primary_Delegate_Phone_Number__c;
        record.peRecord.Primary_Delegate_Phone_Type__c = this.originaldelegaterecord[0].peRecord.Primary_Delegate_Phone_Type__c;
        record.peRecord.Primary_Delegate_Last_Name__c = this.originaldelegaterecord[0].peRecord.Primary_Delegate_Last_Name__c;
        record.peRecord.Primary_Delegate_YOB__c = this.originaldelegaterecord[0].peRecord.Primary_Delegate_YOB__c;
        record.peRecord.Primary_Delegate_Email__c = this.originaldelegaterecord[0].peRecord.Primary_Delegate_Email__c;
        record.peRecord.Is_Delegate_Certify__c = this.originaldelegaterecord[0].peRecord.Is_Delegate_Certify__c;        
        this.delegaterecord = [...this.delegaterecord];

        window.setTimeout(() => {
            this.template.querySelectorAll('lightning-input').forEach((element) => { 
                element.setCustomValidity('');
                element.reportValidity();
            });
        }, 10);
    }

    closeUnsavedModal(event) {
        this.isUnsavedModalOpen = false;  
        this.disableButton = false;
    }

    openUnsavedModal(event) {
        this.inputValidatedAll();
        this.comboBoxValidatedAll();

        if(this.isInputValidated && this.isComboBoxValidated) {  
            this.isLoading = true;
            let countryCode = this.delegaterecord[0].peRecord.Country__c;
            let stateCode = this.delegaterecord[0].peRecord.State__c;
            let year = this.delegaterecord[0].peRecord.Primary_Delegate_YOB__c;

            checkDelegateAge({countryCode: countryCode, stateCode: stateCode, year: year})
            .then((result) => {
                if(result == 'false') {
                    this.showErrorToast('Delegate age should not be Minor');
                 }
                 else{
                    this.isUnsavedModalOpen = true; 
                    this.disableButton = false; 
                 }
            })
            .catch((error) => {
                this.showErrorToast(JSON.stringify(error.body.message));
            })
            .finally(() => {
                this.isLoading = false;
            })

        }
    }

    proceedDetailsModal(event) {
        this.disableButton = true;
        updatePeRecords({peRecord: this.delegaterecord[0].peRecord})
        .then((result) => {
            this.showSuccessToast(this.delegaterecord[0].peRecord.Primary_Delegate_First_Name__c +' '+ 'Record Successfully Saved.');
           // this.dispatchEvent(new CustomEvent("refreshdelegatetabchange"));
        })
        .catch((error) => {
            this.showErrorToast(JSON.stringify(error.body.message));
        })
        .finally(() => {
            this.isUnsavedModalOpen = false;
        })
    }

    showSuccessToast(record) {
        const evt = new ShowToastEvent({
            title: record,
            message: record,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showErrorToast(errorRec) {
        const evt = new ShowToastEvent({
            title: errorRec,
            message: errorRec,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}