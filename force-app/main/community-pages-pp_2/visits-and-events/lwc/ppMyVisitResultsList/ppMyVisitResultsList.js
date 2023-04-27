import { LightningElement, track, api } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import mobileTemplate from './ppMyVisitResultsListMobile.html';
import tabletTemplate from './ppMyVisitResultsListTablet.html';
import desktopTemplate from './ppMyVisitResultsList.html';
import PP_ICONS from '@salesforce/resourceUrl/pp_community_icons';
import getPatientVisitsWithResults from '@salesforce/apex/ModifiedVisitResultsRemote.getInitDataForVisitResultsModified';
import NO_RESULTS_MESSAGE from '@salesforce/label/c.PG_VP_L_No_Items_display';
import NOT_AVAILABLE from '@salesforce/label/c.Study_Visit_No_Date_Or_Time_Entered';

export default class PpMyVisitResultsList extends LightningElement {
    @track completedVisitsWithResults;
    showSpinner = true;
    @api currentVisitId;
    urlString;
    patientVisitWrapper;
    @track currentVisit;
    @track showResults;
    @track onLoad;

    NO_RESULTS_AVAILABLE = PP_ICONS + '/' + 'results_Illustration.svg';
    userTimezone = TIME_ZONE;

    labels = {
        NO_RESULTS_MESSAGE,
        NOT_AVAILABLE
    };

    connectedCallback() {
        this.urlString = window.location.href;
        if (window.location.href.includes('pvId')) {
            this.currentVisitId = communityService.getUrlParameter('pvId');
        }
        this.onLoad = true;
        this.initializeData();
    }

    get isDesktop() {
        return FORM_FACTOR == 'Large';
    }

    get isMobile() {
        return FORM_FACTOR == 'Small';
    }

    get isTablet() {
        return FORM_FACTOR == 'Medium';
    }

    get isInitiliazed() {
        return (
            !this.showSpinner &&
            this.completedVisitsWithResults &&
            this.completedVisitsWithResults.length > 0
        );
    }

    get isPatientVisitNotSelected() {
        return this.urlString.includes('vrlist&pvId') ? false : true;
    }

    render() {
        if (this.isDesktop) {
            return desktopTemplate;
        } else if (this.isMobile) {
            return mobileTemplate;
        } else {
            return tabletTemplate;
        }
    }

    renderedCallback() {
        this.handleVisitChangeCSS();
    }

    initializeData() {
        if (this.onLoad) this.showSpinner = true;
        getPatientVisitsWithResults()
            .then((patientVisitWrapper) => {
                this.patientVisitWrapper = patientVisitWrapper;
                this.completedVisitsWithResults = patientVisitWrapper.patientVisitsWithResultsList;
                if (this.completedVisitsWithResults && !this.currentVisitId) {
                    this.currentVisitId = this.completedVisitsWithResults[0]?.Id;
                    this.currentVisit = this.completedVisitsWithResults[0];
                }

                //pass currentVisitId and patientVisitWrapper to jayashree component
                if (this.onLoad) this.showSpinner = false;
                this.showResults = true;
            })
            .catch((error) => {
                console.error(error);
            });
    }

    handleVisitChangeCSS() {
        if (this.currentVisitId) {
            this.template.querySelectorAll('.active-custom-box').forEach(function (patientVisit) {
                patientVisit.classList.remove('active-custom-box');
                patientVisit.classList.add('inactive-custom-box');
            });
            let selectedVisitDiv = this.template.querySelector(
                '[data-id="' + this.currentVisitId + '"]'
            );
            if (selectedVisitDiv) {
                selectedVisitDiv.className = 'active-custom-box';
            }
        }
    }

    onVisitSelect(event) {
        this.currentVisitId = event.currentTarget.dataset.id;
        this.onLoad = false;
        this.initializeData();
        this.handleVisitChangeCSS();
        this.showResults = false;
        if (this.isMobile || this.isTablet) {
            //show user the results values if available
            window.history.replaceState(null, null, '?vrlist&pvId=' + this.currentVisitId);
            this.urlString = window.location.href;
            const custEvent = new CustomEvent('visitclick', {
                detail: false
            });
            this.dispatchEvent(custEvent);
        }

        for (let i = 0; i < this.completedVisitsWithResults.length; i++) {
            if (this.currentVisitId == this.completedVisitsWithResults[i].Id) {
                this.currentVisit = this.completedVisitsWithResults[i];
                break;
            }
        }
        this.showResults = true;
    }

    handleBackToVisitList() {
        if (this.isMobile || this.isTablet) {
            window.history.replaceState(null, null, '?vrlistHome');
            this.urlString = window.location.href;
        }
    }
}
