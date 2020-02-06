/**
 * Created by Igor Malyuta on 04.02.2020.
 */

import {LightningElement, api, track} from 'lwc';
import formFactor from '@salesforce/client/formFactor';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import AvatarColorCalculator from 'c/avatarColorCalculator';

import largeTemplate from './messageBoardHeader.html';
import mobileTemplate from './messageBoardHeaderMobile.html';

import backLabel from '@salesforce/label/c.BTN_Back';
import newMessLabel from '@salesforce/label/c.MS_New_Mess';
import recipientsPlaceholder from '@salesforce/label/c.MS_Input_PI_Recipients_Placeholder';
import selectStudyPlaceholderLabel from '@salesforce/label/c.MS_Select_Study_Ph';
import teamLabel from '@salesforce/label/c.Study_Team';
import piLabel from '@salesforce/label/c.PI_Colon';

import searchParticipant from '@salesforce/apex/MessagePageRemote.searchParticipant';

export default class MessageBoardHeader extends LightningElement {

    labels = {
        newMessLabel,
        backLabel,
        recipientsPlaceholder,
        selectStudyPlaceholderLabel,
        teamLabel,
        piLabel
    };

    @api userMode;
    @api enrollments;
    @api selectedEnrollment;
    @api isMultipleMode;
    @api isPastStudy;

    @track fullName;
    @track selectedPeId;

    connectedCallback() {
        if (this.selectedEnrollment) {
            this.fullName = this.userMode === 'PI' ?
                this.selectedEnrollment.Participant__r.Full_Name__c :
                this.selectedEnrollment.Study_Site__r.Principal_Investigator__r.Name;
        } else {
            this.fullName = '';
        }
    }

    render() {
        return formFactor === 'Small' ? mobileTemplate : largeTemplate;
    }

    renderedCallback() {
        if (this.selectedEnrollment) {
            this.fullName = this.userMode === 'PI' ?
                this.selectedEnrollment.Participant__r.Full_Name__c :
                this.selectedEnrollment.Study_Site__r.Principal_Investigator__r.Name;
        }
    }

    //Template Methods:-------------------------------------------------------------------------------------------------
    get isPIMode() {
        return this.userMode === 'PI';
    }

    get bubbleColor() {
        return 'background: ' + new AvatarColorCalculator().getColorFromString(this.fullName);
    }

    get initials() {
        let initials = this.fullName.match(/\b\w/g) || [];
        return ((initials.shift() || '') + (initials.shift() || '')).toUpperCase();
    }

    get enrollmentsOptions() {
        let options = [];
        if (this.enrollments) {
            this.enrollments.forEach(function (item) {
                options.push({
                    label: item.Clinical_Trial_Profile__r.Study_Code_Name__c,
                    value: item.Id
                });
            });
        }
        return options;
    }

    //Handlers:---------------------------------------------------------------------------------------------------------
    handleBackClick() {
        this.dispatchEvent(new CustomEvent('back'));
    }

    handleEnrollmentSelect(event) {
        this.dispatchEvent(new CustomEvent('enrollmentselect', {
            detail: {
                peId: event.target.value
            }
        }));
    }

    //Search Handlers:--------------------------------------------------------------------------------------------------
    handleSearch(event) {
        searchParticipant(event.detail)
            .then(results => {
                this.template.querySelector('c-web-lookup').setSearchResults(results);
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Lookup Error',
                    message: 'An error occurred while searching with the lookup field.',
                    variant: 'error'
                }));
                console.error('Lookup error', JSON.stringify(error));
            });
    }

    handleSelectionChange() {
        let lookUp = this.template.querySelector('c-web-lookup');
        this.dispatchEvent(new CustomEvent('selectionchange', {
            detail: {
                selection: lookUp ? lookUp.getSelection() : null
            }
        }));
    }
}