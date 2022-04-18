import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import RTL_Languages from '@salesforce/label/c.RTL_Languages';

export default class TeleVisitsListView extends LightningElement {
    isMobileApp = false;
    isMobileScreen = false;
    isRTL = false;
    labels = {
        RTL_Languages
    };
    options = ['Upcoming', 'Past', 'Cancelled'];
    containerClass = '';
    titleClass = '';
    filterLabel = '';
    teleVisits = {};
    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                console.log('RR_COMMUNITY_JS loaded');
                this.isMobileApp = communityService.isMobileSDK();
                this.isMobileScreen = communityService.isMobileOS();
                this.isRTL = this.labels.RTL_Languages.contains(communityService.getLanguage());
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading RR_COMMUNITY_JS',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }
}
