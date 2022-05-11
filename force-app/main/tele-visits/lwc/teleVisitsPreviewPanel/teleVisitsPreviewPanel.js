import { LightningElement, api, wire, track } from 'lwc';
import RTL_Languages from '@salesforce/label/c.RTL_Languages';
import FILTER_LABEL from '@salesforce/label/c.Home_Page_StudyVisit_Show_Filter_Visits';
import NO_ITEMS from '@salesforce/label/c.PG_VP_L_No_Items_display';
import TIMEZONE from '@salesforce/i18n/timeZone';
import getTeleVisits from '@salesforce/apex/TeleVisitRemote.getTeleVisits';
import TV_TH_Attendees from '@salesforce/label/c.TV_TH_Attendees';
import TV_TH_Date from '@salesforce/label/c.TV_TH_Date';
import TV_TH_Duration from '@salesforce/label/c.TV_TH_Duration';
import TV_TH_Time from '@salesforce/label/c.TV_TH_Time';
import TV_TH_Title from '@salesforce/label/c.TV_TH_Title';
import FORM_FACTOR from '@salesforce/client/formFactor';
import SEE_ALL from '@salesforce/label/c.Resources_See_All';

const ENTRIES_ON_PAGE = 4;
export default class TeleVisitsPreviewPanel extends LightningElement {
    @api isMobileApp;
    @api isRTL;
    @api isAluminiHome;
    @track teleVisits = [];
    @track tabTeleVisits = [{}];
    allRecordsCount;
    entriesOnPage = ENTRIES_ON_PAGE;
    pageNumber = 1;
    isDisplayTable = false;
    isVisitAvailable = false;
    isFilterAvailable = false;
    searchStatus = '';

    labels = {
        RTL_Languages,
        FILTER_LABEL,
        NO_ITEMS,
        TV_TH_Title,
        TV_TH_Time,
        TV_TH_Duration,
        TV_TH_Date,
        TV_TH_Attendees,
        SEE_ALL
    };

    @track options = [];

    isInitialized = false;
    timeZone = TIMEZONE;

    renderedCallback() {
        if (this.isInitialized) {
            return;
        } else {
            this.loadVisits();
            //this.isInitialized = true;
        }
    }

    get containerClass() {
        return 'tv-body' + (this.isInitialized ? '' : 'hidden');
    }
    get isDesktop() {
        return FORM_FACTOR === 'Large';
    }
    get titleClass() {
        return 'tv-title' + (this.isRTL ? ' tile-rtl' : '');
    }
    get attendeeVisibility() {
        return this.isAluminiHome ? true : false;
    }
    statusHandler(event) {
        this.searchStatus = event.detail;
        this.loadVisits();
    }
    handlePaginatorChanges(value) {
        this.tabTeleVisits = JSON.parse(JSON.stringify(value));
    }

    loadVisits() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) this.spinner.show();
        getTeleVisits({ visitMode: this.searchStatus })
            .then((result) => {
                console.log('RK::', result);
                //if any visits are present
                this.allRecordsCount = result.length;
                this.isVisitAvailable = this.allRecordsCount > 0;
                this.isDisplayTable = this.allRecordsCount > 0;
                if (this.isVisitAvailable) {
                    let teleVisitsAll = result;

                    //check visit statuses
                    if (!this.isInitialized) {
                        let unique = [...new Set(teleVisitsAll.map(visit => visit.visitStatus))];
                        if (unique.length > 1) {
                            for (let vStatus of unique) {
                                let visitOption = {
                                    label: vStatus,
                                    value: vStatus
                                };
                                this.options = [...this.options, visitOption];
                            }
                            //assign default filter
                            if (unique.includes('Scheduled')) {
                                this.searchStatus = 'Scheduled';
                                teleVisitsAll.map(visit => {
                                    if (visit.visitStatus === 'Scheduled') {
                                        this.teleVisits = [...this.teleVisits, visit];
                                    }
                                });
                            } else if (unique.includes('Completed')) {
                                this.searchStatus = 'Completed';
                                teleVisitsAll.map(visit => {
                                    if (visit.visitStatus === 'Completed') {
                                        this.teleVisits = [...this.teleVisits, visit];
                                    }
                                });
                            } else {
                                this.searchStatus = 'Cancelled';
                                teleVisitsAll.map(visit => {
                                    if (visit.visitStatus === 'Cancelled') {
                                        this.teleVisits = [...this.teleVisits, visit];
                                    }
                                });
                            }
                            this.isFilterAvailable = true;
                        } else {
                            this.searchStatus = unique[0];
                            this.teleVisits = teleVisitsAll;
                        }

                        this.isInitialized = true;
                    } else {
                        this.teleVisits = teleVisitsAll;
                    }
                }
                this.handlePaginatorChanges(this.teleVisits);
                if (this.spinner) {
                    this.spinner.hide();
                }
            })
            .catch((error) => {
                console.log('error', error);
            });
    }

    displayData(event) {
        let index = event.target.value;
        let dataElements = this.template.querySelectorAll("div[data-index='" + index + "']");
        dataElements.forEach(function (ele) {
            ele.classList.toggle('hidden');
        });
        let spans = this.template.querySelectorAll("span[data-index='" + index + "']");
        spans.forEach(function (spn) {
            spn.classList.toggle('hidden');
        });
    }
}