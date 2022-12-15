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
            this.showBanner = true;
        }
    }
    showManagePreferences() {
        this.showmodal = true;
    }

    closeTheBanner() {
        this.showBanner = false;
    }

    acceptAll() {
        communityService.setCookie('RRCookies', 'agreed');
        this.showBanner = false;
    }

    get backDropClass() {
        return 'slds-backdrop ' + (this.showmodal ? ' slds-backdrop_open ' : '');
    }
}
