import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import rr_community_icons from '@salesforce/resourceUrl/rr_community_icons';
import LOFI_LOGIN_ICONS from '@salesforce/resourceUrl/Lofi_Login_Icons';
import PP_Communication_Pref_Del_Blank_Page from '@salesforce/label/c.PP_Communication_Pref_Del_Blank_Page';
import PP_Communication_Pref from '@salesforce/label/c.PP_Communication_Pref';
import PP_Communication_Pref_Study from '@salesforce/label/c.PP_Communication_Pref_Study';
import PP_Communication_Pref_Study_consent from '@salesforce/label/c.PP_Communication_Pref_Study_consent';
import PP_Communication_Pref_Phone from '@salesforce/label/c.PP_Communication_Pref_Phone';
import PP_Communication_Pref_Email from '@salesforce/label/c.PP_Communication_Pref_Email';
import PP_Communication_Pref_SMS from '@salesforce/label/c.PP_Communication_Pref_SMS';
import PP_Communication_Pref_Dmail from '@salesforce/label/c.PP_Communication_Pref_Dmail';
import PP_Communication_Pref_All from '@salesforce/label/c.PP_Communication_Pref_All';
import PP_Communication_Pref_Outreach from '@salesforce/label/c.PP_Communication_Pref_Outreach';
import PP_Communication_Pref_Outreach_consentA from '@salesforce/label/c.PP_Communication_Pref_Outreach_consentA';
import PP_Communication_Pref_Outreach_consentB from '@salesforce/label/c.PP_Communication_Pref_Outreach_consentB';
import PP_Communication_Pref_Outreach_consentC from '@salesforce/label/c.PP_Communication_Pref_Outreach_consentC';
import PP_Communication_Pref_Blank_Del from '@salesforce/label/c.PP_Communication_Pref_Blank_Del';
import PP_Communication_Pref_Blank_Del_View_Par from '@salesforce/label/c.PP_Communication_Pref_Blank_Del_View_Par';
import PP_Communication_Pref_savechanges from '@salesforce/label/c.PP_Communication_Pref_savechanges';
import PP_Profile_Update_Success from '@salesforce/label/c.PP_Profile_Update_Success';
import PP_Communication_Pref_Outreach_Gen_Comm from '@salesforce/label/c.PP_Communication_Pref_Outreach_Gen_Comm';
import PP_Communication_Pref_Warning from '@salesforce/label/c.PP_Communication_Pref_Warning';
import PP_Communication_Pref_Mobile_Required from '@salesforce/label/c.PP_Communication_Pref_Mobile_Required';
import PP_Communication_Pref_Mobile_Required_Del from '@salesforce/label/c.PP_Communication_Pref_Mobile_Required_Del';
import PP_Study_Consent_Adult_ROW from '@salesforce/label/c.PP_Study_Consent_Adult_ROW';
import PP_Study_Consent_Adult_US from '@salesforce/label/c.PP_Study_Consent_Adult_US';
import PP_Communication_Purchase_Pref_V2 from '@salesforce/label/c.PP_Communication_Purchase_Pref_V2';
import PP_IQVIA_Communication_US from '@salesforce/label/c.PP_IQVIA_Communication_US';
import PP_Outreach_Communication_Pref_A from '@salesforce/label/c.PP_Outreach_Communication_Pref_A';
import PP_Outreach_Communication_Pref_B from '@salesforce/label/c.PP_Outreach_Communication_Pref_B';
import PP_Outreach_Communication_Pref_C from '@salesforce/label/c.PP_Outreach_Communication_Pref_C';
import PP_Outreach_Communication_Pref_D from '@salesforce/label/c.PP_Outreach_Communication_Pref_D';


import PP_Communication_Par_Mobile_Upd_Success from '@salesforce/label/c.PP_Communication_Par_Mobile_Upd_Success';
import PP_Communication_Del_Mobile_Upd_Success from '@salesforce/label/c.PP_Communication_Del_Mobile_Upd_Success';
import PP_Profile_Information from '@salesforce/label/c.PP_Profile_Information';
import PP_Communication_Study_Static_Message from '@salesforce/label/c.PP_Communication_Study_Static_Message';
import PP_Phone_Mandatory from '@salesforce/label/c.PP_Phone_Mandatory';
import PP_Phone_Numeric from '@salesforce/label/c.PP_Phone_Numeric';
import Mob_Phone_Field from '@salesforce/label/c.Mob_Phone_Field';
import BTN_Save from '@salesforce/label/c.BTN_Save';
import BACK from '@salesforce/label/c.Back';

//END TO DO

import getInitData from '@salesforce/apex/AccountSettingsController.getInitData';
import saveConsent from '@salesforce/apex/PreferenceManagementController.saveConsent';
import updateParticipantMobileNumber from '@salesforce/apex/PreferenceManagementController.updateParticipantMobileNumber';

import getisRTL from '@salesforce/apex/PreferenceManagementController.getIsRTL';

import createCommPrefEvent from '@salesforce/apex/PreferenceManagementController.createCommPrefEvent';

import { loadScript } from 'lightning/platformResourceLoader';
import rrCommunity from '@salesforce/resourceUrl/rr_community_js';

export default class PpCommunicationPreferences extends NavigationMixin(LightningElement) {
    @api isDelegate;
    @api participantState;
    @api isDesktop;
    @api consentPreferenceData;
    @api userMode;
    @api isRTL;

    label = {
        PP_Communication_Pref_Del_Blank_Page,
        PP_Outreach_Communication_Pref_D,
        PP_Outreach_Communication_Pref_C,
        PP_Outreach_Communication_Pref_B,
        PP_Outreach_Communication_Pref_A,
        PP_IQVIA_Communication_US,
        PP_Communication_Purchase_Pref_V2,
        PP_Study_Consent_Adult_US,
        PP_Study_Consent_Adult_ROW,
        PP_Communication_Pref,
        PP_Communication_Pref_Study,
        PP_Communication_Pref_Study_consent,
        PP_Communication_Pref_Phone,
        PP_Communication_Pref_Email,
        PP_Communication_Pref_SMS,
        PP_Communication_Pref_Dmail,
        PP_Communication_Pref_All,
        PP_Communication_Pref_Outreach,
        PP_Communication_Pref_Outreach_consentA,
        PP_Communication_Pref_Outreach_consentB,
        PP_Communication_Pref_Outreach_consentC,
        PP_Communication_Pref_Blank_Del,
        PP_Communication_Pref_Blank_Del_View_Par,
        PP_Communication_Pref_savechanges,
        PP_Profile_Update_Success,
        PP_Communication_Pref_Outreach_Gen_Comm,
        PP_Communication_Pref_Warning,
        PP_Communication_Pref_Mobile_Required,
        PP_Communication_Pref_Mobile_Required_Del,
        PP_Communication_Par_Mobile_Upd_Success,
        PP_Communication_Del_Mobile_Upd_Success,
        PP_Profile_Information,
        PP_Communication_Study_Static_Message,
        PP_Phone_Mandatory,
        PP_Phone_Numeric,
        Mob_Phone_Field,
        BTN_Save,
        BACK
    };

    @track studyDetails = [];
    @track outReachDetails = [];
    @track consentPreferenceDataLocal = [];
    @track contactDataLocal = [];
    currentEvtObj;

    spinner = false;
    loaded = false;
    isPrivacyPolicy = false;
    showIQIVAOutreachConsentFlag = false;
    showStudyConsentFlag = false;
    DisableConsentsForDelInParView = false;
    showStaticMessageForDelSelfViewEmpty =false;
    showPERConsents = false;
    ShowPDEConsents = false;
    isDelegateAlsoAParticipant =false;
    //hideConsentsForDelegateView = false;
    isParticipantLoggedIn = false;
    isPrimaryDelegate = false;
    isDelegateSelfView = false;
    isAdultParticipant = false;
    isEmailAvailabelForParticipant = false;
    currentPERId = '';
    currentPDEId = '';
    updatedPerRecord = {};
    commPrefForPrivacyPolicy = true;
    emailSMSConsent = false;

    studyError = false;
    isMobilePhoneNumberAvailable = true;
    outreachError = false;
    currentParticipantId;
    currentContactId;
    errorLabelText = '';

    participantObject;
    delegateObject;

    errorIconPosition = 'margin-left: 0px';

    isCountryUS = false;

    //@track phoneSvg = rr_community_icons +'/'+'logo.svg';
    phoneSvg = rr_community_icons + '/' + 'com-phone.svg' + '#' + 'com-phone';
    emailSvg = rr_community_icons + '/' + 'com-email.svg' + '#' + 'com-email';
    smsSvg = rr_community_icons + '/' + 'com-sms.svg' + '#' + 'com-sms';
    dmailSvg = rr_community_icons + '/' + 'com-dmail.svg' + '#' + 'com-dmail';
    allSvg = rr_community_icons + '/' + 'com-all.svg' + '#' + 'com-all';

    exclamation = LOFI_LOGIN_ICONS + '/status-exclamation.svg';
    exclamation_orange = rr_community_icons + '/' + 'status-exclamation.svg';

    connectedCallback() {
        // Get Initial Load Data
        this.spinner = true;

        getInitData({ userMode: this.userMode })
            .then((result) => {
                this.spinner = false;
                let data = JSON.parse(result).consentPreferenceData;
                this.consentPreferenceDataLocal = data;
                this.setConsentVisibility();
                if (this.showPERConsents) {
                    this.consentPreferenceDataLocal.perList.forEach(function (study) {
                        study['all'] = false;
                        study['error'] = false;
                    });
                }
                if(this.ShowPDEConsents){
                    this.consentPreferenceDataLocal.pdeList.forEach(function (pde) {
                        pde['all'] = false;
                        pde['error'] = false;
                        pde['parLastNameInitial'] = pde.Patient_Delegate__r.Participant__r.Last_Name__c.slice(0,1);
                    });
                }

                this.isCountryUS = (this.consentPreferenceDataLocal.myContact.MailingCountry!= undefined &&  this.consentPreferenceDataLocal.myContact.MailingCountry == 'United States' ? true : false);
                let conData = JSON.parse(result).myContact;
                this.contactDataLocal.push(conData);
                this.contactDataLocal.forEach(function (con) {
                    con['all'] = false;
                    con['error'] = false;
                });

                this.updateALLFlag();
                this.updateALLOutReachFlag();
                this.updateAllPDEFlag();
                //this.setConsentVisibility();

                if (!this.isMobilePhoneNumberAvailable) {
                    this.studyError = this.checkSMSCheckedOrNot();
                }
                // If delegate is in self view and IQVIA outreach is off and mobile phone is not available for delegate
                if (
                    this.isDelegateSelfView &&
                    !this.showIQIVAOutreachConsentFlag &&
                    !this.isMobilePhoneNumberAvailable
                ) {
                    this.studyError = this.checkSMSCheckedOrNot();
                }
                // If Seconary delegate switch to Participant Account setting, dont show the Error message in any case.
                if (
                    !this.isPrimaryDelegate &&
                    !this.isDelegateSelfView &&
                    !this.isParticipantLoggedIn
                ) {
                    this.studyError = false;
                }
            })
            .catch((error) => {
                this.showCustomToast('', 'Failed To read the Data...', 'error');
                this.spinner = false;
            });

        if (!this.loaded) {
            loadScript(this, rrCommunity).then(() => {
                if (communityService.isMobileSDK()) {
                    this.isDesktop = false;
                }
            });
            getisRTL()
                .then((data) => {
                    this.isRTL = data;
                })
                .catch(function (error) {
                    console.error('Error RTL: ' + JSON.stringify(error));
                });
        }
    }

    openPrivacyPolicy() {
        this.isPrivacyPolicy = true;
        this.commPrefForPrivacyPolicy = true;
    }

    closePrivacyPolicy() {
        this.isPrivacyPolicy = false;
    }

    redirectToProfileInfoTab() {
        window.history.replaceState(null, null, '?profileInformation');
        sessionStorage.setItem('Cookies', 'Accepted');
        window.location.reload(true);
    }

    setConsentVisibility() {
        this.isParticipantLoggedIn = this.consentPreferenceDataLocal.isParticipantLoggedIn;
        this.isPrimaryDelegate = this.consentPreferenceDataLocal.isPrimaryDelegate;
        this.isDelegateSelfView = this.consentPreferenceDataLocal.isDelegateSelfView;
        this.isAdultParticipant = this.consentPreferenceDataLocal.isAdultParticipant;
        this.isEmailAvailabelForParticipant =
            this.consentPreferenceDataLocal.isEmailAvailabelForParticipant;
        this.isMobilePhoneNumberAvailable =
            this.consentPreferenceDataLocal.isMobilePhoneNumberAvailable;
        this.currentParticipantId = this.consentPreferenceDataLocal.currentParticipant.Id;
        this.currentContactId = this.consentPreferenceDataLocal.currentParticipant.Contact__c;
        this.isDelegateAlsoAParticipant= this.consentPreferenceDataLocal.isDelegateAlsoAParticipant;

        //when pure partipant Logs in
        if(this.isParticipantLoggedIn && !this.isDelegateAlsoAParticipant){
            this.showPERConsents=true;
        }
        //When delegate switch to participant View
        else if(!this.isParticipantLoggedIn && !this.isDelegateSelfView){
            this.showPERConsents=true;
        }
        //when delegate is in self View
        else if(this.isDelegateSelfView){
            this.ShowPDEConsents=true;
        }
        //When Participant(also a delegate) Logs in
        else if(this.isParticipantLoggedIn && this.isDelegateAlsoAParticipant){
            this.showPERConsents=true;
            this.ShowPDEConsents=true;
        }


        //Check IQVIA Outreach Consent Visibility
        if (this.showIQVIAOutreachConsent()) {
            this.showIQIVAOutreachConsentFlag = true;
        }
        //Check Study Consent Visibility
        if (this.consentPreferenceDataLocal.perList.length > 0 || this.consentPreferenceDataLocal.pdeList.length > 0) {
            this.showStudyConsentFlag = true;
        }

        /*if (!this.showIQIVAOutreachConsentFlag && !this.showStudyConsentFlag) {
            if (!this.isParticipantLoggedIn && this.isDelegateSelfView) {
                this.hideConsentsForDelegateView = true;
                console.log('Hide for Delegate self View');
            }
        }
        */

         //Check if Delegate is in self View with no Studies associated and Iqvia Outreach Toggle Off
         if (this.isDelegateSelfView && this.consentPreferenceDataLocal.pdeList.length == 0 && !this.consentPreferenceDataLocal.isIQIVAOutrechToggleOnAtCTP) {
            this.showStaticMessageForDelSelfViewEmpty = true;
        }
        //
        if (!this.isParticipantLoggedIn && !this.isDelegateSelfView) {
            this.DisableConsentsForDelInParView = true;
        }

        this.consentPreferenceDataLocal.isSelfAccountSettingWarningMessage
            ? (this.errorLabelText = this.label.PP_Communication_Pref_Mobile_Required)
            : (this.errorLabelText = this.label.PP_Communication_Pref_Mobile_Required_Del);
    }

    resetSpinner() {
        if (
            this.consentPreferenceDataLocal.perList.length == 0 ||
            this.consentPreferenceDataLocal.perList.length == 0
        ) {
            this.spinner = true;
        } else {
            this.spinner = false;
        }
    }

    get cardRTL() {
        return this.isRTL ? 'cardRTL' : '';
    }

    get borderStyle() {
        return this.isRTL ? 'study-paramters border-left' : 'study-paramters border-right';
    }

    get borderStyleMobile() {
        return this.isRTL
            ? 'slds-col slds-size-custom_3-of-10 border-left'
            : 'slds-col slds-size-custom_3-of-10 border-right';
    }

    get phoneErrorBorder() {
        return this.isRTL ? 'po-white-border-right' : 'po-white-border-left';
    }

    get phoneErrorBtnMarin() {
        return this.isRTL ? 'mr-5 saveBtn' : 'ml-5 saveBtn';
    }

    get phoneErrorBtnMarinMobile() {
        return this.isRTL ? 'mr-5 saveBtn h-40' : 'ml-5 saveBtn h-40';
    }

    get phoneErrorHeaderMarPad() {
        return this.isRTL ? 'mb-10 mr-10' : 'mb-10';
    }

    get phoneErrorHeaderMarPadMobile() {
        return this.isRTL ? 'mb-10 mobile-align' : 'mb-10';
    }

    get communicationPrefHeader() {
        return this.isRTL ? 'header mr-10' : 'header';
    }

    get getPad10() {
        return this.isRTL ? 'mr-10' : '';
    }

    get getStudyConsentMargin() {
        return this.isRTL ? 'sub-header mr-10 commsTxt' : 'sub-header commsTxt';
    }

    get iconChevron() {
        return 'icon-chevron-left';
    }

    get getPurchaseProptyTxt() {
        return this.isRTL ? 'sub-header mr-10 commsTxt tx-italic' : 'sub-header commsTxt tx-italic';
    }

    get StudyConsentClass() {
        return this.isRTL ? 'study-content study-content-mobile-rtl' : 'study-content study-content-mobile';
    }

    renderedCallback() {}

    selectAllOptions(event) {
        let objName = event.target.dataset.objname;
        if(objName ==='PER'){
            this.updateStudyData(event.target.label, event.target.checked, event.target.name, event);
        } else if(objName ==='PDE'){
            this.updatePDEData(event.target.label, event.target.checked, event.target.name, event);
        }
    }

    showMenuBar(event) {
        let queryString = window.location.href;
        if (queryString.includes('communication-preferenceswithprevtask')) {
            window.close();
        }
        if (event.target.dataset.header) {
            this.dispatchEvent(
                new CustomEvent('shownavmenubar', {
                    detail: {
                        header: event.target.dataset.header
                    }
                })
            );
            this.isInitialized = false;
        }
    }

    selectIndividualOptions(event) {
        let objName = event.target.dataset.objname;
        if(objName ==='PER'){
            this.updateStudyData(event.target.label, event.target.checked, event.target.name, event);
        } else if(objName ==='PDE'){
            this.updatePDEData(event.target.label, event.target.checked, event.target.name, event);
        }
    }

    updateStudyData(label, value, studyId, eventObj) {
        let processConsentSave = false;
        this.currentPERId = studyId;

        let mobileAvailability = this.isMobilePhoneNumberAvailable;
        let studyError = this.studyError;
        let template = this.template;

        let checkOtherSMSOptInsAvailable = false;
        let isEmailSMSConsentChecked = false;

        if (label == 'All') {
            this.consentPreferenceDataLocal.perList.forEach(function (study) {
                if (study.Id == studyId) {
                    let processSave = true;
                    // If mobile number is not available - prevent save consents
                    if (!mobileAvailability) {
                        processSave = false;
                        studyError = true;
                    }

                    // save consents if all is false and study error is true: opt out for sms and other channels should happen
                    if (value == false && studyError == true && !study['error']) {
                        processSave = true;
                    }

                    // First time error has occured: push error attribute the loacal study object
                    // prevent save consents if all is true and study error is true: opt out for sms and other channels should not happen
                    if (value == true && studyError == true) {
                        processSave = false;
                        study['error'] = true;
                    }

                    if (!processSave) {
                        window.scrollTo({ top: 0, behavior: 'smooth' });
                    }

                    if (processSave) {
                        study.Permit_Voice_Text_contact_for_this_study__c =
                            study.Permit_Mail_Email_contact_for_this_study__c =
                            study.Study_Direct_Mail_Consent__c =
                            study.Permit_SMS_Text_for_this_study__c =
                                value;
                        processConsentSave = true;
                        isEmailSMSConsentChecked = true;
                        //studyError = false;
                        // Update checkOtherSMSOptInsAvailable flag to check if SMS channel is checked for other studies/IQVIA outreach
                        study.Permit_SMS_Text_for_this_study__c == false
                            ? (checkOtherSMSOptInsAvailable = true)
                            : (checkOtherSMSOptInsAvailable = false);
                        study['error'] = false;
                    } else {
                        if (value) {
                            studyError = true;
                            // Highlight error on "All" Checkbox
                            value ? eventObj.target.classList.add('highlightErrorCheckbox') : '';
                            // To highlight SMS with error when All checkbox is errred
                            let inputFields = template.querySelectorAll('.smsElements');
                            inputFields.forEach((ele) => {
                                let perId = ele.getAttribute('data-id');
                                let label = ele.getAttribute('data-label');
                                if (perId == studyId && label == 'SMS_STUDY') {
                                    ele.classList.add('highlightErrorCheckbox');
                                }
                            });
                            window.scrollTo({ top: 0, behavior: 'smooth' });
                        }
                    }
                }
            });
        } else {
            this.consentPreferenceDataLocal.perList.forEach(function (study) {
                // If not clicked on All - Individual operation

                switch (label) {
                    case 'Phone':
                        study.Id == studyId
                            ? (study.Permit_Voice_Text_contact_for_this_study__c = value)
                            : '';
                        processConsentSave = true;
                        break;
                    case 'Email':
                        study.Id == studyId
                            ? (study.Permit_Mail_Email_contact_for_this_study__c = value)
                            : '';
                        processConsentSave = true;
                        isEmailSMSConsentChecked = true;
                        break;
                    case 'SMS':
                        if (study.Id == studyId) {
                            let processSave = true;
                            // If mobile number is not available - prevent save consents
                            if (!mobileAvailability) {
                                processSave = false;
                                studyError = true;
                            }

                            // save consents if all is false and study error is true: opt out for sms and other channels should happen
                            if (value == false && studyError == true && !study['error']) {
                                processSave = true;
                            }

                            // First time error has occured: push error attribute the loacal study object
                            // prevent save consents if all is true and study error is true: opt out for sms and other channels should not happen
                            if (value == true && studyError == true) {
                                processSave = false;
                                study['error'] = true;
                            }

                            if (!processSave) {
                                window.scrollTo({ top: 0, behavior: 'smooth' });
                            }

                            if (processSave) {
                                study.Permit_SMS_Text_for_this_study__c = value;
                                processConsentSave = true;
                                isEmailSMSConsentChecked = true;
                                //studyError = false;
                                // Update checkOtherSMSOptInsAvailable flag to check if SMS channel is checked for other studies/IQVIA outreach
                                study.Permit_SMS_Text_for_this_study__c == false
                                    ? (checkOtherSMSOptInsAvailable = true)
                                    : (checkOtherSMSOptInsAvailable = false);
                                study['error'] = false;
                            } else {
                                if (value) {
                                    studyError = true;

                                    value
                                        ? eventObj.target.classList.add('highlightErrorCheckbox')
                                        : '';
                                    window.scrollTo({ top: 0, behavior: 'smooth' });
                                }
                            }
                        }
                        break;
                    case 'DMail':
                        study.Id == studyId ? (study.Study_Direct_Mail_Consent__c = value) : '';
                        processConsentSave = true;
                        break;
                }
            });
        }
        this.studyError = studyError;
        if (checkOtherSMSOptInsAvailable) {
            this.studyError = this.checkSMSCheckedOrNot();
        }
        if (processConsentSave) {
            this.emailSMSConsent = isEmailSMSConsentChecked;
            this.updateALLFlag();
            this.doSaveCommunicationPref('PER');
        }
    }
    //Update Patient delegate Enrollment record.
    updatePDEData(label, value, pdeId,eventObj) {
        let processConsentSave = false;
        this.currentPDEId = pdeId;

        let mobileAvailability = this.isMobilePhoneNumberAvailable;
        let studyError = this.studyError;
        let template = this.template;

        let checkOtherSMSOptInsAvailable = false;

        if (label == 'All') {
            this.consentPreferenceDataLocal.pdeList.forEach(function (pde) {
                if (pde.Id == pdeId) {
                    let processSave = true;
                    // If mobile number is not available - prevent save consents
                    if (!mobileAvailability) {
                        processSave = false;
                        studyError = true;
                    }

                    // save consents if all is false and study error is true: opt out for sms and other channels should happen
                    if (value == false && studyError == true && !pde['error']) {
                        processSave = true;
                    }

                    // First time error has occured: push error attribute the loacal study object
                    // prevent save consents if all is true and study error is true: opt out for sms and other channels should not happen
                    if (value == true && studyError == true) {
                        processSave = false;
                        pde['error'] = true;
                    }

                    if (!processSave) {
                        window.scrollTo({ top: 0, behavior: 'smooth' });
                    }

                    if (processSave) {
                        pde.Study_Phone_Consent__c =
                        pde.Study_Email_Consent__c =
                        pde.Study_SMS_Consent__c =
                        pde.Study_Direct_Mail_Consent__c =
                                value;
                        processConsentSave = true;
                        //studyError = false;
                        // Update checkOtherSMSOptInsAvailable flag to check if SMS channel is checked for other studies/IQVIA outreach
                        pde.Study_SMS_Consent__c == false
                            ? (checkOtherSMSOptInsAvailable = true)
                            : (checkOtherSMSOptInsAvailable = false);
                        pde['error'] = false;
                    } else {
                        if (value) {
                            studyError = true;
                            // Highlight error on "All" Checkbox
                            value ? eventObj.target.classList.add('highlightErrorCheckbox') : '';
                            // To highlight SMS with error when All checkbox is errred
                            let inputFields = template.querySelectorAll('.smsElements');
                            inputFields.forEach((ele) => {
                                let pdeRecordId = ele.getAttribute('data-id');
                                let label = ele.getAttribute('data-label');
                                if (pdeRecordId == pdeId && label == 'SMS_STUDY') {
                                    ele.classList.add('highlightErrorCheckbox');
                                }
                            });
                            window.scrollTo({ top: 0, behavior: 'smooth' });
                        }
                    }
                }
            });
        } else {
            this.consentPreferenceDataLocal.pdeList.forEach(function (pde) {
                // If not clicked on All - Individual operation

                switch (label) {
                    case 'Phone':
                        pde.Id == pdeId
                            ? (pde.Study_Phone_Consent__c = value)
                            : '';
                        processConsentSave = true;
                        break;
                    case 'Email':
                        pde.Id == pdeId
                            ? (pde.Study_Email_Consent__c = value)
                            : '';
                        processConsentSave = true;
                        break;
                    case 'SMS':
                        if (pde.Id == pdeId) {
                            let processSave = true;
                            // If mobile number is not available - prevent save consents
                            if (!mobileAvailability) {
                                processSave = false;
                                studyError = true;
                            }

                            // save consents if all is false and study error is true: opt out for sms and other channels should happen
                            if (value == false && studyError == true && !pde['error']) {
                                processSave = true;
                            }

                            // First time error has occured: push error attribute the loacal study object
                            // prevent save consents if all is true and study error is true: opt out for sms and other channels should not happen
                            if (value == true && studyError == true) {
                                processSave = false;
                                pde['error'] = true;
                            }

                            if (!processSave) {
                                window.scrollTo({ top: 0, behavior: 'smooth' });
                            }

                            if (processSave) {
                                pde.Study_SMS_Consent__c = value;
                                processConsentSave = true;
                                //studyError = false;
                                // Update checkOtherSMSOptInsAvailable flag to check if SMS channel is checked for other studies/IQVIA outreach
                                pde.Study_SMS_Consent__c == false
                                    ? (checkOtherSMSOptInsAvailable = true)
                                    : (checkOtherSMSOptInsAvailable = false);
                                pde['error'] = false;
                            } else {
                                if (value) {
                                    studyError = true;

                                    value
                                        ? eventObj.target.classList.add('highlightErrorCheckbox')
                                        : '';
                                    window.scrollTo({ top: 0, behavior: 'smooth' });
                                }
                            }
                        }
                        break;
                    case 'DMail':
                        pde.Id == pdeId ? (pde.Study_Direct_Mail_Consent__c = value) : '';
                        processConsentSave = true;
                        break;
                }
            });
        }
        this.studyError = studyError;
        if (checkOtherSMSOptInsAvailable) {
            this.studyError = this.checkSMSCheckedOrNot();
        }
        if (processConsentSave) {
            this.updateAllPDEFlag();
            this.doSaveCommunicationPref('PDE');
        }
        
    }

    // Helper Method : To Update ALL flag comparing phone, email, sms and direct email at study as well as sponsor level
    updateALLFlag() {
        this.consentPreferenceDataLocal.perList.forEach(function (study) {
            study.Permit_Voice_Text_contact_for_this_study__c &&
            study.Permit_Mail_Email_contact_for_this_study__c &&
            study.Permit_SMS_Text_for_this_study__c &&
            study.Study_Direct_Mail_Consent__c
                ? (study.all = true)
                : (study.all = false);
        });
    }
    // Helper Method : To Update ALL flag comparing phone, email, sms and direct email at study as well as sponsor level -PDE Records
    updateAllPDEFlag(){
        this.consentPreferenceDataLocal.pdeList.forEach(function (pde){
            pde.Study_Phone_Consent__c &&
            pde.Study_Email_Consent__c &&
            pde.Study_SMS_Consent__c &&
            pde.Study_Direct_Mail_Consent__c 
                 ? (pde.all= true)
                 : (pde.all= false);
        });
    }

    // Save Communication Pref data
    doSaveCommunicationPref(requestFrom) {
        this.spinner = true;
        let perObj = {};
        let pdeObj ={};
        let perId = this.currentPERId;
        let pdeId =this.currentPDEId;
        let studyJSON='';
        if (perId && requestFrom == 'PER') {
            this.consentPreferenceDataLocal.perList.forEach(function (perRecord) {
                if (perRecord.Id == perId) {
                    perObj.perId = perRecord.Id;
                    perObj.ParticipantContId = perRecord.Participant__r.Contact__c;
                    perObj.participantOptInEmail =
                        perRecord.Permit_Mail_Email_contact_for_this_study__c;
                    perObj.participantOptInSMSText = perRecord.Permit_SMS_Text_for_this_study__c;
                    perObj.participantOptInPhone =
                        perRecord.Permit_Voice_Text_contact_for_this_study__c;
                    perObj.participantOptInDirectEmail = perRecord.Study_Direct_Mail_Consent__c;
                }
                studyJSON=JSON.stringify(perObj);
            });
        }
        //Save PDE Record
        else if (pdeId && requestFrom == 'PDE') {
            this.consentPreferenceDataLocal.pdeList.forEach(function (pdeRecord) {
                if (pdeRecord.Id == pdeId) {
                    pdeObj.pdeId = pdeRecord.Id;
                    //pdeObj.ParticipantContId = pdeRecord.Participant__r.Contact__c;
                    pdeObj.delegateOptInEmail =pdeRecord.Study_Email_Consent__c;
                    pdeObj.delegateOptInSMSText = pdeRecord.Study_SMS_Consent__c;
                    pdeObj.delegateOptInPhone =pdeRecord.Study_Phone_Consent__c;
                    pdeObj.delegateOptInDirectEmail = pdeRecord.Study_Direct_Mail_Consent__c;
                }
                studyJSON=JSON.stringify(pdeObj);
            });
        }

        let conObj = {};
        if (requestFrom == 'IQVIA_OUTREACH') {
            conObj.contactId = this.contactDataLocal[0].Id;
            conObj.contactOptInEmail = this.contactDataLocal[0].Participant_Opt_In_Status_Emails__c;
            conObj.contactOptInSMSText = this.contactDataLocal[0].Participant_Opt_In_Status_SMS__c;
            conObj.contactOptInPhone =
                this.contactDataLocal[0].Participant_Phone_Opt_In_Permit_Phone__c;
            conObj.contactOptInDirectEmail = this.contactDataLocal[0].IQVIA_Direct_Mail_Consent__c;
            conObj.participantLoogedIn = this.isParticipantLoggedIn;
            conObj.isAdultParticipant = this.isAdultParticipant;
            conObj.isEmailAvailabelForParticipant = this.isEmailAvailabelForParticipant;
            conObj.isDelegateSelfView = this.isDelegateSelfView;
        }

        saveConsent({
            //studyDataJSON: JSON.stringify(perObj),
            studyDataJSON: studyJSON,
            outReachDataJSON: JSON.stringify(conObj),
            requestFrom: requestFrom
        }) //kk
            .then((result) => {
                this.spinner = false;
                this.showCustomToast('', this.label.PP_Profile_Update_Success, 'success');
                if (this.emailSMSConsent) {
                    createCommPrefEvent()
                        .then((responseSuccess) => {})
                        .catch((responseFailure) => {
                            this.showCustomToast('', 'Failed to publish Platfrom Event', 'error');
                        });
                }
                this.currentPERId = '';
                conObj = {};
            })
            .catch((error) => {
                this.showCustomToast('', 'Failed To save the Record...', 'error');
                this.spinner = false;
            });
    }

    // Helper Method: Toast Notification
    // To be replaced with community service helper method
    showCustomToast(title, message, varient) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: varient
        });
        this.dispatchEvent(toastEvent);
    }

    /* Outreach Handlers */

    selectAllOptionsOutreach(event) {
        this.updateOutReachData(event.target.label, event.target.checked, event.target.name, event);
    }

    selectIndividualOptionsOutreach(event) {
        this.updateOutReachData(event.target.label, event.target.checked, event.target.name, event);
    }

    updateOutReachData(label, value, outReachId, eventObj) {
        let processConsentSave = false;
        let mobileAvailability = this.isMobilePhoneNumberAvailable;
        let studyError = this.studyError;
        let template = this.template;
        let checkOtherSMSOptInsAvailable = false;
        let isEmailSMSConsentChecked = false;

        this.contactDataLocal.forEach(function (con) {
            switch (label) {
                case 'All':
                    let processSave = true;
                    // If mobile number is not available - prevent save consents
                    if (!mobileAvailability) {
                        processSave = false;
                        studyError = true;
                    }

                    // save consents if all is false and study error is true: opt out for sms and other channels should happen
                    //if(value == false && studyError == true && study.Permit_SMS_Text_for_this_study__c ){
                    if (value == false && studyError == true && !con['error']) {
                        processSave = true;
                    }

                    // First time error has occured: push error attribute the loacal study object
                    // prevent save consents if all is true and study error is true: opt out for sms and other channels should not happen
                    if (value == true && studyError == true) {
                        processSave = false;
                        con['error'] = true;
                    }

                    if (!processSave) {
                        window.scrollTo({ top: 0, behavior: 'smooth' });
                    }

                    if (processSave) {
                        con.Participant_Phone_Opt_In_Permit_Phone__c =
                            con.Participant_Opt_In_Status_Emails__c =
                            con.Participant_Opt_In_Status_SMS__c =
                            con.IQVIA_Direct_Mail_Consent__c =
                                value;
                        processConsentSave = true;
                        isEmailSMSConsentChecked = true;
                        //studyError = false;
                        // Update checkOtherSMSOptInsAvailable flag to check if SMS channel is checked for other studies/IQVIA outreach
                        con.Participant_Opt_In_Status_SMS__c == false
                            ? (checkOtherSMSOptInsAvailable = true)
                            : (checkOtherSMSOptInsAvailable = false);
                        con['error'] = false;
                    } else {
                        if (value) {
                            studyError = true;
                            value ? eventObj.target.classList.add('highlightErrorCheckbox') : '';
                            let inputFields = template.querySelectorAll('.smsElements');
                            inputFields.forEach((ele) => {
                                let conId = ele.getAttribute('data-id');
                                let label = ele.getAttribute('data-label');
                                if (conId == outReachId && label == 'SMS_OUTREACH') {
                                    console.log('Matched Element');
                                    ele.classList.add('highlightErrorCheckbox');
                                }
                            });
                            window.scrollTo({ top: 0, behavior: 'smooth' });
                        }
                    }
                    break;
                case 'Phone':
                    con.Participant_Phone_Opt_In_Permit_Phone__c = value;
                    processConsentSave = true;
                    break;
                case 'Email':
                    con.Participant_Opt_In_Status_Emails__c = value;
                    processConsentSave = true;
                    isEmailSMSConsentChecked = true;
                    break;
                case 'SMS':
                    let processOutreachSave = true;
                    // If mobile number is not available - prevent save consents
                    if (!mobileAvailability) {
                        processOutreachSave = false;
                        studyError = true;
                    }

                    // save consents if all is false and study error is true: opt out for sms and other channels should happen
                    //if(value == false && studyError == true && study.Permit_SMS_Text_for_this_study__c ){
                    if (value == false && studyError == true && !con['error']) {
                        processOutreachSave = true;
                    }

                    // First time error has occured: push error attribute the loacal study object
                    // prevent save consents if all is true and study error is true: opt out for sms and other channels should not happen
                    if (value == true && studyError == true) {
                        processOutreachSave = false;
                        con['error'] = true;
                    }

                    if (!processOutreachSave) {
                        window.scrollTo({ top: 0, behavior: 'smooth' });
                    }

                    if (processOutreachSave) {
                        con.Participant_Opt_In_Status_SMS__c = value;
                        processConsentSave = true;
                        isEmailSMSConsentChecked = true;
                        //studyError = false;
                        // Update checkOtherSMSOptInsAvailable flag to check if SMS channel is checked for other studies/IQVIA outreach
                        con.Participant_Opt_In_Status_SMS__c == false
                            ? (checkOtherSMSOptInsAvailable = true)
                            : (checkOtherSMSOptInsAvailable = false);
                        con['error'] = false;
                    } else {
                        if (value) {
                            studyError = true;
                            value ? eventObj.target.classList.add('highlightErrorCheckbox') : '';
                            window.scrollTo({ top: 0, behavior: 'smooth' });
                        }
                    }
                    break;
                case 'DMail':
                    con.IQVIA_Direct_Mail_Consent__c = value;
                    processConsentSave = true;
                    break;
            }
        });
        this.studyError = studyError;
        if (checkOtherSMSOptInsAvailable) {
            this.studyError = this.checkSMSCheckedOrNot();
        }
        if (processConsentSave) {
            this.emailSMSConsent = isEmailSMSConsentChecked;
            this.updateALLOutReachFlag();
            this.doSaveCommunicationPref('IQVIA_OUTREACH');
        }
    }

    updateALLOutReachFlag() {
        this.contactDataLocal.forEach(function (con) {
            con.Participant_Phone_Opt_In_Permit_Phone__c &&
            con.Participant_Opt_In_Status_Emails__c &&
            con.Participant_Opt_In_Status_SMS__c &&
            con.IQVIA_Direct_Mail_Consent__c
                ? (con.all = true)
                : (con.all = false);
        });
    }

    //Set Visibility if IQVIA Outreach Consent
    showIQVIAOutreachConsent() {
        //If IQVIA Outreach Consent is ON at CTP then only IQVIA Outreach Consent section should be visible.
        if (this.consentPreferenceDataLocal.isIQIVAOutrechToggleOnAtCTP) {
                return true;
        }
        return false;
    }

    isInputValid(event) {
        let numbers = /^[0-9]*$/;
        //let numbers = '((([0-9]{3}) |[0-9]{3}-)[0-9]{3}-[0-9]{4})|\\d';
        let homePhone = event.target.value;
        let saveBtn = this.template.querySelector('.saveBtn');
        if (homePhone === '') {
            event.target.setCustomValidity(this.label.PP_Phone_Mandatory);
            saveBtn.setAttribute('disabled', 'true');
        } else if (!numbers.test(homePhone) && homePhone !== '') {
            saveBtn.setAttribute('disabled', 'true');
            event.target.setCustomValidity(this.label.PP_Phone_Numeric);
        } else {
            event.target.setCustomValidity(''); // reset custom error message
            saveBtn.removeAttribute('disabled');
        }
        event.target.reportValidity();
    }

    savePhone(event) {
        //if (this.isInputValid()) {

        this.spinner = true;
        let phoneCmp = this.template.querySelector('.userInputField');
        let phoneNo = phoneCmp.value;

        updateParticipantMobileNumber({
            parId: this.currentParticipantId,
            contId: this.currentContactId,
            mobilePhone: phoneNo
        })
            .then((result) => {
                let successMsg = this.label.PP_Profile_Update_Success;
                this.isMobilePhoneNumberAvailable = true;
                this.studyError = false;
                this.spinner = false;
                let checkboxError = this.template.querySelectorAll('.highlightErrorCheckbox');
                checkboxError.forEach((errorEle) => {
                    errorEle.classList.remove('highlightErrorCheckbox');
                    // TO DO fix to be provided
                    //errorEle.checked = false;
                    let label = errorEle.getAttribute('data-label');
                    let id = errorEle.getAttribute('data-id');
                    // label != 'SMS'? errorEle.checked = false: "";
                    if (label == 'All' || label == 'SMS_STUDY') {
                        this.consentPreferenceDataLocal.perList.forEach(function (study) {
                            if (study.Id == id) {
                                switch (label) {
                                    case 'All':
                                        errorEle.checked = study.all;
                                        break;
                                    case 'SMS_STUDY':
                                        errorEle.checked = study.Permit_SMS_Text_for_this_study__c;
                                        break;
                                }
                            }
                        });
                    }
                    //For Patient Delegate Enrollment Record
                    if (label == 'All_PDE' || label == 'SMS_PDE') {
                        this.consentPreferenceDataLocal.pdeList.forEach(function (pde) {
                            if (pde.Id == id) {
                                switch (label) {
                                    case 'All_PDE':
                                        errorEle.checked = pde.all;
                                        break;
                                    case 'SMS_PDE':
                                        errorEle.checked = pde.Study_SMS_Consent__c;
                                        break;
                                }
                            }
                        });
                    }
                    if (label == 'All_OUTREACH' || label == 'SMS_OUTREACH') {
                        this.contactDataLocal.forEach(function (con) {
                            if (con.Id == id) {
                                switch (label) {
                                    case 'All_OUTREACH':
                                        errorEle.checked = con.all;
                                        break;
                                    case 'SMS_OUTREACH':
                                        errorEle.checked = con.Participant_Opt_In_Status_SMS__c;
                                        break;
                                }
                            }
                        });
                    }
                });

                let inputFields = this.template.querySelectorAll('.smsElements');
                inputFields.forEach((ele) => {
                    ele.classList.remove('highlightErrorCheckbox');
                });
                //Set success Message
                //TODO: Test if this is working in all the scenarios.
                this.consentPreferenceDataLocal.isSelfAccountSettingWarningMessage
                    ? (successMsg = this.label.PP_Communication_Par_Mobile_Upd_Success)
                    : (successMsg = this.label.PP_Communication_Del_Mobile_Upd_Success);

                this.showCustomToast('', successMsg, 'success');
                this.updateErrorOnStudyPostMobileNumberCorrection();
            })
            .catch((error) => {
                this.showCustomToast('', 'Failed To read the Data...', 'error');
                this.spinner = false;
            });
        //}
    }

    checkSMSCheckedOrNot() {
        let isSmsChecked = false;

        if (!this.isMobilePhoneNumberAvailable) {
            if (this.consentPreferenceDataLocal.perList.length > 0) {
                this.consentPreferenceDataLocal.perList.forEach(function (study) {
                    if (study.Permit_SMS_Text_for_this_study__c) {
                        isSmsChecked = true;
                    }
                });
            }
            //PDE Record Check
            if (this.consentPreferenceDataLocal.pdeList.length > 0) {
                this.consentPreferenceDataLocal.pdeList.forEach(function (pde) {
                    if (pde.Study_SMS_Consent__c) {
                        isSmsChecked = true;
                    }
                });
            }

            if (this.consentPreferenceDataLocal.isIQIVAOutrechToggleOnAtCTP) {
                this.contactDataLocal.forEach(function (con) {
                    if (con.Participant_Opt_In_Status_SMS__c) {
                        isSmsChecked = true;
                    }
                });
            }
        }
        return isSmsChecked;
    }

    updateErrorOnStudyPostMobileNumberCorrection() {
        this.consentPreferenceDataLocal.perList.forEach(function (study) {
            study['error'] = false;
        });
        this.consentPreferenceDataLocal.pdeList.forEach(function (pde) {
            pde['error'] = false;
        });
    }
}