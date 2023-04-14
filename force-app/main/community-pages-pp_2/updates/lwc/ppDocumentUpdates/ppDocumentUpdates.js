import { LightningElement, api } from 'lwc';
import versionDate from '@salesforce/label/c.Version_date';
import removeCard from '@salesforce/apex/PPUpdatesController.removeUpdateCard';
import { NavigationMixin } from 'lightning/navigation';
import VIEW_RESOURCE from '@salesforce/label/c.PP_View_Resource';
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
