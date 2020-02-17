/**
 * Created by Igor Malyuta on 24.12.2019.
 */

import {LightningElement, api, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import emptyChatLabel from '@salesforce/label/c.MS_Empty_Chat';
import selectLabel from '@salesforce/label/c.MS_Select';
import selectPlaceholderLabel from '@salesforce/label/c.MS_Select_Placeholder';
import inputPlaceholderLabel from '@salesforce/label/c.MS_Input_Placeholder';
import limitLabel from '@salesforce/label/c.MS_Char_Limit';
import attFileLabel from '@salesforce/label/c.MS_Attach_File';
import sendBtnLabel from '@salesforce/label/c.BTN_Send';
import fileLimitLabel from '@salesforce/label/c.MS_Attach_File_Limit';
import fileWrongExtLabel from '@salesforce/label/c.MS_Attach_File_Unsup_Type';

import createConversation from '@salesforce/apex/MessagePageRemote.createConversation';
import sendMessage from '@salesforce/apex/MessagePageRemote.sendMessage';
import sendMultipleMessage from '@salesforce/apex/MessagePageRemote.sendMultipleMessage';
import formFactor from "@salesforce/client/formFactor";

const attIconMap = {
    csv: 'attach-file-csv',
    doc: 'attach-file-doc',
    docx: 'attach-file-doc',
    jpg: 'attach-file-jpg',
    pdf: 'attach-file-pdf',
    png: 'attach-file-png',
    xls: 'attach-file-xls'
};

const base64Mark = 'base64,';

export default class MessageBoard extends LightningElement {

    labels = {
        emptyChatLabel,
        selectLabel,
        selectPlaceholderLabel,
        inputPlaceholderLabel,
        limitLabel,
        attFileLabel,
        sendBtnLabel
    };

    fileTypes = '.csv,.doc,.jpg,.pdf,.png,.xls';

    spinner;

    @api userMode;
    @api firstConWr;

    @track enrollments;
    @track conversation;
    @track messageWrappers;
    @track messageTemplates;
    @track isPastStudy;
    @track patientDelegates;

    @track isMultipleMode;
    @track selectedPeId;
    @track selectedEnrollment;
    @track selectedEnrollments;

    @track recipientSelections = [];

    @track messageText;
    @track attachment;
    @track isAttachEnable;
    @track isSendEnable;
    @track isHoldMode;

    @track hideEmptyStub;
    needAfterRenderSetup;

    //Public Methods:---------------------------------------------------------------------------------------------------
    @api
    setTemplates(templates) {
        this.messageTemplates = templates;
    }

    @api
    startNew(enrollments, statusByPeMap) {
        this.attachment = null;
        this.isAttachEnable = false;
        this.conversation = null;
        this.messageWrappers = [];
        this.isPastStudy = false;
        this.patientDelegates = null;
        this.isHoldMode = false;

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
    openExisting(conversation, messageWrappers, isPastStudy, patientDelegates) {
        this.attachment = null;
        this.isAttachEnable = false;
        this.conversation = null;
        this.messageWrappers = [];
        this.patientDelegates = null;

        this.isPastStudy = isPastStudy;
        if (patientDelegates) this.patientDelegates = patientDelegates;

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
        this.attachment = null;
        this.isAttachEnable = false;
        this.conversation = null;
        this.messageWrappers = null;
        this.enrollments = null;
        this.patientDelegates = null;
        this.isMultipleMode = false;
    }

    renderedCallback() {
        this.spinner = this.template.querySelector('c-web-spinner');

        if (this.firstConWr && !this.hideEmptyStub && !this.conversation && !this.enrollments && formFactor !== 'Small') {
            this.openExisting(
                this.firstConWr.conversation,
                this.firstConWr.messages,
                this.firstConWr.isPastStudy,
                this.firstConWr.patientDelegates
            );
        }

        if (this.needAfterRenderSetup) {
            let context = this;
            setTimeout(function () {
                context.clearMessage();
                let footerClass = '.ms-board-footer-' + context.userMode === 'PI' ? 'pi' : 'part';
                context.template.querySelector(footerClass).style.pointerEvents = context.isHoldMode ? 'none' : 'all';
            }, 50);

            this.needAfterRenderSetup = false;
        }
    }

    //Search Handlers:--------------------------------------------------------------------------------------------------
    handleSelectionChange(event) {
        this.selectedEnrollments = event.detail.selection;
        this.checkSendBTNAvailability();
    }

    //File Handlers:----------------------------------------------------------------------------------------------------
    handleFileSelect(event) {
        let file = event.target.files[0];

        let fileSize = parseInt((file.size / 1048576), 10);
        if (fileSize && fileSize >= 3) {
            this.notifyUser('', fileLimitLabel, 'warning');
            event.target.value = null;
            return;
        }
        let fileExtension = file.name.substring(file.name.lastIndexOf('.') + 1);
        if (fileExtension && !attIconMap[fileExtension]) {
            this.notifyUser('', fileWrongExtLabel, 'warning');
            event.target.value = null;
            return;
        }

        this.isAttachEnable = false;

        let fileReader = new FileReader();
        let context = this;
        fileReader.onloadend = function () {
            let readResult = fileReader.result;
            let dataStart = readResult.indexOf(base64Mark) + base64Mark.length;

            context.attachment = {
                fileContent: readResult.substring(dataStart),
                fileName: file.name,
                icon: attIconMap[fileExtension] ? attIconMap[fileExtension] : 'icon-blank'
            };
        };
        fileReader.readAsDataURL(file);
    }

    handleFilePreviewRemove() {
        this.attachment = null;
        this.isAttachEnable = this.isSendEnable;
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
        this.isAttachEnable = this.messageText != null;
        this.checkSendBTNAvailability();
    }

    handleInputEnter(event) {
        this.messageText = event.target.value;
        this.isAttachEnable = this.messageText != null;
        this.checkSendBTNAvailability();
        if (!this.isHoldMode && this.messageText && event.keyCode === 13) this.handleSendClick();
    }

    handleSendClick() {
        let messageText = this.messageText;
        let fileList;
        if (this.attachment) {
            fileList = [
                this.attachment.fileName,
                this.attachment.fileContent
            ];
        }
        this.clearMessage();

        if (this.spinner) this.spinner.show();

        let context = this;
        if (this.userMode === 'PI' && this.isMultipleMode && this.selectedEnrollments) {
            sendMultipleMessage({
                peIds: this.selectedEnrollments, messageText: messageText, fileJSON: JSON.stringify(fileList)
            })
                .then(function () {
                    context.fireMultipleSendEvent();
                })
                .catch(function (error) {
                    console.error('Error in sendMultipleMessage():' + JSON.stringify(error));
                    context.notifyUser('Error', error.message, 'error');
                })
                .finally(function () {
                    if (context.spinner) context.spinner.hide();
                });
        } else {
            if (!this.conversation && this.selectedEnrollment) {
                createConversation({
                    enrollment: this.selectedEnrollment,
                    messageText: messageText,
                    fileJSON: JSON.stringify(fileList)
                })
                    .then(function (data) {
                        context.fireSendEvent(data);
                    })
                    .catch(function (error) {
                        console.error('Error in createConversation():' + JSON.stringify(error));
                        context.notifyUser('Error', error.message, 'error');
                    })
                    .finally(function () {
                        if (context.spinner) context.spinner.hide();
                    });
            } else {
                sendMessage({
                    conversation: this.conversation,
                    messageText: messageText,
                    fileJSON: JSON.stringify(fileList)
                })
                    .then(function (data) {
                        context.fireSendEvent(data);
                    })
                    .catch(function (error) {
                        console.error('Error in sendMessage():' + JSON.stringify(error));
                        context.notifyUser('Error', error.message, 'error');
                    })
                    .finally(function () {
                        if (context.spinner) context.spinner.hide();
                    });
            }
        }
    }

    //Template Methods:-------------------------------------------------------------------------------------------------
    get isPIMode() {
        return this.userMode === 'PI';
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

    get attachBTNStyle() {
        return 'opacity: ' + (this.isSendEnable && this.isAttachEnable ? '1' : '0.5')
            + '; cursor: ' + (this.isSendEnable && this.isAttachEnable ? 'pointer' : 'default')
            + '; pointer-events: ' + (this.isSendEnable && this.isAttachEnable ? 'all' : 'none');
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

    //Service Methods:--------------------------------------------------------------------------------------------------
    clearMessage() {
        this.messageText = null;
        this.isSendEnable = false;
        this.template.querySelector('.ms-send-button').setAttribute('disabled', '');
        this.attachment = null;
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