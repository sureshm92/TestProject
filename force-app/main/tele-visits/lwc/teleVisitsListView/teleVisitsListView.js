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
import getVisits from '@salesforce/apex/TeleVisitService.getVisits';

const ENTRIES_ON_PAGE = 4;
export default class TeleVisitsListView extends LightningElement {
    @api isMobileApp;
    @api isRTL;
    @track teleVisits = [{}];
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
            label: 'Upcoming'
        },
        { value: 'Completed', label: 'Past' },
        { value: 'Cancelled', label: 'Cancelled' }
    ];
    isInitialized = false;
    timeZone = TIMEZONE;
    entriesOnPage = ENTRIES_ON_PAGE;
    pageNumber = 1;
    allRecordsCount;
    isDisplayTable;
    teleVisitsToDisplay = [];

    renderedCallback() {
        if (this.isInitialized) return;
        else {
            this.loadVisits();
            this.isInitialized = true;
        }
    }

    get containerClass() {
        return 'tv-body' + (this.isInitialized ? '' : 'hidden');
    }

    get titleClass() {
        return 'tv-title' + (this.isRTL === true ? ' tile-rtl' : '');
    }

    handlePaginatorChanges(event) {
        this.teleVisitsToDisplay = event.detail;
        //this.rowNumberOffset = this.teleVisitsToDisplay[0].rowNumber - 1;
    }
    statusHandler(event) {
        this.searchStatus = event.detail;
        this.loadVisits();
    }
    loadVisits() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) this.spinner.show();
        getVisits({ visitMode: this.searchStatus })
            .then((result) => {
                console.log(JSON.parse(JSON.stringify(result)));
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
