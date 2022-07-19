import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import unableToLogin from '@salesforce/label/c.Lofi_Unable_to_Login';
import forgotPassword from '@salesforce/label/c.Lofi_Forgot_Password';
import PP_Desktoplogos from '@salesforce/resourceUrl/PP_DesktopLogos';
import LOFI_LOGIN_ICONS from '@salesforce/resourceUrl/Lofi_Login_Icons';
import userName from '@salesforce/label/c.PG_AS_F_Username';
import password from '@salesforce/label/c.PG_Login_F_Password';
import login from '@salesforce/label/c.PG_Login_Title';
import communityLogin from '@salesforce/apex/RRLoginRemote.communityLogin';
import enterUsernameMsg from '@salesforce/label/c.Lofi_Enter_Username';
import enterPasswordMsg from '@salesforce/label/c.Lofi_Enter_Password';

export default class PpLoginForm extends NavigationMixin(LightningElement) {
    @track inError;
    @track errorMsg;
    @track isRTL;
    isLockOut = false;
    timeLeft = 900000;
    spinner;

    eyeHidden = PP_Desktoplogos + '/eye-hidden.svg';
    wave = PP_Desktoplogos + '/wave_desktop.png';
    exclamation = LOFI_LOGIN_ICONS + '/status-exclamation.svg';

    label = {
        unableToLogin,
        forgotPassword,
        userName,
        password,
        enterUsernameMsg,
        enterPasswordMsg,
        login
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
                    console.log(error);
                    this.error = error;
                });
        }
    }

    handleuserNameChange(event) {
        console.log(event.target.value);
        if (event.target.value !== '') {
            this.template.querySelector('[data-id="userName"]').value = event.target.value;
        }
    }

    handlepasswordChange(event) {
        console.log(event.target.value);
        if (event.target.value !== '') {
            this.template.querySelector('[data-id="password"]').value = event.target.value;
        }
    }

    handleShowTimer(event) {
        this.timeLeft = event.detail;
        this.isLockOut = true;
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
        console.log('User Name : ' + userName.value + '\n Password : ' + password.value);
        const allValid = [...this.template.querySelectorAll('lightning-input')].reduce(
            (validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            },
            true
        );
        console.log('Test allValid : ' + allValid);
        if (allValid) {
            console.log('Inside allValid');
            console.log(decodeURIComponent(this.currentPageReference.state.startURL));
            this.spinner = this.template.querySelector('c-web-spinner');
            this.spinner.show();
            communityLogin({
                userName: userName.value,
                password: password.value,
                startUrl: decodeURIComponent(this.currentPageReference.state.startURL)
            })
                .then((result) => {
                    console.log('Result : ' + result);
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
}
