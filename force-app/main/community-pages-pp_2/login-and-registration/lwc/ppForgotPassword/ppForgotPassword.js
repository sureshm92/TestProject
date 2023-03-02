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
import communityResource from '@salesforce/resourceUrl/rr_community_js';
import communityPPTheme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';
import rtlLanguageLabel from '@salesforce/label/c.RTL_Languages';
import footer1 from '@salesforce/label/c.PP_Forgot_Password_Footer1';
import footer2 from '@salesforce/label/c.PP_Forgot_Password_Footer2';
import unableToLogin6 from '@salesforce/label/c.PG_Unable_To_Login_L6';
import backButton from '@salesforce/label/c.BTN_Back';

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
        backButton
    };
    @track btnClassName = 'slds-button btn-sendEmail';

    connectedCallback() {
        Promise.all([loadScript(this, communityResource)])
            .then(() => {
                console.log('RR_COMMUNITY_JS loaded');
                let language = communityService.getUrlParameter('language');
                let label = this.labels;
                this.isRTL = label.rtlLanguageLabel.includes(language);
                console.log('this.isRTL' + this.isRTL);
            })
            .catch((error) => {
                console.log(error.body.message);
            });
        if (!this.usrnameval) {
            this.usrnameval = '';
        }
    }

    renderedCallback() {
        Promise.all([loadStyle(this, communityPPTheme)])
            .then(() => {
                console.log('Files loaded');
            })
            .catch((error) => {
                console.log(error.body.message);
            });
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
                                name: 'Login'
                            },
                            state: {
                                c__username: this.usrnameval
                            }
                        });
                    }
                    this.errorMessage = returnValue['invalidEmail'];
                    this.showError = true;
                    this.btnClassName = 'slds-button btn-sendEmail btn-disable';
                }
                spinner.hide();
            })
            .catch((error) => {
                this.error = error;
                spinner.hide();
            });
    }
    onKeyUp(event) {
        if (event.target.value !== '') {
            this.usrnameval = event.target.value;
        }
        this.btnClassName = 'slds-button btn-sendEmail';
        this.showError = false;
        //checks for "enter" key
        if (event.which === 13) {
            this.handleForgotPassword();
        }
    }

    goBack() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Login'
            }
        });
    }
}