import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class PpExploreUpdates extends NavigationMixin(LightningElement) {
    @api exploreData;
    @api showVisitSection;
    @api desktop = false;
    noExploreImage = false;
    connectedCallback() {
        this.noExploreImage = this.exploreData.resource.Image__c ? false : true;
    }

    handleNoExploreImageError() {
        this.noExploreImage = true;
    }

    navigateResourceDetail() {
        let state;
        if (communityService.isInitialized()) {
            state = communityService.getCurrentCommunityMode().participantState;
        }
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'resource-detail'
            },
            state: {
                resourceid: this.exploreData.resource.Id,
                resourcetype: this.exploreData.resource.RecordType.DeveloperName,
                state: state
            }
        });
    }
}
