import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import LOFI_LOGIN_ICONS from '@salesforce/resourceUrl/Lofi_Login_Icons';
import unableToLogin from '@salesforce/label/c.Lofi_Unable_to_Login';
import forgotPassword from '@salesforce/label/c.Lofi_Forgot_Password';
import userName from '@salesforce/label/c.PG_AS_F_Username';
import password from '@salesforce/label/c.PG_Login_F_Password';
import login from '@salesforce/label/c.PG_Login_Title';
import usrPlaceholder from '@salesforce/label/c.PP_USrPlaceholder';
import pwdPlaceholder from '@salesforce/label/c.Lofi_Forgot_Pwd_Placeholder';
import enterUsernameMsg from '@salesforce/label/c.Lofi_Enter_Username';
import enterPasswordMsg from '@salesforce/label/c.Lofi_Enter_Password';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import isUserPasswordLocked from '@salesforce/apex/RRLoginRemote.isUserPasswordLocked';
import communityLogin from '@salesforce/apex/RRLoginRemote.communityLogin';

export default class LofiLoginForm extends NavigationMixin(LightningElement) {
    @api rtlStyle;
    @api floatInput;
    @api addIconMargin;
    @track isMobileApp;
    @track isRTL;
    @track inError;
    @track errorMsg;
    @api applyPadding;

    lockedOutUsrName;
    timeLeft = 900000;
    isLockOut = false;
    currentPageReference;

    passwordInputType = 'password';
    isEyeHidden = true;

    eyeIcon = LOFI_LOGIN_ICONS + '/eye-icon.svg';
    eyeHidden = LOFI_LOGIN_ICONS + '/eye-hidden.svg';
    exclamation = LOFI_LOGIN_ICONS + '/status-exclamation.svg';

    initialized = false;
    spinner;
    label = {
        unableToLogin,
        forgotPassword,
        rtlLanguages,
        userName,
        password,
        login,
        usrPlaceholder,
        pwdPlaceholder,
        enterUsernameMsg,
        enterPasswordMsg
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
                    this.rtlStyle = 'direction: rtl;';
                    this.floatInput = 'float: right;';
                    this.addIconMargin = 'margin-right: -2.2em;';
                    this.applyPadding = 'padding-right: 3.25em';
                    console.log(
                        'RTL inline styles applied: ' +
                            this.rtlStyle +
                            this.floatInput +
                            this.addIconMargin
                    );
                } else {
                    this.floatInput = 'float: left;';
                    this.addIconMargin = 'margin-left: -2.2em;';
                    this.applyPadding = 'padding-left: 3.25em';
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
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        let timeDiff = this.currentPageReference.state.c__timeDifference;

        if (timeDiff) {
            this.timeLeft = Number(timeDiff);
            this.isLockOut = true;
            this.lockedOutUsrName = this.currentPageReference.state.c__username;
        }
    }
    onInputChange(event) {
        if (event.target.value !== '') {
            this.template
                .querySelector('lightning-input[data-id="' + event.target.label + '"]')
                .setCustomValidity('');
        }
    }
    changeImgSrc() {
        let isEyeHidden = this.isEyeHidden;
        if (isEyeHidden) {
            this.template.querySelector('img').src = this.eyeIcon;
            //this.template.querySelector('img').style = 'padding-top: 9px;';
            this.addIconMargin = this.isRTL
                ? 'padding-top: 9px; margin-right: -2.2em;'
                : 'padding-top: 9px; margin-left: -2.2em;';
            this.passwordInputType = 'text';
        } else {
            this.template.querySelector('img').src = this.eyeHidden;
            //this.template.querySelector('img').style = '';
            this.addIconMargin = this.isRTL ? 'margin-right: -2.2em;' : 'margin-left: -2.2em;';
            this.passwordInputType = 'password';
        }
        this.isEyeHidden = !isEyeHidden;
    }
    handleLogin() {
        let userName = this.template.querySelector('lightning-input[data-id=userName]');
        this.lockedOutUsrName = userName.value;
        let password = this.template.querySelector('lightning-input[data-id=password]');
        if (userName.value !== '') {
            userName.setCustomValidity('');
        } else {
            userName.setCustomValidity(this.label.enterUsernameMsg);
        }
        if (password.value !== '') {
            password.setCustomValidity('');
        } else {
            password.setCustomValidity(this.label.enterPasswordMsg);
        }
        //https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Spread_syntax
        const allValid = [...this.template.querySelectorAll('lightning-input')].reduce(
            (validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            },
            true
        );
        if (allValid) {
            this.spinner = this.template.querySelector('c-web-spinner');
            this.spinner.show();
            communityLogin({ userName: userName.value, password: password.value, startUrl: '' })
                .then((result) => {
                    //Key: startUrl, lockoutError, wrongPasswordError, exception
                    this.spinner.hide();
                    console.log(JSON.stringify(result));
                    if (result.startUrl) {
                        //re-direct to homepage
                        location.href = result.startUrl;
                    } else if (result.lockoutError) {
                        //handle lockout error
                        if (result.TimeDifference) {
                            this.timeLeft = Number(result['TimeDifference']);
                            this.isLockOut = true;
                        }
                    } else if (result.wrongPasswordError) {
                        //handle wrong password error
                        this.inError = true;
                        this.errorMsg = result.wrongPasswordError;
                    } else if (result.exception) {
                        //handle system exception
                        this.inError = true;
                        this.errorMsg = result.exception;
                    } else {
                        //handle unknown error
                        this.inError = true;
                        this.errorMsg = 'Unknown error!';
                    }
                })
                .catch((error) => {
                    console.log(JSON.stringify(error));
                    this.error = error;
                    this.spinner.hide();
                });
        }
    }
    handleForgotPassword() {
        let userName = this.template.querySelector('lightning-input[data-id=userName]').value;
        this.lockedOutUsrName = userName;

        if (userName) {
            isUserPasswordLocked({ userName: userName })
                .then((result) => {
                    console.log('##result: ' + JSON.stringify(result));
                    if (result.TimeDifference) {
                        this.timeLeft = result['TimeDifference'];
                        this.isLockOut = true;
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
    handleShowTimer(event) {
        this.timeLeft = event.detail;
        this.isLockOut = true;
    }

    handleUnableToLogin() {
        let userName = this.isLockOut
            ? this.lockedOutUsrName
            : this.template.querySelector('lightning-input[data-id=userName]').value;

        this.template.querySelector('c-unable-to-login').show(userName);
    }
    handleUnlock(event) {
        this.isLockOut = false;
        this.inError = false;
    }
    onKeyUp(event) {
        if (event.which == 13) {
            this.handleLogin();
        }
    }
}
