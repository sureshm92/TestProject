import { LightningElement, api, track, wire } from 'lwc';
import PG_Ref_L_Information_Sharing from '@salesforce/label/c.PG_Ref_L_Information_Sharing';
import PG_Ref_L_Permit_IQVIA_To_Contact_ESP from '@salesforce/label/c.PG_Ref_L_Permit_IQVIA_To_Contact_ESP';
import PG_Ref_L_Permit_IQVIA_To_Contact_SMS_Non_US from '@salesforce/label/c.PG_Ref_L_Permit_IQVIA_To_Contact_SMS_Non_US';
import PG_Ref_L_Permit_IQVIA_Outreach_Consent_US from '@salesforce/label/c.PG_Ref_L_Permit_IQVIA_Outreach_Consent_US';
import PG_Ref_L_Permit_IQVIA_Outreach_Consent_ROW from '@salesforce/label/c.PG_Ref_L_Permit_IQVIA_Outreach_Consent_ROW';
import PG_Ref_L_Permit_IQVIA_To_Store_And_Contact from '@salesforce/label/c.PG_Ref_L_Permit_IQVIA_To_Store_And_Contact';
import REQUIRED_ERROR_MSG from '@salesforce/label/c.PP_RequiredErrorMessage';
import EMAIL from '@salesforce/label/c.Email';
import PHONE from '@salesforce/label/c.Phone';
import SMS_TEXT from '@salesforce/label/c.SMS_Text';

import fetchStudySite from '@salesforce/apex/ConsentManagerController.fetchStudySite'; 

const consentModel = {};
consentModel.studyConsent = false;
consentModel.studySMSConsent = false;
consentModel.outReachConsent = false;
consentModel.outreachPhoneConsent = false;
consentModel.outreachEmailConsent = false;
consentModel.outreachSMSConsent = false;
consentModel.showError = false;

const contactConsent = {};
contactConsent.Participant_Opt_In_Status_Emails__c = false;
contactConsent.Participant_Opt_In_Status_SMS__c = false;
contactConsent.Participant_Phone_Opt_In_Permit_Phone__c = false;

const participantEnroll = {};
participantEnroll.Participant_Phone_Opt_In_Permit_Phone__c = false;
participantEnroll.Participant_Opt_In_Status_Emails__c = false;
participantEnroll.Participant_Opt_In_Status_SMS__c = false;

export default class ConsentManager extends LightningElement {
    PG_Ref_L_Information_Sharing=PG_Ref_L_Information_Sharing;
    PG_Ref_L_Permit_IQVIA_To_Contact_ESP = PG_Ref_L_Permit_IQVIA_To_Contact_ESP;
    PG_Ref_L_Permit_IQVIA_To_Contact_SMS_Non_US = PG_Ref_L_Permit_IQVIA_To_Contact_SMS_Non_US;
    PG_Ref_L_Permit_IQVIA_Outreach_Consent_US = PG_Ref_L_Permit_IQVIA_Outreach_Consent_US;
    PG_Ref_L_Permit_IQVIA_Outreach_Consent_ROW = PG_Ref_L_Permit_IQVIA_Outreach_Consent_ROW;
    PG_Ref_L_Permit_IQVIA_To_Store_And_Contact= PG_Ref_L_Permit_IQVIA_To_Store_And_Contact;
    REQUIRED_ERROR_MSG  = REQUIRED_ERROR_MSG;
    EMAIL = EMAIL;
    PHONE = PHONE;
    SMS_TEXT = SMS_TEXT;
    CONSENT_TO_STORE_AND_CONTACT;

    @api participantEnrollId;
    @track consentModel = consentModel;
    participantContact = contactConsent;
    pe = participantEnroll;
    isCountryUS;
    isIqviaOutreachEnabled=false;
    _studySiteId;
    _callSource;
    studySite;
    consentMapping = new Map([['pe',null],['contact',null],['cType',null]]);

    constructor(){
        super();
        this.clearConsents();
    }
    @api
    get callSource() {
        return this._callSource;
    }
    set callSource(value) {    
        this._callSource = value; 
        switch(value){
            case 'addParticipant':
                this.CONSENT_TO_STORE_AND_CONTACT = PG_Ref_L_Permit_IQVIA_To_Store_And_Contact;
            break;
            case 'editParticipant':
                this.CONSENT_TO_STORE_AND_CONTACT = PG_Ref_L_Permit_IQVIA_To_Contact_ESP;
            break;
        }
    }

    @api
    get studySiteId() {
        return this._studySiteId;
    }
    set studySiteId(value) {    
        if( value != null || value != undefined){
            this._studySiteId = value;
            this.getStudySite();
        }
    }
    
    @api
    get participantCountry() {
        return this.isCountryUS;
    }
    set participantCountry(value) {
        this.isCountryUS = (value == "US"? true : false);
        this.updateStudyConsentChecks();
        this.updateOutreachConsentChecks();
    }

    @api
    get participantEnrollment() {
        return this.pe;
    }
    set participantEnrollment(value) {
        if( value != null || value != undefined){
            let participantData = JSON.stringify(value);
            this.pe = JSON.parse(participantData);
            this.participantContact = (this.pe.Participant_Contact__r!=undefined?this.pe.Participant_Contact__r :  this.participantContact);
            this.isIqviaOutreachEnabled = this.pe.Clinical_Trial_Profile__r.IQVIA_Outreach__c;
            this.updateStudyConsentChecks();
            this.updateOutreachConsentChecks();
        }
    }

    @api
    validateConsent(){
        let element = this.template.querySelector('[data-id="studyConsent"]');
        this.consentModel.showError = (element.checked ? false : true);
    }

    @api
    reInitialize(){
        this.clearConsents();
        this.template.querySelectorAll('lightning-input').forEach( element => {
            element.checked = false;
        });
    }

    updateStudyConsentChecks(){
        if(this.isCountryUS && this.pe.Permit_Mail_Email_contact_for_this_study__c && this.pe.Permit_Voice_Text_contact_for_this_study__c
            && this.pe.Permit_SMS_Text_for_this_study__c){
            this.consentModel.studyConsent = true;
        }
        else if(!this.isCountryUS && this.pe.Permit_Mail_Email_contact_for_this_study__c && this.pe.Permit_Voice_Text_contact_for_this_study__c){
            this.consentModel.studyConsent = true;
        }
        else{
            this.consentModel.studyConsent = false;
        }
        this.consentModel.studySMSConsent = (!this.isCountryUS && this.pe.Permit_SMS_Text_for_this_study__c ? true : false);
    }

    updateOutreachConsentChecks(){
        if(this.isCountryUS && this.participantContact.Participant_Opt_In_Status_Emails__c && this.participantContact.Participant_Opt_In_Status_SMS__c
            && this.participantContact.Participant_Phone_Opt_In_Permit_Phone__c){
            this.consentModel.outReachConsent = true;
        }
        else{
            this.consentModel.outReachConsent = false;
        }
        if(!this.isCountryUS){
            this.consentModel.outreachEmailConsent = this.participantContact.Participant_Opt_In_Status_Emails__c;
            this.consentModel.outreachSMSConsent = this.participantContact.Participant_Opt_In_Status_SMS__c;
            this.consentModel.outreachPhoneConsent = this.participantContact.Participant_Phone_Opt_In_Permit_Phone__c;
        }
    }

    fireConsentChange(consentType){
        this.consentMapping['cType'] = consentType;
        if(consentType == 'study'){
            this.consentMapping['pe'] = this.pe;
            const consentMap = this.consentMapping;
            const filterChangeEvent = new CustomEvent('consentchange', {
                detail: { consentMap },
            });
            this.dispatchEvent(filterChangeEvent);
        }else{
            this.consentMapping['contact'] = this.participantContact;
            const consentMap = this.consentMapping;
            const filterChangeEvent = new CustomEvent('consentchange', {
                detail: { consentMap },
            });
            this.dispatchEvent(filterChangeEvent);
        }
    }

    handleConsentChange(event){
            let consentType = event.target.name;
            let consent = event.detail.checked;
            
            switch(consentType){
                case 'studyConsent':
                        this.pe.Permit_Mail_Email_contact_for_this_study__c = consent;
                        this.pe.Permit_Voice_Text_contact_for_this_study__c = consent;
                        if(this.isCountryUS){
                            this.pe.Permit_SMS_Text_for_this_study__c = consent;
                        }
                        if(consent)
                            this.consentModel.showError = false;
                        this.fireConsentChange('study');
                        break;
                case 'studySMSConsent':
                        this.pe.Permit_SMS_Text_for_this_study__c = consent;
                        this.fireConsentChange('study');
                        break;
                case 'outReachConsent':
                        this.participantContact.Participant_Phone_Opt_In_Permit_Phone__c 
                        = this.participantContact.Participant_Opt_In_Status_Emails__c 
                        = this.participantContact.Participant_Opt_In_Status_SMS__c 
                        = this.consentModel.outreachEmailConsent 
                        = this.participantContact.Participant_Opt_In_Status_Emails__c
                        = this.consentModel.outreachSMSConsent 
                        = this.participantContact.Participant_Opt_In_Status_SMS__c
                        = this.consentModel.outreachPhoneConsent 
                        = this.participantContact.Participant_Phone_Opt_In_Permit_Phone__c
                        = consent;
                        this.fireConsentChange('outreach');
                        break;
                case 'outreachPhoneConsent':
                        this.participantContact.Participant_Phone_Opt_In_Permit_Phone__c = consent;
                        this.consentModel.outreachPhoneConsent = this.participantContact.Participant_Phone_Opt_In_Permit_Phone__c;
                        
                        this.fireConsentChange('outreach');
                        break;
                case 'outreachEmailConsent':
                        this.participantContact.Participant_Opt_In_Status_Emails__c = consent;
                        this.consentModel.outreachEmailConsent = this.participantContact.Participant_Opt_In_Status_Emails__c;
                        
                        this.fireConsentChange('outreach');
                        break;
                case 'outreachSMSConsent':
                        this.participantContact.Participant_Opt_In_Status_SMS__c = consent;
                        this.consentModel.outreachSMSConsent = this.participantContact.Participant_Opt_In_Status_SMS__c;
                        
                        this.fireConsentChange('outreach');
                        break;
            }
    }


    clearConsents(){
        this.consentModel.studyConsent 
        =this.consentModel.studySMSConsent 
        =this.consentModel.outReachConsent 
        =this.consentModel.outreachPhoneConsent 
        =this.consentModel.outreachEmailConsent 
        =this.consentModel.outreachSMSConsent 
        =this.consentModel.showError 
        =this.participantContact.Participant_Phone_Opt_In_Permit_Phone__c 
        =this.participantContact.Participant_Opt_In_Status_Emails__c 
        =this.participantContact.Participant_Opt_In_Status_SMS__c 
        =this.pe.Permit_Mail_Email_contact_for_this_study__c 
        =this.pe.Permit_Voice_Text_contact_for_this_study__c 
        =this.pe.Permit_SMS_Text_for_this_study__c  
        = false;
    }

    getStudySite(){
        fetchStudySite({ studySiteId : this._studySiteId })
        .then((result) => {
            this.studySite = result;
            this.isIqviaOutreachEnabled = this.studySite.Clinical_Trial_Profile__r.IQVIA_Outreach__c;
        })
        .catch((error) => {
            this.error = error;
        });
    }
}