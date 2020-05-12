/**
 * Created by Igor Malyuta on 03.05.2020.
 */

import {LightningElement, track, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import getEmailTemplateWrappers from '@salesforce/apex/EmailTestBoardRemote.getEmailTemplateWrappers';
import searchRecipient from '@salesforce/apex/EmailTestBoardRemote.searchRecipient';
import searchRelated from '@salesforce/apex/EmailTestBoardRemote.searchRelated';
import getPreviewHTML from '@salesforce/apex/EmailTestBoardRemote.getPreviewHTML';
import sendEmail from '@salesforce/apex/EmailTestBoardRemote.sendEmail';

export default class EmailTestBoard extends LightningElement {

    @track selectedEmail;
    @track sendMethod = 'notification';
    @track onlyImmediately;

    @track recipientId;
    recipientType = 'Contact';
    @track recipientSearchMethod = 'Name';

    @track relatedDisabled;
    @track relatedId;
    @track relatedSearchMethod = 'Name';
    relatedObjectLabel = 'Participant Enrollment';

    @track showPreview;
    @track previewHtml;
    emailWrappers;
    mainSpinner;
    previewSpinner;

    renderedCallback() {
        this.mainSpinner = this.template.querySelector('.main-spinner');
        if(!this.emailWrappers) this.mainSpinner.show();
        this.previewSpinner = this.template.querySelector('.preview-spinner');
    }


    @wire(getEmailTemplateWrappers)
    wireData({data, error}) {
        if (data) {
            this.emailWrappers = data;
            if(this.mainSpinner) this.mainSpinner.hide();
        } else if (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Init data Error',
                message: 'An error occurred while getting initial data.',
                variant: 'error'
            }));
            console.error('Wire error:' + JSON.stringify(error));
        }
    }

    get isRecipientSearchByName() {
        return this.recipientSearchMethod === 'Name';
    }

    get isRelatedSearchByName() {
        return this.relatedSearchMethod === 'Name';
    }

    get relatedInputPlaceholder() {
        if (!this.relatedObjectLabel) return '';
        return 'Type ' + this.relatedObjectLabel + (this.relatedSearchMethod === 'Name' ? ' Name' : ' Id') + ' here...';
    }

    get actionBtnDisabled() {
        return false;
    }

    //Options:----------------------------------------------------------------------------------------------------------
    get emailTemplateOptions() {
        let options = [];
        if (this.emailWrappers) {
            this.emailWrappers.forEach(wr => {
                options.push({
                    label: wr.emailLabel,
                    value: wr.emailDevName
                });
            });
        }
        return options;
    }

    get sendOptions() {
        let options = [];
        options.push({
                label: 'Notification',
                value: 'notification'
            },
            {
                label: 'Immediately',
                value: 'immediately'
            }
        );
        return options;
    }

    get searchOptions() {
        let options = [];
        options.push({
                label: 'Name',
                value: 'Name'
            },
            {
                label: 'Id',
                value: 'Id'
            }
        );
        return options;
    }

    //Handlers:---------------------------------------------------------------------------------------------------------
    handleEmailChange(event) {
        this.selectedEmail = event.target.value;

        let context = this;
        this.emailWrappers.some(wr => {
            if (wr.emailDevName === context.selectedEmail) {
                context.recipientType = wr.recipientType;
                context.onlyImmediately = !wr.supportNotification;
                context.relatedObjectLabel = wr.relatedObjLabel;
                return true;
            }
        });
        this.sendMethod = this.onlyImmediately ? 'immediately' : this.sendMethod;
        this.relatedDisabled = this.onlyImmediately;
        this.relatedId = null;
        this.relatedSearchMethod = this.relatedDisabled ? 'Id' : this.relatedSearchMethod;
    }

    handleSendMethodChange(event) {
        this.sendMethod = event.target.value;
    }

    handleRecipientSearchMethodChange(event) {
        this.recipientSearchMethod = event.target.value;
        this.recipientId = null;
    }

    handleRecipientIdChange(event) {
        this.recipientId = event.target.value;
    }

    handleRelatedSearchMethodChange(event) {
        this.relatedSearchMethod = event.target.value;
        this.relatedId = null;
    }

    handleRelatedIdChange(event) {
        this.relatedId = event.target.value;
    }

    handleShowClick() {
        this.showPreview = !this.showPreview;
        if (this.showPreview) {
            this.previewSpinner.show();
            let context = this;
            getPreviewHTML({
                emailName: context.selectedEmail,
                contactId: context.recipientId,
                relatedId: context.relatedId
            })
                .then(result => {
                    console.log(result);
                    context.previewHtml = result;
                })
                .catch(error => {
                    this.showPreview = false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: '',
                        message: 'Preview error',
                        variant: 'error'
                    }));
                    console.error('Preview error', JSON.stringify(error));
                })
                .finally(() => {
                    this.previewSpinner.hide();
                });
        } else {
            this.previewHtml = null;
        }
    }

    handleSendClick() {
        this.mainSpinner.show();
        sendEmail({
            emailName: this.selectedEmail,
            contactId: this.recipientId,
            recipientType: this.recipientType,
            relatedId: this.relatedId,
            sendMethod: this.sendMethod
        })
            .then(() => {
                alert('Success!');
            })
            .catch(error => {
                console.error('Send error', JSON.stringify(error));
            })
            .finally(() => {
                this.mainSpinner.hide();
            });
    }

    //Search handlers:--------------------------------------------------------------------------------------------------
    handleRecipientSearch(event) {
        searchRecipient({
            searchTerm: event.detail.searchTerm
        })
            .then(results => {
                this.template.querySelector('.recipient-look-up').setSearchResults(results);
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

    handleRelatedSearch(event) {
        searchRelated({
            objT: 'Participant_Enrollment__c',
            searchTerm: event.detail.searchTerm
        })
            .then(results => {
                this.template.querySelector('.related-look-up').setSearchResults(results);
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

    handleRecipientSelectionChange() {
        this.recipientId = this.setChangedSelection('.recipient-look-up');
    }

    handleRelatedSelectionChange() {
        this.relatedId = this.setChangedSelection('.related-look-up');
    }

    setChangedSelection(lookUpClass) {
        let selectedId;
        let lookUp = this.template.querySelector(lookUpClass);
        if (lookUp) {
            selectedId = lookUp.getSelection().length > 0 ? lookUp.getSelection()[0] : null;
        }
        return selectedId;
    }
}