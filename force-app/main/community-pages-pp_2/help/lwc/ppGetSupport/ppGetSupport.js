import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import edit_Year_of_Birth from '@salesforce/label/c.PP_Edit_Year_of_Birth';
import match_Username_Email_Option from '@salesforce/label/c.PP_Username_Email_GetSupport';
import select_Support_Topic from '@salesforce/label/c.PP_Select_Support_Topic';
import ppFrom from '@salesforce/label/c.PP_From';
import ppTo from '@salesforce/label/c.PP_To_Year';
import selectYear from '@salesforce/label/c.PP_SelectYear';
import getSupport from '@salesforce/label/c.PP_Get_Support';
import submitButton from '@salesforce/label/c.PP_Submit_Button';
import minorMessage from '@salesforce/label/c.PP_MinorMessage';
import requestSubmitted from '@salesforce/label/c.PP_Request_Submitted_Success_Message';
import matchUsernameEmail from '@salesforce/label/c.PP_Username_And_Email_Change_GetSupport';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import validateAgeOfMajority from '@salesforce/apex/ApplicationHelpRemote.validateAgeOfMajority';
import createYOBCase from '@salesforce/apex/ApplicationHelpRemote.createYOBCase';
import DEVICE from '@salesforce/client/formFactor';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

export default class PpGetSupport extends NavigationMixin(LightningElement) {
    @api showGetSupport;
    @api isDuplicate;
    @api currentYOB;
    @api showUserMatch;
    @api yearOfBirthPicklistvalues;
    @api userEmail;
    @api usrName;
    @api userMode;
    isEditYOB = false;
    isMatchUsernameEmail = false;
    spinner;
    showMinorErrorMsg = false;
    disableSave = true;
    chngUsernameEmailValue;

    isMobile;
    cardRTL;

    label = {
        edit_Year_of_Birth,
        match_Username_Email_Option,
        select_Support_Topic,
        ppFrom,
        ppTo,
        selectYear,
        getSupport,
        submitButton,
        minorMessage,
        requestSubmitted,
        matchUsernameEmail
    };
    selectedOption;
    selectedYOB;
    placeholder = select_Support_Topic;
    doMatchUsernameEmail;

    connectedCallback() {
        DEVICE != 'Small' ? (this.isMobile = false) : (this.isMobile = true);
        this.isRTL = rtlLanguages.includes(communityService.getLanguage()) ? true : false;
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                console.log('RR_COMMUNITY_JS loaded');
            })
            .catch((error) => {
                console.error('Error in loading RR Community JS: ' + JSON.stringify(error));
            });
    }

    get marginForDOBEdit() {
        if (this.isEditYOB) {
            return 'mt-25';
        }
        if (this.isMatchUsernameEmail) {
            return 'mt-15';
        }
    }

    get marginMatchEmailPass() {
        return this.isMatchUsernameEmail ? 'mb-10' : '';
    }

    get options() {
        return [
            { label: edit_Year_of_Birth, value: edit_Year_of_Birth },
            { label: match_Username_Email_Option, value: match_Username_Email_Option }
        ];
    }

    get yearOptions() {
        return this.yearOfBirthPicklistvalues;
    }
    get isParticipant() {
        return this.showGetSupport;
    }
    get isShowUserMatch() {
        return this.showUserMatch;
    }

    get placeholder() {
        return this.placeholder;
    }
    get isDisableSave() {
        return this.disableSave;
    }
    handleChangeSelection(event) {
        this.disableSave = true;
        this.selectedOption = event.detail.value;
        if (this.selectedOption == edit_Year_of_Birth) {
            this.isEditYOB = true;
            this.isMatchUsernameEmail = false;
        } else if (this.selectedOption == match_Username_Email_Option) {
            this.isMatchUsernameEmail = true;
            this.isEditYOB = false;
        }
    }
    doCheckYearOfBith(event) {
        this.selectedYOB = event.detail.value;
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner.show();

        validateAgeOfMajority({ birthYear: this.selectedYOB })
            .then((result) => {
                let isAdult = result;
                if (isAdult == 'true') {
                    this.showMinorErrorMsg = false;
                    this.disableSave = false;
                } else if (isAdult == 'false') {
                    this.showMinorErrorMsg = this.selectedYOB == '' ? false : true;
                    this.disableSave = true;
                }
                this.spinner.hide();
            })
            .catch((error) => {
                console.log('error', error);
            });
    }
    doChangeUsernameEmail(event) {
        this.chngUsernameEmailValue = event.target.checked;
        this.disableSave = !this.chngUsernameEmailValue;
    }
    doCreateYOBCase(event) {
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner.show();
        if (this.isEditYOB) {
            createYOBCase({
                yob: this.selectedYOB,
                username: false,
                userEmail: '',
                currentYob: this.currentYOB,
                mergeUserNames: this.isDuplicate,
                usrList: this.usrName
            })
                .then((result) => {
                    communityService.showToast('', 'success', requestSubmitted, 100);
                    communityService.navigateToPage('help');
                    this.spinner.hide();
                })
                .catch((error) => {
                    console.log('error', error);
                });
        } else if (this.isMatchUsernameEmail) {
            createYOBCase({
                yob: this.selectedYOB,
                username: true,
                userEmail: this.userEmail,
                currentYob: this.currentYOB,
                mergeUserNames: this.isDuplicate,
                usrList: this.usrName
            })
                .then((result) => {
                    communityService.showToast('', 'success', requestSubmitted, 100);
                    communityService.navigateToPage('help');
                    this.spinner.hide();
                })
                .catch((error) => {
                    console.log('error', error);
                });
        }
    }
    navigateToAccountSettings() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'account-settings'
            }
        });
    }
}
