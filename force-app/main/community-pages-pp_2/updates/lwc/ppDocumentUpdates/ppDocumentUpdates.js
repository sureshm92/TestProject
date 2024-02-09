import { LightningElement, api } from 'lwc';
import versionDate from '@salesforce/label/c.Version_date';
import { NavigationMixin } from 'lightning/navigation';
import VIEW_RESOURCE from '@salesforce/label/c.PP_View_Resource';
import DEVICE from '@salesforce/client/formFactor';
export default class PpDocumentUpdates extends NavigationMixin(LightningElement) {
    @api documentData;
    @api showVisitSection;
    @api desktop;
    noDocumentImage = false;
    thumbnailPresent = false;
    subDomain;
    thumbnail;
    label = {
        versionDate,
        VIEW_RESOURCE
    };
    get cardElement() {
        if (DEVICE == 'Medium') {
            return 'slds-col slds-size_3-of-12 card-element';
        } else {
            return 'slds-col slds-size_2-of-6 card-element';
        }
    }
    get cardDataElement() {
        if (DEVICE == 'Medium') {
            return 'slds-col slds-size_9-of-12 card-data-element';
        } else {
            return 'slds-col slds-size_4-of-6 card-data-element';
        }
    }
   
    connectedCallback() {
        if (this.documentData.thumbnailDocId) {
            this.subDomain = communityService.getSubDomain();
            this.thumbnail =
                this.subDomain +
                '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' +
                this.documentData.thumbnailDocId;
            this.thumbnailPresent = true;
        }
    }

    handleNoThumnnailError() {
        this.thumbnailPresent = false;
    }

    navigateResourceDetail() {
        this.removeCardHandler();
        let participantState;
        if (communityService.isInitialized()) {
            participantState = communityService.getCurrentCommunityMode().participantState;
        }

            this[NavigationMixin.Navigate]({
             type: 'comm__namedPage',
             attributes: {
                 pageName: 'resource-detail'
            },
            state: {
                resourceid: this.documentData.recId,
                resourcetype: this.documentData.resourceDevRecordType,
                state: participantState,
                showHomePage: true
            }
        });
    }
    removeCardHandler() {
        const removeCardEvent = new CustomEvent('removecard', {
            detail: { sendResultId: this.documentData.sendResultId }
        });
        this.dispatchEvent(removeCardEvent);
    }
}
