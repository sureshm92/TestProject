import { LightningElement, track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import forgotPassword from '@salesforce/apex/LightningForgotPasswordController.forgotPasswordCommunity';
import ppEnterAssociatedEmail from '@salesforce/label/c.PP_Enter_Associated_Email';
import forgotLabel from '@salesforce/label/c.PP_ForgotPwd';
import email from '@salesforce/label/c.Email';
import emailSentToUser from '@salesforce/label/c.PP_Email_Sent_To_User';
import emailSent from '@salesforce/label/c.PP_Email_Sent';
import backToLogin from '@salesforce/label/c.PP_BTN_Back_To_Log_in';
import sendEmailLabel from '@salesforce/label/c.PP_SendBtn';
import rtlLanguageLabel from '@salesforce/label/c.RTL_Languages';
import footer1 from '@salesforce/label/c.PP_Forgot_Password_Footer1';
import footer2 from '@salesforce/label/c.PP_Forgot_Password_Footer2';
import unableToLogin6 from '@salesforce/label/c.PG_Unable_To_Login_L6';
import backButton from '@salesforce/label/c.BTN_Back';
import PP_Email_Error from '@salesforce/label/c.PP_Email_Error';

export default class PpForgotPassword extends NavigationMixin(LightningElement) {
    @track showEmailSent = false;
    @track isRTL;
    @track usrnameval;
    @track checkEmailUrl = './CheckPasswordResetEmail';
    @track emailMessage;
    @track errorMessage;
    @track showError = false;
    labels = {
        ppEnterAssociatedEmail,
        forgotLabel,
        email,
        emailSentToUser,
        emailSent,
        backToLogin,
        rtlLanguageLabel,
        sendEmailLabel,
        footer1,
        footer2,
        unableToLogin6,
        backButton,
        PP_Email_Error
    };
    @track btnClassName = 'primaryBtn slds-button btn-sendEmail';
    _patten = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

    connectedCallback() {
        let language = communityService.getUrlParameter('language');
        let label = this.labels;
        this.isRTL = label.rtlLanguageLabel.includes(language);
        if (!this.usrnameval) {
            this.usrnameval = '';
        }
    }

    get inputClass() {
        return this.showError
            ? 'slds-input input-field-container-error'
            : 'slds-input input-field-container';
    }
    get btnClass() {
        return this.btnClassName;
    }

    handleForgotPassword() {
        let spinner = this.template.querySelector('c-web-spinner');
        spinner.show();
        this.usrnameval = this.template.querySelector('input').value;
        if (!this.usrnameval || !this.usrnameval.match(this._patten)) {
            this.handleError(this.labels.PP_Email_Error);
            spinner.hide();
            return;
        }
        forgotPassword({ username: this.usrnameval, checkEmailUrl: this.checkEmailUrl })
            .then((result) => {
                if (result.includes('./CheckPasswordResetEmail')) {
                    this.showEmailSent = true;
                    if (this.showEmailSent == true) {
                        this.emailMessage = this.labels.emailsentsubtitle.replace(
                            '##emailhandle',
                            this.usrnameval
                        );
                    }
                } else if (result) {
                    let returnValue = JSON.parse(result);
                    if (returnValue['timeDifference']) {
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                name: 'Login_PP__c'
                            },
                            state: {
                                c__username: this.usrnameval
                            }
                        });
                    }
                    this.handleError(returnValue['invalidEmail']);
                }
                spinner.hide();
            })
            .catch((error) => {
                this.error = error;
                spinner.hide();
            });
    }
    onKeyUp(event) {
        this.usrnameval = event.target.value;
        this.btnClassName = 'primaryBtn slds-button btn-sendEmail';
        this.showError = false;
        this.template.querySelector('.btn-sendEmail').disabled = false;
        //checks for "enter" key
        if (event.which === 13) {
            this.handleForgotPassword();
        }
    }

    handleKeyDown(event) {
        if (event.key === 'Enter') {
            event.preventDefault();
            this.goBack();
        }
    }

    goBack() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Login_PP__c'
            }
        });
    }

    handleError(message) {
        this.errorMessage = message;
        this.showError = true;
        this.btnClassName = 'primaryBtn slds-button btn-sendEmail btn-disable';
        this.template.querySelector('.btn-sendEmail').disabled = true;
    }
}