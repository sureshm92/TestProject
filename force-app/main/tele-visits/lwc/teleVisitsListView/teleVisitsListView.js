import { LightningElement, api, wire, track } from 'lwc';
import RTL_Languages from '@salesforce/label/c.RTL_Languages';
import FILTER_LABEL from '@salesforce/label/c.Home_Page_StudyVisit_Show_Filter_Visits';
import TIMEZONE from '@salesforce/i18n/timeZone';
import getVisits from '@salesforce/apex/TeleVisitRemote.getVisits';

export default class TeleVisitsListView extends LightningElement {
    @api isMobileApp;
    @api isRTL;
    @track teleVisits = [{}];
    searchStatus = '';
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
    entriesOnPage = 4;
    pageNumber = 1;
    allRecordsCount = 5;
    teleVisitsToDisplay = [];

    connectedCallback() {
        this.searchStatus = 'Scheduled';
        this.loadVisits();
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
    handlePaginatorChanges(event) {
        this.teleVisitsToDisplay = event.detail;
        //this.rowNumberOffset = this.teleVisitsToDisplay[0].rowNumber - 1;
    }
    statusHandler(event) {
        this.searchStatus = event.detail;
        this.loadVisits();
    }
    loadVisits() {
        getVisits({ visitMode: this.searchStatus })
            .then((result) => {
                console.log(JSON.parse(JSON.stringify(result)));
                this.teleVisits = result;
            })
            .catch((error) => {
                console.log(error);
            });
    }
}
