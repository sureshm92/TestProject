import { api, LightningElement } from 'lwc';

import unableToLogin from '@salesforce/label/c.PG_Unable_To_Login';
import unableToLogin1 from '@salesforce/label/c.PG_Unable_To_Login_L1';
import unableToLogin2 from '@salesforce/label/c.PG_Unable_To_Login_L2';
import unableToLogin3 from '@salesforce/label/c.PG_Unable_To_Login_L3';
import unableToLogin4 from '@salesforce/label/c.PG_Unable_To_Login_L4';
import unableToLogin5 from '@salesforce/label/c.PG_Unable_To_Login_L5';
import unableToLogin6 from '@salesforce/label/c.PG_Unable_To_Login_L6';
import unableToLogin7 from '@salesforce/label/c.PG_Unable_To_Login_L7';
import unableToLogin8 from '@salesforce/label/c.PG_Unable_To_Login_L8';
import unableToLogin9 from '@salesforce/label/c.PG_Unable_To_Login_L9';
import unableToLogin10 from '@salesforce/label/c.PG_Unable_To_Login_L10';
import loginLinkForgot from '@salesforce/label/c.PG_Login_Link_Forgot';
import okButton from '@salesforce/label/c.BTN_OK';
import getForgotPasswordUrl from '@salesforce/apex/RRLoginRemote.getForgotPasswordUrl';

import FAV_ICON from '@salesforce/resourceUrl/Lofi_Login_Icons';

export default class UnableToLogin extends LightningElement {
    favIconUrl = FAV_ICON + '/favicon_darkblue_64.svg';
    labels = {
        unableToLogin,
        unableToLogin1,
        unableToLogin2,
        unableToLogin3,
        unableToLogin4,
        unableToLogin5,
        unableToLogin6,
        unableToLogin7,
        unableToLogin8,
        unableToLogin9,
        unableToLogin10,
        loginLinkForgot,
        okButton
    };
    @api isRTLLanguage = false;
    @api userId;
    @api
    showModal() {
        console.log(this.template.querySelector('.unableToLoginPopup'));
        this.template.querySelector('.unableToLoginPopup').show();
    }
    closeModal() {
        this.template.querySelector('.unableToLoginPopup').cancel();
    }
    get fontDirectionAndStyle() {
        return this.isRTLLanguage ? 'allFontColor allFontSize rtlText' : 'allFontColor allFontSize';
    }
    get footerDiv() {
        return this.isRTLLanguage ? 'footerRTL' : 'footerLTR';
    }
    redirectToForgotPassword() {
        getForgotPasswordUrl({ userName: this.userId })
            .then((result) => {
                if (result.includes('**return')) {
                    result = result.replace('**return', '');
                    //component.set('v.errorMessage', rtnValue);
                    //component.set('v.showError', true);
                } else if (result.includes('**url')) {
                    result = result.replace('**url', '');
                    window.open(result, '_top');
                }
            })
            .catch({});
    }
}
