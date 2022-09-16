import { LightningElement, track, wire } from 'lwc';
import getParticipantVisitsDetails from '@salesforce/apex/ParticipantVisitsRemote.getParticipantVisitsDetails';
import getSiteAddress from '@salesforce/apex/ParticipantVisitsRemote.getSiteAddress';
import noVisitsLabel from '@salesforce/label/c.Study_Visit_No_Date_Or_Time_Entered';
import WTELabel from '@salesforce/label/c.Home_Page_StudyVisit_WhToEx';
import myVisits from '@salesforce/label/c.Visit_My_Visits';
import noDataAvailable from '@salesforce/label/c.Visits_No_Data_Available';
import upcoming from '@salesforce/label/c.Visits_Upcoming';
import past from '@salesforce/label/c.Visits_Past';
import results from '@salesforce/label/c.Visit_Result';
import resultsCheck from '@salesforce/label/c.Visit_Check_Result';
import viewAllResults from '@salesforce/label/c.Visits_View_All_Results';
import getIcon from '@salesforce/apex/PatientVisitService.getVisitIconsbyName';
import { NavigationMixin } from 'lightning/navigation';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import basePathName from '@salesforce/community/basePath';
import communicationPreference from '@salesforce/label/c.Communication_Preference_Url';

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
        viewAllResults
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
    @track showChild = false;
    visitimage1 = pp_icons + '/' + 'VisitPageResultImage.png';

    connectedCallback() {
        console.log('Connected callback');
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                this.sfdcBaseURL = window.location.origin + basePathName + communicationPreference;
                this.getParams();
            })
            .catch((error) => {
                this.showErrorToast(this.labels.ERROR_MESSAGE, error.message, 'error');
            });
    }

    getParams() {
        this.visitid = communityService.getUrlParameter('visitid');
        console.log('visit in getParams: ', this.visitid);
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
                    }

                    this.cblabel = this.icondetails[0].Label__c;
                    this.cbdescription = this.icondetails[0].Description__c;
                })
                .catch((error) => {
                    this.showErrorToast('error occured', error.message, 'error');
                });
            this.createEditTask();
            this.getAccount();
        }
    }

    handleBackClick() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Visit_List_Mobile__c'
            }
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

    createEditTask() {
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
                if (
                    this.visitdata.visitStatus == this.status.missed ||
                    this.visitdata.visitStatus == this.status.completed
                ) {
                    this.past = true;
                }
                this.taskId = this.visitdata.task.Id;
                this.taskSubject = this.visitdata.visit.Name;
                this.contentLoaded = true;
                this.showChild = true;
                this.template.querySelector('c-pp-Study-Visit-Details-Card').callFromParent();
            });
        } else {
            this.contentLoaded = true;
        }
    }

    handleDataUpdate() {
        this.createEditTask();
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
