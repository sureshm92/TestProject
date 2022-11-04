import { LightningElement, track, api } from 'lwc';
import getParticipantVisits from '@salesforce/apex/ParticipantVisitsRemote.getParticipantVisits';
import getParticipantVisitsDetails from '@salesforce/apex/ParticipantVisitsRemote.getParticipantVisitsDetails';
import getSiteAddress from '@salesforce/apex/ParticipantVisitsRemote.getSiteAddress';
import basePathName from '@salesforce/community/basePath';
import communicationPreference from '@salesforce/label/c.Communication_Preference_Url';
import noVisitsLabel from '@salesforce/label/c.Study_Visit_No_Date_Or_Time_Entered';
import getIcon from '@salesforce/apex/ParticipantVisitsRemote.getVisitIconsbyName';
import WTELabel from '@salesforce/label/c.Home_Page_StudyVisit_WhToEx';
import TIME_ZONE from '@salesforce/i18n/timeZone';
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
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import formFactor from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
export default class PpStudyVisitPage extends NavigationMixin(LightningElement) {
    label = {
        noVisitsLabel,
        WTELabel,
        noDataAvailable,
        upcoming,
        past,
        results,
        resultsCheck,
        viewAllResults,
        visitUnavailable,
        myVisits,
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
    isResultsCard = true;
    initialized = '';
    visitWrappers = [];
    @api icondetails = [];
    isError = false;
    initialized = '';
    dateloaded = false;
    @track buttonClicked = false;
    cbload = false;
    @api cblabel = '';
    @api cbdescription = '';
    @track noVisitDate = false;
    @track showUpcomingVisits = true;
    @track onVisitSelection = false;
    visitimage1 = pp_icons + '/' + 'VisitPageResultImage.png';
    visitimage2 = pp_icons + '/' + 'VisitPage_1.png';
    @track missedVisit = false;
    @track showList = false;
    isMobile = false;
    hasRendered = false;

    callParticipantVisit() {
        this.cbload = true;
        this.initialPageLoad = true;
        getParticipantVisits({
            visitMode: this.visitMode
        })
            .then((result) => {
                this.template.querySelector('c-web-spinner').show();
                this.visitTimezone = TIME_ZONE;
                if (result.length > 0) {
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
                            if (result[i].task === undefined) {
                                result[i].isReminderDate = false;
                            } else {
                                if (result[i].task.Reminder_Date__c === undefined) {
                                    result[i].isReminderDate = false;
                                } else {
                                    result[i].isReminderDate = true;
                                }
                            }
                            this.upcomingVisits.push(result[i]);
                        } else if (
                            result[i].visit.Status__c == this.status.completed ||
                            result[i].visit.Status__c == this.status.missed
                        ) {
                            if (result[i].visit.Completed_Date__c === undefined) {
                                this.noVisitDate = true;
                                result[i].noVisitDate = this.noVisitDate;
                                result[i].visit.Completed_Date__c = '';
                            }
                            if (result[i].visit.Status__c === this.status.missed) {
                                this.missedVisit = true;
                            } else {
                                this.missedVisit = false;
                            }
                            result[i].missedVisit = this.missedVisit;
                            this.pastVisits.push(result[i]);
                        }
                    }
                    //get upcoming visit details onload
                    this.visitid = this.upcomingVisits[0].visit.Id;
                    this.taskSubject = this.upcomingVisits[0].visit.Name;

                    if (!this.pastVisitId && this.pastVisits.length > 0) {
                        this.pastVisits = this.pastVisits.reverse();
                        this.pastVisitId = this.pastVisits[0].visit.Id;
                    }
                    if (!this.upcomingVisitId && this.upcomingVisits.length > 0) {
                        this.upcomingVisitId = this.upcomingVisits[0].visit.Id;
                        this.visitName = this.upcomingVisits[0].visit.Name;
                        this.plannedDate = this.upcomingVisits[0].visit.Planned_Date__c;
                    }
                    this.showList = true;
                    this.initializeData(this.visitid);
                    this.createEditTask();
                } else {
                    this.template.querySelector('c-web-spinner').hide();
                    this.contentLoaded = true;
                }
                if (this.isMobile) {
                    this.getParams();
                }
            })
            .catch((error) => {
                this.error = error;
            });
    }

    renderedCallback() {
        if (!this.hasRendered) {
            this.template.querySelector('c-web-spinner').show();
            this.hasRendered = true;
        }
    }

    connectedCallback() {
        if (formFactor === 'Small') {
            this.isMobile = true;
        } else {
            this.isMobile = false;
        }
        this.sfdcBaseURL = window.location.origin + basePathName + communicationPreference;
        this.callParticipantVisit();
        getSiteAddress()
            .then((result) => {
                this.template.querySelector('c-web-spinner').show();
                var data = JSON.parse(result);
                this.siteAddress = data.accountAddress;
                this.siteName = data.accountName;
                this.sitePhoneNumber = data.accountPhone;
            })
            .catch((error) => {
                this.showErrorToast('Error occured', error.message, 'error');
            });
    }

    getParams() {
        if (communityService.getUrlParameter('ispast') === 'true') {
            this.past = true;
            this.showUpcomingVisits = false;
            this.visitid = this.pastVisits[0].visit.Id;
        } else {
            this.past = false;
            this.showUpcomingVisits = true;
            this.visitid = this.upcomingVisits[0].visit.Id;
        }
    }

    onUpcomingClick() {
        this.initialPageLoad = false;
        this.showChild = false;
        this.cbload = true;
        this.showList = false;
        this.past = false;
        this.showUpcomingVisits = true;
        if (this.upcomingVisits.length > 0) {
            this.visitid = this.upcomingVisitId;
            this.visitName = this.upcomingVisits[0].visit.Name;
            this.plannedDate = this.upcomingVisits[0].visit.Planned_Date__c;
            this.visitStatus = this.upcomingVisits[0].visit.Status__c;
            this.createEditTask();
        }
        const objChild = this.template.querySelector('c-pp-r-r-icon-splitter');
        objChild.resetValues();
        objChild.handleOnVisitClick();
    }

    onPastClick() {
        this.initialPageLoad = false;
        this.showChild = false;
        this.cbload = true;
        this.showList = false;
        this.past = true;
        this.showUpcomingVisits = false;
        if (this.pastVisits.length > 0) {
            this.visitid = this.pastVisitId;
            this.visitName = this.pastVisits[0].visit.Name;
            this.plannedDate = this.pastVisits[0].visit.Planned_Date__c;
            this.visitStatus = this.pastVisits[0].visit.Status__c;
            this.createEditTask();
        } else {
            this.visitid = this.pastVisitId;
            this.visitName = '';
            this.visitStatus = '';
        }
        const objChild = this.template.querySelector('c-pp-r-r-icon-splitter');
        objChild.resetValues();
        objChild.handleOnVisitClick();
    }

    onVisitSelect(event) {
        this.initialPageLoad = false;
        var index = event.detail.indexval;
        var past = event.detail.past;
        if (past) {
            this.past = true;
            this.visitid = this.pastVisits[index].visit.Id;
            this.visitName = this.pastVisits[index].visit.Name;
            this.plannedDate = this.pastVisits[index].visit.Planned_Date__c;
            if (this.pastVisits[index].missedVisit) {
                this.visitStatus = this.label.visitUnavailable;
                this.isResultsCard = false;
            } else {
                this.visitStatus = this.pastVisits[index].visit.Status__c;
                this.isResultsCard = true;
            }
        } else {
            this.visitid = this.upcomingVisits[index].visit.Id;
            this.visitName = this.upcomingVisits[index].visit.Name;
            this.selectedIndex = index;
            this.past = false;
        }
        this.taskSubject = event.detail.tasksubject;
        if (this.isMobile != true) {
            this.cbload = true;
            this.createEditTask();
            const objChild = this.template.querySelector('c-pp-r-r-icon-splitter');
            objChild.resetValues();
            objChild.handleOnVisitClick();
        }

        if (this.isMobile == true) {
            this.redirectPage(this.visitid);
        }
    }

    redirectPage(visitid) {
        this.visitdetailurl =
            window.location.origin + basePathName + '/visit-details' + '?visitid=' + visitid;

        console.log('visitdetailurl:: ', this.visitdetailurl);

        const config = {
            type: 'standard__webPage',

            attributes: {
                url: this.visitdetailurl
            }
        };

        this[NavigationMixin.GenerateUrl](config).then((url) => {
            window.open(url, '_self');
        });
    }

    handleDataUpdate() {
        this.createEditTask();
    }

    saveClicked() {
        this.showChild = false;
        this.contentLoaded = false;
        this.template.querySelector('c-web-spinner').show();
    }

    createEditTask(index) {
        this.showChild = false;
        this.contentLoaded = false;
        this.template.querySelector('c-web-spinner').show();
        this.showreminderdatepicker = false;
        if (this.visitid) {
            getParticipantVisitsDetails({
                visitId: this.visitid
            }).then((result) => {
                this.showList = true;
                const str =
                    '{"Id":"","Patient_Visit__c":"","Reminder_Date__c":"","ReminderDateTime":"","Remind_Me__c":"","Remind_Using_Email__c":false,"Remind_Using_SMS__c":false}';
                var jsonstr = JSON.stringify(result[0]);
                const obj = JSON.parse(jsonstr);
                if (typeof result[0].task === 'undefined') {
                    obj.task = JSON.parse(str);
                    this.upcomingVisits[this.selectedIndex].isReminderDate = false;
                }
                if (typeof result[0].visitDate === 'undefined') {
                    obj.visitDate = '';
                }
                this.visitdata = obj;
                this.taskId = this.visitdata.task.Id;

                //update bell icon once reminder is created PEH-7825
                if (this.taskId) {
                    if (this.visitdata.task.Reminder_Date__c === undefined) {
                        this.upcomingVisits[this.selectedIndex].isReminderDate = false;
                    } else {
                        this.upcomingVisits[this.selectedIndex].isReminderDate = true;
                    }
                } else {
                    this.upcomingVisits[this.selectedIndex].isReminderDate = false;
                }

                if (!this.past) {
                    this.upcomingVisits[
                        this.selectedIndex
                    ].visit.Planned_Date__c = this.visitdata.visitDate;
                }
                if (this.visitdata.visitDate && this.showUpcomingVisits) {
                    this.upcomingVisits[this.selectedIndex].noVisitDate = false;
                    this.plannedDate = this.upcomingVisits[
                        this.selectedIndex
                    ].visit.Planned_Date__c;
                } else {
                    this.upcomingVisits[this.selectedIndex].noVisitDate = true;
                    this.plannedDate = '';
                }
                this.showChild = true;
                if (!this.initialPageLoad) {
                    this.initializeData(this.visitid);
                    this.contentLoaded = true;
                    this.template.querySelector('c-web-spinner').hide();
                    this.template.querySelector('c-pp-Study-Visit-Details-Card')?.callFromParent();
                } else {
                    this.initializeData(this.visitid);
                    this.contentLoaded = true;
                    this.template.querySelector('c-web-spinner').hide();
                }
            });
        } else {
            this.contentLoaded = true;
            this.template.querySelector('c-web-spinner').hide();
        }
    }

    handleDiscard() {
        this.showChild = false;
        this.createEditTask();
    }

    async handleVisitChange() {
        if (this.visitid) {
            await this.template.querySelector('[data-id="' + this.visitid + '"]');
            const theDiv = this.template.querySelector('[data-id="' + this.visitid + '"]');
            theDiv.className = 'active-custom-box';
        }
    }

    initializeData(visitid) {
        this.initialized = 'false';
        this.cblabel = '';
        this.cbdescription = '';
        this.icondetails = '';
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
                if (result.length != 0) {
                    this.cblabel = this.icondetails[0]?.Label__c;
                    this.cbdescription = this.icondetails[0]?.Description__c;
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
