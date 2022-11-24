import { LightningElement, track } from 'lwc';
import getStudyDocuments from '@salesforce/apex/ResourceRemote.getStudyDocuments';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import noDocumentsAvailable from '@salesforce/label/c.No_Documents_Available';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';

export default class PpResourceDocumentContainer extends LightningElement {
    documentList = [];
    documents = [];
    documentPresent;
    label = {
        noDocumentsAvailable
    };
    spinner;
    isRendered = false;
    loaded = false;
    empty_state = pp_community_icons + '/' + 'documents_empty.png';

    renderedCallback() {
        if (!this.isRendered) {
            this.isRendered = true;
            this.getDocuments();
        }
    }

    getDocuments() {
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner.show();
        getStudyDocuments()
            .then((result) => {
                this.documentList = result.wrappers;
                if (this.documentList.length > 0) {
                    this.documentPresent = true;
                } else {
                    this.documentPresent = false;
                }
                this.loaded = true;
            })
            .catch((error) => {
                this.loaded = true;
                this.showErrorToast('Error occured', error.message, 'error');
            });

        this.spinner.hide();
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
