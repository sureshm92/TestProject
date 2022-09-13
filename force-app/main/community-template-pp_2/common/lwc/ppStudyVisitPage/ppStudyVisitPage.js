import { LightningElement, track, api } from 'lwc';
import getParticipantVisits from '@salesforce/apex/ParticipantVisitsRemote.getParticipantVisits';
import noVisitsLabel from '@salesforce/label/c.Study_Visit_No_Date_Or_Time_Entered';
import getInitData from '@salesforce/apex/ParticipantVisitsRemote.getParticipantVisits';
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
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';

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
        viewAllResults
    };
    @track visitMode = 'All';
    @track upcomingVisits = [];
    @track pastVisits = [];
    @track noVisitDate = false;
    @track visitTimezone = [];
    @track showUpcomingVisits = true;
    @track upcomingVariantValue = 'Neutral';
    @track pastVariantValue = 'Neutral';
    @track onVisitSelection = false;
    @track visitid;
    initialized = '';
    @api icondetails = [];
    isError = false;
    dateloaded = false;
    @track buttonClicked = false;
    cbload = false;
    @api cblabel = '';
    @api cbdescription = '';
    @track customBoxclass = 'slds-box';

    visitimage1 = pp_icons + '/' + 'VisitPageResultImage.png';
    visitimage2 = pp_icons + '/' + 'VisitPage_1.png';

    connectedCallback() {
        this.cbload = true;
        getParticipantVisits({
            visitMode: this.visitMode
        })
            .then((result) => {
                console.log('result::' + JSON.stringify(result));
                console.log('length of resp', result.length);

                //set values on page load
                /*this.visitid = this.upcomingVisits[0].visit.Id;
                this.initializeData(this.visitid);
                console.log('this.visitid::'+this.visitid);
                this.visitname = result[0].visit.Name;
                this.plannedDate = result[0].visit.Planned_Date__c;
                //this.completedDate = result[0].visit.Completed_Date__c;
                this.showUpcomingVisits = true;*/

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
                        console.log('upcomingVisits1::' + this.upcomingVisits[i]);
                    } else if (
                        (result[i].visit.Completed_Date__c != null &&
                            result[i].visit.Status__c == 'Completed') ||
                        (result[i].visit.Completed_Date__c == null &&
                            result[i].visit.Status__c == 'Missed')
                    ) {
                        this.pastVisits.push(result[i]);
                    }

                    //this.visittimezone = TIME_ZONE;
                    //result[i].visittimezone = this.visittimezone;
                    console.log('upcomingVisits::' + this.upcomingVisits[i]);
                    console.log('pastVisits::' + this.pastVisits[i]);

                    //set visitId on load of page
                    /*  this.visitid = this.upcomingVisits[0].visit.Id;
                    this.initializeData(this.visitid);
                    this.visitname = this.upcomingVisits[0].visit.Name;
                    this.plannedDate = this.upcomingVisits[0].visit.Planned_Date__c;
                    this.completedDate = this.pastVisits[0].visit.Completed_Date__c;
                    this.visittimezone = TIME_ZONE;
                    this.upcomingVisits[0].visittimezone = this.visittimezone;*/

                    //set visitId on load of page
                    this.visitid = this.upcomingVisits[0].visit.Id;
                    //this.initializeData(this.visitid);
                    console.log('this.visitid::' + this.visitid);
                    this.visitname = this.upcomingVisits[0].visit.Name;
                    this.plannedDate = this.upcomingVisits[0].visit.Planned_Date__c;
                    this.completedDate = this.upcomingVisits[0].visit.Completed_Date__c;
                    this.visittimezone = TIME_ZONE;
                    this.upcomingVisits[0].visittimezone = this.visittimezone;

                    if (this.plannedDate != null || this.plannedDate != '') {
                        this.dateloaded = true;
                    } else {
                        this.dateloaded = false;
                    }

                    this.showUpcomingVisits = true;

                    /*console.log('visitid::' + this.visitid);
                    console.log('visitname::' + this.visitname);
                    console.log('plannedDate::' + this.plannedDate);
                    console.log('completedDate::' + this.completedDate);
                    console.log('visittimezone::' + this.upcomingVisits[0].visittimezone);*/
                }
                this.initializeData(this.visitid);
            })
            .catch((error) => {
                this.error = error;
            });
    }
    onUpcomingClick(event) {
        this.showUpcomingVisits = true;
    }
    onPastClick(event) {
        this.showUpcomingVisits = false;
    }

    onVisitSelect(event) {
        this.cbload = true;
        // $(".slds-box").removeClass("active");
        //   $(this).addClass('active');
        //this.buttonClicked = this.buttonClicked ? 'slds-box active' : 'slds-box inactive';
        //this.buttonClicked = !this.buttonClicked;
        this.customBoxclass = 'slds-box active';
        var index = event.currentTarget.dataset.index;
        this.visitid = this.upcomingVisits[index].visit.Id;
        this.initializeData(this.visitid);
        this.visitname = this.upcomingVisits[index].visit.Name;
        this.plannedDate = this.upcomingVisits[index].visit.Planned_Date__c;
        this.completedDate = this.upcomingVisits[index].visit.Completed_Date__c;
        this.visittimezone = TIME_ZONE;
        this.upcomingVisits[index].visittimezone = this.visittimezone;
        this.createEditTask(this.visitid);

        if (this.plannedDate != null || this.plannedDate != '') {
            this.dateloaded = true;
        } else {
            this.dateloaded = false;
        }

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
                // result returns list of Icon Detail Records based on Patient Visit Id
                this.icondetails = result;
                if (result.length === 0 || result == null || result == '') {
                    this.isError = true;
                } else {
                    this.isError = false;
                }
                if (this.cbload == true) {
                    this.cblabel = this.icondetails[0].Label__c;
                    this.cbdescription = this.icondetails[0].Description__c;
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
