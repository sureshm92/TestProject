/**
 * Created by Igor Malyuta on 24.12.2019.
 */

import {LightningElement, api, track} from 'lwc';

import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import emptyChatLabel from '@salesforce/label/c.MS_Empty_Chat';
import newMessLabel from '@salesforce/label/c.MS_New_Mess';
import selectLabel from '@salesforce/label/c.MS_Select';
import selectPlaceholderLabel from '@salesforce/label/c.MS_Select_Placeholder';
import selectStudyPlaceholderLabel from '@salesforce/label/c.MS_Select_Study_Ph';
import inputPlaceholderLabel from '@salesforce/label/c.MS_Input_Placeholder';
import recipientsPlaceholder from '@salesforce/label/c.MS_Input_PI_Recipients_Placeholder';
import limitLabel from '@salesforce/label/c.MS_Char_Limit';
import attFileLabel from '@salesforce/label/c.MS_Attach_File';
import sendBtnLabel from '@salesforce/label/c.BTN_Send';
import teamLabel from '@salesforce/label/c.Study_Team';
import piLabel from '@salesforce/label/c.PI_Colon';
import toastSTSend from '@salesforce/label/c.MS_Toast_Message_ST_Send';
import toastPASend from '@salesforce/label/c.MS_Toast_Message_PA_Send';

import createConversation from '@salesforce/apex/MessagePageRemote.createConversation';
import sendMessage from '@salesforce/apex/MessagePageRemote.sendMessage';
import searchParticipant from '@salesforce/apex/MessagePageRemote.searchParticipant';

export default class MessageBoard extends LightningElement {

    labels = {
        emptyChatLabel,
        newMessLabel,
        selectLabel,
        selectPlaceholderLabel,
        selectStudyPlaceholderLabel,
        recipientsPlaceholder,
        inputPlaceholderLabel,
        limitLabel,
        attFileLabel,
        sendBtnLabel,
        teamLabel,
        piLabel
    };

    @api userMode;

    @track enrollments;
    @track conversation;
    @track messageWrappers;
    @track messageTemplates;
    @track isPastStudy;

    @track isMultipleMode;
    @track selectedEnrollment;
    @track selectedEnrollments;

    @track recipientSelections = [];

    @track messageText;
    @track hideEmptyStub;

    //Public Methods:---------------------------------------------------------------------------------------------------
    @api
    setTemplates(templates) {
        this.messageTemplates = templates;
    }

    @api
    startNew(enrollments, isPastStudy) {
        this.conversation = null;
        this.messageWrappers = [];
        if (isPastStudy !== undefined) this.isPastStudy = isPastStudy;

        this.enrollments = enrollments;
        this.isMultipleMode = enrollments.length > 1;
        if (!this.isMultipleMode) this.selectedEnrollment = enrollments[0];

        this.hideEmptyStub = true;
    }

    @api
    openExisting(conversation, messageWrappers, isPastStudy) {
        this.conversation = null;
        this.messageWrappers = [];
        if (isPastStudy) this.isPastStudy = isPastStudy;

        this.isMultipleMode = false;
        this.conversation = conversation;
        this.messageWrappers = messageWrappers;
        this.selectedEnrollment = conversation.Participant_Enrollment__r;

        this.hideEmptyStub = true;
    }

    //Search Handlers:--------------------------------------------------------------------------------------------------
    handleSearch(event) {
        searchParticipant(event.detail)
            .then(results => {
                this.template.querySelector('c-web-lookup').setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser(
                    'Lookup Error',
                    'An error occurred while searching with the lookup field.',
                    'error'
                );
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
            });
    }

    handleSelectionChange() {
        let lookUpResult = this.template.querySelector('c-web-lookup').getSelection();
        this.selectedEnrollments = lookUpResult.map(res => res.id);
        console.log('Selection change. PEIds:' + JSON.stringify(this.selectedEnrollments));
    }

    //Handlers:---------------------------------------------------------------------------------------------------------
    handleEnrollmentSelect(event) {
        let peId = event.target.value;
        let selectedPE = null;
        this.enrollments.forEach(pe => {
            if (pe.Id === peId) selectedPE = pe;
        });

        this.selectedEnrollment = selectedPE;
    }

    handleMessageText(event) {
        this.messageText = event.target.value;
        let sendBtn = this.template.querySelector('.ms-send-button');
        if (this.messageText) {
            sendBtn.removeAttribute('disabled');
        } else {
            sendBtn.setAttribute('disabled', '');
        }
    }

    handleInputEnter(event) {
        if(this.messageText && event.keyCode === 13) this.handleSendClick();
    }

    handleSendClick(event) {
        //Add opportunity for Attach

        if (!this.conversation) {
            createConversation({enrollment: this.selectedEnrollment, messageText: this.messageText})
                .then(data => {
                    this.fireSendEvent(data);
                })
                .catch(error => {
                    console.error('Error in createConversation():' + JSON.stringify(error));
                });
        } else {
            sendMessage({conversation: this.conversation, messageText: this.messageText})
                .then(data => {
                    this.fireSendEvent(data);
                })
                .catch(error => {
                    console.error('Error in sendMessage():' + JSON.stringify(error));
                });
        }
    }

    //Picklist Options:-------------------------------------------------------------------------------------------------
    get enrollmentsOptions() {
        let options = [];
        if (this.enrollments) {
            this.enrollments.forEach(item => {
                options.push({
                    label: item.Clinical_Trial_Profile__r.Study_Code_Name__c,
                    value: item.Id
                });
            });
        }
        return options;
    }

    get messageTemplateOptions() {
        let options = [];
        if (this.userMode === 'Participant' && this.messageTemplates) {
            this.messageTemplates.forEach((item) => {
                options.push({
                    label: item,
                    value: item
                });
            });
        }
        return options;
    }

    //Service Methods:--------------------------------------------------------------------------------------------------
    get isPIMode() {
        return this.userMode === 'PI';
    }

    clearMessage() {
        this.messageText = null;
        this.template.querySelector('.ms-send-button').setAttribute('disabled', '');
    }

    fireSendEvent(wrapper) {
        this.dispatchEvent(new CustomEvent('conversationupdate', {
            detail: {
                conWr: wrapper
            }
        }));
        this.clearMessage();

        let toastLabel = this.userMode === 'PI' ? toastPASend : toastSTSend;
        this.notifyUser('', toastLabel, 'success');
    }

    notifyUser(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({title, message, variant}));
    }
}