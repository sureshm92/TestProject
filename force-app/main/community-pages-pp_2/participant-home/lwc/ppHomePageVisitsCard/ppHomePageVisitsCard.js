//Created by Chetna Chauhan Sep 9,2022
import { LightningElement, api, track } from 'lwc';
import getVisitsPreviewAndCount from '@salesforce/apex/ParticipantVisitsRemote.getVisitsPreviewAndCount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import What_to_Expect from '@salesforce/label/c.Upcoming_Visit_Expect';
import UPCOMING from '@salesforce/label/c.Televisit_Upcoming';
import MORE from '@salesforce/label/c.PIR_more';
import NO_DATE from '@salesforce/label/c.PP_Date_Unavailable';
import NO_TIME from '@salesforce/label/c.PP_Time_Unavailable';
import VISIT_NO_EXPECT from '@salesforce/label/c.Visit_No_Expect';
import EVENT_NO_EXPECT from '@salesforce/label/c.Event_No_Expect';
import View_Visit_Details from '@salesforce/label/c.View_Visit_Details';
import View_Event_Details from '@salesforce/label/c.View_Event_Details';
import PG_Mobile_Title_Upcoming_Visits from '@salesforce/label/c.PG_Mobile_Title_Upcoming_Visits';
import PG_Mobile_Title_Upcoming_Events from '@salesforce/label/c.PG_Mobile_Title_Upcoming_Events';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import No_Upcoming_Visit from '@salesforce/label/c.Visit_No_Upcoming_Visit';
import No_Upcoming_Event from '@salesforce/label/c.Event_No_Upcoming_Event';
import visit_clock from '@salesforce/label/c.Upcoming_Visits_Clock';
import visit_calendar from '@salesforce/label/c.Upcoming_Visit_calendar';
import Upcoming_Visit_Location from '@salesforce/label/c.Upcoming_Visit_Location';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';

export default class HomePageVisitsCard extends LightningElement {
    planDateTime;
    siteLocation;
    siteTitle;
    sitePhone;
    visitName;
    iconDetails;
    moreIconsCount;
    @track upcomingVisit;
    @api desktop;
    @api isProgram;
    userTimeZone = TIME_ZONE;
    isInitialized = false;
    labels = {
        What_to_Expect,
        UPCOMING,
        MORE,
        View_Visit_Details,
        View_Event_Details,
        NO_DATE,
        NO_TIME,
        VISIT_NO_EXPECT,
        EVENT_NO_EXPECT,
        No_Upcoming_Visit,
        visit_clock,
        visit_calendar,
        Upcoming_Visit_Location,
        No_Upcoming_Event,
        PG_Mobile_Title_Upcoming_Visits,
        PG_Mobile_Title_Upcoming_Events
    };

    isUpcomingDetails = false;
    isVisitAvailable = false;
    empty_state = pp_community_icons + '/' + 'empty_visits.png';
    spinner;
    renderedCallback() {
        if (this.isInitialized != true) {
            this.initializeData();
        }
    }

    initializeData() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) {
            this.spinner.show();
        }
        getVisitsPreviewAndCount({})
            .then((result) => {
                let visitDetails = result.visitPreviewList;
                this.isVisitAvailable = result.showVisits;
                if (visitDetails != null && visitDetails.length != 0 && visitDetails != '') {
                    this.isUpcomingDetails = true;
                    let initialVisit = visitDetails.find(
                        (visitDetail) =>
                            visitDetail.visit.Is_Pre_Enrollment_Patient_Visit__c == true
                    );

                    this.upcomingVisit = initialVisit ? initialVisit : visitDetails[0];
                    this.planDateTime = this.upcomingVisit.visitDate
                        ? this.upcomingVisit.visitDate
                        : false;
                    this.visitName = this.upcomingVisit.visit?.Name;
                    this.siteTitle =
                        this.upcomingVisit.visit.Participant_Enrollment__r?.Study_Site__r?.Site__r?.Name;
                    this.sitePhone =
                        this.upcomingVisit.visit.Participant_Enrollment__r?.Study_Site__r?.Site__r?.Phone;
                    let location =
                        this.upcomingVisit.visit.Participant_Enrollment__r?.Study_Site__r?.Site__r
                            ?.BillingAddress;

                    this.siteLocation = location
                        ? (location.street ? location.street : '') +
                          ', ' +
                          (location.city ? location.city : '') +
                          ', ' +
                          (location.stateCode ? location.stateCode : '') +
                          ' ' +
                          (location.postalCode ? location.postalCode : '')
                        : '';

                    let icons = this.upcomingVisit.iconDetails;
                    this.moreIconsCount = icons.length > 4 ? icons.length - 4 : false;
                    this.iconDetails = icons.length > 0 ? icons?.slice(0, 4) : false;
                } else {
                    this.isUpcomingDetails = false;
                }
                if (this.spinner) {
                    this.spinner.hide();
                }
                this.isInitialized = true;
            })
            .catch((error) => {
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
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
    setSessionCookie() {
        sessionStorage.setItem('Cookies', 'Accepted');
        return true;
    }
}
