/**
 * Created by Igor Malyuta on 21.12.2019.
 */

import {LightningElement, api, track, wire} from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import communityStyle from '@salesforce/resourceUrl/rr_community_css';
import proxima from '@salesforce/resourceUrl/proximanova';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import messagesLabel from '@salesforce/label/c.MS_Messages';
import newMessLabel from '@salesforce/label/c.MS_New_Mess';
import emptyConversationLabel from '@salesforce/label/c.MS_Empty_Conversations';
import studyTeamLabel from '@salesforce/label/c.Study_Team';
import attachmentLabel from '@salesforce/label/c.MS_Attachment';

import getInit from '@salesforce/apex/MessagePageRemote.getInitData';
import markRead from '@salesforce/apex/MessagePageRemote.markConversationAsRead';

export default class MessagesPage extends LightningElement {

    labels = {messagesLabel, newMessLabel, emptyConversationLabel, studyTeamLabel, attachmentLabel};

    spinner;
    messageBoard;
    messageTemplates;

    @track initialized;
    @track hideEmptyStub;
    @track creationMode;

    @track userMode = 'Participant';
    @track enrollments;
    @track canStartConversation;
    @track conversationWrappers;

    @track selectedConWrapper;

    renderedCallback() {
        if (!this.initialized) {
            this.spinner = this.template.querySelector('c-web-spinner');
            this.spinner.show();

            loadStyle(this, proxima + '/proximanova.css');
            loadStyle(this, communityStyle);
        }

        if (!this.messageBoard && this.initialized) {
            if (!this.canStartConversation) this.changePlusStyle(false);

            this.messageBoard = this.template.querySelector('c-message-board');
            if (this.userMode === 'Participant') {
                this.messageBoard.setTemplates(this.messageTemplates);
            }

            //Select top conversation when page load
            // if (this.conversationWrappers) {
            //     let firstConversationWrapper = this.conversationWrappers[0];
            //     this.messageBoard.openExisting(firstConversationWrapper.conversation, firstConversationWrapper.messages);
            //     this.changeConversationsBackground(firstConversationWrapper.conversation.Id);
            // }
        }
    }

    @wire(getInit)
    wireInitData({data, error}) {
        if (data) {
            this.userMode = data.userMode;
            this.enrollments = data.enrollments;
            this.conversationWrappers = data.conversationWrappers;
            this.canStartConversation = this.checkCanStartNewConversation();

            this.initialized = true;
            if (this.userMode === 'Participant') this.messageTemplates = data.messageTemplates;
            if (this.conversationWrappers && this.conversationWrappers.length > 0) this.hideEmptyStub = true;

            if (this.spinner) this.spinner.hide();
        } else if (error) {
            console.log('Error:' + JSON.stringify(error));
            if (this.spinner) this.spinner.hide();
        }
    }

    get isPIMode() {
        return this.userMode === 'PI';
    }

    //Handlers:---------------------------------------------------------------------------------------------------------
    handleNewMessageClick(event) {
        if (!this.canStartConversation) return;

        this.hideEmptyStub = true;
        this.creationMode = true;
        this.changePlusStyle(false);
        this.changeConversationsBackground(null);

        let enrollments = this.userMode === 'PI' ? this.enrollments : this.getFreeEnrollments();
        this.messageBoard.startNew(enrollments);
    }

    handleOpenConversation(event) {
        let conItem = event.detail.item;

        if (this.creationMode) {
            this.creationMode = false;
            this.canStartConversation = this.checkCanStartNewConversation();
            this.changePlusStyle(this.canStartConversation);
        }

        this.changeConversationsBackground(conItem.conversation.Id);
        this.messageBoard.openExisting(conItem.conversation, conItem.messages, conItem.isPastStudy);
    }

    handleMessageSend(event) {
        let conWr = event.detail.conWr;
        let isNew = true;
        let updatedWrappers = [];
        if (this.conversationWrappers) {
            this.conversationWrappers.forEach(wr => {
                if (wr.conversation.Id === conWr.conversation.Id) {
                    updatedWrappers.push(conWr);
                    isNew = false;
                } else {
                    updatedWrappers.push(wr);
                }
            });
        }

        if (isNew) updatedWrappers.unshift(conWr);

        this.conversationWrappers = updatedWrappers;
        this.creationMode = false;
        this.canStartConversation = this.checkCanStartNewConversation();
        this.changePlusStyle(this.canStartConversation);

        //Wait for Rerender
        let context = this;
        setTimeout(() => {
            context.changeConversationsBackground(conWr.conversation.Id);
        }, 50);

        this.messageBoard.openExisting(conWr.conversation, conWr.messages);
    }

    //Service Methods:--------------------------------------------------------------------------------------------------
    changePlusStyle(enabled) {
        let newMessBTN = this.template.querySelector('.ms-btn-new');
        newMessBTN.style.opacity = enabled ? 1 : 0.5;
        newMessBTN.style.cursor = enabled ? 'pointer' : 'default';
    }

    checkCanStartNewConversation() {
        if (!this.enrollments || this.enrollments.length < 1) return false;
        if (!this.conversationWrappers) return true;
        if (this.userMode === 'PI' && this.enrollments.length === 1) {
            if (this.conversationWrappers.length === 1) {
                let conPEId = this.conversationWrappers[0].conversation.Participant_Enrollment__c;
                if (this.enrollments[0].Id === conPEId) return false;
            }
            return true;
        }

        return this.getFreeEnrollments().length !== 0;
    }

    changeConversationsBackground(conId) {
        let conItems = this.template.querySelectorAll('c-conversation-item');
        if (conItems) {
            conItems.forEach(conItem => {
                conItem.setSelectedMode(conItem.item.conversation.Id === conId);
            });
        }
    }

    //For Participants
    getFreeEnrollments() {
        if (!this.enrollments) return null;
        if (!this.conversationWrappers) return this.enrollments;

        let context = this;
        let freeEnrollments = [];
        this.enrollments.forEach(pe => {
            let engagedEnrollment;
            context.conversationWrappers.forEach(wr => {
                if (wr.conversation.Participant_Enrollment__c === pe.Id) engagedEnrollment = pe;
            });

            if (!engagedEnrollment) freeEnrollments.push(pe);
        });

        return freeEnrollments;
    }
}