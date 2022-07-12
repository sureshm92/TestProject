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
import FORM_FACTOR from '@salesforce/client/formFactor';
import SEE_ALL from '@salesforce/label/c.Resources_See_All';
import TV_UPCOMING from '@salesforce/label/c.Televisit_Upcoming';
import TV_PAST from '@salesforce/label/c.Televisit_Past';
import TV_CANCELED from '@salesforce/label/c.Televisit_Canceled';

const ENTRIES_ON_PAGE = 5;
export default class TeleVisitsPreviewPanel extends LightningElement {
    @api isRTL;
    @track teleVisits = [];
    @track tabTeleVisits = [{}];
    allRecordsCount;
    entriesOnPage = ENTRIES_ON_PAGE;
    isDisplayTable = false;
    isVisitAvailable = false;
    isFilterAvailable = false;
    searchStatus = '';
    @api participantState;
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

    get urlLink()
    {
      var isParticipant =JSON.parse(JSON.stringify(this.participantState.pe));
      if(isParticipant)
      {
          return 'study-workspace?tab=tab-visits&visitmode=TeleVisitDetails';
      }
      else {
          return 'televisits?tab=televisits';
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
    get selectContainer() {
        return 'select-container' + (this.isRTL ? '-rtl' : '');
    }

    get selectClass() {
        return 'select-list' + (this.isRTL ? '-rtl' : '');
    }
    get iconChevron() {
        return 'icon-chevron-' + (this.isRTL ? 'left' : 'right');
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
        console.log('rtl', this.isRTL);
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) this.spinner.show();
        getTeleVisits({ visitMode: this.searchStatus })
            .then((result) => {
                let allTeleVisits = result;
                if (!this.isInitialized) {
                    if (allTeleVisits != null && allTeleVisits.length > 0) {
                        let teleVisitStatusOptions = [
                            ...new Set(allTeleVisits.map((visit) => visit.visitStatus))
                        ];
                        //removing blank values
                        let teleVisitStatus = teleVisitStatusOptions.filter((tv) => tv);
                        if (teleVisitStatus.length >= 1) {
                            //configute  filter
                            for (let tvStatus of teleVisitStatus) {
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
                            this.options.sort(this.sortVisitStatus('value'));
                            //assign default filter
                            if (teleVisitStatus.includes('Scheduled')) {
                                this.searchStatus = 'Scheduled';
                                this.teleVisits = this.filterVisits(allTeleVisits, 'Scheduled');
                            } else if (teleVisitStatus.includes('Completed')) {
                                this.searchStatus = 'Completed';
                                this.teleVisits = this.filterVisits(allTeleVisits, 'Completed');
                            } else {
                                this.searchStatus = 'Cancelled';
                                this.teleVisits = this.filterVisits(allTeleVisits, 'Cancelled');
                            }
                            this.isFilterAvailable = true;
                        }
                        this.handleStatusChange(this.teleVisits);
                        this.isInitialized = true;
                        this.isDisplayTable = true;
                        this.isVisitAvailable = true;
                    }
                } else {
                    if (allTeleVisits != null && allTeleVisits.length > 0) {
                        //show visits
                        this.teleVisits = allTeleVisits;
                        this.handleStatusChange(this.teleVisits);
                        this.isDisplayTable = true;
                    } else {
                        //show no visits message
                        this.teleVisits = [];
                        this.isDisplayTable = false;
                    }
                }
                if (this.spinner) {
                    this.spinner.hide();
                }
            })
            .catch((error) => {
                console.error('error', error);
            });
    }

    filterVisits(initialArray, filterValue) {
        let filteredArray = [];
        initialArray.map((visit) => {
            if (visit.visitStatus === filterValue) {
                filteredArray = [...filteredArray, visit];
            }
        });
        return filteredArray;
    }

    sortVisitStatus(sortAttribute) {
        return function (elementOne, elementTwo) {
            if (elementOne[sortAttribute] > elementTwo[sortAttribute]) {
                return -1;
            } else if (elementOne[sortAttribute] < elementTwo[sortAttribute]) {
                return 1;
            }
            return 0;
        };
    }

    displayData(event) {
        let index = event.target.value;
        let tableContainer = this.template.querySelectorAll('.televisit_table_container');
        tableContainer.forEach(function (ele) {
            if (ele.classList.contains('hidden')) {
                ele.classList.remove('televisit-tr-bgcolor');
            }
        });
        tableContainer.forEach(function (ele) {
            let trIndex = ele.getAttribute('data-index');
            if (index == trIndex) {
                ele.classList.toggle('televisit-tr-bgcolor');
            }
        });

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
