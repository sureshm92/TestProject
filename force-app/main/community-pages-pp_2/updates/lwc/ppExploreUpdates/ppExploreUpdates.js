import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import VERSION_DATE from '@salesforce/label/c.Version_date';
import removeCard from '@salesforce/apex/PPUpdatesController.removeUpdateCard';
import POSTING_DATE from '@salesforce/label/c.Posting_date';
import VIEW_RESOURCE from '@salesforce/label/c.PP_View_Resource';
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

    connectedCallback() {
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
        const targetRecId = this.exploreData.targetRecordId;
        removeCard({ targetRecordId: targetRecId })
            .then((returnValue) => {})
            .catch((error) => {
                console.log('error message ' + error.message);
            });
    }
}
