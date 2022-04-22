import { LightningElement, api, wire, track } from 'lwc';
import RTL_Languages from '@salesforce/label/c.RTL_Languages';
import FILTER_LABEL from '@salesforce/label/c.Home_Page_StudyVisit_Show_Filter_Visits';
import NO_ITEMS from '@salesforce/label/c.PG_VP_L_No_Items_display';
import TIMEZONE from '@salesforce/i18n/timeZone';
import getVisits from '@salesforce/apex/TeleVisitRemote.getVisits';

const ENTRIES_ON_PAGE = 4;
export default class TeleVisitsListView extends LightningElement {
    @api isMobileApp;
    @api isRTL;
    @track teleVisits = [{}];
    @track tabteleVisits = [{}];
    allRecordsCount;
    entriesOnPage = ENTRIES_ON_PAGE;
    pageNumber = 1;
    isDisplayTable = false;
    searchStatus = 'Scheduled';
    labels = {
        RTL_Languages,
        FILTER_LABEL,
        NO_ITEMS
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
