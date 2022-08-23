import { LightningElement, api } from 'lwc';
import edit_Year_of_Birth from '@salesforce/label/c.PP_Edit_Year_of_Birth';
import match_Username_Email from '@salesforce/label/c.PP_Match_Username_Email';
import select_Support_Topic from '@salesforce/label/c.PP_Select_Support_Topic';
import ppFrom from '@salesforce/label/c.PP_From';
import ppTo from '@salesforce/label/c.PP_To_Year';
import selectYear from '@salesforce/label/c.PP_SelectYear';
import getSupport from '@salesforce/label/c.PP_Get_Support';
import submitButton from '@salesforce/label/c.PP_Submit_Button';
import minorMessage from '@salesforce/label/c.PP_MinorMessage';
import requestSubmitted from '@salesforce/label/c.PP_Request_Submitted_Success_Message';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';

import validateAgeOfMajority from '@salesforce/apex/ApplicationHelpRemote.validateAgeOfMajority';
import createYOBCase from '@salesforce/apex/ApplicationHelpRemote.createYOBCase';

export default class PpGetSupport extends LightningElement {
    @api isdelegate;
    @api isDuplicate;
    @api currentYOB;
    @api showUserMatch;
    @api yearOfBirthPicklistvalues;
    isEditYOB = false;
    isMatchUsernameEmail = false;
    spinner;
    showMinorErrorMsg = false;
    disableSave = true;
    changeUserName;
    userEmail;
    usernamesTomerge;

    label = {
        edit_Year_of_Birth,
        match_Username_Email,
        select_Support_Topic,
        ppFrom,
        ppTo,
        selectYear,
        getSupport,
        submitButton,
        minorMessage,
        requestSubmitted
    };

    selectedOption;
    selectedYOB;
    value = 'inProgress';
    placeholder = select_Support_Topic;

    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                console.log('RR_COMMUNITY_JS loaded');
            })
            .catch((error) => {
                console.error('Error in loading RR Community JS: ' + JSON.stringify(error));
            });
    }

    get options() {
        return [
            { label: edit_Year_of_Birth, value: edit_Year_of_Birth },
            { label: match_Username_Email, value: match_Username_Email }
        ];
    }

    get yearOptions() {
        return this.yearOfBirthPicklistvalues;
    }

    handleChange(event) {
        this.selectedOption = event.detail.value;
        if (this.selectedOption == edit_Year_of_Birth) {
            this.isEditYOB = true;
            this.isMatchUsernameEmail = false;
        } else if (this.selectedOption == match_Username_Email) {
            this.isMatchUsernameEmail = true;
            this.isEditYOB = false;
        }
    }
    handleYearChange(event) {}
    get placeholder() {
        return this.placeholder;
    }
    doCheckYearOfBith(event) {
        this.selectedYOB = event.detail.value;
        console.log('????????????slected YOB' + this.selectedYOB);
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
                }
                this.spinner.hide();
            })
            .catch((error) => {
                console.log('error', error);
            });
    }
    doCreateYOBCase(event) {
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner.show();
        if (this.isEditYOB) {
            createYOBCase({
                birthYear: this.selectedYOB,
                username: false,
                userEmail: this.userEmail,
                currentYob: this.currentYOB,
                mergeUserNames: this.isDuplicate,
                usrList: this.usernamesTomerge
            })
                .then((result) => {
                    communityService.showToast('', 'success', requestSubmitted, 300);
                    communityService.navigateToPage('help');
                    this.spinner.hide();
                })
                .catch((error) => {
                    console.log('error', error);
                });
        }
    }
}
