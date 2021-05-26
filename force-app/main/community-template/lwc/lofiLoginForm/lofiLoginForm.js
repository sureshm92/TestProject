import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import LOFI_LOGIN_ICONS from '@salesforce/resourceUrl/Lofi_Login_Icons';
import unableToLogin from '@salesforce/label/c.PG_Unable_To_Login';
import forgotPassword from '@salesforce/label/c.PG_Login_L_Forgot_your_password';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import isUserPasswordLocked from '@salesforce/apex/RRLoginRemote.isUserPasswordLocked';
import communityLogin from '@salesforce/apex/RRLoginRemote.communityLogin';

export default class LofiLoginForm extends NavigationMixin(LightningElement) {
    @api rtlStyle;
    @api floatInput;
    @track isMobileApp;
    @track isRTL;

    passwordInputType = 'password';
    isEyeHidden = true;

    eyeIcon = LOFI_LOGIN_ICONS + '/eye-icon.svg';
    eyeHidden = LOFI_LOGIN_ICONS + '/eye-hidden.svg';
    initialized = false;
    spinner;
    label = {
        unableToLogin,
        forgotPassword,
        rtlLanguages
    };

    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                console.log('RR_COMMUNITY_JS loaded');
                let language = communityService.getUrlParameter('language');
                let label = this.label;
                this.isRTL = label.rtlLanguages.includes(language);
                this.isMobileApp = communityService.isMobileSDK();
                if (this.isRTL) {
                    this.rtlStyle = 'direction: rtl';
                    this.floatInput = 'float: right';
                    console.log('RTL applied: ' + this.rtlStyle);
                } else {
                    this.floatInput = 'float: left';
                }
                this.initialized = true;
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading RR_COMMUNITY_JS',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }

    changeImgSrc() {
        let isEyeHidden = this.isEyeHidden;
        if (isEyeHidden) {
            this.template.querySelector('img').src = this.eyeIcon;
            this.template.querySelector('img').style = 'padding-top: 9px;';
            this.passwordInputType = 'text';
        } else {
            this.template.querySelector('img').src = this.eyeHidden;
            this.template.querySelector('img').style = '';
            this.passwordInputType = 'password';
        }
        this.isEyeHidden = !isEyeHidden;
    }
    handleLogin() {
        let userName = this.template.querySelector('lightning-input[data-id=userName]').value;
        let password = this.template.querySelector('lightning-input[data-id=password]').value;
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner.show();
        communityLogin({ userName: userName, password: password, startUrl: '' })
            .then((result) => {
                //Key: startUrl, lockoutError, wrongPasswordError, exception
                this.spinner.hide();
                console.log(JSON.stringify(result));
                if (result.startUrl) {
                    //re-direct to homepage
                    location.href = result.startUrl;
                } else if (result.lockoutError) {
                    //handle lockout error
                    alert(result.lockoutError);
                } else if (result.wrongPasswordError) {
                    //handle wrong password error
                    alert(result.wrongPasswordError);
                } else if (result.exception) {
                    //handle system exception
                    alert(result.exception);
                } else {
                    //handle unknown error
                    alert('Unknown error');
                }
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
                this.error = error;
                this.spinner.hide();
            });
    }
    handleForgotPassword() {
        let userName = this.template.querySelector('lightning-input[data-id=userName]').value;
        if (userName) {
            isUserPasswordLocked({ userName: userName })
                .then((result) => {
                    console.log('##result: ' + result);
                    if (result) {
                        alert('Redirect to lockout screen');
                        return;
                    }
                })
                .catch((error) => {
                    this.error = error;
                });
        }
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Forgot_Password'
            }
        });
    }
    handleUnableToLogin() {}
    onKeyUp(event) {
        if (event.which == 13) {
            this.handleLogin();
        }
    }
}
