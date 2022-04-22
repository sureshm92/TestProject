import { LightningElement, api, wire, track } from 'lwc';
import RTL_Languages from '@salesforce/label/c.RTL_Languages';
import FILTER_LABEL from '@salesforce/label/c.Home_Page_StudyVisit_Show_Filter_Visits';
import TV_TH_Attendees from '@salesforce/label/c.TV_TH_Attendees';
import TV_TH_Date from '@salesforce/label/c.TV_TH_Date';
import TV_TH_Duration from '@salesforce/label/c.TV_TH_Duration';
import TV_TH_Time from '@salesforce/label/c.TV_TH_Time';
import TV_TH_Title from '@salesforce/label/c.TV_TH_Title';
import NO_ITEMS from '@salesforce/label/c.PG_VP_L_No_Items_display';
import TIMEZONE from '@salesforce/i18n/timeZone';
import getVisits from '@salesforce/apex/TeleVisitRemote.getVisits';

export default class TeleVisitsListView extends LightningElement {
    @api isMobileApp;
    @api isRTL;
    @track teleVisits = [{}];
    @track tabteleVisits = [{}];
    allRecordsCount;
    entriesonpage = 4;
    pageNumber = 1;
    isDisplayTable = false;
    searchStatus = 'Scheduled';
    labels = {
        RTL_Languages,
        FILTER_LABEL,
        NO_ITEMS,
        TV_TH_Title,
        TV_TH_Time,
        TV_TH_Duration,
        TV_TH_Date,
        TV_TH_Attendees
    };

    options = [
        {
            value: 'Scheduled',
            label: 'Scheduled'
        },
        { value: 'Completed', label: 'Completed' },
        { value: 'Cancelled', label: 'Cancelled' }
    ];

    isInitialized = false;
    timeZone = TIMEZONE;
    isDisplayPagination;

    renderedCallback() {
        if (this.isInitialized) return;
        else {
            this.loadVisits();
            this.isInitialized = true;
        }
    }

    /**connectedCallback() {
        this.searchStatus = 'Scheduled';
        this.loadVisits();
    }
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
        this.searchStatus = event.detail;
        this.loadVisits();
    }
    handlePaginatorChanges(event) {
        this.tabteleVisits = JSON.parse(JSON.stringify(event.detail));
    }
    loadVisits() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) this.spinner.show();
        getVisits({ visitMode: this.searchStatus })
            .then((result) => {
                this.teleVisits = result;
                this.allRecordsCount = result.length;
                this.isDisplayTable = this.allRecordsCount > 0;
                if (this.spinner) this.spinner.hide();
            })
            .catch((error) => {
                console.log(error);
            });
    }
}
