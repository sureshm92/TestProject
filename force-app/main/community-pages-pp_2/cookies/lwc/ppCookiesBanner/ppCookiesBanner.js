import { LightningElement, track, api } from 'lwc';
import ppCookiesBannerLoginDesc from '@salesforce/label/c.PP_Cookies_Banner_Login_Desc';
import ppCookiesBannerDesc1 from '@salesforce/label/c.PP_Cookies_Banner_Desc1';
import ppCookiesBannerDesc2 from '@salesforce/label/c.PP_Cookies_Banner_Desc2';
import ppCookiesBannerDesc3 from '@salesforce/label/c.PP_Cookies_Banner_Desc3';
import ppCookiesButtonAccept from '@salesforce/label/c.PP_Cookies_Button_Accept';
import ppCookiesButtonManagePrefer from '@salesforce/label/c.PP_Cookies_Button_Manage_Prefer';
import ppCookieBannerHeader from '@salesforce/label/c.PP_Cookie_Banner_Header';
import getInitData from '@salesforce/apex/AccountSettingsController.getInitData';
import changeOptInCookies from '@salesforce/apex/AccountSettingsController.changeOptInCookies';

import pp_icons from '@salesforce/resourceUrl/pp_community_icons';

import cookieManageCookiesLabel from '@salesforce/label/c.Cookies_Manage_Cookies';
import manageCookiesDesc from '@salesforce/label/c.Manage_Cookies_Desc';
import accountSettingsStrictlyNecessaryCookies from '@salesforce/label/c.AccountSettings_Strictly_Necessary_Cookies';
import cookieAlwaysActive from '@salesforce/label/c.Cookie_Always_Active';
import accountSettingsFunctionalCookiesLabel from '@salesforce/label/c.AccountSettings_Functional_Cookies';
import accountSettingsFunctionalRRCookiesLabel from '@salesforce/label/c.AccountSettings_Functional_RRCookies';
import accountSettingsRRCookiesDescriptionLabel from '@salesforce/label/c.AccountSettings_RRCookies_Description';
import accountSettingsCookiesRRLanguageLabel from '@salesforce/label/c.AccountSettings_Cookies_RRLanguage';
import accountSettingsCookiesRRLanguageDescriptionLabel from '@salesforce/label/c.AccountSettings_Cookies_RRLanguage_Description';
import bTN_AcceptLabel from '@salesforce/label/c.BTN_Accept';
import loadingLabel from '@salesforce/label/c.Loading';

export default class PpCookiesBanner extends LightningElement {
    showmodal = false;
    @api
    loginPage = false;
    @api
    isRTL = false;
    @api
    communityName;
    userMode;
    spinner;
    containerClassCss = 'c-container desk-cookies-banner mob-cookies-banner ';
    label = {
        ppCookiesBannerLoginDesc,
        ppCookiesBannerDesc1,
        ppCookiesBannerDesc2,
        ppCookiesBannerDesc3,
        ppCookiesButtonAccept,
        ppCookiesButtonManagePrefer,
        ppCookieBannerHeader,
        cookieManageCookiesLabel,
        manageCookiesDesc,
        accountSettingsStrictlyNecessaryCookies,
        cookieAlwaysActive,
        accountSettingsFunctionalCookiesLabel,
        accountSettingsFunctionalRRCookiesLabel,
        accountSettingsRRCookiesDescriptionLabel,
        accountSettingsCookiesRRLanguageLabel,
        accountSettingsCookiesRRLanguageDescriptionLabel,
        bTN_AcceptLabel
    };
    showBanner = false;
    initData;
    contact;
    dynamicCSSAppend = pp_icons + '/right.svg';

    connectedCallback() {
        let rrCookies = communityService.getCookie('RRCookies');
        if (!rrCookies || this.loginPage) {
            this.showBanner = true;
            this.blockBackGroundEvents();
            if (this.communityName == 'Default') {
                this.containerClassCss = this.containerClassCss + ' rh-cookies-banner';
            }
        }
        let accList = this.template.querySelectorAll('accordion');
    }
    blockBackGroundEvents() {
        document.body.addEventListener('keypress', this.bodyBlock);
        document.body.addEventListener('keydown', this.bodyBlock);
        document.body.classList.add('cookie-block-user');
    }
    bodyBlock(event) {
        event.preventDefault();
    }
    showManagePreferences() {
        this.spinner = this.template.querySelector('c-web-spinner');

        if (this.spinner) this.spinner.show();
        this.userMode = communityService.getUserMode();
        this.showmodal = true;
        this.closeTheBanner();
        getInitData({
            userMode: this.userMode
        })
            .then((returnValue) => {
                if (this.spinner) this.spinner.hide();
                let initData = JSON.parse(returnValue);
                this.initData = initData;
                this.blockBackGroundEvents();
                this.contact = initData.myContact;
            })
            .catch((error) => {
                communityService.showToast('', 'error', 'Failed To read the Data...', 100);
            });
    }
    renderedCallback() {
        let el = this.template.querySelector('.modal-header-text');
        var bodyStyles = document.body.style;
        bodyStyles.setProperty('--cookieRightIcon', 'url(' + this.dynamicCSSAppend + ')');
    }

    showCookieDiv(event) {
        let el = this.template.querySelectorAll('.accordion.active');
        let divEle = this.template.querySelector("[id='" + event.currentTarget.id + "']");
        divEle.classList.toggle('active');
        let panel = divEle.getElementsByTagName('div')[1];
        if (panel.style.display === 'block') {
            panel.style.display = 'none';
        } else {
            panel.style.display = 'block';
        }
    }

    closeTheBanner() {
        document.body.classList.remove('cookie-block-user');
        this.showBanner = false;
        document.body.removeEventListener('keypress', this.bodyBlock);
        document.body.removeEventListener('keydown', this.bodyBlock);
    }

    acceptAll() {
        communityService.setCookie('RRCookies', 'agreed', 365);
        document.body.classList.remove('cookie-block-user');
        this.showBanner = false;
        changeOptInCookies({
            rrCookieAllowed: true,
            rrLanguageAllowed: true
        })
            .then((returnValue) => {
                this.spinner.hide();
                this.contact.RRCookiesAllowedCookie__c = true;
                this.contact.RRLanguageAllowedCookie__c = true;
                this.setRRCookie();
                this.setRRCookieLanguage();
                this.closeTheBanner();
                this.showmodal = false;
                this.initData = undefined;
                this.updateBrowserCookies();
            })
            .catch((error) => {
                communityService.showToast('', 'error', 'Failed To read the Data...', 100);
                this.spinner.hide();
            });
    }

    get backDropClass() {
        return 'slds-backdrop ' + (this.showmodal ? ' slds-backdrop_open ' : '');
    }

    updateCookies() {
        this.spinner.show();
        let ppLangChecked = this.template.querySelector('[data-id=PPLang]').checked;
        let ppCookieChecked = this.template.querySelector('[data-id=PPCookie]').checked;
        this.contact.RRCookiesAllowedCookie__c = ppCookieChecked;
        this.contact.RRLanguageAllowedCookie__c = ppLangChecked;
        changeOptInCookies({
            rrCookieAllowed: this.contact.RRCookiesAllowedCookie__c,
            rrLanguageAllowed: this.contact.RRLanguageAllowedCookie__c
        })
            .then((returnValue) => {
                this.spinner.hide();
                if (this.contact.RRCookiesAllowedCookie__c) {
                    this.setRRCookie();
                    document.body.classList.remove('cookie-block-user');
                }
                if (this.contact.RRLanguageAllowedCookie__c) {
                    this.setRRCookieLanguage();
                }
                this.closeTheBanner();
                this.updateBrowserCookies();
                this.showmodal = false;
                this.initData = undefined;
            })
            .catch((error) => {
                communityService.showToast('', 'error', 'Failed To read the Data...', 100);
                this.spinner.hide();
            });
    }
    setRRCookie() {
        let d = new Date();
        d.setTime(d.getTime() + 365 * 24 * 60 * 60 * 1000);
        let expires = 'expires=' + d.toUTCString();
        document.cookie = 'RRCookies' + '=' + 'agreed' + ';' + expires + ';path=/';
    }
    setRRCookieLanguage() {
        let d = new Date();
        d.setTime(d.getTime() + 365 * 24 * 60 * 60 * 1000);
        let expires = 'expires=' + d.toUTCString();
        document.cookie =
            'RRLanguage' + '=' + communityService.getLanguage() + ';' + expires + ';path=/';
    }
    updateBrowserCookies() {
        let preventCookieList = [];
        if (!this.contact.RRCookiesAllowedCookie__c) preventCookieList.push('RRCookies');
        if (!this.contact.RRLanguageAllowedCookie__c) preventCookieList.push('RRLanguage');
        if (preventCookieList.length > 0) communityService.deleteCookies(preventCookieList);
    }
}
