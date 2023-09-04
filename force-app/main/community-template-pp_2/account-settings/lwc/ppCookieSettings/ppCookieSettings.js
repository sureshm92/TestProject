import { LightningElement, api } from 'lwc';

import rr_community_icons from '@salesforce/resourceUrl/rr_community_icons';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import communityPPTheme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';

import AccountSettings_Cookie_Settings from '@salesforce/label/c.AccountSettings_Cookie_Settings';
import AccountSettings_Strictly_Necessary_Cookies from '@salesforce/label/c.AccountSettings_Strictly_Necessary_Cookies';
import AccountSettings_Functional_Cookies from '@salesforce/label/c.AccountSettings_Functional_Cookies';
import AccountSettings_Functional_RRCookies from '@salesforce/label/c.AccountSettings_Functional_RRCookies';
import AccountSettings_RRCookies_Description from '@salesforce/label/c.AccountSettings_RRCookies_Description';
import BTN_On from '@salesforce/label/c.BTN_On';
import BTN_Off from '@salesforce/label/c.BTN_Off';
import AccountSettings_Cookies_RRLanguage from '@salesforce/label/c.AccountSettings_Cookies_RRLanguage';
import AccountSettings_Cookies_RRLanguage_Description from '@salesforce/label/c.AccountSettings_Cookies_RRLanguage_Description';
import PP_Profile_Update_Success from '@salesforce/label/c.PP_Profile_Update_Success';
import BACK from '@salesforce/label/c.Back';

import getInitData from '@salesforce/apex/AccountSettingsController.getInitData';
import changeOptInCookies from '@salesforce/apex/AccountSettingsController.changeOptInCookies';

export default class PpCookieSettings extends LightningElement {

    initData;
    contactChanged;
    personWrapper;
    contactSectionData;
    optInEmail;
    optInSMS;
    contact;
    currentEmail;
    isInitialized = false;
    spinner;
    activeSections;

    @api userMode;
    @api isRTL = false;
    @api isMobile = false;
    @api isDelegate = false;

    label = {
        AccountSettings_Cookie_Settings,
        AccountSettings_Strictly_Necessary_Cookies,
        AccountSettings_Functional_Cookies,
        AccountSettings_Functional_RRCookies,
        AccountSettings_RRCookies_Description,
        BTN_On,
        BTN_Off,
        AccountSettings_Cookies_RRLanguage,
        AccountSettings_Cookies_RRLanguage_Description,
        PP_Profile_Update_Success,
        BACK
    };

    connectedCallback(){
        loadScript(this, RR_COMMUNITY_JS)
        .then(() => {
            Promise.all([loadStyle(this, communityPPTheme)])
                .then(() => {  
                    this.spinner = this.template.querySelector('c-web-spinner');
                    this.spinner ? this.spinner.show() : "";
                })
                .catch((error) => {
                    console.log(error.body.message);
                });
        })
        .catch((error) => {
            communityService.showToast('', 'error', error.message, 100);
        });
        communityService.getCurrentCommunityMode().currentDelegateId ? this.isDelegate = true : this.isDelegate = false;
        getInitData({ 
            userMode: this.userMode
         })
        .then((returnValue) => {
            this.isInitialized = true;
            let initData = JSON.parse(returnValue);
            initData.password = {
                old: '',
                new: '',
                reNew: ''
            };
            this.initData = initData;
            this.contactChanged = initData.contactChanged;
            this.personWrapper = initData.contactSectionData.personWrapper;
            this.contactSectionData = initData.contactSectionData;
            this.optInEmail = initData.contactSectionData.personWrapper.optInEmail;
            this.optInSMS = initData.contactSectionData.personWrapper.optInSMS;
            this.contact = initData.myContact;
            this.currentEmail = initData.myContact.Email;

             this.spinner.hide();

        })
        .catch((error) => {
            communityService.showToast('', 'error', 'Failed To read the Data...', 100);
            this.spinner.hide();
        });
    }

    doSwitchOptInCookies(event){
        let dataid = event.currentTarget.getAttribute("data-id");
        this.spinner.show();
        if(dataid === 'PPCookie'){
            this.contact.RRCookiesAllowedCookie__c = event.target.checked;
        }
        else if(dataid === 'PPLang'){
            this.contact.RRLanguageAllowedCookie__c = event.target.checked;
        }
        changeOptInCookies({ 
            rrCookieAllowed: this.contact.RRCookiesAllowedCookie__c,
            rrLanguageAllowed: this.contact.RRLanguageAllowedCookie__c
         })
        .then((returnValue) => {
            communityService.showToast(
                '',
                'success',
                this.label.PP_Profile_Update_Success,
                100
            );
            this.spinner.hide();
        })
        .catch((error) => {
            communityService.showToast('', 'error', 'Failed To read the Data...', 100);
            this.spinner.hide();
        });
    }
    // Getter for back icon
    get iconChevron() {
        return 'icon-chevron-left';
    }
    
    showMenuBar(event) {
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
    
}