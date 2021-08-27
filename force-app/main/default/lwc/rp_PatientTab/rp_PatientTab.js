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
    @api birthmonthdisplay = false;
    @api originalpatientrecord = [];
    isInputValidated = false;
    isComboBoxValidated = false;
    isNotValidated = false;
    @api isUnsavedModalOpen = false;
    @api disableButton = false;
    @api requiredfieldforminor = false;
    @api todayDate;

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

    //requiredFieldForAdultList = ['Patient ID','Email ID','First Name','Birth Month','Birth Year','Last Name','Phone Number','Postal Code'];
    //requiredfieldforminorList = ['Patient ID','First Name','Birth Month','Birth Year','Last Name','Postal Code'];
    //requiredFieldComboBoxForAdultList = ['Sex','Country','Phone Type','State','Site Name','Patient Auth Status','Legal Status'];
    //requiredFieldComboBoxForMinorList = ['Sex','Country','State','Site Name','Patient Auth Status','Legal Status'];
    inputNotIncludedFieldAdult = ['Alt Phone Number','M.I.','Birth Month Date','Birth Year Date','IsEmail','IsPhone','IsSMS'];

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
            }
        } else {
            email.setCustomValidity('You have entered an invalid format');
        }
        element.reportValidity();
    }
    
    fieldValidation(name){
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if(element.label == name && element.label) {
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
                    element.setCustomValidity('');
                    element.reportValidity();
                }
            } 
        });
    }

    inputValidatedForAdultAll() {
        this.isInputValidated = false;
        let isValid = [...this.template.querySelectorAll('lightning-input')].reduce( (val, inp) => {
            let inpVal = true;
            let fieldLabel = inp.label;
            let fieldValue = inp.value;
            switch (fieldLabel) {
                case 'Patient ID':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
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
                case 'First Name':
                if (!fieldValue) { 
                    inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                    inp.reportValidity();
                    inpVal = false;
                }
                break;
                case 'Birth Month':
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
                case 'Last Name':
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
                case 'Postal Code':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                default:
                    if(!this.inputNotIncludedFieldAdult.includes(fieldLabel)){
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

    inputValidatedForMinorAll() {
        this.isInputValidated = false;

        let isValid = [...this.template.querySelectorAll('lightning-input')].reduce( (val, inp) => {
            let inpVal = true;
            let fieldLabel = inp.label;
            let fieldValue = inp.value;
            switch (fieldLabel) {
                case 'Patient ID':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                case 'First Name':
                if (!fieldValue) { 
                    inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                    inp.reportValidity();
                    inpVal = false;
                }
                break;
                case 'Birth Month':
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
                case 'Last Name':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                case 'Postal Code':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                default:
                    if(!this.inputNotIncludedFieldAdult.includes(fieldLabel)){
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

    comboBoxValidatedAdultAll() {
        this.isComboBoxValidated = false;

        let isValid = [...this.template.querySelectorAll('lightning-combobox')].reduce( (val, inp) => {
            let inpVal = true;
            let fieldLabel = inp.label;
            let fieldValue = inp.value;

            switch (fieldLabel) {
                case 'Sex':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                case 'Country':
                if (!fieldValue) { 
                    inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                    inp.reportValidity();
                    inpVal = false;
                }
                break;
                case 'Phone Type':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                case 'State':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                case 'Site Name':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                case 'Patient Auth Status':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                case 'Legal Status':
                        if (!fieldValue) { 
                            inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                            inp.reportValidity();
                            inpVal = false;
                        }
                        break;
                default:
                    if(fieldLabel != 'Phone Type' && fieldLabel != 'Alt Phone Type'){
                        inpVal = true;
                        inp.setCustomValidity("");
                        inp.reportValidity();
                    }
                    break;
            }
            return val && inpVal;
        }, true);

        if (isValid) {
            this.isComboBoxValidated = true;
        }
    }

    comboBoxValidatedMinorAll() {
        this.isComboBoxValidated = false;

        let isValid = [...this.template.querySelectorAll('lightning-combobox')].reduce( (val, inp) => {
            let inpVal = true;
            let fieldLabel = inp.label;
            let fieldValue = inp.value;

            switch (fieldLabel) {
                case 'Sex':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                case 'Country':
                if (!fieldValue) { 
                    inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                    inp.reportValidity();
                    inpVal = false;
                }
                break;
                case 'State':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                case 'Site Name':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                case 'Patient Auth Status':
                    if (!fieldValue) { 
                        inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                        inp.reportValidity();
                        inpVal = false;
                    }
                    break;
                case 'Legal Status':
                        if (!fieldValue) { 
                            inp.setCustomValidity(fieldLabel +' ' + 'is missing.');
                            inp.reportValidity();
                            inpVal = false;
                        }
                        break;
                default:
                    if(fieldLabel != 'Alt Phone Type'){
                        inpVal = true;
                        inp.setCustomValidity("");
                        inp.reportValidity();
                    }
                    break;
            }
            return val && inpVal;
        }, true);

        if (isValid) {
            this.isComboBoxValidated = true;
        }
    }

     /*comboBoxValidatedAll() {
        this.isComboBoxValidated = false;
        var fieldComboBoxConditionCheck;

        if(this.requiredfieldforminor) {
            fieldComboBoxConditionCheck = this.requiredFieldComboBoxForMinorList;
        }
        else{
            fieldComboBoxConditionCheck = this.requiredFieldComboBoxForAdultList;
        }
        var inputComboBoxField = this.template.querySelectorAll('lightning-combobox');
        for(let i = 0; i <inputComboBoxField.length; i++) {
            if(fieldComboBoxConditionCheck.includes(inputComboBoxField[i].label)){
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
    }*/

    changeInputValue(event) {
        let name = event.target.name;
        if(name && name !=='IsEmail' && name !=='IsPhone' && name !=='IsSMS' && name !== 'BirthMonthDate'
                && name !== 'BirthMonthDate'){
            this.fieldValidation(name);
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
            record.peRecord.YOB__c = event.target.value;
            if(record.peRecord.YOB__c.length == 4) {
                this.checkPatientAge(record.peRecord.YOB__c);
                
                if(this.requiredfieldforminor){
                    record.peRecord.Legal_Status__c = 'Yes';
                }
                else{
                    record.peRecord.Legal_Status__c = 'No';
                }
            }
        }
        else if(event.target.dataset.value === 'BirthYearDate') {
            var dt = new Date(event.target.value);
            let year = dt.getFullYear();            
            record.peRecord.YOB__c = year.toString();
            this.checkPatientAge(record.peRecord.YOB__c);

            if(this.requiredfieldforminor){
                record.peRecord.Legal_Status__c = 'Yes';
            }
            else{
                record.peRecord.Legal_Status__c = 'No';
            }
            window.setTimeout(() => {
                const element = this.template.querySelector('[data-value="BirthYearDate"]');
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
        else if(event.target.dataset.value === 'AlternatePhoneNumber') {
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
            this.checkPatientAge(record.peRecord.YOB__c);
            if(!this.requiredfieldforminor){
                event.target.value = 'Yes'
                record.peRecord.Legal_Status__c = event.target.value 
            }
            else if(this.requiredfieldforminor){
                event.target.value = 'No'
                record.peRecord.Legal_Status__c = 'No';
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
    }

    closeUnsavedModal(event) {
        this.isUnsavedModalOpen = false;  
        this.disableButton = false;
    }

    checkPatientAge(year) {
        let countryCode = this.patientrecord[0].peRecord.Country__c;
        let stateCode = this.patientrecord[0].peRecord.State__c;
        let month = this.patientrecord[0].peRecord.Birth_Month__c;

        checkPatientAge({countryCode: countryCode,stateCode: stateCode,
                            month: month, year: year})
        .then((result) => {
            if(result == 'true') {
                this.requiredfieldforminor = false;               
            }
            else {
                this.requiredfieldforminor = true;
            }
        })
        .catch((error) => {
            this.showErrorToast(JSON.stringify(error.body.message));
        })
    }

    openUnsavedModal(event) {
        if(this.requiredfieldforminor && this.patientrecord[0].peRecord.YOB__c != undefined) {
            this.inputValidatedForMinorAll();
            this.comboBoxValidatedMinorAll();
        }
        else if(this.requiredfieldforminor && this.patientrecord[0].peRecord.YOB__c == undefined) {
            this.inputValidatedForAdultAll();
            this.comboBoxValidatedAdultAll();    
        }
        else {
            this.inputValidatedForAdultAll();
            this.comboBoxValidatedAdultAll();    
        }

        if(this.isInputValidated && this.isComboBoxValidated) {  
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