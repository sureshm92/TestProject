/**
 * Created by Igor Malyuta on 21.12.2019.
 */

import { LightningElement, track, wire } from 'lwc';
import formFactor from '@salesforce/client/formFactor';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubSub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import messagesLabel from '@salesforce/label/c.MS_Messages';
import newMessLabel from '@salesforce/label/c.MS_New_Mess';
import emptyConversationLabel from '@salesforce/label/c.MS_Empty_Conversations';
import studyTeamLabel from '@salesforce/label/c.Study_Team';
import disclaimerLabel from '@salesforce/label/c.MS_Chat_Disclaimer';
import showMoreLabel from '@salesforce/label/c.MS_Show_More';
import showLessLabel from '@salesforce/label/c.MS_Show_Less';

import getInit from '@salesforce/apex/MessagePageRemote.getInitData';

export default class MessagesPage extends NavigationMixin(LightningElement) {
    labels = {
        messagesLabel,
        newMessLabel,
        emptyConversationLabel,
        studyTeamLabel,
        disclaimerLabel,
        showMoreLabel,
        showLessLabel
    };

    stubLoad;
    spinner;
    needAfterRenderSetup;
    messageBoard;
    messageTemplates;
    firstConWrapper;
    statusByPeMap;
    isRTL;
    @track showFullDisclaimer;
    @track showBTNLabel = showMoreLabel;

    @track leftDisplay;
    @track rtlDisplay = 'ss';
    @track rightDisplay;

    @track initialized;
    @track hideEmptyStub;
    @track creationMode;

    @track userMode = 'Participant';
    @track enrollments;
    @track canStartConversation;
    @track conversationWrappers;
    // @track isRTL;
    @track selectedConWrapper;
    @track piContactNames;

    connectedCallback() {
        registerListener('reload', this.handleRefreshEvent, this);
        this.needAfterRenderSetup = true;
        this.leftDisplay = true;
        this.rightDisplay = formFactor !== 'Small';
        this.initializer();
    }

    renderedCallback() {
        if (!this.initialized && this.stubLoad) {
            this.spinner = this.template.querySelector('c-web-spinner');
            if (this.spinner) {
                this.spinner.show();
            }
        }

        if (!this.messageBoard && this.initialized) {
            if (!this.canStartConversation) this.changePlusStyle(false);

            this.messageBoard = this.template.querySelector('c-message-board');
            if (this.userMode === 'Participant') {
                this.messageBoard.setTemplates(this.messageTemplates, this.piContactNames);
            }
        }

        if (this.initialized) {
            if (this.firstConWrapper && this.needAfterRenderSetup && formFactor !== 'Small') {
                this.changeConversationsBackground(this.firstConWrapper.conversation.Id);
            }

            this.needAfterRenderSetup = false;
            if (this.spinner) {
                this.spinner.hide();
            }
        }
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    @wire(CurrentPageReference) pageRef;

    //Template Methods:-------------------------------------------------------------------------------------------------
    get disclaimerFullClass() {
        return 'ms-disc-mob-label ' + (this.showFullDisclaimer ? 'visible' : 'hide');
    }

    get disclaimerLessClass() {
        return 'ms-disc-mob-label ' + (this.showFullDisclaimer ? 'hide' : 'visible');
    }

    get leftPartClass() {
        let context = this;
        return (
            'slds-col slds-large-size--1-of-3 slds-medium-size--1-of-3 slds-small-size--1-of-1 ms-left ' +
            (context.isRTL ? ' msgrtl  ' : '') +
            ' ' +
            (this.leftDisplay ? ' visible ' : ' hide ')
        );
    }

    get isRTLret() {
        let context = this;
        return context.isRTL ? 'rtl' : '';
    }
    get headertitleRTL() {
        let context = this;
        return context.isRTL ? 'headertitle' : '';
    }

    get newMessLabelRTL() {
        let context = this;
        return context.isRTL ? 'ms-new-mode newMsgLabel' : 'ms-new-mode';
    }

    get conversationBoardStyles() {
        return navigator.userAgent.match(/Trident/) ? '' : 'display: flex; flex-direction: column;';
    }

    get rightPartClass() {
        return (
            'slds-col slds-large-size--2-of-3 slds-medium-size--2-of-3 slds-small-size--1-of-1 ms-right ' +
            (this.rightDisplay ? '' : 'hide')
        );
    }

    get isPIMode() {
        return this.userMode === 'PI';
    }

    //Handlers:---------------------------------------------------------------------------------------------------------
    handleShowMoreClick(event) {
        this.showFullDisclaimer = !this.showFullDisclaimer;
        this.showBTNLabel = this.showFullDisclaimer ? showLessLabel : showMoreLabel;
    }

    handleNewMessageClick(event) {
        if (!this.canStartConversation) return;

        this.hideEmptyStub = true;
        this.creationMode = true;
        this.changePlusStyle(false);
        this.changeConversationsBackground(null);

        let enrollments = this.userMode === 'PI' ? this.enrollments : this.getFreeEnrollments();
        this.messageBoard.startNew(enrollments, this.statusByPeMap, this.piContactNames);
        this.changeVisiblePart();
    }

    handleOpenConversation(event) {
        let conItem = event.detail.item;
        this.closeCreationMode();

        this.changeConversationsBackground(conItem.conversation.Id);
        this.messageBoard.openExisting(
            conItem.conversation,
            conItem.messages,
            conItem.isPastStudy,
            conItem.patientDelegates,
            this.piContactNames
        );
        this.changeVisiblePart();
    }

    handleBoardClose(event) {
        this.changeVisiblePart();
        this.closeCreationMode();
        this.changeConversationsBackground(null);
        if (!this.conversationWrappers) this.hideEmptyStub = false;
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

        updatedWrappers.sort(function (a, b) {
            return (
                new Date(b.messages[0].message.CreatedDate) -
                new Date(a.messages[0].message.CreatedDate)
            );
        });

        this.conversationWrappers = updatedWrappers;
        this.creationMode = false;
        this.canStartConversation = this.checkCanStartNewConversation();
        this.changePlusStyle(this.canStartConversation);

        //Wait for Rerender
        let context = this;
        setTimeout(function () {
            context.changeConversationsBackground(conWr.conversation.Id);
        }, 50);

        this.messageBoard.openExisting(
            conWr.conversation,
            conWr.messages,
            conWr.isPastStudy,
            conWr.patientDelegates,
            this.piContactNames
        );
    }

    handleRefreshEvent() {
        if (this.spinner) this.spinner.show();
        this.messageBoard.closeBoard();
        this.changeVisiblePart();
        this.initialized = false;
        this.needAfterRenderSetup = true;
        this.messageBoard = null;

        this.initializer();
    }

    //Service Methods:--------------------------------------------------------------------------------------------------
    initializer() {
        this.creationMode = false;
        this.conversationWrappers = null;
        this.enrollments = null;

        let context = this;
        setTimeout(function () {
            let stub = context.template.querySelector('c-builder-stub');
            stub.isDummy(function (dummy) {
                if (!dummy) {
                    getInit({
                        formFactor: formFactor,
                        isIE: navigator.userAgent.match(/Trident|Edge/) !== null
                    })
                        .then((data) => {
                            if (!data.isPageEnabled) {
                                context[NavigationMixin.Navigate]({
                                    type: 'comm__namedPage',
                                    attributes: {
                                        pageName: 'home'
                                    }
                                });
                            }

                            context.userMode = data.userMode;
                            context.enrollments = data.enrollments;
                            context.statusByPeMap = data.statusByPeMap;
                            context.piContactNames = data.piContactNames;
                            context.isRTL = data.isRTL;
                            context.conversationWrappers = data.conversationWrappers;
                            if (context.conversationWrappers)
                                context.firstConWrapper = context.conversationWrappers[0];
                            context.canStartConversation = context.checkCanStartNewConversation();
                            context.initialized = true;
                            if (context.userMode === 'Participant')
                                context.messageTemplates = data.messageTemplates;
                            if (
                                context.conversationWrappers &&
                                context.conversationWrappers.length > 0
                            )
                                context.hideEmptyStub = true;
                        })
                        .catch((error) => {
                            console.error('Error in getInit():' + JSON.stringify(error));
                            context.notifyUser('Error', error.message, 'error');
                        });
                } else {
                    stub.setPageName('cMessagesPage');
                }
                context.stubLoad = true;
            });
        }, 1);
    }

    changePlusStyle(enabled) {
        let newMessBTN = this.template.querySelector('.ms-btn-new');
        newMessBTN.style.opacity = enabled ? '1' : '0.5';
        newMessBTN.style.cursor = enabled ? 'pointer' : 'default';
    }

    checkCanStartNewConversation() {
        if (!this.enrollments || this.enrollments.length < 1) return false;
        if (!this.conversationWrappers) return true;
        if (this.userMode === 'PI') {
            return !(this.conversationWrappers.length === 1 && this.enrollments.length === 1);
        }

        let freeEnrollments = this.getFreeEnrollments();
        return freeEnrollments && freeEnrollments.length !== 0;
    }

    closeCreationMode() {
        if (this.creationMode) {
            this.creationMode = false;
            this.canStartConversation = this.checkCanStartNewConversation();
            this.changePlusStyle(this.canStartConversation);
        }
    }

    changeConversationsBackground(conId) {
        let conItems = this.template.querySelectorAll('c-conversation-item');
        if (conItems) {
            conItems.forEach(function (conItem) {
                conItem.setSelectedMode(conItem.item.conversation.Id === conId);
            });
        }
    }

    changeVisiblePart() {
        this.leftDisplay = formFactor !== 'Small' ? true : !this.leftDisplay;
        this.rightDisplay = formFactor !== 'Small' ? true : !this.rightDisplay;
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

    notifyUser(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}
