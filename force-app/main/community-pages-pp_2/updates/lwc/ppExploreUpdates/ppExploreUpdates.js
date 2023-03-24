import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import VERSION_DATE from '@salesforce/label/c.Version_date';
import removeCard from '@salesforce/apex/PPUpdatesController.removeUpdateCard';
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
        this.removeCardHandler();
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
            state +
            '&showHomePage=true';;

        const config = {
            type: 'standard__webPage',

            attributes: {
                url: detailLink
            }
        };

        this[NavigationMixin.Navigate](config,true);
    }
    removeCardHandler(){
        const targetRecId = this.exploreData.targetRecordId;
        removeCard({targetRecordId : targetRecId})
        .then((returnValue) => {
        })
        .catch((error) => {
            //console.log('error message 1'+error.message);
            this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
            this.spinner.hide();
        });
    }
}
