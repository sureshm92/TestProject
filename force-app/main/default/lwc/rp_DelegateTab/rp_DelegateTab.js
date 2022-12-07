import { LightningElement, api, track } from 'lwc';
import delegateUpdatePeRecords from '@salesforce/apex/RPRecordReviewLogController.delegateUpdatePeRecords';
import checkDelegateAge from '@salesforce/apex/RPRecordReviewLogController.checkDelegateAge';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//importing Custom Label
import RH_RP_Delegate_First_Name from '@salesforce/label/c.RH_RP_Delegate_First_Name';
import RH_RP_Delegate_Phone_Number from '@salesforce/label/c.RH_RP_Delegate_Phone_Number';
import RH_RP_Delegate_Phone_Type from '@salesforce/label/c.RH_RP_Delegate_Phone_Type';
import RH_RP_Delegate_Last_Name from '@salesforce/label/c.RH_RP_Delegate_Last_Name';
import RH_RP_Delegate_Email_Id from '@salesforce/label/c.RH_RP_Delegate_Email_Id';
import RH_RP_Delegate_Alt_Phone_Number from '@salesforce/label/c.RH_RP_Delegate_Alt_Phone_Number';
import RH_RP_Delegate_Alt_Phone_Type from '@salesforce/label/c.RH_RP_Delegate_Alt_Phone_Type';
import RH_RP_Delegate_Birth_Year from '@salesforce/label/c.RH_RP_Delegate_Birth_Year';
import RH_RP_Delegate_Certify from '@salesforce/label/c.RH_RP_Delegate_Certify';
import RH_RP_Cancel from '@salesforce/label/c.RH_RP_Cancel';
import RH_RP_Save from '@salesforce/label/c.RH_RP_Save';
import RH_RP_Delegate_Save_Data from '@salesforce/label/c.RH_RP_Delegate_Save_Data';
import RH_RP_Delegate_Ask_for_Save from '@salesforce/label/c.RH_RP_Delegate_Ask_for_Save';
import RH_RP_Delegate_Proceed from '@salesforce/label/c.RH_RP_Delegate_Proceed';
import RH_RP_Delegate_Cancel_Record from '@salesforce/label/c.RH_RP_Delegate_Cancel_Record';
import RH_RP_Delegate_Ask_For_Cancel from '@salesforce/label/c.RH_RP_Delegate_Ask_For_Cancel';
import RH_RP_Delegate_Save_Ok from '@salesforce/label/c.RH_RP_Delegate_Save_Ok';
import RH_RP_Delegate_Missing_field from '@salesforce/label/c.RH_RP_Delegate_Missing_field';
import RH_RP_Delegate_Email_Format_Error from '@salesforce/label/c.RH_RP_Delegate_Email_Format_Error';
import RH_RP_Delegate_Minor_Error from '@salesforce/label/c.RH_RP_Delegate_Minor_Error';
import RH_RP_Delegate_Successfully_Saved from '@salesforce/label/c.RH_RP_Delegate_Successfully_Saved';
import icon_chevron_up_white from '@salesforce/resourceUrl/icon_chevron_up_white';
import RH_RP_Select_Phone_Type from '@salesforce/label/c.RH_RP_Select_Phone_Type';
import RH_RP_Select_Alternative_Type from '@salesforce/label/c.Select_Alternative_Type';
import RH_RP_Select_Birth_Year from '@salesforce/label/c.RH_RP_Select_Birth_Year';
import SS_RH_US_Consent from '@salesforce/label/c.SS_RH_US_Consent';
import SS_RH_ROW_Consent_Email from '@salesforce/label/c.SS_RH_ROW_Consent_Email';
import SS_RH_ROW_Consent_SMS from '@salesforce/label/c.SS_RH_ROW_Consent_SMS';


export default class Rp_DelegateTab extends LightningElement {
    label = {
        RH_RP_Select_Birth_Year,
        RH_RP_Select_Alternative_Type,
        RH_RP_Select_Phone_Type,
        RH_RP_Delegate_First_Name,
        RH_RP_Delegate_Phone_Number,
        RH_RP_Delegate_Phone_Type,
        RH_RP_Delegate_Last_Name,
        RH_RP_Delegate_Email_Id,
        RH_RP_Delegate_Alt_Phone_Number,
        RH_RP_Delegate_Alt_Phone_Type,
        RH_RP_Delegate_Birth_Year,
        RH_RP_Delegate_Certify,
        RH_RP_Cancel,
        RH_RP_Save,
        RH_RP_Delegate_Save_Data,
        RH_RP_Delegate_Ask_for_Save,
        RH_RP_Delegate_Proceed,
        RH_RP_Delegate_Cancel_Record,
        RH_RP_Delegate_Ask_For_Cancel,
        RH_RP_Delegate_Save_Ok,
        RH_RP_Delegate_Missing_field,
        RH_RP_Delegate_Email_Format_Error,
        RH_RP_Delegate_Minor_Error,
        RH_RP_Delegate_Successfully_Saved,
        RH_RP_Select_Phone_Type,
        SS_RH_US_Consent,
        SS_RH_ROW_Consent_Email,
        SS_RH_ROW_Consent_SMS
    };
    topIcon = icon_chevron_up_white;

    @api
    get delegaterecordlist() {
        return this.delegaterecord;
    }
    set delegaterecordlist(value) {
        this.delegaterecord = JSON.parse(JSON.stringify(value));
    }

    @api
    get originaldelegaterecordlist() {
        return this.originaldelegaterecord;
    }
    set originaldelegaterecordlist(value) {
        this.originaldelegaterecord = JSON.parse(JSON.stringify(value));
    }

    @api isLoading = false;
    @api delegaterecord;
    @api originaldelegaterecord;
    @api isUnsavedModalOpen = false;
    @api disableButton =false;
    @api requiredFieldList = ['First Name','Phone Number','Last Name','Email ID'];
    @api requiredFieldComboBoxList = ['Phone Type','Birth Year'];
    @api isaccesslevelthree = false;
    @api isCountryus;
    getCountry=false;
    isInputValidated = false;
    isComboBoxValidated = false;
    isEmailFormatValidated = false;
    disabledSaveButton = true;
    cancelOpen = false;

    goTop(){
        window.scrollTo({
            top: 100,
            left: 0,
            behavior: 'smooth'
          });
    }

    checkValidEmail(element) {
        this.isEmailFormatValidated = false;
        var regexp = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([A-Za-z0-9a-À-ÖØ-öø-ÿÀÁÂÃÈÉÊÌÑÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưËẾăạảấầẩẫậắằẳẵÇặẹẻẽềềếểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ]+\.)+[A-Za-z0-9a-À-ÖØ-öø-ÿÀÁÂÃÈÉÊÌÑÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưËẾăạảấầẩẫậắằẳẵÇặẹẻẽềềếểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ]{2,}))$/;
        var regexpInvalid = new RegExp(/[\¡¿«»¢£¥€¤›]/);
        let emailValue = element.value;
        var invalidCheck = regexpInvalid.test(emailValue);
        if (invalidCheck == false) {
            element.setCustomValidity('');
            if (emailValue.match(regexp)) {
                element.setCustomValidity('');
                this.isEmailFormatValidated = true;
            } else {
                element.setCustomValidity(this.label.RH_RP_Delegate_Email_Format_Error);
                this.isEmailFormatValidated = false;
            }
        } else {
            email.setCustomValidity(this.label.RH_RP_Delegate_Email_Format_Error);
            this.isEmailFormatValidated = false;
        }
        element.reportValidity();
    }
    
    fieldValidation(name){
        this.template.querySelectorAll('lightning-input').forEach(element => {

            if(element.name == name) {
              if(!element.value) {
                    element.setCustomValidity(element.label  +' ' +  this.label.RH_RP_Delegate_Missing_field);
                    element.reportValidity();
              }
              else if(element.name == 'Email ID'){
                this.checkValidEmail(element)
              }
             else {
                    element.setCustomValidity('');
                    element.reportValidity();
                }
            }    
        });

        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if(element.name == name) {
              if(!element.value) {
                    element.setCustomValidity(element.label  +' ' + this.label.RH_RP_Delegate_Missing_field);
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
            let fieldname = inp.name;

            switch (fieldname) {
                case 'First Name':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + this.label.RH_RP_Delegate_Missing_field);
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                case 'Phone Number':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + this.label.RH_RP_Delegate_Missing_field);
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                case 'Last Name':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + this.label.RH_RP_Delegate_Missing_field);
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                case 'Birth Year':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + this.label.RH_RP_Delegate_Missing_field);
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                case 'Email ID':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + this.label.RH_RP_Delegate_Missing_field);
                        inp.reportValidity();
                        inpVal = false;
                    }
                    if(fieldValue) {
                        this.checkValidEmail(inp);
                        if(!this.isEmailFormatValidated){
                            inpVal = false;
                        }

                    }
                    break; 
                default:
                    if( fieldname != 'IsDelegateCertify' && fieldname != 'IsDelegateCertifyUS' && fieldname !=='IsDelegateCertifyROW' && fieldname != 'PDAP' && fieldname != 'PDAT'){
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
             if(this.requiredFieldComboBoxList.includes(inputComboBoxField[i].name)){
                 if(!inputComboBoxField[i].value) {
                     if(inputComboBoxField[i].name == 'Phone Type'){
                        inputComboBoxField[i].setCustomValidity(this.label.RH_RP_Delegate_Phone_Type  +' ' + this.label.RH_RP_Delegate_Missing_field);
                     }else{
                        inputComboBoxField[i].setCustomValidity(inputComboBoxField[i].label  +' ' + this.label.RH_RP_Delegate_Missing_field);
                     }
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
        this.disabledSaveButton = false;

        if(fieldName && fieldName !=='IsDelegateCertify' && fieldName !=='IsDelegateCertifyUS' && fieldName !=='IsDelegateCertifyROW' && fieldName !=='PDAP' && fieldName !=='PDAT'){
            this.fieldValidation(fieldName);
            this.disabledSaveButton = false;
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
        else if(event.target.dataset.value === 'IsDelegateCertifyUS') {
            record.peRecord.Delegate_Consent__c = event.target.checked;
            record.peRecord.Delegate_SMS_Consent__c = event.target.checked;
        }
         else if(event.target.dataset.value === 'IsDelegateCertifyROW') {
            record.peRecord.Delegate_Consent__c = event.target.checked;
        }
        else if(event.target.dataset.value === 'IsDelegateCertifySMS') {
            record.peRecord.Delegate_SMS_Consent__c = event.target.checked;
        }
        else if(event.target.dataset.value === 'PDAP') {
            record.peRecord.Primary_Delegate_s_Alt_Phone__c = event.target.value;
        }
        else if(event.target.dataset.value === 'PDAT') {
            record.peRecord.Primary_Delegate_s_Alt_Phone_Type__c = event.target.value;
        }
        this.delegaterecord = [...this.delegaterecord];

        if(this.delegaterecord[0].peRecord.Is_Delegate_Certify__c == false || this.delegaterecord[0].peRecord.Delegate_Consent__c==false){
            this.disabledSaveButton = true;
        }
    }

    cancelRecord(event) {
        this.disabledSaveButton = true;
        this.cancelOpen = false;
        let record = this.delegaterecord.find(ele  => ele.peRecord.Id === this.originaldelegaterecord[0].peRecord.Id);
        record.peRecord.Primary_Delegate_First_Name__c = this.originaldelegaterecord[0].peRecord.Primary_Delegate_First_Name__c;
        record.peRecord.Primary_Delegate_Phone_Number__c = this.originaldelegaterecord[0].peRecord.Primary_Delegate_Phone_Number__c;
        record.peRecord.Primary_Delegate_Phone_Type__c = this.originaldelegaterecord[0].peRecord.Primary_Delegate_Phone_Type__c;
        record.peRecord.Primary_Delegate_Last_Name__c = this.originaldelegaterecord[0].peRecord.Primary_Delegate_Last_Name__c;
        record.peRecord.Primary_Delegate_YOB__c = this.originaldelegaterecord[0].peRecord.Primary_Delegate_YOB__c;
        record.peRecord.Primary_Delegate_Email__c = this.originaldelegaterecord[0].peRecord.Primary_Delegate_Email__c;
        record.peRecord.Primary_Delegate_s_Alt_Phone__c = this.originaldelegaterecord[0].peRecord.Primary_Delegate_s_Alt_Phone__c;
        record.peRecord.Primary_Delegate_s_Alt_Phone_Type__c = this.originaldelegaterecord[0].peRecord.Primary_Delegate_s_Alt_Phone_Type__c;
        record.peRecord.Is_Delegate_Certify__c = this.originaldelegaterecord[0].peRecord.Is_Delegate_Certify__c;        
        this.delegaterecord = [...this.delegaterecord];

        this.template.querySelectorAll('lightning-input').forEach((element) => { 
            if(element.name != 'IsDelegateCertify'){
                element.setCustomValidity(" ");
                element.reportValidity();
            }
        });

        this.template.querySelectorAll('lightning-combobox').forEach((element) => { 
            element.setCustomValidity(" ");
            element.reportValidity();
        });

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
            let countryCode = this.delegaterecord[0].peRecord.Mailing_Country_Code__c;
            let stateCode = this.delegaterecord[0].peRecord.Mailing_State_Code__c;
            let year = this.delegaterecord[0].peRecord.Primary_Delegate_YOB__c;

            checkDelegateAge({countryCode: countryCode, stateCode: stateCode, year: year})
            .then((result) => {
                if(result == 'false') {
                    this.showErrorToast(this.label.RH_RP_Delegate_Minor_Error);
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
        this.disabledSaveButton = true;

        delegateUpdatePeRecords({peRecord: this.delegaterecord[0].peRecord})
        .then((result) => {
           /** let record = this.originaldelegaterecord.find(ele  => ele.peRecord.Id === result.Id);
            record.peRecord.Primary_Delegate_First_Name__c = result.Primary_Delegate_First_Name__c;
            record.peRecord.Primary_Delegate_Phone_Number__c = result.Primary_Delegate_Phone_Number__c;
            record.peRecord.Primary_Delegate_Phone_Type__c = result.Primary_Delegate_Phone_Type__c;
            record.peRecord.Primary_Delegate_Last_Name__c = result.Primary_Delegate_Last_Name__c;
            record.peRecord.Primary_Delegate_YOB__c = result.Primary_Delegate_YOB__c;
            record.peRecord.Primary_Delegate_Email__c =result.Primary_Delegate_Email__c;
            record.peRecord.Primary_Delegate_s_Alt_Phone__c = result.Primary_Delegate_s_Alt_Phone__c;        
            record.peRecord.Primary_Delegate_s_Alt_Phone_Type__c = result.Primary_Delegate_s_Alt_Phone_Type__c;        
            record.peRecord.Is_Delegate_Certify__c = result.Is_Delegate_Certify__c;        
            this.originaldelegaterecord = [...this.originaldelegaterecord]; **/
            this.showSuccessToast(result.Primary_Delegate_First_Name__c +' '+ this.label.RH_RP_Delegate_Successfully_Saved);
          
            /*const selectedvalue = {patientRecord: this.delegaterecord}; 
            const selectedEvent = new CustomEvent('refreshdelegatetabchange', { detail: selectedvalue });
            this.dispatchEvent(selectedEvent);*/

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

    cancelModelOpen(){
        this.cancelOpen = true;
    }
    closeCancelModal() {
        this.cancelOpen = false;
    }
}