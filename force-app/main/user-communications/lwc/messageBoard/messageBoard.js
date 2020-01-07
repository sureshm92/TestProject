/**
 * Created by Igor Malyuta on 24.12.2019.
 */

import {LightningElement, api, track} from 'lwc';

import emptyChatLabel from '@salesforce/label/c.MS_Empty_Chat';
import selectLabel from '@salesforce/label/c.MS_Select';
import selectPlaceholderLabel from '@salesforce/label/c.MS_Select_Placeholder';
import inputPlaceholderLabel from '@salesforce/label/c.MS_Input_Placeholder';
import limitLabel from '@salesforce/label/c.MS_Char_Limit';
import attFileLabel from '@salesforce/label/c.MS_Attach_File';
import sendBtnLabel from '@salesforce/label/c.BTN_Send';
import teamLabel from '@salesforce/label/c.Study_Team';

import createConversation from '@salesforce/apex/MessagePageRemote.createConversation';
import sendMessage from '@salesforce/apex/MessagePageRemote.sendMessage';

export default class MessageBoard extends LightningElement {

    labels = {
        emptyChatLabel,
        selectLabel,
        selectPlaceholderLabel,
        inputPlaceholderLabel,
        limitLabel,
        attFileLabel,
        sendBtnLabel,
        teamLabel
    };

    @api userMode;

    @track enrollments;
    @track conversation;
    @track messageWrappers;
    @track messageTemplates;

    @track isMultipleMode;
    @track selectedEnrollment;
    @track selectedEnrollments;
    @track messageText;
    @track hideEmptyStub;

    //Public Methods:---------------------------------------------------------------------------------------------------
    @api
    setTemplates(templates) {
        this.messageTemplates = templates;
    }

    @api
    startNew(enrollments) {
        this.conversation = null;
        this.messageWrappers = [];

        this.enrollments = enrollments;
        this.isMultipleMode = enrollments.length > 1;
        if (!this.isMultipleMode) this.selectedEnrollment = enrollments[0];

        this.hideEmptyStub = true;
    }

    @api
    openExisting(conversation, messageWrappers) {
        this.conversation = null;
        this.messageWrappers = [];

        this.isMultipleMode = false;
        this.conversation = conversation;
        this.messageWrappers = messageWrappers;
        this.selectedEnrollment = conversation.Participant_Enrollment__r;

        this.hideEmptyStub = true;
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
    }

    handleSendClick(event) {
        //Add opportunity for Attach

        if (!this.conversation) {
            createConversation({enrollment: this.selectedEnrollment, messageText: this.messageText})
                .then(data => {
                    this.dispatchEvent(new CustomEvent('conversationupdate', {
                        detail: {
                            conWr: data
                        }
                    }));
                })
                .catch(error => {
                    console.log('Error in createConversation():' + JSON.stringify(error));
                });
        } else {
            let senderName;
            if (this.userMode === 'PI') {
                senderName = this.selectedEnrollment.Study_Site__r.Principal_Investigator__r.Name;
            } else {
                senderName = this.selectedEnrollment.Participant__r.Full_Name__c;
            }
            let message = {
                objectApiName: 'Message__c',
                Conversation__c: this.conversation.Id,
                Message_Content__c: this.messageText,
                Sender_Name__c: senderName
            };
            sendMessage({conversation: this.conversation, message: message})
                .then(() => {
                    console.log('Success!');
                })
                .catch(error => {
                    console.log('Error in sendMessage():' + JSON.stringify(error));
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

    get isPIMode() {
        return this.userMode === 'PI';
    }
}