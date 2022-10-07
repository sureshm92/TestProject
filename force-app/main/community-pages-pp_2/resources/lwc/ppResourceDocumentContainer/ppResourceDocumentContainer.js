import { LightningElement, track } from 'lwc';
import getStudyDocuments from '@salesforce/apex/ResourceRemote.getStudyDocuments';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PpResourceDocumentContainer extends LightningElement {
    @track documentList = '';
    @track documents = [];

    connectedCallback() {
        this.getDocuments();
    }

    getDocuments() {
        getStudyDocuments()
            .then((result) => {
                this.documentList = result.wrappers;
                for (let i = 0; i < this.documentList.length; i++) {
                    let file = {
                        Id: this.documentList[i].resource.Id,
                        Title: this.documentList[i].resource.Title__c,
                        VersionDate: this.documentList[i].resource.Version_Date__c,
                        thumbnailFileCard:
                            '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&amp;versionId=' +
                            this.documentList[i].thumbnailDocId
                    };
                    this.documents.push(file);
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
