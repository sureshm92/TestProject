import { LightningElement, track, api } from 'lwc';
import getParticipantVisits from '@salesforce/apex/ParticipantVisitsRemote.getParticipantVisits';
import noVisitsLabel from '@salesforce/label/c.Study_Visit_No_Date_Or_Time_Entered';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import getInitData from '@salesforce/apex/ParticipantVisitsRemote.getParticipantVisits';
import getIcon from '@salesforce/apex/PatientVisitService.getVisitIcons';
import WTELabel from '@salesforce/label/c.Home_Page_StudyVisit_WhToEx';
import TIME_ZONE from '@salesforce/i18n/timeZone';

export default class PpStudyVisitPage extends LightningElement {
    label = {
        noVisitsLabel
    };
    @track visitMode = 'All';
    @track upcomingVisits = [];
    @track pastVisits = [];
    @track noVisitDate = false;
    @track visittimezone = [];
    @track showUpcomingVisits = true;
    @track visitname;
    @track upcomingVariantValue = 'Neutral';
    @track pastVariantValue = 'Neutral';
    @track onVisitSelection = false;
    @track visitid;
    @track plannedDate;

    initialized = '';
    @api icondetails = [];
    isError = false;
    labels = {
        WTELabel
    };

    connectedCallback() {
        getParticipantVisits({
            visitMode: this.visitMode
        })
            .then((result) => {
                this.upcomingVariantValue = 'brand';
                this.pastVariantValue = 'Neutral';

                //console.log('result::' + JSON.stringify(result));
                //set visitId on load of page
                this.visitid = result[0].visit.Id;
                this.initializeData(this.visitid);
                this.visitname = result[0].visit.Name;
                this.plannedDate = result[0].visit.Planned_Date__c;

                for (let i = 0; i < result.length; i++) {
                    if (
                        result[i].visit.Completed_Date__c == null &&
                        (result[i].visit.Status__c == 'Scheduled' ||
                            result[i].visit.Status__c == 'Pending')
                    ) {
                        if (result[i].visit.Planned_Date__c === undefined) {
                            this.noVisitDate = true;
                            result[i].noVisitDate = this.noVisitDate;
                        }
                        this.upcomingVisits.push(result[i]);
                    } else if (
                        result[i].visit.Completed_Date__c != null &&
                        (result[i].visit.Status__c == 'Completed' ||
                            result[i].visit.Status__c == 'Missed')
                    ) {
                        this.pastVisits.push(result[i]);
                    }

                    this.visittimezone = TIME_ZONE;
                    result[i].visittimezone = this.visittimezone;
                }
            })
            .catch((error) => {
                this.error = error;
            });
    }

    onUpcomingClick(event) {
        this.showUpcomingVisits = true;
        this.upcomingVariantValue = 'brand';
        this.pastVariantValue = 'Neutral';
    }
    onPastClick(event) {
        this.showUpcomingVisits = false;
        this.pastVariantValue = 'brand';
        this.upcomingVariantValue = 'Neutral';
    }

    onVisitSelect(event) {
        var index = event.target.dataset.value;
        this.visitid = this.upcomingVisits[index].visit.Id;
        this.visitname = this.upcomingVisits[index].visit.Name;
        this.plannedDate = this.upcomingVisits[index].visit.Planned_Date__c;
        this.visittimezone = TIME_ZONE;
        this.upcomingVisits[index].visittimezone = this.visittimezone;
        this.createEditTask(this.visitid);

        const childCmp = this.template.querySelector('c-pp-r-r-icon-splitter');
        childCmp.resetValues();

        this.initializeData(this.visitid);
    }

    createEditTask(visitid) {}

    initializeData(visitid) {
        this.initialized = 'false';

        getIcon({
            visitId: visitid
        })
            .then((result) => {
                this.icondetails = result;
                console.log('these are icon details:', this.icondetails);
                if (result.length === 0) {
                    this.isError = true;
                } else {
                    this.isError = false;
                }
            })
            .catch((error) => {
                this.showErrorToast('error occured', error.message, 'error');
            });
    }

    showErrorToast(titleText, messageText, variantType) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: titleText,
                message: messageText,
                variant: variantType
            })
        );
    }
}
