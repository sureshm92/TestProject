import { LightningElement, track, api } from 'lwc';
import ppCookiesBannerLoginDesc from '@salesforce/label/c.PP_Cookies_Banner_Login_Desc';
import ppCookiesBannerDesc1 from '@salesforce/label/c.PP_Cookies_Banner_Desc1';
import ppCookiesBannerDesc2 from '@salesforce/label/c.PP_Cookies_Banner_Desc2';
import ppCookiesBannerDesc3 from '@salesforce/label/c.PP_Cookies_Banner_Desc3';
import ppCookiesButtonAccept from '@salesforce/label/c.PP_Cookies_Button_Accept';
import ppCookiesButtonManagePrefer from '@salesforce/label/c.PP_Cookies_Button_Manage_Prefer';
import ppCookieBannerHeader from '@salesforce/label/c.PP_Cookie_Banner_Header';

export default class PpCookiesBanner extends LightningElement {
    showmodal = false;
    @api
    loginPage = false;
    @api
    isRTL = false;
    @api
    communityName;
    containerClassCss = 'c-container desk-cookies-banner mob-cookies-banner ';
    label = {
        ppCookiesBannerLoginDesc,
        ppCookiesBannerDesc1,
        ppCookiesBannerDesc2,
        ppCookiesBannerDesc3,
        ppCookiesButtonAccept,
        ppCookiesButtonManagePrefer,
        ppCookieBannerHeader
    };
    showBanner = false;

    connectedCallback() {
        let rrCookies = communityService.getCookie('RRCookies');
        if (!rrCookies || this.loginPage) {
            document.body.classList.add('cookie-block-user');
            this.showBanner = true;
            if (this.communityName == 'Default') {
                this.containerClassCss = this.containerClassCss + ' rh-cookies-banner';
            }
        }
    }
    showManagePreferences() {
        this.showmodal = true;
    }

    closeTheBanner() {
        document.body.classList.remove('cookie-block-user');
        this.showBanner = false;
    }

    acceptAll() {
        communityService.setCookie('RRCookies', 'agreed', 365);
        document.body.classList.remove('cookie-block-user');
        this.showBanner = false;
    }

    get backDropClass() {
        return 'slds-backdrop ' + (this.showmodal ? ' slds-backdrop_open ' : '');
    }
}
