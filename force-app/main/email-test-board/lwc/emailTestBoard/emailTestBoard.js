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

    @track currentEmailWrapper;
    @track selectedEmail;
    @track sendMethod = 'notification';

    @track recipientId;
    @track recipientSearchMethod = 'Name';
    @track relatedId;
    @track relatedSearchMethod = 'Id';

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

    get isSupportNotification() {
        if(!this.currentEmailWrapper) return true;
        return !this.currentEmailWrapper.supportNotification;
    }

    get isSupportRelatedSearchByName () {
        if(!this.currentEmailWrapper) return true;
        return !this.currentEmailWrapper.supportSearchByName;
    }

    get isRecipientSearchByName() {
        return this.recipientSearchMethod === 'Name';
    }

    get isRelatedSearchByName() {
        return this.relatedSearchMethod === 'Name';
    }

    get relatedInputPlaceholder() {
        if (!this.currentEmailWrapper || !this.currentEmailWrapper.relatedObjLabel) return '';
        return 'Type ' + this.currentEmailWrapper.relatedObjLabel
            + (this.relatedSearchMethod === 'Name' ? ' Name' : ' Id') + ' here...';
    }

    get isRelatedInputDisabled() {
        if(!this.currentEmailWrapper) return true;
        return !this.currentEmailWrapper.supportNotification;
    }

    get isPreviewDisabled() {
        if(!this.currentEmailWrapper || !this.recipientId) return true;
        return !this.relatedId;
    }

    get isSendDisabled() {
        if(!this.currentEmailWrapper || !this.recipientId) return true;
        if(this.currentEmailWrapper.supportNotification && !this.relatedId) return true;
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
        this.currentEmailWrapper = null;
        this.selectedEmail = event.target.value;
        this.emailWrappers.some(wr => {
            if (wr.emailDevName === this.selectedEmail) {
                this.currentEmailWrapper = wr;
                return true;
            }
        });
        this.sendMethod = this.currentEmailWrapper.supportNotification ? this.sendMethod : 'immediately';
        this.relatedSearchMethod = this.currentEmailWrapper.supportSearchByName ? 'Name' : 'Id';
        this.clearSelection(this.relatedId, '.related-look-up');
    }

    handleSendMethodChange(event) {
        this.sendMethod = event.target.value;
    }

    handleRecipientSearchMethodChange(event) {
        this.recipientSearchMethod = event.target.value;
        this.clearSelection(this.recipientId, '.recipient-look-up');
    }

    handleRecipientIdChange(event) {
        this.recipientId = event.target.value;
    }

    handleRelatedSearchMethodChange(event) {
        this.relatedSearchMethod = event.target.value;
        this.clearSelection(this.relatedId, '.related-look-up');
    }

    handleRelatedIdChange(event) {
        this.relatedId = event.target.value;
    }

    handleShowClick() {
        this.showPreview = !this.showPreview;
        if (this.showPreview) {
            this.previewSpinner.show();
            getPreviewHTML({
                wrapper: JSON.stringify(this.currentEmailWrapper),
                contactId: this.recipientId,
                relatedId: this.relatedId
            })
                .then(result => {
                    this.previewHtml = result;
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
            wrapper: JSON.stringify(this.currentEmailWrapper),
            contactId: this.recipientId,
            relatedId: this.relatedId,
            sendMethod: this.sendMethod
        })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: '',
                    message: 'Email was sent',
                    variant: 'success'
                }));
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
            objName: this.currentEmailWrapper.relatedObjName,
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

    clearSelection(field, lookUpClass) {
        if(field) {
            let lookUp = this.template.querySelector(lookUpClass);
            if (lookUp) lookUp.clearSelection();
        }
    }
}