import { LightningElement, track, wire } from 'lwc';
import getParticipantVisits from '@salesforce/apex/ParticipantVisitsRemote.getPatientVisitsDetails';
import getParticipantVisitsDetails from '@salesforce/apex/ParticipantVisitsRemote.getParticipantVisitsDetails';
import getSiteAddress from '@salesforce/apex/ParticipantVisitsRemote.getSiteAddress';
import noVisitsLabel from '@salesforce/label/c.Study_Visit_No_Date_Or_Time_Entered';
import WTELabel from '@salesforce/label/c.Home_Page_StudyVisit_WhToEx';
import myVisits from '@salesforce/label/c.Visit_My_Visits';
import noDataAvailable from '@salesforce/label/c.Visits_No_Data_Available';
import upcoming from '@salesforce/label/c.Visits_Upcoming';
import past from '@salesforce/label/c.Visits_Past';
import BTN_Back from '@salesforce/label/c.BTN_Back';
import results from '@salesforce/label/c.Visit_Result';
import resultsCheck from '@salesforce/label/c.Visit_Check_Result';
import viewAllResults from '@salesforce/label/c.Visits_View_All_Results';
import getIcon from '@salesforce/apex/ParticipantVisitsRemote.getVisitIconsbyName';
import { NavigationMixin } from 'lightning/navigation';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import basePathName from '@salesforce/community/basePath';
import visitdetails from '@salesforce/label/c.Visit_Details';
import eventdetails from '@salesforce/label/c.Event_Details';
import communicationPreference from '@salesforce/label/c.Communication_Preference_Url';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Unavailable from '@salesforce/label/c.Study_Visit_Unavailable';

export default class PpStudyVisitDetailsMobile extends NavigationMixin(LightningElement) {
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
        visitdetails,
        eventdetails,
        BTN_Back,
        Unavailable
    };
    status = {
        scheduled: 'Scheduled',
        pending: 'Pending',
        completed: 'Completed',
        missed: 'Missed'
    };
    @track icondetails;
    @track visitid;
    @track cblabel = '';
    @track cbdescription = '';
    @track isError = false;
    @track visitdata;
    @track taskId;
    @track taskSubject;
    @track sfdcBaseURL;
    @track siteAddress;
    @track siteName;
    @track sitePhoneNumber;
    @track contentLoaded = false;
    @track past = false;
    @track isInitialVisit = false;
    @track showChild = false;
    visitimage1 = pp_icons + '/' + 'VisitPageResultImage.png';
    @track visitDetail;
    visitName = '';
    plannedDate = '';
    visitStatus = '';
    visitTimezone = '';
    hasRendered = false;
    isEvent = false;
    @track visitdetailpageurl = '';
    @track missedVisit = false;

    renderedCallback() {
        if (!this.hasRendered) {
            this.template.querySelector('c-web-spinner').show();
            this.hasRendered = true;
        }
    }

    connectedCallback() {
        if (window.location.pathname.includes('event')) {
            this.isEvent = true;
            this.missedVisit = true;
        }
        this.contentLoaded = false;
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                this.sfdcBaseURL = window.location.origin + basePathName + communicationPreference;
                this.getParams();
            })
            .catch((error) => {
                this.showErrorToast(this.labels.ERROR_MESSAGE, error.message, 'error');
            });
    }

    getVisitDetails(visitid) {
        if (visitid != null) {
            getParticipantVisits({
                visitId: visitid
            })
                .then((result) => {
                    this.visitDetail = result;
                    if (result.length != 0 || result != null || result != '') {
                        this.visitName = this.visitDetail[0]?.Visit__r?.Patient_Portal_Name__c;
                        this.plannedDate = this.visitDetail[0].Planned_Date__c;
                        this.visitStatus = this.visitDetail[0].Status__c;
                        this.visitTimezone = TIME_ZONE;
                        this.isInitialVisit =
                            this.visitDetail[0].Is_Pre_Enrollment_Patient_Visit__c;
                    }
                    if (this.visitStatus == 'Missed') {
                        this.visitStatus = this.label.Unavailable;
                        if (this.isEvent != true) {
                            this.missedVisit = true;
                        }
                    }
                })
                .catch((error) => {
                    this.showErrorToast('error occured', error.message, 'error');
                });
        }
    }
    getParams() {
        if (this.isEvent) {
            this.visitid = communityService.getUrlParameter('eventid');
        } else {
            this.visitid = communityService.getUrlParameter('visitid');
        }
        this.cblabel = '';
        this.cbdescription = '';
        if (this.visitid != null) {
            getIcon({
                visitId: this.visitid
            })
                .then((result) => {
                    this.icondetails = result;
                    if (result.length === 0 || result == null || result == '') {
                        this.isError = true;
                    } else {
                        this.isError = false;
                        this.cblabel = this.icondetails[0].Label__c;
                        this.cbdescription = this.icondetails[0].Description__c;
                    }
                })
                .catch((error) => {
                    this.showErrorToast('error occured', error.message, 'error');
                });
            this.getVisitDetails(this.visitid);
            this.createEditTask();
            this.getAccount();
        }
    }

    handleBackClick() {
        if (this.isEvent) {
            this.visitdetailpageurl =
                window.location.origin + basePathName + '/events' + '?ispast=' + this.past;
        } else {
            this.visitdetailpageurl =
                window.location.origin + basePathName + '/visits' + '?ispast=' + this.past;
        }
        const config = {
            type: 'standard__webPage',
            attributes: {
                url: this.visitdetailpageurl
            }
        };
        this[NavigationMixin.GenerateUrl](config).then((url) => {
            sessionStorage.setItem('Cookies', 'Accepted');
            window.open(url, '_self');
        });
    }

    getAccount() {
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

    handleDiscard() {
        this.showChild = false;
        this.createEditTask();
    }

    createEditTask() {
        this.showChild = false;
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
                if (typeof result[0].plannedDate === 'undefined') {
                    obj.plannedDate = '';
                }
                this.visitdata = obj;
                if (
                    this.visitdata.visitStatus == this.status.missed ||
                    this.visitdata.visitStatus == this.status.completed
                ) {
                    this.past = true;
                }
                //this.isInitialVisit = this.visitdata.Is_Pre_Enrollment_Patient_Visit__c;
                this.taskId = this.visitdata.task.Id;
                this.taskSubject = this.visitdata.visit.Name;
                this.contentLoaded = true;
                this.template.querySelector('c-web-spinner').hide();
                this.showChild = true;
                if (this.template.querySelector('c-pp-Study-Visit-Details-Card')) {
                    this.template.querySelector('c-pp-Study-Visit-Details-Card').callFromParent();
                }
            });
        } else {
            this.contentLoaded = true;
            this.template.querySelector('c-web-spinner').hide();
        }
    }

    handleDataUpdate() {
        this.redirectPage(this.visitid);
    }

    redirectPage(visitid) {
        if (this.isEvent) {
            this.visitdetailurl =
                window.location.origin + basePathName + '/event-details' + '?eventid=' + visitid;
        } else {
            this.visitdetailurl =
                window.location.origin + basePathName + '/visit-details' + '?visitid=' + visitid;
        }
        const config = {
            type: 'standard__webPage',

            attributes: {
                url: this.visitdetailurl
            }
        };

        this[NavigationMixin.GenerateUrl](config).then((url) => {
            sessionStorage.setItem('Cookies', 'Accepted');
            window.open(url, '_self');
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
