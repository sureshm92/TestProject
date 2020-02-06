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
import backLabel from '@salesforce/label/c.BTN_Back';

import createConversation from '@salesforce/apex/MessagePageRemote.createConversation';
import sendMessage from '@salesforce/apex/MessagePageRemote.sendMessage';
import searchParticipant from '@salesforce/apex/MessagePageRemote.searchParticipant';
import sendMultipleMessage from '@salesforce/apex/MessagePageRemote.sendMultipleMessage';
import formFactor from "@salesforce/client/formFactor";

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
        piLabel,
        backLabel
    };

    fileTypes = '.csv,.doc,.jpg,.pdf,.png,.xls';

    @api userMode;
    @api firstConWr;

    @track enrollments;
    @track conversation;
    @track messageWrappers;
    @track messageTemplates;
    @track isPastStudy;

    @track isMultipleMode;
    @track selectedPeId;
    @track selectedEnrollment;
    @track selectedEnrollments;

    @track recipientSelections = [];

    @track messageText;
    @track isSendEnable;
    @track isHoldMode;
    @track hideEmptyStub;
    needAfterRenderSetup;

    contentDocId;

    //Public Methods:---------------------------------------------------------------------------------------------------
    @api
    setTemplates(templates) {
        this.messageTemplates = templates;
    }

    @api
    startNew(enrollments, statusByPeMap) {
        this.conversation = null;
        this.messageWrappers = [];
        this.isPastStudy = false;

        this.enrollments = enrollments;
        this.isMultipleMode = enrollments.length > 1;
        if (!this.isMultipleMode) {
            this.selectedEnrollment = enrollments[0];

            if (this.userMode === 'Participant') this.isPastStudy = statusByPeMap[this.selectedEnrollment.Id];
        }

        this.needAfterRenderSetup = true;
        this.hideEmptyStub = true;
    }

    @api
    openExisting(conversation, messageWrappers, isPastStudy) {
        this.conversation = null;
        this.messageWrappers = [];
        this.isPastStudy = isPastStudy;

        this.isMultipleMode = false;
        this.conversation = conversation;
        this.messageWrappers = messageWrappers;
        this.selectedEnrollment = conversation.Participant_Enrollment__r;
        this.isHoldMode = !conversation.Participant_Enrollment__r.Study_Site__r.Messages_Are_Available__c;

        this.needAfterRenderSetup = true;
        this.hideEmptyStub = true;
    }

    @api
    closeBoard() {
        this.hideEmptyStub = false;
        this.conversation = null;
        this.messageWrappers = null;
        this.enrollments = null;
        this.isMultipleMode = false;
    }

    renderedCallback() {
        if (this.firstConWr && !this.hideEmptyStub && !this.conversation && !this.enrollments && formFactor !== 'Small') {
            this.openExisting(this.firstConWr.conversation, this.firstConWr.messages, this.firstConWr.isPastStudy);
        }

        if (this.needAfterRenderSetup) {
            let context = this;
            setTimeout(function () {
                context.clearMessage();
                context.template.querySelector('.ms-board-footer').style.pointerEvents = context.isHoldMode ? 'none' : 'all';
            }, 50);

            this.needAfterRenderSetup = false;
        }

        // this.template.addEventListener('uploadfinished', this.handleUploadFinished);
    }

    //Search Handlers:--------------------------------------------------------------------------------------------------
    handleSelectionChange(event) {
        this.selectedEnrollments = event.detail.selection;
        this.checkSendBTNAvailability();
    }

    //Handlers:---------------------------------------------------------------------------------------------------------
    handleBackClick(event) {
        this.dispatchEvent(new CustomEvent('back'));
    }

    handleEnrollmentSelect(event) {
        let peId = event.detail.peId;
        this.selectedEnrollment = this.enrollments.filter(function (pe) {
            return pe.Id === peId
        })[0];
        this.checkSendBTNAvailability();
    }

    handleMessageText(event) {
        this.messageText = event.target.value;
        this.checkSendBTNAvailability();
        this.changeAttachStyle();
    }

    handleInputEnter(event) {
        if (!this.isHoldMode && this.messageText && event.keyCode === 13) this.handleSendClick();
    }

    handleSendClick(event) {
        let messageText = this.messageText;
        this.clearMessage();

        if (this.userMode === 'PI' && this.isMultipleMode && this.selectedEnrollments) {
            sendMultipleMessage({peIds: this.selectedEnrollments, messageText: messageText})
                .then(() => {
                    this.fireMultipleSendEvent();
                })
                .catch(error => {
                    console.error('Error in sendMultipleMessage():' + JSON.stringify(error));
                    this.notifyUser('Error', error.message, 'error');
                });
        } else {
            if (!this.conversation && this.selectedEnrollment) {
                createConversation({enrollment: this.selectedEnrollment, messageText: messageText})
                    .then(data => {
                        this.fireSendEvent(data);
                    })
                    .catch(error => {
                        console.error('Error in createConversation():' + JSON.stringify(error));
                        this.notifyUser('Error', error.message, 'error');
                    });
            } else {
                let docId = this.contentDocId ? this.contentDocId : null;
                sendMessage({conversation: this.conversation, messageText: messageText})
                    .then(data => {
                        this.fireSendEvent(data);
                    })
                    .catch(error => {
                        console.error('Error in sendMessage():' + JSON.stringify(error));
                        this.notifyUser('Error', error.message, 'error');
                    });
            }
        }
    }

    handleUploadFinished(event) {
        console.log('handleUploadFinished Enter');
        if (event.detail.files) {
            console.log('>>Doc id:' + event.detail.files[0].documentId);

            this.contentDocId = event.detail.files[0].documentId;
        }
    }

    handleTMP(event) {
        console.log('>Click');
    }

    //Template Methods:-------------------------------------------------------------------------------------------------
    get isPIMode() {
        return this.userMode === 'PI';
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

    get messageTemplateOptions() {
        let options = [];
        if (this.userMode === 'Participant' && this.messageTemplates) {
            this.messageTemplates.forEach(function (item) {
                options.push({
                    label: item,
                    value: item
                });
            });
        }
        return options;
    }

    checkSendBTNAvailability() {
        let sendBtn = this.template.querySelector('.ms-send-button');
        if (this.messageText && (this.selectedEnrollment || this.selectedEnrollments) && !this.isHoldMode) {
            this.isSendEnable = true;
            sendBtn.removeAttribute('disabled');
        } else {
            this.isSendEnable = false;
            sendBtn.setAttribute('disabled', '');
        }
    }

    changeAttachStyle() {
        let attachBTN = this.template.querySelector('.ms-att-file-label');
        if (attachBTN) {
            attachBTN.style.opacity = this.isSendEnable ? 1 : 0.5;
            attachBTN.style.pointerEvents = this.isSendEnable ? 'all' : 'none';
        }
    }

    //Service Methods:--------------------------------------------------------------------------------------------------
    clearMessage() {
        this.messageText = null;
        this.isSendEnable = false;
        this.template.querySelector('.ms-send-button').setAttribute('disabled', '');
        this.changeAttachStyle();
    }

    fireSendEvent(wrapper) {
        this.dispatchEvent(new CustomEvent('conversationupdate', {
            detail: {
                conWr: wrapper
            }
        }));
        this.clearMessage();
    }

    fireMultipleSendEvent() {
        this.dispatchEvent(new CustomEvent('multiplymailing'));
    }

    notifyUser(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({title, message, variant}));
    }
}