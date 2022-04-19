import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import RTL_Languages from '@salesforce/label/c.RTL_Languages';
import FILTER_LABEL from '@salesforce/label/c.Home_Page_StudyVisit_Show_Filter_Visits';
import TIMEZONE from '@salesforce/i18n/timeZone';

export default class TeleVisitsListView extends LightningElement {
    isMobileApp = false;
    isMobileScreen = false;
    isRTL = false;
    labels = {
        RTL_Languages,
        FILTER_LABEL
    };
    options = [
        {
            value: 'Upcoming',
            label: 'Upcoming'
        },
        { value: 'Past', label: 'Past' },
        { value: 'Cancelled', label: 'Cancelled' }
    ];
    filterLabel = options.FILTER_LABEL;
    teleVisits = {};
    isInitialized = false;
    timeZone = TIMEZONE;

    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                console.log('RR_COMMUNITY_JS loaded');
                this.isMobileApp = communityService.isMobileSDK();
                this.isMobileScreen = communityService.isMobileOS();
                this.isRTL = this.labels.RTL_Languages.contains(communityService.getLanguage());
                this.isInitialized = true;
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
    get containerClass() {
        return 'tv-body' + this.isInitialized ? '' : 'hidden';
    }

    get titleClass() {
        return 'tv-title' + this.isRTL ? 'tile-rtl' : '';
    }
}
