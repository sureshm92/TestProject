import { LightningElement, track } from 'lwc';
import getStudyDocuments from '@salesforce/apex/ResourceRemote.getStudyDocuments';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import noDocumentsAvailable from '@salesforce/label/c.No_Documents_Available';

import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';

export default class PpResourceDocumentContainer extends LightningElement {
    documentList = [];
    documents = [];
    documentPresent = false;

    label = {
        noDocumentsAvailable
    };

    empty_state = pp_community_icons + '/' + 'documents_empty.png';

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
