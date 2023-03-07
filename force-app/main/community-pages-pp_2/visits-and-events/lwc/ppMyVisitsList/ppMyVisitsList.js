import { LightningElement, track, api } from 'lwc';
import getParticipantVisitsDetails from '@salesforce/apex/ParticipantVisitsRemote.getParticipantVisitsDetails';
import noVisitsLabel from '@salesforce/label/c.Study_Visit_No_Date_Or_Time_Entered';
import noDataAvailable from '@salesforce/label/c.Visits_No_Data_Available';
import upcoming from '@salesforce/label/c.Visits_Upcoming';
import past from '@salesforce/label/c.Visits_Past';
import results from '@salesforce/label/c.Visit_Result';
import resultsCheck from '@salesforce/label/c.Visit_Check_Result';
import viewAllResults from '@salesforce/label/c.Visits_View_All_Results';
import visitUnavailable from '@salesforce/label/c.Study_Visit_Unavailable';
import myVisits from '@salesforce/label/c.My_Visits';
import loading from '@salesforce/label/c.Loading';
import visitdetails from '@salesforce/label/c.Visit_Details';
import { NavigationMixin } from 'lightning/navigation';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import No_Upcoming_Visits from '@salesforce/label/c.Visit_No_Upcoming_Visits';
import No_Upcoming_Events from '@salesforce/label/c.Event_No_Upcoming_Events';
import No_Past_Visit from '@salesforce/label/c.Visit_No_Past_Visit';
import No_Past_Event from '@salesforce/label/c.Event_No_Past_Event';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';

export default class ppMyVisitsList extends NavigationMixin(LightningElement) {
    label = {
        noVisitsLabel,
        noDataAvailable,
        upcoming,
        past,
        results,
        resultsCheck,
        viewAllResults,
        visitUnavailable,
        myVisits,
        loading,
        visitdetails,
        No_Upcoming_Visits,
        No_Upcoming_Events,
        No_Past_Visit,
        No_Past_Event
    };
    status = {
        scheduled: 'Scheduled',
        pending: 'Pending',
        completed: 'Completed',
        missed: 'Missed'
    };

    @api pastvisits;
    @api upcomingvisits;
    @api visittimezone;

    @api showupcomingvisits;
    @api visitid;
    @api pastvisitid;
    @api upcomingvisitid;
    @api visitdata;
    @api ismobile;
    @api initialpageload;
    @api past;
    @api isevent;

    @track showreminderdatepicker = false;
    @track contentLoaded = false;
    @track visitName;
    @track plannedDate;
    @track visitStatus;
    @track taskId;
    @track showList = true;
    @track selectedIndex = 0;
    @track visitTimezone = '';

    initialized = '';
    cbload = false;

    @api isupcomingvisits;
    ispastvisits = true;

    empty_state = pp_community_icons + '/' + 'empty_visits.png';

    connectedCallback() {
        this.visitTimezone = TIME_ZONE;
    }
    renderedCallback() {
        this.handleVisitChange();
    }

    onPastClick() {
        this.cbload = true;
        this.past = true;
        if (this.visitid) {
            const theDiv = this.template.querySelector('[data-id="' + this.visitid + '"]');
            if (theDiv) {
                theDiv.className = 'inactive-custom-box';
            }
        }
        this.showupcomingvisits = false;
        if (this.pastvisits.length > 0) {
            this.ispastvisits = true;
            this.visitid = this.pastvisitid;
            this.visitName = this.pastvisits[0].visit.Name;
            this.plannedDate = this.pastvisits[0].visit.Planned_Date__c;
            this.visitStatus = this.pastvisits[0].visit.Status__c;
            this.createEditTask();
        } else {
            this.ispastvisits = false;
            this.contentLoaded = true;
            this.template.querySelector('c-web-spinner').hide();
        }
        const pastEvent = new CustomEvent('pastclick');
        this.dispatchEvent(pastEvent);
    }
    handleVisitChange() {
        if (this.visitid) {
            this.template.querySelector('[data-id="' + this.visitid + '"]');
            const theDiv = this.template.querySelector('[data-id="' + this.visitid + '"]');
            if (theDiv) {
                theDiv.className = 'active-custom-box';
            }
        }
    }
    onUpcomingClick() {
        this.cbload = true;
        if (this.visitid) {
            const theDiv = this.template.querySelector('[data-id="' + this.visitid + '"]');
            if (theDiv) {
                theDiv.className = 'inactive-custom-box';
            }
        }
        this.showupcomingvisits = true;
        if (this.upcomingvisits.length > 0) {
            this.isupcomingvisits = true;
            this.visitid = this.upcomingvisitid;
            this.visitName = this.upcomingvisits[0].visit.Name;
            this.plannedDate = this.upcomingvisits[0].visit.Planned_Date__c;
            this.visitStatus = this.upcomingvisits[0].visit.Status__c;
            this.createEditTask();
        } else {
            this.isupcomingvisits = false;
            this.contentLoaded = true;
            this.template.querySelector('c-web-spinner').hide();
        }
        const upcomingEvent = new CustomEvent('upcomingclick');
        this.dispatchEvent(upcomingEvent);
    }

    createEditTask(index) {
        console.log('Inside Create Edit');
        this.contentLoaded = false;
        this.template.querySelector('c-web-spinner').show();
        this.showreminderdatepicker = false;
        if (this.visitid) {
            getParticipantVisitsDetails({
                visitId: this.visitid
            }).then((result) => {
                const str =
                    '{"Id":"","Patient_Visit__c":"","Reminder_Date__c":"","ReminderDateTime":"","Remind_Me__c":"","Remind_Using_Email__c":false,"Remind_Using_SMS__c":false}';
                var jsonstr = JSON.stringify(result[0]);
                const obj = JSON.parse(jsonstr);
                if (typeof result[0].task === 'undefined') {
                    obj.task = JSON.parse(str);
                }
                if (typeof result[0].visitDate === 'undefined') {
                    obj.visitDate = '';
                }
                this.visitdata = obj;
                this.taskId = this.visitdata.task.Id;

                //update bell icon once reminder is created PEH-7825
                if (this.taskId && this.upcomingVisits) {
                    this.upcomingVisits[this.selectedIndex].isReminderDate = true;
                }
                if (!this.past && this.upcomingVisits) {
                    this.upcomingVisits[
                        this.selectedIndex
                    ].visit.Planned_Date__c = this.visitdata.visitDate;
                    if (this.visitdata.visitDate && this.showupcomingvisits) {
                        this.upcomingvisits[this.selectedIndex].noVisitDate = false;
                        this.plannedDate = this.upcomingvisits[
                            this.selectedIndex
                        ].visit.Planned_Date__c;
                    } else {
                        this.upcomingvisits[this.selectedIndex].noVisitDate = true;
                        this.plannedDate = '';
                    }
                }
                this.contentLoaded = true;
                this.template.querySelector('c-web-spinner').hide();
            });
        } else {
            this.contentLoaded = true;
            this.template.querySelector('c-web-spinner').hide();
        }
    }

    onVisitSelect(event) {
        var index = event.currentTarget.dataset.index;
        var past = event.currentTarget.dataset.past;
        const theDiv = this.template.querySelector('[data-id="' + this.visitid + '"]');
        theDiv.className = 'inactive-custom-box';
        if (past === 'true') {
            this.past = true;
            this.visitid = this.pastvisits[index].visit.Id;
            this.visitName = this.pastvisits[index].visit.Name;
            this.plannedDate = this.pastvisits[index].visit.Planned_Date__c;
            this.visitStatus = this.pastvisits[index].visit.Status__c;
        } else {
            this.visitid = this.upcomingvisits[index].visit.Id;
            this.visitName = this.upcomingvisits[index].visit.Name;
            this.selectedIndex = index;
            this.past = false;
        }
        this.taskSubject = event.currentTarget.dataset.name;
        if (this.ismobile != true) {
            this.cbload = true;
            this.createEditTask();
        }

        if (this.ismobile == true) {
        }
        const visitEvent = new CustomEvent('visitchange', {
            detail: { past: this.past, indexval: index, tasksubject: this.taskSubject }
        });
        this.dispatchEvent(visitEvent);
    }
}
