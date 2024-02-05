import { LightningElement, api } from 'lwc';
import versionDate from '@salesforce/label/c.Version_date';
import { NavigationMixin } from 'lightning/navigation';
import VIEW_RESOURCE from '@salesforce/label/c.PP_View_Resource';
import DOWNLOAD_RESOURCE from '@salesforce/label/c.PP_Download_Resource';
import DEVICE from '@salesforce/client/formFactor';
export default class PpDocumentUpdates extends NavigationMixin(LightningElement) {
    @api documentData;
    @api showVisitSection;
    @api desktop;
    noDocumentImage = false;
    thumbnailPresent = false;
    subDomain;
    thumbnail;
    hideCmp;
    label = {
        versionDate,
        VIEW_RESOURCE,
        DOWNLOAD_RESOURCE
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
    get isAppDoc(){
        if (communityService.isInitialized()) {
            if (communityService.isMobileSDK() && (this.documentData.resourceDevRecordType == 'Study_Document')) {
                return true;
            }
        }
        return false;           
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
            if (communityService.isMobileSDK() && (this.documentData.resourceDevRecordType == 'Study_Document')) {
                 this.hideCmp = true;
                 window.open('../sfc/servlet.shepherd/document/download/' + this.documentData.thumbnailDocId)
                 const decrimentCountEvent = new CustomEvent('decrimentcount', {
                 detail: null
            });
            this.dispatchEvent(decrimentCountEvent);
     
            }
        else{
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
    }
    removeCardHandler() {
        const removeCardEvent = new CustomEvent('removecard', {
            detail: { sendResultId: this.documentData.sendResultId }
        });
        this.dispatchEvent(removeCardEvent);
    }
}
