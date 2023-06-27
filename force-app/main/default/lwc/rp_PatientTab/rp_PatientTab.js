import { LightningElement, api, track } from 'lwc';
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
import RH_RP_Main_Info from '@salesforce/label/c.RH_RP_Main_Info';
import RH_RP_Patient_ID from '@salesforce/label/c.RH_RP_Patient_ID';
import RH_RP_Email_ID from '@salesforce/label/c.RH_RP_Email_ID';
import RH_RP_First_Name from '@salesforce/label/c.RH_RP_First_Name';
import RH_RP_Middle_Initial from '@salesforce/label/c.RH_RP_Middle_Initial';
import RH_RP_Birth_Month from '@salesforce/label/c.RH_RP_Birth_Month';
import RH_RP_Birth_Year from '@salesforce/label/c.RH_RP_Birth_Year';
import RH_RP_Last_Name from '@salesforce/label/c.RH_RP_Last_Name';
import RH_RP_Sex from '@salesforce/label/c.RH_RP_Sex';
import RH_RP_Address from '@salesforce/label/c.RH_RP_Address';
import RH_RP_Country from '@salesforce/label/c.RH_RP_Country';
import RH_RP_Phone_Number from '@salesforce/label/c.RH_RP_Phone_Number';
import RH_RP_Phone_Type from '@salesforce/label/c.RH_RP_Phone_Type';
import RH_RP_State from '@salesforce/label/c.RH_RP_State';
import RH_RP_Alt_Phone_Number from '@salesforce/label/c.RH_RP_Alt_Phone_Number';
import RH_RP_Alt_Phone_Type from '@salesforce/label/c.RH_RP_Alt_Phone_Type';
import RH_RP_Postal_Code from '@salesforce/label/c.RH_RP_Postal_Code';
import RH_RP_site_info from '@salesforce/label/c.RH_RP_site_info';
import RH_RP_Site_Name from '@salesforce/label/c.RH_RP_Site_Name';
import RH_RP_Patient_Auth_Status from '@salesforce/label/c.RH_RP_Patient_Auth_Status';
import RH_RP_Legal_Status from '@salesforce/label/c.RH_RP_Legal_Status';
import RH_RP_Patient_Authorization from '@salesforce/label/c.RH_RP_Patient_Authorization';
import RH_RP_Save_Data from '@salesforce/label/c.RH_RP_Save_Data';
import RH_RP_Save_Changes from '@salesforce/label/c.RH_RP_Save_Changes';
import RH_RP_Cancel_Record from '@salesforce/label/c.RH_RP_Cancel_Record';
import RH_RP_discard_changes from '@salesforce/label/c.RH_RP_discard_changes';
import Save from '@salesforce/label/c.Save';
import BTN_Close from '@salesforce/label/c.BTN_Close';
import Cancel from '@salesforce/label/c.Cancel';
import Proceed from '@salesforce/label/c.Proceed';
import BTN_OK from '@salesforce/label/c.BTN_OK';
import RH_RP_Select_Birth_Month from '@salesforce/label/c.RH_RP_Select_Birth_Month';
import RH_RP_Select_Birth_Year from '@salesforce/label/c.RH_RP_Select_Birth_Year';
import RH_RP_Select_Sex from '@salesforce/label/c.RH_RP_Select_Sex';
import RH_RP_Select_Country from '@salesforce/label/c.RH_RP_Select_Country';
import RH_RP_Select_Phone_Type from '@salesforce/label/c.RH_RP_Select_Phone_Type';
import RH_RP_Select_State from '@salesforce/label/c.RH_RP_Select_State';
import RH_RP_Select_Site_Name from '@salesforce/label/c.RH_RP_Select_Site_Name';
import RH_RP_Patient_Auth_Status_Verified from '@salesforce/label/c.RH_RP_Patient_Auth_Status_Verified';
import RH_RP_Legal_Status_Verified from '@salesforce/label/c.RH_RP_Legal_Status_Verified';
import RH_RP_Invalid_Email from '@salesforce/label/c.RH_RP_Invalid_Email';
import RH_RP_is_missing from '@salesforce/label/c.RH_RP_is_missing';
import RH_RP_Future_Month from '@salesforce/label/c.RH_RP_Future_Month';
import RH_RP_Patient_Auth_should_be_Yes from '@salesforce/label/c.RH_RP_Patient_Auth_should_be_Yes';
import RH_RP_Duplicate_Record_Found from '@salesforce/label/c.RH_RP_Duplicate_Record_Found';
import RH_RP_Delegate_Information_is_mandatory from '@salesforce/label/c.RH_RP_Delegate_Information_is_mandatory';
import RH_RP_Legal_status_warning_message from '@salesforce/label/c.RH_RP_Legal_status_warning_message';
import RH_RP_success_message from '@salesforce/label/c.RH_RP_success_message';
import RH_RP_Record_Saved_Successfully from '@salesforce/label/c.RH_RP_Record_Saved_Successfully';
import RH_RP_Legal_status_Warning_Minor_No from '@salesforce/label/c.RH_RP_Legal_status_Warning_Minor_No';
import RH_RP_Legal_status_Warning_Adult_Yes from '@salesforce/label/c.RH_RP_Legal_status_Warning_Adult_Yes';
import FORM_FACTOR from '@salesforce/client/formFactor';
import icon_chevron_up_white from '@salesforce/resourceUrl/icon_chevron_up_white'

export default class Rp_PatientTab extends LightningElement {
    @track patientrecord;
    @api states = [];
    @api originalpatientrecord = [];
    @api isUnsavedModalOpen = false;
    @api disableButton = false;
    @track stateRequired = true;
    @track validationList = [];
    cancelOpen = false;
    @api disabledsavebutton;
    @api monthDateValue;
    @api yearDateValue;
    @api isMinor = false;
    @api isaccesslevelthree = false;
    issavesuccess = true;

    @api
    get patientrecordlist() {
        return this.patientrecord;
    }
    set patientrecordlist(value) {
        this.patientrecord = JSON.parse(JSON.stringify(value));
        if (this.isaccesslevelthree) {
            disabledsavebutton = true;
        }
    }

    topIcon = icon_chevron_up_white;

    label = {
        PG_Ref_L_Information_Sharing,
        PG_Ref_L_Permit_IQVIA_Confirmation,
        PG_Ref_L_Permit_IQVIA_To_ShareInformation,
        PG_Ref_L_Permit_IQVIA_To_Contact_Email,
        PG_Ref_L_Permit_IQVIA_To_Contact_Phone,
        PG_Ref_L_Permit_IQVIA_To_Contact_SMS,
        RH_Email_Validation_Pattern,
        RH_Email_Invalid_Characters,
        RH_RP_Main_Info,
        RH_RP_Patient_ID,
        RH_RP_Email_ID,
        RH_RP_First_Name,
        RH_RP_Middle_Initial,
        RH_RP_Birth_Month,
        RH_RP_Birth_Year,
        RH_RP_Last_Name,
        RH_RP_Sex,
        RH_RP_Address,
        RH_RP_Country,
        RH_RP_Phone_Number,
        RH_RP_Phone_Type,
        RH_RP_State,
        RH_RP_Alt_Phone_Number,
        RH_RP_Alt_Phone_Type,
        RH_RP_Postal_Code,
        RH_RP_site_info,
        RH_RP_Site_Name,
        RH_RP_Patient_Auth_Status,
        RH_RP_Legal_Status,
        RH_RP_Patient_Authorization,
        RH_RP_Save_Data,
        RH_RP_Save_Changes,
        RH_RP_Cancel_Record,
        RH_RP_discard_changes,
        Save,
        BTN_Close,
        Cancel,
        Proceed,
        BTN_OK,
        RH_RP_Select_Birth_Month,
        RH_RP_Select_Birth_Year,
        RH_RP_Select_Sex,
        RH_RP_Select_Country,
        RH_RP_Select_Phone_Type,
        RH_RP_Select_State,
        RH_RP_Select_Site_Name,
        RH_RP_Patient_Auth_Status_Verified,
        RH_RP_Legal_Status_Verified,
        RH_RP_Invalid_Email,
        RH_RP_is_missing,
        RH_RP_Future_Month,
        RH_RP_Patient_Auth_should_be_Yes,
        RH_RP_Duplicate_Record_Found,
        RH_RP_Delegate_Information_is_mandatory,
        RH_RP_Legal_status_warning_message,
        RH_RP_success_message,
        RH_RP_Record_Saved_Successfully,
        RH_RP_Legal_status_Warning_Adult_Yes,
        RH_RP_Legal_status_Warning_Minor_No

    };

    requiredFieldForAdult = ['PatientID', 'EmailID', 'FirstName', 'BirthYear', 'LastName', 'Country', 'PatientAuthStatus', 'LegalStatus'];
    requiredfieldforMinor = ['PatientID', 'EmailID', 'FirstName', 'BirthYear', 'LastName', 'Country', 'PatientAuthStatus', 'LegalStatus'];

    goTop() {
        window.scrollTo({
            top: 100,
            behavior: 'smooth'
        });
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
                element.setCustomValidity(this.label.RH_RP_Invalid_Email);
                returnValue = false;
            }
        }
        else {
            email.setCustomValidity(this.label.RH_RP_Invalid_Email);
            returnValue = false;
        }
        element.reportValidity();
        return returnValue;
    }

    customFieldValidation(dataValue) {

        let element = this.template.querySelector('[data-value="' + dataValue + '"]');
        let fieldValue = element.value;
        let fieldLabel = element.label;
        let fieldname = element.name;
        let returnvalue;

        if (!fieldValue && fieldname != 'Email ID') {
            element.setCustomValidity(fieldLabel + ' ' + this.label.RH_RP_is_missing);
            returnvalue = false;
        }
        else if (fieldValue && fieldname == 'Email ID') {
            let isEmailValidated = this.checkValidEmail(element);
            if (isEmailValidated) {
                returnvalue = true;
            }
            else {
                returnvalue = false;
            }
        }
        else if (fieldValue && fieldname == 'Birth Year') {
            let monthValueAvilable = this.template.querySelector('[data-value="BirthMonth"]');
            let monthValue = monthValueAvilable.value;
            let yearValueAvilable = this.template.querySelector('[data-value="BirthYear"]');
            let yearValue = yearValueAvilable.value;
            monthValueAvilable.setCustomValidity('');

            if (monthValue != null && yearValue != null) {
                var currentTime = new Date();
                var year = currentTime.getFullYear();
                var month = currentTime.getMonth() + 1;

                if (parseInt(monthValue) > parseInt(month) && year == yearValue) {
                    monthValueAvilable.setCustomValidity(this.label.RH_RP_Future_Month);
                    monthValueAvilable.reportValidity();
                    returnvalue = false;
                }
            }
        }
        else if (fieldValue && fieldname == 'Birth Month') {
            let monthValueAvilable = this.template.querySelector('[data-value="BirthMonth"]');
            let monthValue = monthValueAvilable.value;
            let yearValueAvilable = this.template.querySelector('[data-value="BirthYear"]');
            let yearValue = yearValueAvilable.value;
            monthValueAvilable.setCustomValidity('');
            if (monthValue != null && yearValue != null) {
                var currentTime = new Date();
                var year = currentTime.getFullYear();
                var month = currentTime.getMonth() + 1;

                if (parseInt(monthValue) > parseInt(month) && year == yearValue) {
                    monthValueAvilable.setCustomValidity(this.label.RH_RP_Future_Month);
                    monthValueAvilable.reportValidity();
                    element.value = '';
                    returnvalue = false;
                }
            }
        }
        else {
            element.setCustomValidity('');
            returnvalue = true;
        }
        element.reportValidity();
        return returnvalue;
    }
    removeCustomFieldValidation(dataValue) {
        let element = this.template.querySelector('[data-value="' + dataValue + '"]');
        element.setCustomValidity(" ");
        element.reportValidity();
    }

    get disableField() {
        if (this.isaccesslevelthree) {
            return true;
        } else if (this.patientrecord[0].isMinor) {
            return true;
        } else {
            return false;
        }
    }

    changeInputValue(event) {
        let isAllFieldValidated = false;
        this.disabledsavebutton = true;

        let isRequired = this.patientrecord[0].isRequired;
        let dataValue = event.target.dataset.value;
        this.disabledsavebutton = true;
        this.validationList = [];

        if (isRequired && this.requiredFieldForAdult.includes(dataValue)) {
            isAllFieldValidated = this.customFieldValidation(dataValue);
            this.validationList.push(isAllFieldValidated);
        }
        else if (this.requiredfieldforMinor.includes(dataValue)) {
            isAllFieldValidated = this.customFieldValidation(dataValue);
            this.validationList.push(isAllFieldValidated);
        }

        let record = this.patientrecord.find(ele => ele.peRecord.Id === event.target.dataset.id);
        if (event.target.dataset.value === 'PatientID') {
            record.peRecord.Patient_ID__c = event.target.value;
        }
        else if (event.target.dataset.value === 'EmailID') {
            record.peRecord.Email__c = event.target.value;
        }
        else if (event.target.dataset.value === 'FirstName') {
            record.peRecord.Participant_Name__c = event.target.value;
        }
        else if (event.target.dataset.value === 'MI') {
            record.peRecord.Patient_Middle_Name_Initial__c = event.target.value;
        }
        else if (event.target.dataset.value === 'BirthMonth') {
            record.peRecord.Birth_Month__c = event.target.value;
        }
        else if (event.target.dataset.value === 'BirthYear') {
            record.peRecord.YOB__c = event.target.value;
            if (record.peRecord.YOB__c) {
                this.checkPatientAge();
            }
        }
        else if (event.target.dataset.value === 'LastName') {
            record.peRecord.Participant_Surname__c = event.target.value;
        }
        else if (event.target.dataset.value === 'Sex') {
            record.peRecord.Patient_Sex__c = event.target.value;
        }
        else if (event.target.dataset.value === 'Country') {
            this.issavesuccess = false;
            record.peRecord.Mailing_Country_Code__c = event.target.value;
            this.states = this.patientrecord[0].statesByCountryMap[record.peRecord.Mailing_Country_Code__c];
            if (this.states.length > 0) {
                this.stateRequired = true;
            }
            else {
                this.stateRequired = false;
                record.peRecord.Mailing_State_Code__c = '';
            }
            this.issavesuccess = true;
        }
        else if (event.target.dataset.value === 'States') {
            record.peRecord.Mailing_State_Code__c = event.target.value;
        }
        else if (event.target.dataset.value === 'PhoneNumber') {
            record.peRecord.Phone__c = event.target.value;
        }
        else if (event.target.dataset.value === 'PhoneType') {
            record.peRecord.Patient_Phone_Type__c = event.target.value;
        }
        else if (event.target.dataset.value === 'AltPhoneNumber') {
            record.peRecord.Participant_Alternative_Phone__c = event.target.value;
        }
        else if (event.target.dataset.value === 'AltPhoneType') {
            record.peRecord.Participant_Alt_Phone_Type__c = event.target.value;
        }
        else if (event.target.dataset.value === 'PostalCode') {
            record.peRecord.Postal_Code__c = event.target.value;
        }
        else if (event.target.dataset.value === 'SiteName') {
            record.peRecord.Study_Site__c = event.target.value;
            record.peRecord.RP_Site_Selected__c = event.target.value;
            record.backendSelectedSite = event.target.value;
        }
        else if (event.target.dataset.value === 'PatientAuthStatus') {
            record.peRecord.Patient_Auth__c = event.target.value;
        }
        else if (event.target.dataset.value === 'LegalStatus') {
            // if (this.patientrecord[0].isRequired) {
            //     event.target.value = 'Yes'
            //     record.peRecord.Legal_Status__c = event.target.value;
            // }
            // else {
            //     event.target.value = 'No'
            //     record.peRecord.Legal_Status__c = event.target.value;
            // }
            record.peRecord.Legal_Status__c = event.target.value;
            //this.checkPatientAge();
        }
        else if (event.target.dataset.value === 'IsEmail') {
            record.peRecord.Is_Email__c = event.target.checked;
        }
        else if (event.target.dataset.value === 'IsPhone') {
            record.peRecord.Is_Phone__c = event.target.checked;
        }
        else if (event.target.dataset.value === 'IsSMS') {
            record.peRecord.Is_SMS__c = event.target.checked;
        }
        this.patientrecord = [...this.patientrecord];

        if (this.patientrecord[0].peRecord.Patient_ID__c != undefined && this.patientrecord[0].peRecord.Participant_Name__c != undefined
            && this.patientrecord[0].peRecord.YOB__c != undefined && this.patientrecord[0].peRecord.Patient_Auth__c != undefined
            && this.patientrecord[0].peRecord.Participant_Surname__c != undefined
            && this.patientrecord[0].peRecord.Participant_Surname__c != ''
            && this.patientrecord[0].peRecord.Participant_Surname__c != null
            && this.patientrecord[0].peRecord.Participant_Name__c != null
            && this.patientrecord[0].peRecord.Participant_Name__c != ''
            && this.patientrecord[0].peRecord.Patient_ID__c != ''
            && this.patientrecord[0].peRecord.Patient_ID__c != null
            && this.patientrecord[0].peRecord.Legal_Status__c != null 
            && (this.patientrecord[0].peRecord.Mailing_Country_Code__c == 'US' ? 
                (this.patientrecord[0].peRecord.Permit_Mail_Email_contact_for_this_study__c &&
                this.patientrecord[0].peRecord.Permit_SMS_Text_for_this_study__c  &&
                this.patientrecord[0].peRecord.Permit_Voice_Text_contact_for_this_study__c) :
                (this.patientrecord[0].peRecord.Permit_Mail_Email_contact_for_this_study__c &&
                this.patientrecord[0].peRecord.Permit_Voice_Text_contact_for_this_study__c)
            )
        ) {
            this.disabledsavebutton = false;
        }
        else {
            this.disabledsavebutton = true;
        }
    }

    cancelRecord(event) {
        this.disabledsavebutton = true;
        this.cancelOpen = false;
        let record = this.patientrecord.find(ele => ele.peRecord.Id === this.originalpatientrecord[0].peRecord.Id);
        record.peRecord.Patient_ID__c = this.originalpatientrecord[0].peRecord.Patient_ID__c;
        record.peRecord.Email__c = this.originalpatientrecord[0].peRecord.Email__c;
        record.peRecord.Participant_Name__c = this.originalpatientrecord[0].peRecord.Participant_Name__c;
        record.peRecord.Patient_Middle_Name_Initial__c = this.originalpatientrecord[0].peRecord.Patient_Middle_Name_Initial__c;
        record.peRecord.Birth_Month__c = this.originalpatientrecord[0].peRecord.Birth_Month__c;
        record.peRecord.YOB__c = this.originalpatientrecord[0].peRecord.YOB__c;
        record.peRecord.Participant_Surname__c = this.originalpatientrecord[0].peRecord.Participant_Surname__c;
        record.peRecord.Patient_Sex__c = this.originalpatientrecord[0].peRecord.Patient_Sex__c;
        record.peRecord.Mailing_Country_Code__c = this.originalpatientrecord[0].peRecord.Mailing_Country_Code__c;
        record.peRecord.Mailing_State_Code__c = this.originalpatientrecord[0].peRecord.Mailing_State_Code__c;
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
        this.checkPatientAge();
/*
        this.requiredfieldforMinor.forEach(item => {
            this.removeCustomFieldValidation(item);
        });

        this.requiredFieldForAdult.forEach(item => {
            this.removeCustomFieldValidation(item);
        });
*/        
    }

    closeUnsavedModal(event) {
        this.isUnsavedModalOpen = false;
        this.disableButton = false;
    }

    checkPatientAge() {
        let countryCode = this.patientrecord[0].peRecord.Mailing_Country_Code__c;
        let stateCode = this.patientrecord[0].peRecord.Mailing_State_Code__c;
        let year = this.patientrecord[0].peRecord.YOB__c;
        let month = this.patientrecord[0].peRecord.Birth_Month__c;

        checkPatientAge({ countryCode: countryCode, stateCode: stateCode, month: month, year: year })
            .then((result) => {
                if (result == 'true') {
                    this.patientrecord[0].isRequired = false;
                    this.patientrecord[0].isMinor = true;
                    this.isMinor = true;
                    this.patientrecord[0].peRecord.Legal_Status__c = 'No'; 
                    this.patientrecord[0].peRecord.Email__c = '';
                    this.patientrecord[0].peRecord.Phone__c = '';
                    this.patientrecord[0].peRecord.Patient_Phone_Type__c = '';
                    this.patientrecord[0].peRecord.Participant_Alternative_Phone__c = '';
                    this.patientrecord[0].peRecord.Participant_Alt_Phone_Type__c = '';
                    this.removeCustomFieldValidation('EmailID');
                    this.removeCustomFieldValidation('PhoneNumber');
                    //this.removeCustomFieldValidation('PhoneType');
                }
                else {
                    this.patientrecord[0].isRequired = true;  
                    this.patientrecord[0].isMinor = false;
                    this.isMinor = false;
                    this.patientrecord[0].peRecord.Legal_Status__c = 'Yes'; 
                }
            })
            .catch((error) => {
                this.showErrorToast(JSON.stringify(error.body.message));
            })
    }

    openUnsavedModal(event) {
        let isAllFieldValidated = false;
        this.validationList = [];
        let checkCondition = [];

        /*if (this.patientrecord[0].isRequired) {
            this.requiredfieldforMinor.forEach(item => {
                this.removeCustomFieldValidation(item);
            });
        }
        else {
            this.requiredFieldForAdult.forEach(item => {
                this.removeCustomFieldValidation(item);
            });
        }*/
        checkCondition = this.patientrecord[0].isRequired ? this.requiredFieldForAdult : this.requiredfieldforMinor;

        for (let i = 0; i < checkCondition.length; i++) {
            isAllFieldValidated = this.customFieldValidation(checkCondition[i]);
            this.validationList.push(isAllFieldValidated);
        }

        if (!this.validationList.includes(false)) {
            let newPatientId = this.patientrecord[0].peRecord.Patient_ID__c;
            let oldPatientId = this.originalpatientrecord[0].peRecord.Patient_ID__c;
            let countryCode = this.patientrecord[0].peRecord.Mailing_Country_Code__c;
            let stateCode = this.patientrecord[0].peRecord.Mailing_State_Code__c;
            let month = this.patientrecord[0].peRecord.Birth_Month__c;
            let year = this.patientrecord[0].peRecord.YOB__c;
            let legalStatus = this.patientrecord[0].peRecord.Legal_Status__c;
            if (this.patientrecord[0].peRecord.Patient_Auth__c == 'No') {
                this.showErrorToast(this.label.RH_RP_Patient_Auth_should_be_Yes);
            }
            else {
                patientValidation({
                    newPatientId: newPatientId, oldPatientId: oldPatientId,
                    countryCode: countryCode, stateCode: stateCode,
                    month: month, year: year, legalStatus: legalStatus
                })
                    .then((result) => {
                        if (result == 'DuplicatePatientId') {
                            this.showErrorToast(this.label.RH_RP_Duplicate_Record_Found + ' ' + JSON.stringify(this.patientrecord[0].peRecord.Patient_ID__c));
                        }else if(result == 'Minor' && legalStatus == 'Yes'){
                            this.showErrorToast(this.label.RH_RP_Legal_status_Warning_Minor_No);
                        }
                        else if(result != 'Minor' && result != 'Validation Passed' && legalStatus == 'No'){
                            this.showErrorToast(this.label.RH_RP_Legal_status_Warning_Adult_Yes);
                        }
                        else if (result == 'Minor') {
                            this.showErrorToast(this.label.RH_RP_Delegate_Information_is_mandatory);
                        }
                        else if (result == 'LegalStatus') {
                            this.showErrorToast(this.label.RH_RP_Legal_status_warning_message);
                        }
                        else {
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
    }

    proceedDetailsModal(event) {
        this.disableButton = true;
        this.issavesuccess = false;
        updatePeRecords({ peRecord: this.patientrecord[0].peRecord })
            .then((result) => {
                this.showSuccessToastSave(this.patientrecord[0].peRecord.Participant_Name__c + ' ' + this.label.RH_RP_success_message);
                this.issavesuccess = true;
                const selectedvalue = { patientRecord: this.patientrecord };
                const selectedEvent = new CustomEvent('refreshpatienttabchange', { detail: selectedvalue });
                this.dispatchEvent(selectedEvent);
            })
            .catch((error) => {
                this.issavesuccess = true;
                this.showErrorToast(JSON.stringify(error.body.message));
            })
            .finally(() => {
                this.issavesuccess = true;
                this.isUnsavedModalOpen = false;
                this.disabledsavebutton = true;
            })
    }

    showSuccessToast(event) {
        const evt = new ShowToastEvent({
            title: this.label.RH_RP_Record_Saved_Successfully,
            message: this.label.RH_RP_Record_Saved_Successfully,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showSuccessToastSave(MessageRec) {
        const evt = new ShowToastEvent({
            title: MessageRec,
            message: MessageRec,
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
    cancelModelOpen() {
        this.cancelOpen = true;
    }
    closeCancelModal() {
        this.cancelOpen = false;
    }
    handleConsentUpdate(event){
        
        if(event.detail.consentMap.cType == 'outreach'){
            this.patientrecord[0].peRecord.Participant_Opt_In_Status_Emails__c = event.detail.consentMap.contact.Participant_Opt_In_Status_Emails__c;
            this.patientrecord[0].peRecord.Participant_Opt_In_Status_SMS__c = event.detail.consentMap.contact.Participant_Opt_In_Status_SMS__c;
            this.patientrecord[0].peRecord.Participant_Phone_Opt_In_Permit_Phone__c = event.detail.consentMap.contact.Participant_Phone_Opt_In_Permit_Phone__c;
            this.patientrecord[0].peRecord.IQVIA_Direct_Mail_Consent__c = event.detail.consentMap.contact.IQVIA_Direct_Mail_Consent__c;
        }
        if(event.detail.consentMap.cType == 'study'){
            this.patientrecord[0].peRecord.Permit_Mail_Email_contact_for_this_study__c = event.detail.consentMap.pe.Permit_Mail_Email_contact_for_this_study__c;
            this.patientrecord[0].peRecord.Permit_SMS_Text_for_this_study__c = event.detail.consentMap.pe.Permit_SMS_Text_for_this_study__c;
            this.patientrecord[0].peRecord.Permit_Voice_Text_contact_for_this_study__c = event.detail.consentMap.pe.Permit_Voice_Text_contact_for_this_study__c;
        }
        if (this.patientrecord[0].peRecord.Patient_ID__c != undefined && this.patientrecord[0].peRecord.Participant_Name__c != undefined
            && this.patientrecord[0].peRecord.YOB__c != undefined && this.patientrecord[0].peRecord.Patient_Auth__c != undefined
            && this.patientrecord[0].peRecord.Participant_Surname__c != undefined
            && this.patientrecord[0].peRecord.Participant_Surname__c != ''
            && this.patientrecord[0].peRecord.Participant_Surname__c != null
            && this.patientrecord[0].peRecord.Participant_Name__c != null
            && this.patientrecord[0].peRecord.Participant_Name__c != ''
            && this.patientrecord[0].peRecord.Patient_ID__c != ''
            && this.patientrecord[0].peRecord.Patient_ID__c != null
            && this.patientrecord[0].peRecord.Legal_Status__c != null 
            && (this.patientrecord[0].peRecord.Mailing_Country_Code__c == 'US' ? 
            (this.patientrecord[0].peRecord.Permit_Mail_Email_contact_for_this_study__c &&
            this.patientrecord[0].peRecord.Permit_SMS_Text_for_this_study__c  &&
            this.patientrecord[0].peRecord.Permit_Voice_Text_contact_for_this_study__c) :
            (this.patientrecord[0].peRecord.Permit_Mail_Email_contact_for_this_study__c &&
            this.patientrecord[0].peRecord.Permit_Voice_Text_contact_for_this_study__c)
            )
        ) {
            this.disabledsavebutton = false;
        }
        else {
            this.disabledsavebutton = true;
        }
       
    }
    participantcountry(){
        return (this.pe.peRecord.Mailing_Country_Code__c == '' ? 'UK' : pe.peRecord.Mailing_Country_Code__c);
    }
}