import { LightningElement, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
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
import rtlLanguageLabel from '@salesforce/label/c.RTL_Languages';

export default class PpForgotPassword extends NavigationMixin(LightningElement) {
    @track showEmailSent = false;
    @track isRTL;
    @track usrnameval;
    @track checkEmailUrl = './CheckPasswordResetEmail';
    @track emailMessage;
    @track errorMessage;
    labels = {
        ppEnterAssociatedEmail,
        forgotLabel,
        email,
        emailSentToUser,
        emailSent,
        backToLogin,
        rtlLanguageLabel,
        sendEmailLabel
    };

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

    get rtlStyleClass() {}

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
                }
                spinner.hide();
            })
            .catch((error) => {
                this.error = error;
                spinner.hide();
            });
    }
    onKeyUp(event) {
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
