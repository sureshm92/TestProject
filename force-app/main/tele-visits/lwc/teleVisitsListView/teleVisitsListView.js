import { LightningElement, api, wire } from 'lwc';
//import { loadScript } from 'lightning/platformResourceLoader';
//import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import RTL_Languages from '@salesforce/label/c.RTL_Languages';
import FILTER_LABEL from '@salesforce/label/c.Home_Page_StudyVisit_Show_Filter_Visits';
import TIMEZONE from '@salesforce/i18n/timeZone';
import getVisits from '@salesforce/apex/TeleVisitService.getVisits';

export default class TeleVisitsListView extends LightningElement {
    @api isMobileApp;
    @api isRTL;
    teleVisits = [{}];
    searchStatus = 'Scheduled';
    @wire(getVisits, { visitMode: '$searchStatus' }) wiredVisits({ error, data }) {
        if (data) {
            this.teleVisits = data;
        } else if (error) {
            console.log('error', error);
        }
    }
    labels = {
        RTL_Languages,
        FILTER_LABEL
    };
    options = [
        {
            value: 'Scheduled',
            label: 'Upcoming'
        },
        { value: 'Completed', label: 'Past' },
        { value: 'Cancelled', label: 'Cancelled' }
    ];

    isInitialized = true;
    timeZone = TIMEZONE;

    /*connectedCallback() {
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
    }*/
    get containerClass() {
        return 'tv-body' + (this.isInitialized ? '' : 'hidden');
    }

    get titleClass() {
        return 'tv-title' + (this.isRTL === true ? ' tile-rtl' : '');
    }
    get filterLabel() {
        return this.labels.FILTER_LABEL;
    }
    statusHandler(event) {
        console.log('event detail', event.detail);
        this.searchStatus = event.detail;
    }
}
