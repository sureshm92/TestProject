import { LightningElement, track, wire } from 'lwc';
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
import showEyeTooltip from '@salesforce/label/c.Login_Form_Hide';
import hideEyeTooltip from '@salesforce/label/c.Login_Form_Show';
import isUserPasswordLocked from '@salesforce/apex/RRLoginRemote.isUserPasswordLocked';
import communityLogin from '@salesforce/apex/RRLoginRemote.communityLogin';

export default class LofiLoginForm extends NavigationMixin(LightningElement) {
    @track isMobileApp;
    @track isRTL;
    @track inError;
    @track errorMsg;
    @track addIconMargin;
    @track isMobileScreen;

    rtlStyle;
    floatInput;
    applyPaddingLogin;
    applyPaddingPassword;
    errorIconPosition;
    erroContainerPosition;
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
    tooltipMsg;

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
        enterPasswordMsg,
        showEyeTooltip,
        hideEyeTooltip
    };

    connectedCallback() {
        window.addEventListener('resize', this.adjustWindowHeight.bind(this));
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                console.log('RR_COMMUNITY_JS loaded');
                let language = communityService.getUrlParameter('language');
                let label = this.label;
                this.tooltipMsg = label.hideEyeTooltip;
                this.isRTL = label.rtlLanguages.includes(language);
                this.isMobileApp = communityService.isMobileSDK();
                this.isMobileScreen = communityService.isMobileOS();
                if (this.isRTL) {
                    this.rtlStyle = '/* @noflip */ direction: rtl;';
                    this.floatInput = 'float: right;';
                    this.addIconMargin = 'margin-right: -2.2em;';
                    this.errorIconPosition = 'margin-right: -2.5em';
                    this.erroContainerPosition =
                        this.isMobileScreen || this.isMobileSDK ? '' : 'margin-right: 0.5em';
                    console.log(
                        'RTL inline styles applied: ' +
                            this.rtlStyle +
                            this.floatInput +
                            this.addIconMargin
                    );
                } else {
                    this.floatInput = 'float: left;';
                    this.addIconMargin = 'margin-left: -2.2em;';
                    this.errorIconPosition = 'margin-left: -2.5em';
                    this.erroContainerPosition =
                        this.isMobileScreen || this.isMobileSDK ? '' : 'margin-left: 0.5em';
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

    renderedCallback() {
        this.adjustWindowHeight();
    }

    adjustWindowHeight() {
        if (this.inError) {
            switch (window.innerHeight) {
                case 609:
                case 577:
                    document.querySelectorAll(
                        '.slds-col.slds-large-size_4-of-7'
                    )[0].style.maxHeight = '115vh';
                    document.querySelectorAll('.slds-col.slds-large-size_3-of-7')[0].style.height =
                        '115vh';
                    break;
                case 554:
                case 525:
                    document.querySelectorAll(
                        '.slds-col.slds-large-size_4-of-7'
                    )[0].style.maxHeight = '130vh';
                    document.querySelectorAll('.slds-col.slds-large-size_3-of-7')[0].style.height =
                        '130vh';
                    break;
                case 487:
                case 462:
                    document.querySelectorAll(
                        '.slds-col.slds-large-size_4-of-7'
                    )[0].style.maxHeight = '150vh';
                    document.querySelectorAll('.slds-col.slds-large-size_3-of-7')[0].style.height =
                        '145vh';
                    document.querySelectorAll(
                        '.slds-col.slds-large-size_4-of-7 img'
                    )[0].style.marginTop = '-25px';
                    break;
            }
        }
    }

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        if (this.currentPageReference.state.c__username) {
            isUserPasswordLocked({ userName: this.currentPageReference.state.c__username })
                .then((result) => {
                    if (result.TimeDifference) {
                        this.timeLeft = Number(result['TimeDifference']);
                        this.isLockOut = true;
                        this.lockedOutUsrName = this.currentPageReference.state.c__username;
                    }
                })
                .catch((error) => {
                    console.log(error);
                    this.error = error;
                });
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
            this.tooltipMsg = this.label.showEyeTooltip;
            this.addIconMargin = this.isRTL
                ? 'padding-top: 9px; margin-right: -2.2em;'
                : 'padding-top: 9px; margin-left: -2.2em;';
            this.passwordInputType = 'text';
        } else {
            this.template.querySelector('img').src = this.eyeHidden;
            this.tooltipMsg = this.label.hideEyeTooltip;
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
            communityLogin({
                userName: userName.value,
                password: password.value,
                startUrl: decodeURIComponent(this.currentPageReference.state.startURL)
            })
                .then((result) => {
                    //Key: startUrl, lockoutError, wrongPasswordError, exception
                    this.spinner.hide();
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
        sessionStorage.setItem('CookiesonLoginPage', 'Accepted');
        let userName = this.template.querySelector('lightning-input[data-id=userName]').value;
        this.lockedOutUsrName = userName;

        if (userName) {
            isUserPasswordLocked({ userName: userName })
                .then((result) => {
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
    get isMobile() {
        return this.isMobileSDK || this.isMobileScreen;
    }
}
