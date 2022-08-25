import { LightningElement, api} from 'lwc';

import rr_community_icons from '@salesforce/resourceUrl/rr_community_icons';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import communityPPTheme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';

import TST_password_updated_successfully from '@salesforce/label/c.TST_password_updated_successfully';
import TST_Your_current_password_is_invalid from '@salesforce/label/c.TST_Your_current_password_is_invalid';
import PG_AS_F_Current_Password from '@salesforce/label/c.PG_AS_F_Current_Password';
import PG_AS_F_New_password from '@salesforce/label/c.PG_AS_F_New_password';
import PP_AS_F_Re_enter_new_password from '@salesforce/label/c.PP_AS_F_Re_enter_new_password';
import Pswd_Your_Pswd_Include from '@salesforce/label/c.Pswd_Your_Pswd_Include';
import Pswd_8_Characters from '@salesforce/label/c.Pswd_8_Characters';
import Pswd_Include_Any_3 from '@salesforce/label/c.Pswd_Include_Any_3';
import Pswd_Numbers from '@salesforce/label/c.Pswd_Numbers';
import Pswd_Uppercase from '@salesforce/label/c.Pswd_Uppercase';
import Pswd_Lowercase from '@salesforce/label/c.Pswd_Lowercase';
import Pswd_Special_Characters from '@salesforce/label/c.Pswd_Special_Characters';
import PG_AS_F_Update_Password from '@salesforce/label/c.PG_AS_F_Update_Password';
import PP_Password_Management from '@salesforce/label/c.PP_Password_Management';
import PP_Incorrect_password from '@salesforce/label/c.PP_Incorrect_password';
import PP_Password_does_not_fit_criteria from '@salesforce/label/c.PP_Password_does_not_fit_criteria';
import PP_Password_does_not_match from '@salesforce/label/c.PP_Password_does_not_match';
import PP_Password_Requirements from '@salesforce/label/c.PP_Password_Requirements';
import BACK from '@salesforce/label/c.Back';

import getInitData from '@salesforce/apex/AccountSettingsController.getInitData';
import changePassword from '@salesforce/apex/AccountSettingsController.changePassword';

export default class PpChangePassword extends LightningElement {

    initData;
    contactChanged;
    personWrapper;
    contactSectionData;
    optInEmail;
    optInSMS;
    isDisabled;
    contact;
    currentEmail;
    isInitialized = false;
    spinner;
    
    @api userMode;
    @api isRTL = false;
    @api isMobile = false;
    @api isDelegate = false;

    rtl = true;

    caps;
    small;
    numbers;
    length;
    special;

    updateButton;
    passwordDoNotMatch;
    passwordDoNotMatchCriterion;
    incorrectOldPassword = false;

    showCurrentPassword = false;
    showNewPassword = false;
    showReNewPassword = false;

    label = {
        TST_password_updated_successfully,
        TST_Your_current_password_is_invalid,
        PP_Password_Management,
        PP_Incorrect_password,
        PP_Password_does_not_fit_criteria,
        PP_Password_does_not_match,
        PG_AS_F_Current_Password,
        PG_AS_F_New_password,
        PP_Password_Requirements,
        PP_AS_F_Re_enter_new_password,
        Pswd_Your_Pswd_Include,
        Pswd_8_Characters,
        Pswd_Include_Any_3,
        Pswd_Numbers,
        Pswd_Uppercase,
        Pswd_Lowercase,
        Pswd_Special_Characters,
        PG_AS_F_Update_Password,
        BACK
    };

    // Getter for back icon
    get iconChevron() {
        return 'icon-chevron-left';
    }

    // Getters to set input values on load
    get currentPassword(){
        return this.initData.password.old;
    }

    get newPassword(){
        return this.initData.password.new;
    }

    get reNewPassword(){
        return this.initData.password.reNew
    }

    // Component padding
    get headerPanelClass() {
        return this.isMobile ? 'header-panel-mobile' : 'header-panel';
    }

    // Getters for Input Type Masked
    get currentPasswordCssClass(){
        return this.showCurrentPassword ? 'profile-info-input' : 'profile-info-input masked';
    }

    get newPasswordCssClass(){
        return this.showNewPassword ? 'profile-info-input' : 'profile-info-input masked';
    }

    get reNewPasswordCssClass(){
        return this.showReNewPassword ? 'profile-info-input' : 'profile-info-input masked';
    }

    // Getters For Icon color Change
    get toggleCurrentPasswordMaskIcon(){
        return this.showCurrentPassword ? '#297DFD' : '#999999';
    }

    get toggleNewPasswordMaskIcon(){
        return this.showNewPassword ? '#297DFD' : '#999999';
    }

    get toggleReNewPasswordMaskIcon(){
        return this.showReNewPassword ? '#297DFD' : '#999999';
    }

    // getRTL
    get cardRTL() {
        return this.isRTL ? 'cardRTL' : '';     
    }

    get iconEye(){
        return this.isRTL ? 'icon-eye-rtl' : 'icon-eye';       
    }

    get iconEyeMobile(){
        return this.isRTL ? 'icon-eye-mobile-rtl' : 'icon-eye-mobile';
    }

    get reNewMargin(){
        return this.isRTL ? 'slds-form-element margin-lr-15Plus' : 'slds-form-element margin-lr-15';
    }

    // Icons 
    check = rr_community_icons + '/' + 'check.svg' + '#' + 'check';
    //icon_eye = rr_community_icons + '/' + 'icons.svg' + '#' + 'icon-eye'

    get eyeIcon(){
        return "icon-eye";
    }

    get checkIcon(){
        return "check";
    }

    get green(){
        return "#2ac243";
    }

    get gray(){
        return "#7e7e7e";
    }
    renderedCallback(){
        
    }
    connectedCallback(){
        loadScript(this, RR_COMMUNITY_JS)
        .then(() => {
            Promise.all([loadStyle(this, communityPPTheme)])
                .then(() => {  
                    this.spinner = this.template.querySelector('c-web-spinner');
                    this.spinner ? this.spinner.show() : "";
                })
                .catch((error) => {
                    console.log(error.body.message);
                });
        })
        .catch((error) => {
            communityService.showToast('', 'error', error.message, 100);
        });

        communityService.getCurrentCommunityMode().currentDelegateId ? this.isDelegate = true : this.isDelegate = false;
        getInitData({ 
            userMode: userMode
         })
        .then((returnValue) => {
            this.isInitialized = true;
            let initData = JSON.parse(returnValue);
            initData.password = {
                old: '',
                new: '',
                reNew: ''
            };
            this.initData = initData;
            this.contactChanged = initData.contactChanged;
            this.personWrapper = initData.contactSectionData.personWrapper;
            this.contactSectionData = initData.contactSectionData;
            this.optInEmail = initData.contactSectionData.personWrapper.optInEmail;
            this.optInSMS = initData.contactSectionData.personWrapper.optInSMS;
            this.isDisabled = true;
            this.contact = initData.myContact;
            this.currentEmail = initData.myContact.Email;

             this.spinner.hide();

        })
        .catch((error) => {
            communityService.showToast('', 'error', 'Failed To read the Data...', 100);
            this.spinner.hide();
        });
    }

    disableUpdateButton(){
        let updateButton = this.template.querySelector('button[data-id=updateBtn]');
        updateButton != null ? updateButton.disabled = true : "";      
    }

    enableUpdateButton(){
        let updateButton = this.template.querySelector('button[data-id=updateBtn]')
        updateButton != null ? updateButton.removeAttribute("disabled") : "";
    }
    
    onChangeInput(event) {
        this.isDisabled = true;

        let key = event.target.getAttribute("data-label");
        let value = event.target.value;

        switch (key) {
            case 'old':
                this.initData.password.old = value;
                break;
            case 'new':
                this.initData.password.new = value;
                this.checkPasswordMatch();
                break;
            case 'renew':
                this.initData.password.reNew = value;
                this.checkPasswordMatch();                     
                break;
        }
        
     
        let password = this.initData.password.new;
        let oldpassword = this.initData.password.old;
        let renewpassword = this.initData.password.reNew;

        // Current Password Validation
        if(oldpassword == null || oldpassword == "" || oldpassword == undefined){
            this.incorrectOldPassword = false;
            this.validateOldPassword();
        }

        // Handle Update button visibility
        if( this.isDelegate ||
            password == null ||
            password == undefined ||
            password.length == 0  ||
            renewpassword == null ||
            renewpassword == undefined ||
            renewpassword.length == 0)
        {
            this.disableUpdateButton();
        }else if(password != renewpassword){
            this.disableUpdateButton();
        }else if(password == renewpassword && (password.length < 8 || renewpassword.length < 8)){
            this.disableUpdateButton();
        }else if(oldpassword.length == 0){
            this.disableUpdateButton();
        }else{
            this.enableUpdateButton();
        }

         //Password Strength Check
         let strengthValue = {
            caps: false,
            length: false,
            special: false,
            numbers: false,
            small: false
        };

        //Check Password Length
        if (password.length >= 8) {
            strengthValue.length = true;
            this.passwordDoNotMatchCriterion = false;
        }
       
        //Calculate Password Strength
        for (let index = 0; index < password.length; index++) {
            let char = password.charCodeAt(index);
            if (!strengthValue.caps && char >= 65 && char <= 90) {
                strengthValue.caps = true;
            } else if (!strengthValue.numbers && char >= 48 && char <= 57) {
                strengthValue.numbers = true;
            } else if (!strengthValue.small && char >= 97 && char <= 122) {
                strengthValue.small = true;
            } else if (
                (!strengthValue.special && char >= 33 && char <= 47) ||
                (char >= 58 && char <= 64) ||
                (char >= 91 && char <= 96) ||
                (char >= 123 && char <= 126)
            ) {
                strengthValue.special = true;
            }
        }
        this.caps = strengthValue.caps;
        this.small = strengthValue.small;
        this.numbers = strengthValue.numbers;
        this.length = strengthValue.length;
        this.special = strengthValue.special;

        // New Password Do Not Match Criteria
        if (password.length == 0) {
            this.passwordDoNotMatchCriterion = false;
        }else if (password.length > 0 && password.length < 8 ) {
            this.passwordDoNotMatchCriterion = true;
        }else{
            ((this.caps + this.small + this.numbers + this.special) < 3) ? this.passwordDoNotMatchCriterion = true : this.passwordDoNotMatchCriterion = false;
        }

        let newPassEle = this.template.querySelector('lightning-input[data-id=newe-password]');        
        this.passwordDoNotMatchCriterion ? newPassEle.classList.add("profile-info-error-input") : newPassEle.classList.remove("profile-info-error-input");
    }

    checkPasswordMatch(){
        let password = this.initData.password.new;
        let newPassword = this.initData.password.reNew;
        if(password.length > 0 && newPassword.length > 0){
            password != newPassword ? this.passwordDoNotMatch = true : this.passwordDoNotMatch = false;
        }
        else{
            this.passwordDoNotMatch = false;
        }     

        let reEnterPassEle = this.template.querySelector('lightning-input[data-id=reenter-password]');        
        this.passwordDoNotMatch ? reEnterPassEle.classList.add("profile-info-error-input") : reEnterPassEle.classList.remove("profile-info-error-input");
    }

    doChangePassword(){
        this.spinner.show();
        changePassword({ 
            newPassword: this.initData.password.new,
            verifyNewPassword: this.initData.password.reNew,
            oldPassword: this.initData.password.old
         })
        .then((returnValue) => {
            communityService.showToast(
                '',
                'success',
                this.label.TST_password_updated_successfully,
                100
            );
            communityService.navigateToPage('account-settings?password-change');
            this.initData.password = {
                old: '',
                new: '',
                reNew: ''
            };          
        })
        .catch((error) => {
            let errorMessage = error.body.message.split('\n')[0];
            (errorMessage == 'Error: Your old password is invalid.') ?  this.incorrectOldPassword = true : this.incorrectOldPassword = false;

            communityService.showToast('', 'error', errorMessage, 100);
            this.validateOldPassword();
            this.spinner.hide();
        });
    }

    validateOldPassword(){
        let currentPassEle = this.template.querySelector('lightning-input[data-id=current-password]');        
        this.incorrectOldPassword ? currentPassEle.classList.add("profile-info-error-input") : currentPassEle.classList.remove("profile-info-error-input");
    }

    togglePassword(event){
        let iconId = event.currentTarget.getAttribute("data-id");
        switch (iconId){
            case '1':
                this.showCurrentPassword = !this.showCurrentPassword;
                break;
            case '2':
                this.showNewPassword = !this.showNewPassword;
                break;
            case '3':
                this.showReNewPassword = !this.showReNewPassword;
                break;
        }        
    }

    showMenuBar(event) {
        if (event.target.dataset.header) {
            this.dispatchEvent(
                new CustomEvent('shownavmenubar', {
                    detail: {
                        header: event.target.dataset.header
                    }
                })
            );
            this.isInitialized = false;
        }
    }

}