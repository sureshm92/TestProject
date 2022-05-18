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
import TV_TITLE from '@salesforce/label/c.Home_Page_Tele_Visit_Details_Tab';
import TV_UPCOMING from '@salesforce/label/c.Televisit_Upcoming';

import TV_PAST from '@salesforce/label/c.Televisit_Past';

import TV_CANCELED from '@salesforce/label/c.Televisit_Canceled';

import FORM_FACTOR from '@salesforce/client/formFactor';
import SEE_ALL from '@salesforce/label/c.Resources_See_All';
const ENTRIES_ON_PAGE = 5;
export default class TeleVisitsPreviewPanel extends LightningElement {
    @api isMobileApp;
    @api isRTL;
    @track teleVisits = [];
    @track tabTeleVisits = [{}];
    allRecordsCount;
    entriesOnPage = ENTRIES_ON_PAGE;
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
        SEE_ALL,
        TV_TITLE,
        TV_UPCOMING,
        TV_PAST,
        TV_CANCELED
    };

    @track options = [];

    isInitialized = false;
    timeZone = TIMEZONE;

    renderedCallback() {
        if (this.isInitialized) {
            return;
        } else {
            this.loadVisits();
        }
    }

    get containerClass() {
        return 'tv-body' + (this.isInitialized ? '' : ' hidden');
    }
    get isDesktop() {
        return FORM_FACTOR === 'Large';
    }
    get titleClass() {
        return 'tv-title' + (this.isRTL ? ' tile-rtl' : '');
    }

    statusHandler(event) {
        this.searchStatus = event.detail;
        this.loadVisits();
    }

    handleStatusChange(value) {
        if (value.length > 5) {
            value.splice(5);
        }
        this.tabTeleVisits = JSON.parse(JSON.stringify(value));
    }

    loadVisits() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) this.spinner.show();
        getTeleVisits({ visitMode: this.searchStatus })
            .then((result) => {
                //if any visits are present
                this.allRecordsCount = result.length;
                this.isVisitAvailable = this.allRecordsCount > 0;
                this.isDisplayTable = this.allRecordsCount > 0;
                if (this.isVisitAvailable) {
                    let allTeleVisits = result;
                    //create options for filter on initialization
                    if (!this.isInitialized) {
                        let teleVisitStatus = [
                            ...new Set(allTeleVisits.map((visit) => visit.visitStatus))
                        ];
                        if (teleVisitStatus.length > 1) {
                            for (let tvStatus of teleVisitStatus) {
                                //  let tvStatusLabel =
                                let visitOption = {
                                    label:
                                        tvStatus == 'Scheduled'
                                            ? this.labels.TV_UPCOMING
                                            : tvStatus == 'Completed'
                                            ? this.labels.TV_PAST
                                            : this.labels.TV_CANCELED,
                                    value: tvStatus
                                };
                                this.options = [...this.options, visitOption];
                            }
                            //assign default filter
                            if (teleVisitStatus.includes('Scheduled')) {
                                this.searchStatus = 'Scheduled';
                                allTeleVisits.map((visit) => {
                                    if (visit.visitStatus === 'Scheduled') {
                                        this.teleVisits = [...this.teleVisits, visit];
                                    }
                                });
                            } else if (teleVisitStatus.includes('Completed')) {
                                this.searchStatus = 'Completed';
                                allTeleVisits.map((visit) => {
                                    if (visit.visitStatus === 'Completed') {
                                        this.teleVisits = [...this.teleVisits, visit];
                                    }
                                });
                            } else {
                                this.searchStatus = 'Cancelled';
                                allTeleVisits.map((visit) => {
                                    if (visit.visitStatus === 'Cancelled') {
                                        this.teleVisits = [...this.teleVisits, visit];
                                    }
                                });
                            }
                            this.isFilterAvailable = true;
                        } else {
                            this.searchStatus = teleVisitStatus[0];
                            this.teleVisits = allTeleVisits;
                        }
                        this.isInitialized = true;
                    } else {
                        this.teleVisits = allTeleVisits;
                    }
                }
                this.handleStatusChange(this.teleVisits);
                if (this.spinner) {
                    this.spinner.hide();
                }
            })
            .catch((error) => {
                console.error('error', error);
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
