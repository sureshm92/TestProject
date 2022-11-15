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
    empty_state = pp_community_icons + '/' + 'documents_empty.png';

    connectedCallback() {
        this.getDocuments();
    }

    async getDocuments() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) {
            this.spinner.show();
        }
        await getStudyDocuments()
            .then((result) => {
                this.documentList = result.wrappers;
                if (this.documentList.length > 0) {
                    this.documentPresent = true;
                } else {
                    this.documentPresent = false;
                }
            })
            .catch((error) => {
                this.showErrorToast('Error occured', error.message, 'error');
            });
        if (this.spinner) {
            this.spinner.hide();
        }
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
