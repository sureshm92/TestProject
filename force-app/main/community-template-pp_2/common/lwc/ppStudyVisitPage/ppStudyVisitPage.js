import { LightningElement, track, api } from 'lwc';
import getParticipantVisits from '@salesforce/apex/ParticipantVisitsRemote.getParticipantVisits';
import getParticipantVisitsDetails from '@salesforce/apex/ParticipantVisitsRemote.getParticipantVisitsDetails';
import getSiteAddress from '@salesforce/apex/ParticipantVisitsRemote.getSiteAddress';
import basePathName from '@salesforce/community/basePath';
import communicationPreference from '@salesforce/label/c.Communication_Preference';
import noVisitsLabel from '@salesforce/label/c.Study_Visit_No_Date_Or_Time_Entered';
import getIcon from '@salesforce/apex/PatientVisitService.getVisitIconsbyName';
import WTELabel from '@salesforce/label/c.Home_Page_StudyVisit_WhToEx';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import myVisits from '@salesforce/label/c.Visit_My_Visits';
import noDataAvailable from '@salesforce/label/c.Visits_No_Data_Available';
import upcoming from '@salesforce/label/c.Visits_Upcoming';
import past from '@salesforce/label/c.Visits_Past';
import results from '@salesforce/label/c.Visit_Result';
import resultsCheck from '@salesforce/label/c.Visit_Check_Result';
import viewAllResults from '@salesforce/label/c.Visits_View_All_Results';
import myvisits from '@salesforce/label/c.My_Visits';
import loading from '@salesforce/label/c.Loading';
import visitdetails from '@salesforce/label/c.Visit_Details';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
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
        myvisits,
        loading,
        visitdetails
    };
    status = {
        scheduled: 'Scheduled',
        pending: 'Pending',
        completed: 'Completed',
        missed: 'Missed'
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
    @track initialPageLoad = false;
    initialized = '';
    visitWrappers = [];
    @api icondetails = [];
    isError = false;
    initialized = '';
    isError = false;
    dateloaded = false;
    @track buttonClicked = false;
    cbload = false;
    @api cblabel = '';
    @api cbdescription = '';
    @track noVisitDate = false;
    @track visitTimezone = [];
    @track showUpcomingVisits = true;
    @track onVisitSelection = false;
    visitimage1 = pp_icons + '/' + 'VisitPageResultImage.png';
    visitimage2 = pp_icons + '/' + 'VisitPage_1.png';

    callParticipantVisit() {
        this.cbload = true;
        this.initialPageLoad = true;
        getParticipantVisits({
            visitMode: this.visitMode
        })
            .then((result) => {
                if (result.length > 0) {
                    this.visitid = result[0].visit.Id;
                    this.taskSubject = result[0].visit.Name;
                    for (let i = 0; i < result.length; i++) {
                        if (
                            result[i].visit.Completed_Date__c == null &&
                            (result[i].visit.Status__c == this.status.scheduled ||
                                result[i].visit.Status__c == this.status.pending)
                        ) {
                            if (result[i].visit.Planned_Date__c === undefined) {
                                this.noVisitDate = true;
                                result[i].noVisitDate = this.noVisitDate;
                            } else {
                                result[i].noVisitDate = false;
                            }
                            this.upcomingVisits.push(result[i]);
                        } else if (
                            result[i].visit.Status__c == this.status.completed ||
                            result[i].visit.Status__c == this.status.missed
                        ) {
                            if (result[i].visit.Completed_Date__c === undefined) {
                                this.noVisitDate = true;
                                result[i].noVisitDate = this.noVisitDate;
                            }
                            this.pastVisits.push(result[i]);
                        }
                        this.visitTimezone = TIME_ZONE;
                        result[i].visitTimezone = this.visitTimezone;
                    }
                    if (!this.pastVisitId && this.pastVisits.length > 0) {
                        this.pastVisits = this.pastVisits.reverse();
                        this.pastVisitId = this.pastVisits[0].visit.Id;
                    }
                    if (!this.upcomingVisitId && this.upcomingVisits.length > 0) {
                        this.upcomingVisitId = this.upcomingVisits[0].visit.Id;
                        this.visitName = this.upcomingVisits[0].visit.Name;
                        this.plannedDate = this.upcomingVisits[0].visit.Planned_Date__c;
                    }
                    this.initializeData(this.visitid);
                    this.createEditTask();
                } else {
                    this.contentLoaded = true;
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
                this.showErrorToast('Error occured', error.message, 'error');
            });
    }

    onUpcomingClick(event) {
        this.showChild = false;
        if (this.visitid) {
            const theDiv = this.template.querySelector('[data-id="' + this.visitid + '"]');
            theDiv.className = 'inactive-custom-box-class';
        }
        this.template.querySelector('[data-id="upcoming"]').className =
            'slds-button slds-button_brand up-button active-button-background';
        this.template.querySelector('[data-id="past"]').className =
            'slds-button slds-button_neutral past-button inactive-button-background';
        this.showUpcomingVisits = true;
        if (this.upcomingVisits.length > 0) {
            this.visitid = this.upcomingVisitId;
            this.visitName = this.upcomingVisits[0].visit.Name;
            this.plannedDate = this.upcomingVisits[0].visit.Planned_Date__c;
            this.visitStatus = this.upcomingVisits[0].visit.Status__c;
            this.past = false;
            this.createEditTask();
        }
    }

    onPastClick(event) {
        this.showChild = false;
        if (this.visitid) {
            const theDiv = this.template.querySelector('[data-id="' + this.visitid + '"]');
            theDiv.className = 'inactive-custom-box-class';
        }
        this.template.querySelector('[data-id="past"]').className =
            'slds-button slds-button_brand past-button active-button-background';
        this.template.querySelector('[data-id="upcoming"]').className =
            'slds-button slds-button_neutral up-button inactive-button-background';
        this.showUpcomingVisits = false;
        if (this.pastVisits) {
            this.visitid = this.pastVisitId;
            this.visitName = this.pastVisits[0].visit.Name;
            this.plannedDate = this.pastVisits[0].visit.Planned_Date__c;
            this.visitStatus = this.pastVisits[0].visit.Status__c;
            this.past = true;
            this.createEditTask();
        }
    }

    onVisitSelect(event) {
        this.initialPageLoad = false;
        var index = event.currentTarget.dataset.index;
        var past = event.currentTarget.dataset.past;
        const theDiv = this.template.querySelector('[data-id="' + this.visitid + '"]');
        theDiv.className = 'inactive-custom-box-class';
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
        const objChild = this.template.querySelector('c-pp-R-R-Icon-Splitter');
        objChild.resetValues();
    }

    handleDataUpdate() {
        this.createEditTask();
    }

    createEditTask(index) {
        this.contentLoaded = false;
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
                const theDiv = this.template.querySelector('[data-id="' + this.visitid + '"]');
                theDiv.className = 'active-custom-box-class';
                this.upcomingVisits[this.selectedIndex].visit.Planned_Date__c =
                    this.visitdata.visitDate;
                this.upcomingVisits[this.selectedIndex].visit.Completed_Date__c =
                    this.visitdata.visit.Completed_Date__c;
                if (this.visitdata.visitDate) {
                    this.upcomingVisits[this.selectedIndex].noVisitDate = false;
                }
                this.plannedDate = this.upcomingVisits[this.selectedIndex].visit.Planned_Date__c;
                this.showChild = true;
                if (!this.initialPageLoad) {
                    this.initializeData(this.visitid);
                    this.contentLoaded = true;
                    this.template.querySelector('c-pp-Study-Visit-Details-Card').callFromParent();
                } else {
                    this.initializeData(this.visitid);
                    this.contentLoaded = true;
                }
            });
        } else {
            this.contentLoaded = true;
        }
    }

    initializeData(visitid) {
        this.initialized = 'false';
        getIcon({
            visitId: visitid
        })
            .then((result) => {
                this.icondetails = result;
                if (result.length === 0 || result == null || result == '') {
                    this.isError = true;
                } else {
                    this.isError = false;
                }
                if (this.cbload == true && result.length != 0) {
                    this.cblabel = this.icondetails[0].Label__c;
                    this.cbdescription = this.icondetails[0].Description__c;
                }
            })
            .catch((error) => {
                this.showErrorToast('Error occured', error.message, 'error');
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
