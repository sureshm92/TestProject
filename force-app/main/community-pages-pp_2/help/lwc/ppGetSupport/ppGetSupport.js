import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import edit_Year_of_Birth from '@salesforce/label/c.PP_Edit_Year_of_Birth';
import match_Username_Email_Option from '@salesforce/label/c.PP_Username_Email_in_GetSupport';
import select_Support_Topic from '@salesforce/label/c.PP_Select_Support_Topic';
import ppFrom from '@salesforce/label/c.PP_From';
import ppTo from '@salesforce/label/c.PP_To_Year';
import selectYear from '@salesforce/label/c.PP_SelectYear';
import getSupport from '@salesforce/label/c.PP_Get_Support';
import submitButton from '@salesforce/label/c.PP_Submit_Button';
import minorMessage from '@salesforce/label/c.PP_MinorMessage';
import PP_Duplicate_Usernames from '@salesforce/label/c.PP_Duplicate_Usernames';
import PP_UsrNameLabel from '@salesforce/label/c.PP_UsrNameLabel';
import requestSubmitted from '@salesforce/label/c.PP_Request_Submitted_Success_Message';
import matchUsernameEmail from '@salesforce/label/c.PP_Username_And_Email_Change_GetSupport';
import PP_Merge_Username from '@salesforce/label/c.PP_Merge_Username';
import PP_MergeExisting from '@salesforce/label/c.PP_MergeExisting';
import validateAgeOfMajority from '@salesforce/apex/ApplicationHelpRemote.validateAgeOfMajority';
import validateUsername from '@salesforce/apex/ApplicationHelpRemote.validateUsername';
import createYOBCase from '@salesforce/apex/ApplicationHelpRemote.createYOBCase';
import DEVICE from '@salesforce/client/formFactor';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';

export default class PpGetSupport extends NavigationMixin(LightningElement) {
    @api showGetSupport;
    @api isDuplicate;
    @api currentYOB;
    @api showUserMatch;
    @api yearOfBirthPicklistvalues;
    @api userEmail;
    @api usrName;
    @api userMode;
    @api currentContactEmail;
    isEditYOB = false;
    isMatchUsernameEmail = false;
    spinner;
    showMinorErrorMsg = false;
    disableSave = true;
    chngUsernameEmailValue;
    userNamesList = [];
    usernamesTomerge = [];
    showUserNames = false;
    UseremailDuplicate;
    userNamesListvalue;
    duplicateInfoHeader;
    checkMatchUsernameEmail = false;
    checkMergeUsernameEmail = false;

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
        matchUsernameEmail,
        PP_Duplicate_Usernames,
        PP_UsrNameLabel,
        PP_Merge_Username,
        PP_MergeExisting
    };
    selectedOption;
    selectedYOB;
    placeholder = select_Support_Topic;
    doMatchUsernameEmail;
    YOBSelected = false;

    connectedCallback() {
        DEVICE != 'Small' ? (this.isMobile = false) : (this.isMobile = true);
        this.isRTL = rtlLanguages.includes(communityService.getLanguage()) ? true : false;
    }

    get marginForDOBEdit() {
        return this.isEditYOB || (this.isMatchUsernameEmail && !this.UseremailDuplicate)
            ? 'fixed-height'
            : '';
    }

    get dropDownOpacityClass() {
        return this.isEditYOB || this.isMatchUsernameEmail
            ? 'mb-15 support-combobox help-support'
            : 'support-combobox opacity help-support';
    }

    get YOBOpacityClass() {
        return this.YOBSelected ? 'support-year' : 'support-year opacity';
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

    get highlightErrorForYOBClass() {
        return this.showMinorErrorMsg
            ? 'highlight-error mt-5 fadePlaceholder'
            : 'mt-5 fade fadePlaceholder';
    }
    handleChangeSelection(event) {
        this.disableSave = true;
        this.selectedOption = event.detail.value;
        if (this.selectedOption == edit_Year_of_Birth) {
            this.isEditYOB = true;
            this.isMatchUsernameEmail = false;
            this.UseremailDuplicate = false;
            this.checkMergeUsernameEmail = false;
            this.checkMatchUsernameEmail = false;
        } else if (this.selectedOption == match_Username_Email_Option) {
            this.isMatchUsernameEmail = true;
            this.isEditYOB = false;
            this.checkMergeUsernameEmail =
                this.isMatchUsernameEmail && this.isDuplicate ? true : false;
            this.checkMatchUsernameEmail = this.isDuplicate ? false : true;
            this.selectedYOB = false;
            this.showMinorErrorMsg = false;
        }
    }
    doCheckYOB(event) {
        this.YOBSelected = true;
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
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner.show();
        if (this.chngUsernameEmailValue && this.isDuplicate) {
            this.UseremailDuplicate = true;
        } else {
            this.UseremailDuplicate = false;
        }
        if (this.UseremailDuplicate) {
            validateUsername().then((result) => {
                let usernames = result;
                this.userNamesList = usernames;
                let usrList = [];
                for (let key in usernames) {
                    usrList.push(usernames[key].value);
                }
                this.userNamesListvalue = usernames[0].value;
                this.usernamesTomerge = usrList;
                this.spinner.hide();
            });
        } else {
            this.userNamesList = [];
            this.spinner.hide();
        }
    }
    handleChange(event) {
        this.userNamesListvalue = event.detail.value;
        if (!this.chngUsernameEmailValue) {
            this.disableSave = true;
        } else {
            this.disableSave = false;
        }
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
                userEmail: this.userNamesListvalue,
                currentYob: this.currentYOB,
                mergeUserNames: this.isDuplicate,
                usrList: this.usernamesTomerge
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
