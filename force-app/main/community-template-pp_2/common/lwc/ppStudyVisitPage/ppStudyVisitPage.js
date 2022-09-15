import { LightningElement, track, api } from 'lwc';
import getParticipantVisits from '@salesforce/apex/ParticipantVisitsRemote.getParticipantVisits';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import getIcon from '@salesforce/apex/PatientVisitService.getVisitIcons';
import WTELabel from '@salesforce/label/c.Home_Page_StudyVisit_WhToEx';
import getParticipantVisitsDetails from '@salesforce/apex/ParticipantVisitsRemote.getParticipantVisitsDetails';
import getSiteAddress from '@salesforce/apex/ParticipantVisitsRemote.getSiteAddress';
import basePathName from '@salesforce/community/basePath';
import { NavigationMixin } from 'lightning/navigation';

import communicationPreference from '@salesforce/label/c.Communication_Preference';
import noVisitsLabel from '@salesforce/label/c.Study_Visit_No_Date_Or_Time_Entered';
import myVisits from '@salesforce/label/c.Visit_My_Visits';
import noDataAvailable from '@salesforce/label/c.Visits_No_Data_Available';
import upcoming from '@salesforce/label/c.Visits_Upcoming';
import past from '@salesforce/label/c.Visits_Past';
import results from '@salesforce/label/c.Visit_Result';
import resultsCheck from '@salesforce/label/c.Visit_Check_Result';
import viewAllResults from '@salesforce/label/c.Visits_View_All_Results';
import visitUnavailable from '@salesforce/label/c.Study_Visit_Unavailable';

export default class PpStudyVisitPage extends LightningElement {
    label = {
        noVisitsLabel,
        myVisits,
        WTELabel,
        noDataAvailable,
        upcoming,
        past,
        results,
        resultsCheck,
        viewAllResults,
        visitUnavailable
    };
    @track visitMode = 'All';
    @track upcomingVisits = [];
    @track pastVisits = [];
    @track sitePhoneNumber;
    @track noVisitDate = false;
    @track showUpcomingVisits = true;
    @track onVisitSelection = false;
    @track contentLoaded = false;
    @track visitTimezone;
    @track visitName;
    @track plannedDate;
    @track visitid;
    @track visitdata;
    @track visitStatus;
    @track showreminderdatepicker = false;
    @track sfdcBaseURL;
    @track siteAddress;
    @track selecteddate = '';
    @track taskId;
    @track taskSubject;
    @track showChild = false;
    @track siteName;
    @track past = false;
    @track pastVisitId;
    @track upcomingVisitId;
    @track selectedIndex = 0;
    initialized = '';
    visitMode = 'All';
    visitWrappers = [];
    @api icondetails = [];
    isError = false;
    @track isReminderDate=false;
    @track missedVisit = false;


    callParticipantVisit() {
        getParticipantVisits({
            visitMode: this.visitMode
        })
            .then((result) => {          
                //set visitId on load of page
                this.visitid = result[0].visit.Id;
                this.taskSubject = result[0].visit.Name;

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
                        if(result[i].task?.Reminder_Date__c !== undefined){
                            result[i].isReminderDate = true;
                        }else{
                            result[i].isReminderDate = false;
                        }

                        this.upcomingVisits.push(result[i]);
                    } else if (
                        result[i].visit.Status__c == 'Completed' ||
                        result[i].visit.Status__c == 'Missed'
                    ) {
                        if(result[i].visit.Status__c === 'Missed'){
                            this.missedVisit = true;
                        }else{
                            this.missedVisit = false;
                        }
                        result[i].missedVisit = this.missedVisit;
                        this.pastVisits.push(result[i]);
                    }
                    this.visitTimezone = TIME_ZONE;
                    result[i].visitTimezone = this.visitTimezone;
                }
                this.pastVisits = this.pastVisits.reverse();
                if (!this.pastVisitId) {
                    this.pastVisitId = this.pastVisits[0].visit.Id;
                }
                if (!this.upcomingVisitId) {
                    this.upcomingVisitId = this.upcomingVisits[0].visit.Id;
                    this.visitName = this.upcomingVisits[0].visit.Name;
                    this.plannedDate = this.upcomingVisits[0].visit.Planned_Date__c;
                }
               
            })
            .catch((error) => {
                this.error = error;
            });
    }

    connectedCallback() {
        this.sfdcBaseURL = window.location.origin + basePathName + communicationPreference;
        this.callParticipantVisit();
        getSiteAddress()
            .then((result) => {
                var data = JSON.parse(result);
                this.siteAddress = data.accountAddress;
                this.siteName = data.accountName;
                this.sitePhoneNumber = data.accountPhone;
            })
            .catch((error) => {
            });
    }

    onUpcomingClick(event) {
        if (this.visitid) {
            const theDiv = this.template.querySelector('[data-id="' + this.visitid + '"]');
            theDiv.className = 'inactiveCustomBoxclass';
        }
        this.template.querySelector('[data-id="upcoming"]').className =
            'slds-button slds-button_brand up-button active-button-background';
        this.template.querySelector('[data-id="past"]').className =
            'slds-button slds-button_neutral past-button inactive-button-background';
        this.showUpcomingVisits = true;
        this.visitid = this.upcomingVisitId;
        this.visitName = this.upcomingVisits[0].visit.Name;
        this.plannedDate = this.upcomingVisits[0].visit.Planned_Date__c;
        this.visitStatus = this.upcomingVisits[0].visit.Status__c;
        this.past = false;
        this.createEditTask();
    }

    onPastClick(event) {
        if (this.visitid) {
            const theDiv = this.template.querySelector('[data-id="' + this.visitid + '"]');
            theDiv.className = 'inactiveCustomBoxclass';
        }
        this.template.querySelector('[data-id="past"]').className =
            'slds-button slds-button_brand past-button active-button-background';
        this.template.querySelector('[data-id="upcoming"]').className =
            'slds-button slds-button_neutral up-button inactive-button-background';
        this.showUpcomingVisits = false;
        this.visitid = this.pastVisitId;
        this.visitName = this.pastVisits[0].visit.Name;
        this.plannedDate = this.pastVisits[0].visit.Planned_Date__c;
        this.visitStatus = this.pastVisits[0].visit.Status__c;

        this.past = true;
        this.createEditTask();
    }

    onVisitSelect(event) {
        var index = event.currentTarget.dataset.index;
        var past = event.currentTarget.dataset.past;
        const theDiv = this.template.querySelector('[data-id="' + this.visitid + '"]');
        theDiv.className = 'inactiveCustomBoxclass';
        if (past == 'true') {
            this.past = true;
            this.visitid = this.pastVisits[index].visit.Id;
            this.visitName = this.pastVisits[index].visit.Name;
            this.plannedDate = this.pastVisits[index].visit.Planned_Date__c;
            this.visitStatus = this.pastVisits[index].visit.Status__c;
        } else {
            this.visitid = this.upcomingVisits[index].visit.Id;
            this.visitName = this.upcomingVisits[index].visit.Name;
            this.selectedIndex = index;
            this.past = false;
        }
        this.taskSubject = event.currentTarget.dataset.name;
        this.createEditTask();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Visit_Details_Mobile__c'
            }
        });
        this.initializeData(this.visitid);
    }


    handleDataUpdate() {
        this.createEditTask();
    }

    createEditTask(index) {
        this.contentLoaded = false;
        this.showChild = false;
        this.showreminderdatepicker = false;
        getParticipantVisitsDetails({
            visitId: this.visitid
        })
            .then((result) => {
                var str =
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
                const theDiv = this.template.querySelector('[data-id="' + this.visitid + '"]');
                theDiv.className = 'activeCustomBoxclass';
                this.upcomingVisits[
                    this.selectedIndex
                ].visit.Planned_Date__c = this.visitdata.visitDate;
                this.upcomingVisits[
                    this.selectedIndex
                ].visit.Completed_Date__c = this.visitdata.visit.Completed_Date__c;
                this.plannedDate = this.upcomingVisits[this.selectedIndex].visit.Planned_Date__c;
                this.contentLoaded = true;
                this.showChild = true;                
                           })
            .catch((error) => {
                this.error = error;
            });
    }

    initializeData(visitid) {
        this.initialized = 'false';
        getIcon({
            visitId: visitid
        })
            .then((result) => {
                this.icondetails = result;
                if (result.length === 0) {
                    this.isError = true;
                } else {
                    this.isError = false;
                }
                let iconNames = '';
                for (let i = 0; i < result.length; i++) {
                    iconNames += result[i].icons + ';';
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