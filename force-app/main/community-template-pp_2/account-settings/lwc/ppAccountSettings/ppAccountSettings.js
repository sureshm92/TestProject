import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import ACCOUNT_SETTINGS from '@salesforce/label/c.PP_Account_Settings';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import PROFILE_INFO from '@salesforce/label/c.PP_Profile_Information';
import PASSWORD_MANAGEMENT from '@salesforce/label/c.PP_Password_Management';
import COMMUNICATION_PREF from '@salesforce/label/c.Communication_Preferences';
import LANG_LOCATION from '@salesforce/label/c.PP_Language_and_Location';
import CUSTOMIZE_EXP from '@salesforce/label/c.PP_Customize_Experience';
import COOKIE_SETTINGS from '@salesforce/label/c.PP_Cookie_Settings';
import MEDICAL_RECORD_ACCESS from '@salesforce/label/c.Medical_Record_Access';
import getInitData from '@salesforce/apex/AccountSettingsController.getInitDataforAccPage';
import MANAGE_DELEGATES from '@salesforce/label/c.PP_ManageDelegates';
import MANAGE_ASSIGNMENTS from '@salesforce/label/c.PP_Assignments';
import STUDIES_AND_PROGRAM_PP from '@salesforce/label/c.Studies_And_Program_PP';
export default class PpAccountSettings extends LightningElement {
    @api userMode;
    @api isRTL = false;
    @api isMobile = false;
    @api isInitialized = false;
    @api isDelegate = false;
    @track initData;
    @track personWrapper;
    @track contactSectionData;
    componentId = 'asHome';
    partipantStateInfo;
    showMobileNavComponent = false;
    spinner;
    participantState;
    consentPreferenceData;
    isDesktopFlag = true;

    labels = {
        ACCOUNT_SETTINGS,
        PROFILE_INFO,
        PASSWORD_MANAGEMENT,
        COMMUNICATION_PREF,
        LANG_LOCATION,
        CUSTOMIZE_EXP,
        COOKIE_SETTINGS,
        MEDICAL_RECORD_ACCESS,
        ERROR_MESSAGE,
        MANAGE_DELEGATES,
        MANAGE_ASSIGNMENTS,
        STUDIES_AND_PROGRAM_PP

    };

    navHeadersList = [
        { label: PROFILE_INFO, value: 'profileInformation' },
        { label: PASSWORD_MANAGEMENT, value: 'password-change' },
        { label: COMMUNICATION_PREF, value: 'communication-preferences' },
        { label: LANG_LOCATION, value: 'lang-loc' },
        { label: CUSTOMIZE_EXP, value: 'changePref' },
        { label: COOKIE_SETTINGS, value: 'cookiesSettings' }
        //{ label: MEDICAL_RECORD_ACCESS, value: 'medRecAccess' }
    ];
    medicalRecordVendorToggle = false;
    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                this.spinner = this.template.querySelector('c-web-spinner');
                this.spinner.show();
                this.initializeData();
                this.isMobile ? (this.isDesktopFlag = false) : (this.isDesktopFlag = true);
            })
            .catch((error) => {
                this.showToast(this.labels.ERROR_MESSAGE, error.message, 'error');
            });
    }

    renderedCallback() {
        if (!this.isMobile) {
            this.handleActiveNavigationClass(this.componentId);
        }
    }

    /**CSS Related Getters START */

    get bodyContainerClass() {
        return this.isMobile
            ? this.isRTL
                ? 'slds-grid slds-wrap body-content-mobile-rtl'
                : 'slds-grid slds-wrap body-content-mobile'
            : this.isRTL
            ? 'slds-grid slds-wrap body-content rtl'
            : 'slds-grid slds-wrap body-content';
    }

    get titleClass() {
        return this.isMobile
            ? this.isRTL
                ? 'title slds-col slds-size_1-of-1 slds-p-right_large title-mobile'
                : 'title slds-size_1-of-1 title-mobile '
            : this.isRTL
            ? 'title slds-col slds-size_1-of-1 rtl slds-p-left_large'
            : 'title slds-size_1-of-1';
    }

    get navBarClass() {
        return this.isRTL
            ? 'slds-col slds-size_1-of-1 nav-bar-container-rtl rtl'
            : 'slds-size_1-of-1 nav-bar-container';
    }

    get iconContainerClass() {
        return this.isRTL ? 'icon-container-rtl' : 'icon-container';
    }

    get expandIconName() {
        return this.isRTL ? 'utility:chevronleft' : 'utility:chevronright';
    }

    get navComponentContainerClass() {
        return this.isMobile
            ? 'slds-col slds-size_12-of-12 nav-component-container slds-p-left_none'
            : this.isRTL
            ? 'slds-col slds-size_9-of-12 nav-component-container-rtl'
            : 'slds-col slds-size_9-of-12 nav-component-container';
    }

    get navComponentClass() {
        return this.isRTL
            ? this.isMobile
                ? 'nav-component-mobile rtl'
                : 'nav-component rtl'
            : this.isMobile
            ? 'nav-component-mobile'
            : 'nav-component';
    }

    /**CSS Related Getters END */

    /**Active Header Getters START */
    get showProfileInformation() {
        return this.componentId === 'profileInformation' ? true : false;
    }

    get showPasswordManagement() {
        return this.componentId === 'password-change' ? true : false;
    }

    get showCommunicationPreference() {
        return this.componentId === 'communication-preferences' ? true : false;
    }

    get showLanguageAndLocation() {
        return this.componentId === 'lang-loc' ? true : false;
    }

    get showCustomizeExperience() {
        return this.componentId === 'changePref' ? true : false;
    }

    get showCookieSettings() {
        return this.componentId === 'cookiesSettings' ? true : false;
    }

    get showMedicalRecordAccess() {
        return this.componentId === 'medRecAccess' ? true : false;
    }
    get showManageDelegates(){
        return this.componentId === 'manage-delegates' ? true : false;
    }
    get showManageAssignments(){
        return this.componentId === 'manage-assignmens' ? true : false;
    }
    initializeData() {
        this.displayManageDelegates();
        getInitData()
            .then((result) => {
                let initialData = JSON.parse(result);
                this.medicalRecordVendorToggle = communityService.getParticipantData().ctp
                    ? communityService.getParticipantData().ctp.Medical_Vendor_is_Available__c
                    : false;
                if (this.medicalRecordVendorToggle) {
                    this.navHeadersList.push({
                        label: MEDICAL_RECORD_ACCESS,
                        value: 'medRecAccess'
                    });
                }
                initialData.password = {
                    old: '',
                    new: '',
                    reNew: ''
                };

                const queryString = window.location.href;

                this.personWrapper = initialData.contactSectionData.personWrapper;
                this.contactSectionData = initialData.contactSectionData;

                this.isInitialized = true;
                this.setComponentId(queryString);
                this.spinner.hide();
            })
            .catch((error) => {
                this.showToast(this.labels.ERROR_MESSAGE, error.message, 'error');
            });
    }
    displayManageDelegates(){
        let isDelegateSwitchingToParView = false;
        let showManageDelegateTab = false;
        let showMamanageAssignmentTab = false;
        let isDelSelfView =
        communityService.getParticipantData().value == 'ALUMNI' ||
        (communityService.getParticipantData().hasPatientDelegates &&
            !communityService.getParticipantData().isDelegate &&
            !communityService.getParticipantData().pe);
        let allUserModes = communityService.getAllUserModes();  
        //Delegate switched to Par View    
        if (communityService.getCurrentCommunityMode().currentDelegateId){
            isDelegateSwitchingToParView = true;
            showMamanageAssignmentTab = false;
            showManageDelegateTab = false;
        } 
        //Del Self View
        else if(isDelSelfView){
            showMamanageAssignmentTab = true;
            showManageDelegateTab = false;
        }   
        //Pure Participant Login
        else if(!isDelegateSwitchingToParView && !communityService.getParticipantData().hasPatientDelegates){
            showMamanageAssignmentTab = false;
            showManageDelegateTab = true;        
        } 
        //Multi Role    
        else if(!isDelegateSwitchingToParView && communityService.getParticipantData().hasPatientDelegates && allUserModes){ // For Participant also same JSON make sure it shouldnt execute for Participnat
            allUserModes.forEach(function(item) {
                if(item.userMode == 'Participant'){
                    if(item.subModes){
                        item.subModes.forEach(function(subModeitem) {
                            if(subModeitem.currentDelegateId == null){
                                showMamanageAssignmentTab = true;
                                showManageDelegateTab = true;
                    
                            }    
                        });
                    }
                }
            });
        }  
        if (showManageDelegateTab) {
            this.navHeadersList.push({
                label: MANAGE_DELEGATES,
                value: 'manage-delegates'
            });
        }
        if (showMamanageAssignmentTab) {
            this.navHeadersList.push({
                label: MANAGE_ASSIGNMENTS,
                value: 'manage-assignmens'
            });
        }
    }

    setComponentId(queryString) {
        if (queryString.includes('profileInformation')) {
            this.componentId = 'profileInformation';
            window.history.replaceState(null, null, '?profileInformation');
        } else if (queryString.includes('password-change')) {
            this.componentId = 'password-change';
            window.history.replaceState(null, null, '?password-change');
        } else if (queryString.includes('communication-preferences')) {
            this.componentId = 'communication-preferences';
            if (queryString.includes('communication-preferenceswithprevtask')) {
                window.history.replaceState(null, null, '?communication-preferenceswithprevtask');
            } else {
                window.history.replaceState(null, null, '?communication-preferences');
            }
        } else if (queryString.includes('lang-loc')) {
            this.componentId = 'lang-loc';
            window.history.replaceState(null, null, '?lang-loc');
        } else if (queryString.includes('changePref')) {
            this.componentId = 'changePref';
            window.history.replaceState(null, null, '?changePref');
        } else if (queryString.includes('cookiesSettings')) {
            this.componentId = 'cookiesSettings';
            window.history.replaceState(null, null, '?cookiesSettings');
        } else if (queryString.includes('medRecAccess')) {
            this.componentId = 'medRecAccess';
            window.history.replaceState(null, null, '?medRecAccess');
        } else if (queryString.includes('manage-delegates')) {
            this.componentId = 'manage-delegates';
            window.history.replaceState(null, null, '?manage-delegates');
        } else if (queryString.includes('manage-assignmens')) {
            this.componentId = 'manage-assignmens';
            window.history.replaceState(null, null, '?manage-assignmens');
        } else {
            if (!this.isMobile) {
                this.componentId = 'profileInformation';
                window.history.replaceState(null, null, '?profileInformation');
            } else if (this.isMobile) {
                this.componentId = 'asHome';
                this.showMobileNavComponent = true;
            } else {
                console.error('We were on a Break!');
            }
        }
    }

    navigateToSelectedComponent(event) {
        let selectedComponent = event.currentTarget.dataset.header;
        this.handleActiveNavigationClass(selectedComponent);
        this.setComponentId(selectedComponent);
    }

    showNavigationMenu(event) {
        this.componentId = 'asHome';
        this.showMobileNavComponent = true;
        window.history.replaceState(null, null, '?asHome');
    }

    handleSelectedHeader(event) {
        let selectedHeader = event.target.dataset.header
            ? event.target.dataset.header
            : event.currentTarget.dataset.header;
        this.showMobileNavComponent = false;
        this.setComponentId(selectedHeader);
    }

    /**Reusable Methods START*/

    showToast(titleText, messageText, variantType) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: titleText,
                message: messageText,
                variant: variantType
            })
        );
    }

    handleActiveNavigationClass(selectedHeader) {
        this.template.querySelector('.slds-is-active')
            ? this.template.querySelector('.slds-is-active').classList.remove('slds-is-active')
            : '';
        this.template.querySelector(`[data-header="${selectedHeader}"]`)
            ? this.template
                  .querySelector(`[data-header="${selectedHeader}"]`)
                  .classList.add('slds-is-active')
            : '';
    }

    /**Reusable Methods END*/
}