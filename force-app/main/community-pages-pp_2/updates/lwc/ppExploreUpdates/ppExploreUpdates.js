import { LightningElement, api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import VERSION_DATE from '@salesforce/label/c.Version_date';
import POSTING_DATE from '@salesforce/label/c.Posting_date';
import VIEW_RESOURCE from '@salesforce/label/c.PP_View_Resource';
import DEVICE from '@salesforce/client/formFactor';
export default class PpExploreUpdates extends NavigationMixin(LightningElement) {
    @api exploreData;
    @api showVisitSection;
    @api desktop;
    noExploreImage = false;
    labels = {
        VERSION_DATE,
        POSTING_DATE,
        VIEW_RESOURCE
    };  
    @track isAndroidTab=false;

    get cardElement() {
        if (DEVICE == 'Medium' || ( DEVICE == 'Small' && this.isAndroidTab)) {
            return 'slds-col slds-size_3-of-12 card-element';
        } else {
            return 'slds-col slds-size_2-of-6 card-element';
        }
    }
    get cardDataElement() {
        if (DEVICE == 'Medium' || ( DEVICE == 'Small' && this.isAndroidTab)) {
            return 'slds-col slds-size_9-of-12 card-data-element';
        } else {
            return 'slds-col slds-size_4-of-6 card-data-element';
        }
    }
    connectedCallback() {
        this.isAndroidTab=communityService.isAndroidTablet();
        this.noExploreImage = this.exploreData.thumbnailImage ? false : true;
    }

    handleNoExploreImageError() {
        this.noExploreImage = true;
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
                resourceid: this.exploreData.recId,
                resourcetype: this.exploreData.resourceDevRecordType,
                state: participantState,
                showHomePage: true
            }
        });
    }
    removeCardHandler() {
        const removeCardEvent = new CustomEvent('removecard', {
            detail: { sendResultId: this.exploreData.sendResultId }
        });
        this.dispatchEvent(removeCardEvent);
    }
}
