import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import VERSION_DATE from '@salesforce/label/c.Version_date';

export default class PpExploreUpdates extends NavigationMixin(LightningElement) {
    @api exploreData;
    @api showVisitSection;
    @api desktop;
    noExploreImage = false;
    labels = {
        VERSION_DATE
    };

    connectedCallback() {
        this.noExploreImage = this.exploreData.thumbnailImage ? false : true;
    }

    handleNoExploreImageError() {
        console.log('No thumbnail Image');
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
            this.exploreData.recId +
            '&resourcetype=' +
            this.exploreData.resourceDevRecordType +
            '&state=' +
            state;

        const config = {
            type: 'standard__webPage',

            attributes: {
                url: detailLink
            }
        };

        this[NavigationMixin.GenerateUrl](config).then((url) => {
            sessionStorage.setItem('Cookies', 'Accepted');
            window.open(url, '_self');
        });
    }
}
