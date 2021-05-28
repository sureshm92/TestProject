import { LightningElement, api, track } from 'lwc';
import usrnameLabel from '@salesforce/label/c.PG_Login_F_User_Name';
import forgotLabel from '@salesforce/label/c.PP_ForgotPwd';
import sendLabel from '@salesforce/label/c.BTN_Send';
import usrPlaceholder from '@salesforce/label/c.PP_USrPlaceholder';
import cancelLabel from '@salesforce/label/c.BTN_Cancel';
import backtologin from '@salesforce/label/c.Link_Back_To_Login';
import emailsent from '@salesforce/label/c.PG_Email_Sent_Title';
import emailsentsubtitle from '@salesforce/label/c.PP_EmailSent';
import rtlLanguageLabel from '@salesforce/label/c.RTL_Languages';
import forgotPassword from '@salesforce/apex/LightningForgotPasswordController.forgotPassword';
import setExperienceId from '@salesforce/apex/LightningForgotPasswordController.setExperienceId';
import communityResource from '@salesforce/resourceUrl/rr_community_js';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
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
        usrPlaceholder
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
    @track usrnameval;
    @track rtlCss = '';
    @track emailMessage;

    connectedCallback() {
        Promise.all([loadScript(this, communityResource)])
            .then(() => {
                console.log('Files loaded.');
            })
            .catch((error) => {
                console.log(error.body.message);
            });
        if (!this.usrnameval) {
            this.usrnameval = '';
            this.userPlaceholder = ' ' + this.labels.usrPlaceholder + ' ';
        }
        this.initialize();
    }

    get rtlStyleClass() {
        if (this.isRTL) {
            this.rtlCss = 'forgotpwd-rtl';
        }
        return this.rtlCss;
    }

    handleForgotPassword() {
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
                    this.errorMessage = result;
                    this.showError = true;
                }
            })
            .catch((error) => {
                this.error = error;
            });
    }

    onKeyUp() {
        //checks for "enter" key
        if (event.detail('keyCode') === 13) {
            this.handleForgotPassword();
        }
    }

    initialize() {
        var rtl_language = this.labels.rtlLanguageLabel;
        const forgotPasswordurl = window.location.search;
        const urlParams = new URLSearchParams(forgotPasswordurl);
        var paramLanguage = urlParams.get('language');
        console.log('paramLanguage-->' + paramLanguage);
        this.isRTL = rtl_language.includes(paramLanguage);
        var community = window.location.pathname.startsWith('/gsk/')
            ? '/gsk/s/login'
            : window.location.pathname.startsWith('/janssen/')
            ? '/janssen/s/login'
            : '/s/login';
        this.backPage = community;
    }

    goBack() {
        var community = window.location.pathname.startsWith('/gsk/')
            ? '/gsk/s/login'
            : window.location.pathname.startsWith('/janssen/')
            ? '/janssen/s/login'
            : '/s/login';
        window.location.href = community;
    }
}
