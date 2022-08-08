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
import getInitData from '@salesforce/apex/AccountSettingsController.getInitData';
export default class PpAccountSettings extends LightningElement {
    @api userMode;
    @api isRTL = false;
    @api isMobile = false;
    @api isInitialized = false;
    @api isDelegate = false;
    @track initData;
    @track personWrapper;
    @track contactSectionData;
    @track contact;
    componentId = 0;
    userType = '';
    currentEmail = '';
    optInEmail = false;
    optInSMS = false;
    contactChanged = false;
    showMobileNavComponent = false;
    spinner;
    labels = {
        ACCOUNT_SETTINGS,
        PROFILE_INFO,
        PASSWORD_MANAGEMENT,
        COMMUNICATION_PREF,
        LANG_LOCATION,
        CUSTOMIZE_EXP,
        COOKIE_SETTINGS,
        MEDICAL_RECORD_ACCESS,
        ERROR_MESSAGE
    };

    navHeadersList = [
        { label: PROFILE_INFO, value: 'profileInformation' },
        { label: PASSWORD_MANAGEMENT, value: 'passwordchange' },
        { label: COMMUNICATION_PREF, value: 'communication-preferences' },
        { label: LANG_LOCATION, value: 'langloc' },
        { label: CUSTOMIZE_EXP, value: 'changePref' },
        { label: COOKIE_SETTINGS, value: 'cookiesSettings' },
        { label: MEDICAL_RECORD_ACCESS, value: 'medRecAccess' }
    ];

    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                this.spinner = this.template.querySelector('c-web-spinner');
                this.spinner.show();
                this.initializeData();
            })
            .catch((error) => {
                this.showToast(this.labels.ERROR_MESSAGE, error.message, 'error');
            });
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
        return this.componentId === 1 ? true : false;
    }

    get showPasswordManagement() {
        return this.componentId === 2 ? true : false;
    }

    get showCommunicationPreference() {
        return this.componentId === 3 ? true : false;
    }

    get showLanguageAndLocation() {
        return this.componentId === 4 ? true : false;
    }

    get showCustomizeExperience() {
        return this.componentId === 5 ? true : false;
    }

    get showCookieSettings() {
        return this.componentId === 6 ? true : false;
    }

    get showMedicalRecordAccess() {
        return this.componentId === 7 ? true : false;
    }

    initializeData() {
        getInitData({ userMode: this.userMode })
            .then((result) => {
                let initialData = JSON.parse(result);
                initialData.password = {
                    old: '',
                    new: '',
                    reNew: ''
                };

                const queryString = window.location.href;

                this.initData = initialData;
                this.contactChanged = initialData.contactChanged;
                this.personWrapper = initialData.contactSectionData.personWrapper;
                this.contactSectionData = initialData.contactSectionData;
                this.optInEmail = initialData.contactSectionData.personWrapper.optInEmail;
                this.optInSMS = initialData.contactSectionData.personWrapper.optInSMS;
                this.userType = initialData.myContact.UserCommunytyType__c;
                this.contact = initialData.myContact;
                this.currentEmail = initialData.myContact.Email;
                this.isInitialized = true;
                this.setComponentId(queryString);
                this.spinner.hide();
            })
            .catch((error) => {
                this.showToast(this.labels.ERROR_MESSAGE, error.message, 'error');
            });
    }

    setComponentId(queryString) {
        if (queryString.includes('profileInformation')) {
            this.componentId = 1;
            window.history.replaceState(null, null, '?profileInformation');
        } else if (queryString.includes('passwordchange')) {
            this.componentId = 2;
            window.history.replaceState(null, null, '?passwordchange');
        } else if (queryString.includes('communicationPreferences')) {
            this.componentId = 3;
            window.history.replaceState(null, null, '?communicationPreferences');
        } else if (queryString.includes('langloc')) {
            this.componentId = 4;
            window.history.replaceState(null, null, '?langloc');
        } else if (queryString.includes('changePref')) {
            this.componentId = 5;
            window.history.replaceState(null, null, '?changePref');
        } else if (queryString.includes('cookiesSettings')) {
            this.componentId = 6;
            window.history.replaceState(null, null, '?cookiesSettings');
        } else if (queryString.includes('medRecAccess')) {
            this.componentId = 7;
            window.history.replaceState(null, null, '?medRecAccess');
        } else {
            if (!this.isMobile) {
                this.componentId = 1;
                window.history.replaceState(null, null, '?profileInformation');
            } else if (this.isMobile) {
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
        this.componentId = 0;
        this.showMobileNavComponent = true;
        window.history.replaceState(null, null, '?asHome');
    }

    handleSelectedHeader(event) {
        let selectedHeader = event.target.dataset.header;
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
            : 'I am Iron Man!!';
        this.template.querySelector(`[data-header="${selectedHeader}"]`)
            ? this.template
                  .querySelector(`[data-header="${selectedHeader}"]`)
                  .classList.add('slds-is-active')
            : 'Avengers Assemble!!';
    }

    /**Reusable Methods END*/
}
