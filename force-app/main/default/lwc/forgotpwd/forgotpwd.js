import { LightningElement, api, track } from 'lwc';
import usrnameLabel from '@salesforce/label/c.PG_Login_F_User_Name';
import sendLabel from '@salesforce/label/c.BTN_Send';
import cancelLabel from '@salesforce/label/c.BTN_Cancel';
import backtologin from '@salesforce/label/c.Link_Back_To_Login';
import emailsent from '@salesforce/label/c.PG_Email_Sent_Title';
import emailsentsubtitle from '@salesforce/label/c.PG_Email_Sent_Sub_Title';
import forgotPassword from '@salesforce/apex/LightningForgotPasswordController.forgotPassword';
import setExperienceId from '@salesforce/apex/LightningForgotPasswordController.setExperienceId';
import communityResource from '@salesforce/resourceUrl/rr_community_js';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { createMessageContext, releaseMessageContext, publish } from 'lightning/messageService';
import { NavigationMixin } from 'lightning/navigation';
import MESSAGECHANNEL from '@salesforce/messageChannel/UsernameMessageChannel__c';

export default class Forgotpwd extends NavigationMixin(LightningElement) {
    @api recordId;
    labels = {
        usrnameLabel,
        sendLabel,
        cancelLabel,
        backtologin,
        emailsent,
        emailsentsubtitle
    };
    @track showEmailSent = false;
    @track usernameLabel = 'Username';
    @track submitButtonLabel = 'Send Password Reset Email';
    @track showError = false;
    @track errorMessage;
    @track checkEmailUrl = './CheckPasswordResetEmail';
    //@api expid;
    @track backPage;
    @track isRTL;
    @track usrnameval;

    /*qsToEventMap = {
        expid: 'e.c:setExpId'
    }*/

    context = createMessageContext();

    publishMC() {
        const message = {
            recordId: this.usrnameval
        };
        publish(this.context, MESSAGECHANNEL, message);
    }

    disconnectedCallback() {
        releaseMessageContext(this.context);
    }

    connectedCallback() {
        alert(this.expid);
        Promise.all([loadScript(this, communityResource)])
            .then(() => {
                console.log('Files loaded.');
            })
            .catch((error) => {
                console.log(error.body.message);
            });
        this.initialize();
    }

    handleForgotPassword() {
        alert('inside handle password forgot--->');
        //var username = this.usrnameval;
        //var checkEmailUrl = this.checkEmailUrl;
        this.usrnameval = this.template.querySelector('lightning-input').value;
        console.log('usrnameval-->' + this.usrnameval);
        console.log('checkemail--->' + this.checkEmailUrl);
        forgotPassword({ username: this.usrnameval, checkEmailUrl: this.checkEmailUrl })
            .then((result) => {
                console.log('window-->' + window.location.pathname);
                console.log('inside result--->' + result);
                if (result.includes('./CheckPasswordResetEmail')) {
                    this.dispatchEvent(
                        new CustomEvent('userinput', { detail: { usr: this.usrnameval } })
                    );

                    this.showEmailSent = true;

                    // window.location.href = result;
                } else if (result) {
                    this.errorMessage = result;
                    this.showError = true;
                }
            })
            .catch((error) => {
                this.error = error;
            });
    }

    /*setBrandingCookie() {
        var expId = this.expid;
        if (expId) {
            setExperienceId({ expId: this.expid })
                .then((result) => {
                    console.log('iii');
                })
                .catch((error) => {
                    this.error = error;
                });
        }
    }*/
    onKeyUp() {
        //checks for "enter" key
        if (event.detail('keyCode') === 13) {
            this.handleForgotPassword();
        }
    }

    /*setExpId() {
        var expId = this.expid;
        if (expId) {
            this.expid = expId;
        }
        this.setBrandingCookie();
    }*/

    initialize() {
        // var rtl_language = $A.get('$Label.c.RTL_Languages');
        //var paramLanguage = communityService.getUrlParameter('language');
        //component.set('v.isRTL', rtl_language.includes(paramLanguage));
        /*$A.get('e.siteforce:registerQueryEventMap')
            .setParams({ qsToEvent: helper.qsToEventMap })
            .fire();*/
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
