import { LightningElement,api,track} from 'lwc';
import updatePeRecords from '@salesforce/apex/RPRecordReviewLogController.updatePeRecords';
import patientValidation from '@salesforce/apex/RPRecordReviewLogController.patientValidation';
import checkPatientAge from '@salesforce/apex/RPRecordReviewLogController.checkPatientAge';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PG_Ref_L_Information_Sharing from '@salesforce/label/c.PG_Ref_L_Information_Sharing';
import PG_Ref_L_Permit_IQVIA_Confirmation from '@salesforce/label/c.PG_Ref_L_Permit_IQVIA_Confirmation';
import PG_Ref_L_Permit_IQVIA_To_ShareInformation from '@salesforce/label/c.PG_Ref_L_Permit_IQVIA_To_ShareInformation';
import PG_Ref_L_Permit_IQVIA_To_Contact_Email from '@salesforce/label/c.PG_Ref_L_Permit_IQVIA_To_Contact_Email';
import PG_Ref_L_Permit_IQVIA_To_Contact_Phone from '@salesforce/label/c.PG_Ref_L_Permit_IQVIA_To_Contact_Phone';
import PG_Ref_L_Permit_IQVIA_To_Contact_SMS from '@salesforce/label/c.PG_Ref_L_Permit_IQVIA_To_Contact_SMS';
import RH_Email_Validation_Pattern from '@salesforce/label/c.RH_Email_Validation_Pattern';
import RH_Email_Invalid_Characters from '@salesforce/label/c.RH_Email_Invalid_Characters';

export default class Rp_PatientTab extends LightningElement {
    @track patientrecord;
    @api states = [];
    @api originalpatientrecord = [];
    @api isUnsavedModalOpen = false;
    @api disableButton = false;
    @api todayDate;
    @track stateRequired = true;
    @track validationList = [];


    @api
    get patientrecordlist() {
        return this.patientrecord;
    }
    set patientrecordlist(value) {
        this.patientrecord = JSON.parse(JSON.stringify(value));
    }

    connectedCallback() {
        var today = new Date();
        this.todayDate= today.toISOString();  
    }

    label = {
        PG_Ref_L_Information_Sharing,
        PG_Ref_L_Permit_IQVIA_Confirmation,
        PG_Ref_L_Permit_IQVIA_To_ShareInformation,
        PG_Ref_L_Permit_IQVIA_To_Contact_Email,
        PG_Ref_L_Permit_IQVIA_To_Contact_Phone,
        PG_Ref_L_Permit_IQVIA_To_Contact_SMS,
        RH_Email_Validation_Pattern,
        RH_Email_Invalid_Characters
    };

    requiredFieldForAdult = ['PatientID','EmailID','FirstName','BirthMonth','BirthYear','LastName','PhoneNumber','PostalCode',
                                'Sex','Country','PhoneType','States','SiteName','PatientAuthStatus','LegalStatus'];
    requiredfieldforMinor = ['PatientID','FirstName','BirthMonth','BirthYear','LastName','PostalCode',
                                'Sex','Country','States','SiteName','PatientAuthStatus','LegalStatus'];
    //requiredComboBoxForAdult = ['Sex','Country','PhoneType','States','SiteName','PatientAuthStatus','LegalStatus'];
   // requiredComboBoxForMinor = ['Sex','Country','States','SiteName','PatientAuthStatus','LegalStatus'];
 
    inputNotIncludedField = ['AltPhoneNumber','AltPhoneType','MI','BirthMonthDate',
                                    'BirthYearDate','IsEmail','IsPhone','IsSMS'];
    inputNotIncludedFieldForMinor = ['Email ID','Phone Type','Alt Phone Type','Phone Number','Alt Phone Number','M.I.','Birth Month Date',
                                        'Birth Year Date','IsEmail','IsPhone','IsSMS'];

    yearValidation(year,element) {
        var text = /^[0-9]+$/;
        var current_year=new Date().getFullYear();
        if (year.length != 4) {
            element.setCustomValidity('You have entered an invalid format');
            element.reportValidity();
            return false;
        }
        else if(year != 0 && (year != "") && (!text.test(year))) {
            element.setCustomValidity('You have entered an invalid format');
            element.reportValidity();
            return false;
        }
        else if((year < 1900) || (year > current_year)) {
            element.setCustomValidity('Year should be in range 1900 to current year');
            element.reportValidity();
            return false;
        }
        else{
            element.setCustomValidity('');
            element.reportValidity();
            return true;
        }
    }

    monthValidation(month,element) {
        var text =/^(0?[1-9]|1[012])$/;
        if(!text.test(month)) {
            element.setCustomValidity('You have entered an invalid format');
            element.reportValidity();
            return false;
        }
        else{
            element.setCustomValidity('');
            element.reportValidity();
            return true;
        }
    }

    checkValidEmail(element) {
        let returnValue = false;
        var regexp = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([A-Za-z0-9a-À-ÖØ-öø-ÿÀÁÂÃÈÉÊÌÑÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưËẾăạảấầẩẫậắằẳẵÇặẹẻẽềềếểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ]+\.)+[A-Za-z0-9a-À-ÖØ-öø-ÿÀÁÂÃÈÉÊÌÑÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưËẾăạảấầẩẫậắằẳẵÇặẹẻẽềềếểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ]{2,}))$/;
        var regexpInvalid = new RegExp(/[\¡¿«»¢£¥€¤›]/);
        let emailValue = element.value;
        var invalidCheck = regexpInvalid.test(emailValue);
        if (invalidCheck == false) {
            element.setCustomValidity('');
            if (emailValue.match(regexp)) {
                element.setCustomValidity('');
                returnValue = true;
            } 
            else {
                element.setCustomValidity('You have entered an invalid format');
                returnValue = false;
            }
        } 
        else {
            email.setCustomValidity('You have entered an invalid format');
            returnValue = false;
        }
        element.reportValidity();
        return returnValue;
    }
    
    customFieldValidation(dataValue) {

        let element = this.template.querySelector('[data-value="' +dataValue+ '"]');
        let fieldValue = element.value;
        let fieldLabel = element.label;
        let returnvalue;

        if(!fieldValue) {
            element.setCustomValidity(fieldLabel +' ' + 'is missing.');
            returnvalue = false;
        }
        else if(fieldValue && fieldLabel =='Birth Month') {
            let isMonthValidated= this.monthValidation(fieldValue,element);
            if(isMonthValidated) {
                returnvalue = true;
            }
            else {
                returnvalue = false;
            }
        }
        else if(fieldValue && fieldLabel =='Birth Year') {
            let monthValueAvilable = this.template.querySelector('[data-value="BirthMonth"]');
            let monthValue = monthValueAvilable.value;
            if(!monthValue){
                monthValueAvilable.setCustomValidity('Fill before Birth Year');
                monthValueAvilable.reportValidity();
                element.value = '';
                returnvalue = false;
            }
            else {
                let isYearValidated= this.yearValidation(fieldValue,element);
                if(isYearValidated) {
                    returnvalue = true;
                }
                else {
                    returnvalue = false;
                }
            }
        }
        else if(fieldValue && fieldLabel =='Email ID') {
            let isEmailValidated= this.checkValidEmail(element);
            if(isEmailValidated) {
                returnvalue = true;
            }
            else {
                returnvalue = false;
            }
        }
        else{
            element.setCustomValidity('');
            returnvalue = true;
        }
        element.reportValidity();
        return returnvalue;
    }


    /*customFieldValidationAll() {
        let checkCondition =[];
        let returnvalue;

        checkCondition= this.patientrecord[0].isRequired ? this.requiredFieldForAdult : this.requiredfieldforMinor;

        for(let i=0; i<checkCondition.length; i++) {
            let dataValue = checkCondition[i];
            let element = this.template.querySelector('[data-value="' +dataValue+ '"]');
            let fieldValue = element.value;
            let fieldLabel = element.label;

            if(!fieldValue) {
                element.setCustomValidity(fieldLabel +' ' + 'is missing.');
                returnvalue = false;
            }
            else if(fieldValue && fieldLabel =='Birth Month') {
                let isMonthValidated= this.monthValidation(fieldValue,element);
                if(isMonthValidated) {
                    returnvalue = true;
                }
                else {
                    returnvalue = false;
                }
            }
            else if(fieldValue && fieldLabel =='Birth Year') {
                let monthValueAvilable = this.template.querySelector('[data-value="BirthMonth"]');
                let monthValue = monthValueAvilable.value;
                if(!monthValue){
                    monthValueAvilable.setCustomValidity('Fill before Birth Year');
                    monthValueAvilable.reportValidity();
                    element.value = '';
                    returnvalue = false;
                }
                else {
                    let isYearValidated= this.yearValidation(fieldValue,element);
                    if(isYearValidated) {
                        returnvalue = true;
                    }
                    else {
                        returnvalue = false;
                    }
                }
            }
            else if(fieldValue && fieldLabel =='Email ID') {
                let isEmailValidated= this.checkValidEmail(element);
                if(isEmailValidated) {
                    returnvalue = true;
                }
                else {
                    returnvalue = false;
                }
            }
            else{
                element.setCustomValidity('');
                returnvalue = true;
            }
            element.reportValidity();
        }
        return returnvalue; 
    }*/

    removeCustomFieldValidation(dataValue) {
        let element = this.template.querySelector('[data-value="' +dataValue+ '"]');
        element.setCustomValidity('');
        element.reportValidity();
    }

    changeInputValue(event) {
        let isRequired = this.patientrecord[0].isRequired;
        let dataValue = event.target.dataset.value.trim();

        if(isRequired && this.requiredFieldForAdult.includes(dataValue)) {
             this.customFieldValidation(dataValue);
        }
        else if(this.requiredfieldforMinor.includes(dataValue)){
            this.customFieldValidation(dataValue);
        }
        
        let record = this.patientrecord.find(ele  => ele.peRecord.Id === event.target.dataset.id);
        if(event.target.dataset.value === 'PatientID') {
            record.peRecord.Patient_ID__c = event.target.value;
        }
        else if(event.target.dataset.value === 'EmailID') {
            record.peRecord.Email__c = event.target.value;
        }
        else if(event.target.dataset.value === 'FirstName') {
            record.peRecord.Participant_Name__c = event.target.value;
        }
        else if(event.target.dataset.value === 'MI') {
            record.peRecord.Patient_Middle_Name_Initial__c = event.target.value;
        }
        else if(event.target.dataset.value === 'BirthMonth') {
            record.peRecord.Birth_Month__c = event.target.value;
        }
        else if(event.target.dataset.value === 'BirthMonthDate') {
            let dt = new Date(event.target.value);
            let month=  dt.getMonth() + 1;
            record.peRecord.Birth_Month__c = month.toString();
            window.setTimeout(() => {
                const element = this.template.querySelector('[data-value="BirthMonth"]');
                element.setCustomValidity('');
                element.reportValidity();
            }, 10);
        }
        else if(event.target.dataset.value === 'BirthYear') {
            let value = event.target.value;
            if(value.length == 4) {
                record.peRecord.YOB__c = event.target.value;
                this.checkPatientAge();
                if(this.patientrecord[0].isRequired){
                    record.peRecord.Legal_Status__c = 'Yes';
                }
                else{
                    record.peRecord.Legal_Status__c = 'No';
                }
            }
        }
        else if(event.target.dataset.value === 'BirthYearDate') {
            let value = event.target.value;
            var dt = new Date(value);
            let year = dt.getFullYear();            
            record.peRecord.YOB__c = year.toString();
            this.checkPatientAge();
            if(record.isRequired){
                record.peRecord.Legal_Status__c = 'Yes';
            }
            else{
                record.peRecord.Legal_Status__c = 'No';
            }
            window.setTimeout(() => {
                const element = this.template.querySelector('[data-value="BirthYear"]');
                element.setCustomValidity('');
                element.reportValidity();
            }, 10);
            
        }
        else if(event.target.dataset.value === 'LastName') {
            record.peRecord.Participant_Surname__c = event.target.value;
        }
        else if(event.target.dataset.value === 'Sex') {
            record.peRecord.Patient_Sex__c = event.target.value;
        }
        else if(event.target.dataset.value === 'Country') {
            record.peRecord.Country__c = event.target.value;
            this.states = this.patientrecord[0].statesByCountryMap[record.peRecord.Country__c];
            if(this.states.length> 0){
                this.stateRequired = true;
            }
            else{
                this.stateRequired = false;
                record.peRecord.State__c = '';
            }
        }
        else if(event.target.dataset.value === 'States') {
            record.peRecord.State__c = event.target.value;
        }
        else if(event.target.dataset.value === 'PhoneNumber') {
            record.peRecord.Phone__c = event.target.value;
        }
        else if(event.target.dataset.value === 'PhoneType') {
            record.peRecord.Patient_Phone_Type__c = event.target.value;
        }
        else if(event.target.dataset.value === 'AltPhoneNumber') {
            record.peRecord.Participant_Alternative_Phone__c = event.target.value;
        }
        else if(event.target.dataset.value === 'AltPhoneType') {
            record.peRecord.Participant_Alt_Phone_Type__c = event.target.value;
        }
        else if(event.target.dataset.value === 'PostalCode') {
            record.peRecord.Postal_Code__c = event.target.value;
        }
        else if(event.target.dataset.value === 'SiteName') {
            record.peRecord.Study_Site__c = event.target.value;
        }
        else if(event.target.dataset.value === 'PatientAuthStatus') {
            record.peRecord.Patient_Auth__c = event.target.value;
        }
        else if(event.target.dataset.value === 'LegalStatus') {
            this.checkPatientAge();
            if(record.isRequired){
                event.target.value = 'Yes'
                record.peRecord.Legal_Status__c = event.target.value 
            }
            else{
                event.target.value = 'No'
                record.peRecord.Legal_Status__c = event.target.value;
            }
        }
        else if(event.target.dataset.value === 'IsEmail') {
            record.peRecord.Is_Email__c = event.target.checked;
        }
        else if(event.target.dataset.value === 'IsPhone') {
            record.peRecord.Is_Phone__c = event.target.checked;
        }
        else if(event.target.dataset.value === 'IsSMS') {
            record.peRecord.Is_SMS__c = event.target.checked;
        }
        this.patientrecord = [...this.patientrecord];
        
    }

    cancelRecord(event) {
        let record = this.patientrecord.find(ele  => ele.peRecord.Id === this.originalpatientrecord[0].peRecord.Id);
        record.peRecord.Patient_ID__c = this.originalpatientrecord[0].peRecord.Patient_ID__c;
        record.peRecord.Email__c = this.originalpatientrecord[0].peRecord.Email__c;
        record.peRecord.Participant_Name__c = this.originalpatientrecord[0].peRecord.Participant_Name__c;
        record.peRecord.Patient_Middle_Name_Initial__c = this.originalpatientrecord[0].peRecord.Patient_Middle_Name_Initial__c;
        record.peRecord.Birth_Month__c = this.originalpatientrecord[0].peRecord.Birth_Month__c;
        record.peRecord.YOB__c = this.originalpatientrecord[0].peRecord.YOB__c;
        record.peRecord.Participant_Surname__c = this.originalpatientrecord[0].peRecord.Participant_Surname__c;
        record.peRecord.Patient_Sex__c = this.originalpatientrecord[0].peRecord.Patient_Sex__c;
        record.peRecord.Country__c = this.originalpatientrecord[0].peRecord.Country__c;
        record.peRecord.State__c = this.originalpatientrecord[0].peRecord.State__c;
        record.peRecord.Phone__c = this.originalpatientrecord[0].peRecord.Phone__c;
        record.peRecord.Patient_Phone_Type__c = this.originalpatientrecord[0].peRecord.Patient_Phone_Type__c;
        record.peRecord.Participant_Alternative_Phone__c = this.originalpatientrecord[0].peRecord.Participant_Alternative_Phone__c;
        record.peRecord.Participant_Alt_Phone_Type__c = this.originalpatientrecord[0].peRecord.Participant_Alternative_Phone__c;
        record.peRecord.Postal_Code__c = this.originalpatientrecord[0].peRecord.Postal_Code__c;
        record.peRecord.Study_Site__c = this.originalpatientrecord[0].peRecord.Study_Site__c;
        record.peRecord.Patient_Auth__c = this.originalpatientrecord[0].peRecord.Patient_Auth__c;
        record.peRecord.Legal_Status__c = this.originalpatientrecord[0].peRecord.Legal_Status__c;
        record.peRecord.Is_Email__c = this.originalpatientrecord[0].peRecord.Is_Email__c;
        record.peRecord.Is_Phone__c = this.originalpatientrecord[0].peRecord.Is_Phone__c;
        record.peRecord.Is_SMS__c = this.originalpatientrecord[0].peRecord.Is_SMS__c;
        this.patientrecord = [...this.patientrecord];

        if(this.patientrecord[0].isRequired) {
            this.requiredfieldforMinor.forEach(item => {
                this.removeCustomFieldValidation(item);
            });
        }
        else{
            this.requiredFieldForAdult.forEach(item => {
                this.removeCustomFieldValidation(item);
            });
           
        }

    }

    closeUnsavedModal(event) {
        this.isUnsavedModalOpen = false;  
        this.disableButton = false;
    }

    checkPatientAge() {
        let countryCode = this.patientrecord[0].peRecord.Country__c;
        let stateCode = this.patientrecord[0].peRecord.State__c;
        let year = this.patientrecord[0].peRecord.YOB__c;
        let month = this.patientrecord[0].peRecord.Birth_Month__c;

        checkPatientAge({countryCode: countryCode,stateCode: stateCode,
                            month: month, year: year})
        .then((result) => {
            if(result == 'true') {
                this.patientrecord[0].isRequired = false;               
            }
            else {
                this.patientrecord[0].isRequired = true;
            }
        })
        .catch((error) => {
            this.showErrorToast(JSON.stringify(error.body.message));
        })
    }



    openUnsavedModal(event) {

         let isAllFieldValidated = false;
         this.validationList = [];
         let checkCondition =[];

         if(this.patientrecord[0].isRequired) {
            this.requiredfieldforMinor.forEach(item => {
                this.removeCustomFieldValidation(item);
            });
        }
        else{
            this.requiredFieldForAdult.forEach(item => {
                this.removeCustomFieldValidation(item);
            });
        }
        checkCondition= this.patientrecord[0].isRequired ? this.requiredFieldForAdult : this.requiredfieldforMinor;
        for(let i=0; i<checkCondition.length; i++) {

            isAllFieldValidated = this.customFieldValidation(checkCondition[i].trim());      
            this.validationList.push(isAllFieldValidated);
        }
        let check;
        if(this.validationList.includes(false)){
            check = false
        }
        else{
            check = true
        }
        if(check) {  
            let newPatientId = this.patientrecord[0].peRecord.Patient_ID__c;
            let oldPatientId = this.originalpatientrecord[0].peRecord.Patient_ID__c;
            let countryCode = this.patientrecord[0].peRecord.Country__c;
            let stateCode = this.patientrecord[0].peRecord.State__c;
            let month = this.patientrecord[0].peRecord.Birth_Month__c;
            let year = this.patientrecord[0].peRecord.YOB__c;
            let legalStatus = this.patientrecord[0].peRecord.Legal_Status__c;

            patientValidation({newPatientId: newPatientId, oldPatientId: oldPatientId ,
                                countryCode: countryCode,stateCode: stateCode,
                                    month: month,year: year,legalStatus: legalStatus})
            .then((result) => {
                if(result == 'DuplicatePatientId') {
                    this.showErrorToast('Duplicate Patient Record found for'+' '+JSON.stringify(this.patientrecord[0].peRecord.Patient_ID__c));
                }
                else if(result == 'Minor') {                    
                    this.showErrorToast('Delegate information is mandatory in case of minor Patient');
                }
                else if(result == 'LegalStatus') {                    
                    this.showErrorToast('Legal Status should be Yes in case of minor Patient');
                }
                else{
                    this.isUnsavedModalOpen = true; 
                    this.disableButton = false; 
                }
            })
            .catch((error) => {
                this.showErrorToast(JSON.stringify(error.body.message));
                this.isUnsavedModalOpen = false; 
            })
        }
    }

    proceedDetailsModal(event) {
        this.disableButton = true;
        updatePeRecords({peRecord: this.patientrecord[0].peRecord})
        .then((result) => {
            console.log(JSON.stringify(result));
           this.dispatchEvent(new CustomEvent("refreshpatienttabchange"));
           eval("$A.get('e.force:refreshView').fire();");

        })
        .catch((error) => {
            this.showErrorToast(JSON.stringify(error.body.message));
        })
        .finally(() => {
            this.isUnsavedModalOpen = false;
        })
    }

    showSuccessToast(event) {
        const evt = new ShowToastEvent({
            title: 'Record Saved Successfully',
            message: 'Record Saved Successfully',
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