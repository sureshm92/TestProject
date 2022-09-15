//Created by Chetna Chauhan Sep 9,2022
import { LightningElement, api, track } from 'lwc';
import getVisitsPreview from '@salesforce/apex/ParticipantVisitsRemote.getVisitsPreview';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import What_to_Expect from '@salesforce/label/c.Upcoming_Visit_Expect';
import UPCOMING from '@salesforce/label/c.Televisit_Upcoming';
import MORE from '@salesforce/label/c.PIR_more';
import NO_DATE from '@salesforce/label/c.PP_Date_Unavailable';
import NO_TIME from '@salesforce/label/c.PP_Time_Unavailable';
import NO_EXPECT from '@salesforce/label/c.Visit_No_Expect';
import View_Visit_Details from '@salesforce/label/c.View_Visit_Details';
import TIME_ZONE from '@salesforce/i18n/timeZone';

export default class HomePageVisitsCard extends LightningElement {
    planDateTime;
    siteLocation;
    siteTitle;
    sitePhone;
    visitName;
    iconDetails;
    moreIconsCount;
    @track upcomingVisit;
    userTimeZone = TIME_ZONE;
    isInitialized = false;
    labels = {
        What_to_Expect,
        UPCOMING,
        MORE,
        View_Visit_Details,
        NO_DATE,
        NO_TIME,
        NO_EXPECT
    };

    connectedCallback() {
        this.initializeData();
        this.isInitialized = true;
    }

    initializeData() {
        getVisitsPreview({})
            .then((result) => {
                let visitDetails = result;
                if (visitDetails != null) {
                    this.upcomingVisit = visitDetails[0];
                    this.planDateTime = this.upcomingVisit.visitDate
                        ? this.upcomingVisit.visitDate
                        : false;
                    this.visitName = this.upcomingVisit.visit.Name;
                    this.siteTitle =
                        this.upcomingVisit.visit.Participant_Enrollment__r?.Study_Site__r?.Site__r?.Name;
                    this.sitePhone =
                        this.upcomingVisit.visit.Participant_Enrollment__r?.Study_Site__r?.Site__r?.Phone;
                    let location =
                        this.upcomingVisit.visit.Participant_Enrollment__r?.Study_Site__r.Site__r
                            ?.BillingAddress;
                    this.siteLocation =
                        (location.street ? location.street : '') +
                        ', ' +
                        (location.city ? location.city : '') +
                        ', ' +
                        (location.stateCode ? location.stateCode : '') +
                        ' ' +
                        (location.postalCode ? location.postalCode : '');
                    let icons = this.upcomingVisit.iconDetails;
                    this.moreIconsCount = icons.length > 4 ? icons.length - 4 : false;
                    this.iconDetails =icons.length > 0 ? icons?.slice(0, 4) :false;
                }
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
}
