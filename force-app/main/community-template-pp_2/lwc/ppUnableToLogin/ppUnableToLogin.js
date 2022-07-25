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
import isUserPasswordLocked from '@salesforce/apex/RRLoginRemote.isUserPasswordLocked';

export default class PpUnableToLogin extends NavigationMixin(LightningElement) {
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
        loginLinkForgot
    };
    @api isRTLLanguage = false;
    @api userId;

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

    closeModal() {
        let closemodal = false;
        const selectedEvent = new CustomEvent('modalclose', {
            detail: closemodal
        });
        this.dispatchEvent(selectedEvent);
    }
}
