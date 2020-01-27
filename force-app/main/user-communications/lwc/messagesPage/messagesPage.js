/**
 * Created by Igor Malyuta on 21.12.2019.
 */

import {LightningElement, api, track, wire} from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import communityStyle from '@salesforce/resourceUrl/rr_community_css';
import proxima from '@salesforce/resourceUrl/proximanova';
import {CurrentPageReference} from 'lightning/navigation';
import {registerListener, unregisterAllListeners} from 'c/pubSub';

import messagesLabel from '@salesforce/label/c.MS_Messages';
import newMessLabel from '@salesforce/label/c.MS_New_Mess';
import emptyConversationLabel from '@salesforce/label/c.MS_Empty_Conversations';
import studyTeamLabel from '@salesforce/label/c.Study_Team';
import attachmentLabel from '@salesforce/label/c.MS_Attachment';

import getInit from '@salesforce/apex/MessagePageRemote.getInitData';

export default class MessagesPage extends LightningElement {

    labels = {messagesLabel, newMessLabel, emptyConversationLabel, studyTeamLabel, attachmentLabel};

    spinner;
    messageBoard;
    messageTemplates;
    firstConWrapper;

    @track initialized;
    @track hideEmptyStub;
    @track creationMode;

    @track userMode = 'Participant';
    @track enrollments;
    @track canStartConversation;
    @track conversationWrappers;

    @track selectedConWrapper;


    connectedCallback() {
        registerListener('reload', this.handleRefreshEvent, this);
        this.initializer();
    }

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
            if (this.userMode === 'Participant') this.messageBoard.setTemplates(this.messageTemplates);

            if (this.firstConWrapper) this.changeConversationsBackground(this.firstConWrapper.conversation.Id);
        }

        if (this.initialized) this.spinner.hide();
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    @wire(CurrentPageReference) pageRef;

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
            this.conversationWrappers.forEach(function (wr) {
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
        setTimeout(function () {
            context.changeConversationsBackground(conWr.conversation.Id);
        }, 50);

        this.messageBoard.openExisting(conWr.conversation, conWr.messages, conWr.isPastStudy);
    }

    handleRefreshEvent() {
        if (this.spinner) this.spinner.show();
        this.messageBoard.closeBoard();
        this.initialized = false;
        this.messageBoard = null;

        this.initializer();
    }

    //Service Methods:--------------------------------------------------------------------------------------------------
    initializer() {
        this.creationMode = false;
        this.conversationWrappers = null;
        this.enrollments = null;

        getInit()
            .then(data => {
                this.userMode = data.userMode;
                this.enrollments = data.enrollments;

                this.conversationWrappers = data.conversationWrappers;
                if (this.conversationWrappers) this.firstConWrapper = this.conversationWrappers[0];
                this.canStartConversation = this.checkCanStartNewConversation();

                this.initialized = true;
                if (this.userMode === 'Participant') this.messageTemplates = data.messageTemplates;
                if (this.conversationWrappers && this.conversationWrappers.length > 0) this.hideEmptyStub = true;
            })
            .catch(error => {
                console.error('Error in getInit():' + JSON.stringify(error));
            });
    }

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
            conItems.forEach(function (conItem) {
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
        this.enrollments.forEach(function (pe) {
            let engagedEnrollment;
            context.conversationWrappers.forEach(function (wr) {
                if (wr.conversation.Participant_Enrollment__c === pe.Id) engagedEnrollment = pe;
            });

            if (!engagedEnrollment) freeEnrollments.push(pe);
        });

        return freeEnrollments;
    }
}