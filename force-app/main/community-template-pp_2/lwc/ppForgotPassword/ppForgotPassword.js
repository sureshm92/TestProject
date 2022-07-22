import { LightningElement, track } from 'lwc';
import forgotPassword from '@salesforce/apex/LightningForgotPasswordController.forgotPasswordCommunity';
import usrnameLabel from '@salesforce/label/c.PG_AS_F_Username';
import ppEnterAssociatedEmail from '@salesforce/label/c.PP_Enter_Associated_Email';
import forgotLabel from '@salesforce/label/c.PP_ForgotPwd';

export default class PpForgotPassword extends LightningElement {
    @track showEmailSent = false;
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
            this.userPlaceholder = this.labels.usrPlaceholder;
        }
    }

    get rtlStyleClass() {
        //if (this.isRTL) {
        //     this.rtlCss = 'forgotpwd-rtl';
        // }
        //  return this.rtlCss;
    }

    handleForgotPassword() {
        console.log('&&&&&&&&&&&&&&&&%%%2');
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
}
