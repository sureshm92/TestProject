import { LightningElement, track } from 'lwc';
import getStudyDocuments from '@salesforce/apex/ResourceRemote.getStudyDocuments';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import noDocumentsAvailable from '@salesforce/label/c.No_Documents_Available';
export default class PpResourceDocumentContainer extends LightningElement {
    documentList = [];
    documents = [];
    documentPresent = false;

    label = {
        noDocumentsAvailable
    };

    connectedCallback() {
        this.getDocuments();
    }

    getDocuments() {
        getStudyDocuments()
            .then((result) => {
                this.documentList = result.wrappers;
                if (this.documentList.length > 0) {
                    this.documentPresent = true;
                }
            })
            .catch((error) => {
                this.showErrorToast('Error occured', error.message, 'error');
            });
    }

    showErrorToast(titleText, messageText, variantType) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: titleText,
                message: messageText,
                variant: variantType
            })
        );
    }
}
