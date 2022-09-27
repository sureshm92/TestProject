import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

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
import BTN_OK from '@salesforce/label/c.BTN_OK';
import isUserPasswordLocked from '@salesforce/apex/RRLoginRemote.isUserPasswordLocked';

import FAV_ICON from '@salesforce/resourceUrl/Lofi_Login_Icons';

export default class UnableToLogin extends NavigationMixin(LightningElement) {
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
        BTN_OK
    };
    @api isRTLLanguage = false;
    userId;
    @api show(userName) {
        this.template.querySelector('.unableToLoginPopup').show();
        this.userId = userName;
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
        if (this.userId) {
            isUserPasswordLocked({ userName: this.userId })
                .then((result) => {
                    console.log('##result: ' + JSON.stringify(result));
                    if (result.TimeDifference) {
                        this.template.querySelector('.unableToLoginPopup').cancel();
                        const unableToLoginEvent = new CustomEvent('unabletologin', {
                            detail: result['TimeDifference']
                        });
                        this.dispatchEvent(unableToLoginEvent);
                    } else {
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                name: 'Forgot_Password'
                            }
                        });
                    }
                })
                .catch((error) => {
                    console.log(error);
                    this.error = error;
                });
        } else {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Forgot_Password'
                }
            });
        }
    }
}
