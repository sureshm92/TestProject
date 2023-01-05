import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class PpExploreUpdates extends NavigationMixin(LightningElement) {
    @api exploreData;
    @api showVisitSection;
    @api desktop = false;
    noExploreImage = false;
    connectedCallback() {
        this.noExploreImage = this.exploreData.resource.Image__c ? false : true;
        console.log('+++++++++this.noExploreImage'+this.noExploreImage);
    }

    handleNoExploreImageError() {
        this.noExploreImage = true;
    }

    navigateResourceDetail() {
        let subDomain = communityService.getSubDomain();
        let state;
        if (communityService.isInitialized()) {
            state = communityService.getCurrentCommunityMode().participantState;
        }
        let detailLink =
            window.location.origin +
            subDomain +
            '/s/resource-detail' +
            '?resourceid=' +
            this.exploreData.resource.Id +
            '&resourcetype=' +
            this.exploreData.resource.RecordType.DeveloperName +
            '&state=' +
            state;

        const config = {
            type: 'standard__webPage',

            attributes: {
                url: detailLink
            }
        };

        this[NavigationMixin.GenerateUrl](config).then((url) => {
            window.open(url, '_self');
        });
    }
}