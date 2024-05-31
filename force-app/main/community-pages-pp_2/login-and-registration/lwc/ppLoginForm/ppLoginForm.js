import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import unableToLogin from '@salesforce/label/c.PG_Unable_To_Login';
import forgotPassword from '@salesforce/label/c.Lofi_Forgot_Password';
import PP_Desktoplogos from '@salesforce/resourceUrl/PP_DesktopLogos';
import LOFI_LOGIN_ICONS from '@salesforce/resourceUrl/Lofi_Login_Icons';
import userName from '@salesforce/label/c.PG_AS_F_Username';
import password from '@salesforce/label/c.PG_Login_F_Password';
import login from '@salesforce/label/c.BTN_Log_In';
import communityLogin from '@salesforce/apex/RRLoginRemote.communityLogin';
import enterUsernameMsg from '@salesforce/label/c.Lofi_Enter_Username';
import enterPasswordMsg from '@salesforce/label/c.Lofi_Enter_Password';
import isUserPasswordLocked from '@salesforce/apex/RRLoginRemote.isUserPasswordLocked';
import communityPPTheme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';
import PP_Login_Form_Show from '@salesforce/label/c.PP_Login_Form_Show';
import PP_Login_Form_Hide from '@salesforce/label/c.PP_Login_Form_Hide';
import PP_For_Participants_and_Caregivers from '@salesforce/label/c.PP_For_Participants_and_Caregivers';
import PP_Connecting_professionals from '@salesforce/label/c.PP_Connecting_professionals';

export default class PpLoginForm extends NavigationMixin(LightningElement) {
    @track inError;
    @track errorMsg;
    @track isRTL;
    errorIconPosition;
    isLockOut = false;
    timeLeft = 900000;
    spinner;
    lockedOutUsrName;
    showPopup = false;
    @track userNam;
    @track inputError = false;
    btnclassName = 'slds-input input-field-container';

    passwordInputType = 'password';
    isEyeHidden = true;

    eyeHidden = PP_Desktoplogos + '/eye-hidden.svg';
    wave = PP_Desktoplogos + '/wave_desktop.png';
    exclamation = LOFI_LOGIN_ICONS + '/status-exclamation.svg';
    eyeIcon = LOFI_LOGIN_ICONS + '/eye-icon.svg';

    label = {
        unableToLogin,
        forgotPassword,
        userName,
        password,
        enterUsernameMsg,
        enterPasswordMsg,
        login,
        PP_Login_Form_Hide,
        PP_Login_Form_Show,
        PP_For_Participants_and_Caregivers,
        PP_Connecting_professionals
    };

    currentPageReference;
    erroContainerPosition = 'margin-left: 13px';
    errorIconPosition = 'margin-left: 8px';

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
                    this.error = error;
                });
        }
    }
    connectedCallback() {
        let rvalue = sessionStorage.getItem('myKey');
         console.log('session paramValue- '+this.currentPageReference.state.lg);
         if(rvalue != this.currentPageReference.state.lg){
             console.log('not   matching');
             this[NavigationMixin.Navigate]({
                 type: 'comm__namedPage',
                 attributes: {
                     name: 'Login'
                 }
                 });
         }

    }


    handleuserNameChange(event) {
        if (event.target.value !== '') {
            this.template.querySelector('[data-id="userName"]').value = event.target.value;
        }
        if (event.which == 13) {
            this.handleLogin();
        }
        this.btnclassName = 'slds-input input-field-container';
    }

    handlepasswordChange(event) {
        if (event.target.value !== '') {
            this.template.querySelector('[data-id="password"]').value = event.target.value;
        }
        if (event.which == 13) {
            this.handleLogin();
        }
        this.btnclassName = 'slds-input input-field-container';
    }

    handleUnlock(event) {
        this.isLockOut = false;
        this.inError = false;
    }

    handleUnableToLogin() {
        let userName = this.isLockOut
            ? this.lockedOutUsrName
            : this.template.querySelector('lightning-input[data-id=userName]').value;

        this.template.querySelector('c-unable-to-login').show(userName);
    }

    handleLogin() {
        let userName = this.template.querySelector('input[data-id=userName]');
        this.lockedOutUsrName = userName.value;
        let password = this.template.querySelector('input[data-id=password]');
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
                        this.inputError = true;
                        this.errorMsg = result.wrongPasswordError;
                        this.btnclassName = 'slds-input input-field-container-error';
                    } else if (result.exception) {
                        //handle system exception
                        this.inError = true;
                        this.errorMsg = result.exception;
                        this.inputError = true;
                        this.btnclassName = 'slds-input input-field-container-error';
                    } else {
                        //handle unknown error
                        this.inError = true;
                        this.errorMsg = 'Unknown error!';
                    }
                })
                .catch((error) => {
                    this.error = error;
                    this.spinner.hide();
                });
        }
    }
    handleForgotPassword() {
        let userName = this.template.querySelector('input[data-id=userName]').value;
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
                                name: 'Forgot_Login_Password__c'
                            }
                        });
                    }
                })
                .catch((error) => {
                    this.error = error;
                });
        } else {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Forgot_Login_Password__c'
                }
            });
        }
    }
    handleUnableToLogin() {
        this.userNam = this.isLockOut
            ? this.lockedOutUsrName
            : this.template.querySelector('input[data-id=userName]').value;
        this.showPopup = true;
    }
    handleModalClose(event) {
        const showHideModal = event.detail.showpopup;
        const timeLeft = event.detail.timeleft;
        if (timeLeft) {
            this.timeLeft = timeLeft;
            this.isLockOut = true;
            this.showPopup = showHideModal;
        } else {
            this.showPopup = showHideModal;
        }
    }
    get className() {
        return this.btnclassName;
    }

    get PasswordEyeIconTitle() {
        return this.isEyeHidden ? this.label.PP_Login_Form_Show : this.label.PP_Login_Form_Hide;
    }

    changeImgSrc() {
        let isEyeHidden = this.isEyeHidden;
        if (isEyeHidden) {
            this.template.querySelector('.eye-icon img').src = this.eyeIcon;
            this.tooltipMsg = this.label.showEyeTooltip;
            this.addIconMargin = this.isRTL
                ? 'padding-top: 9px; margin-right: -2.2em;'
                : 'padding-top: 9px; margin-left: -2.2em;';
            this.passwordInputType = 'text';
        } else {
            this.template.querySelector('.eye-icon img').src = this.eyeHidden;
            this.tooltipMsg = this.label.hideEyeTooltip;
            this.addIconMargin = this.isRTL ? 'margin-right: -2.2em;' : 'margin-left: -2.2em;';
            this.passwordInputType = 'password';
        }
        this.isEyeHidden = !isEyeHidden;
    }
}