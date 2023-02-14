import { LightningElement, api, track } from 'lwc';
import usrnameLabel from '@salesforce/label/c.PG_AS_F_Username';
import forgotLabel from '@salesforce/label/c.PP_ForgotPwd';
import sendLabel from '@salesforce/label/c.BTN_Send';
import usrPlaceholder from '@salesforce/label/c.PP_USrPlaceholder';
import cancelLabel from '@salesforce/label/c.BTN_Cancel';
import backtologin from '@salesforce/label/c.Link_Back_To_Login';
import emailsent from '@salesforce/label/c.PG_Email_Sent_Title';
import emailsentsubtitle from '@salesforce/label/c.PP_EmailSent';
import sendEmailLabel from '@salesforce/label/c.PP_SendBtn';
import rtlLanguageLabel from '@salesforce/label/c.RTL_Languages';
import forgotPassword from '@salesforce/apex/LightningForgotPasswordController.forgotPasswordCommunity';
import communityResource from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';

export default class Forgotpwd extends NavigationMixin(LightningElement) {
    @api recordId;
    labels = {
        usrnameLabel,
        sendLabel,
        cancelLabel,
        backtologin,
        emailsent,
        emailsentsubtitle,
        rtlLanguageLabel,
        forgotLabel,
        usrPlaceholder,
        sendEmailLabel
    };
    @track showEmailSent = false;
    @track usernameLabel = 'Username';
    @track submitButtonLabel = 'Send Password Reset Email';
    @track showError = false;
    @track errorMessage;
    @track checkEmailUrl = './CheckPasswordResetEmail';
    @api expid;
    @track backPage;
    @track isRTL;
    @track isMobileApp;
    @track usrnameval;
    @track rtlCss = '';
    @track emailMessage;

    connectedCallback() {
        Promise.all([loadScript(this, communityResource)])
            .then(() => {
                console.log('RR_COMMUNITY_JS loaded');
                let language = communityService.getUrlParameter('language');
                let label = this.labels;
                this.isRTL = label.rtlLanguageLabel.includes(language);
                this.isMobileApp = communityService.isMobileSDK();
                console.log('this.isRTL' + this.isRTL);
            })
            .catch((error) => {
                console.log(error.body.message);
            });
        if (!this.usrnameval) {
            this.usrnameval = '';
            this.userPlaceholder = this.labels.usrPlaceholder;
        }
    }

    get rtlStyleClass() {
        if (this.isRTL) {
            this.rtlCss = 'forgotpwd-rtl';
        }
        return this.rtlCss;
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
        sessionStorage.setItem('CookiesonLoginPage', 'Accepted');
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Login'
            }
        });
    }
}
