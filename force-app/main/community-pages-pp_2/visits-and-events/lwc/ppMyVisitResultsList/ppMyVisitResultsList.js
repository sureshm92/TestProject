import { LightningElement, track, api } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import mobileTemplate from './ppMyVisitResultsListMobile.html';
import tabletTemplate from './ppMyVisitResultsListTablet.html';
import desktopTemplate from './ppMyVisitResultsList.html';
import PP_ICONS from '@salesforce/resourceUrl/pp_community_icons';
import getPatientVisitsWithResults from '@salesforce/apex/ModifiedVisitResultsRemote.getInitDataForVisitResultsModified';
import NO_RESULTS_MESSAGE from '@salesforce/label/c.PG_VP_L_No_Items_display';
import UNSCHEDULED_VISIT from '@salesforce/label/c.StudyVisit_Unscheduled_Visit';
import NOT_AVAILABLE from '@salesforce/label/c.Study_Visit_No_Date_Or_Time_Entered';

export default class PpMyVisitResultsList extends LightningElement {
    @track completedVisitsWithResults;
    showSpinner = true;
    showResultSpinner;
    @api currentVisitId;
    urlString;
    patientVisitWrapper;
    @track currentVisit;
    @track showResults;
    @track onLoad;
    @track isAndroidTab=false;

    NO_RESULTS_AVAILABLE = PP_ICONS + '/' + 'results_Illustration.svg';
    userTimezone = TIME_ZONE;

    labels = {
        NO_RESULTS_MESSAGE,
        NOT_AVAILABLE,
        UNSCHEDULED_VISIT
    };

    connectedCallback() {
        this.isAndroidTab=communityService.isAndroidTablet();
        this.urlString = window.location.href;
        if (window.location.href.includes('pvId')) {
            this.currentVisitId = communityService.getUrlParameter('pvId');
            if (!this.isDesktop) {
                const custEvent = new CustomEvent('visitclick', {
                    detail: false
                });
                this.dispatchEvent(custEvent);
            }
        }
        this.onLoad = true;
        this.initializeData();
    }

    get isDesktop() {
        return FORM_FACTOR == 'Large';
    }

    get isMobile() {
        return FORM_FACTOR == 'Small' && !this.isAndroidTab;
    }

    get isTablet() {   
        return this.isAndroidTab || FORM_FACTOR == 'Medium';
    }

    get isInitiliazed() {
        return (
            !this.showSpinner &&
            this.completedVisitsWithResults &&
            this.completedVisitsWithResults.length > 0
        );
    }

    get visitResultContainerClass() {
        return this.isInitiliazed || this.showSpinner
            ? 'slds-col slds-small-size_1-of-1 slds-medium-size_1-of-1 slds-large-size_8-of-12 result-container slds-border_left'
            : 'slds-col slds-small-size_1-of-1 slds-medium-size_1-of-1 slds-large-size_8-of-12 result-container slds-border_left slds-m-top_medium';
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
                if (this.completedVisitsWithResults && !this.currentVisitId && this.isDesktop) {
                    this.currentVisitId = this.completedVisitsWithResults[0]?.Id;
                    this.currentVisit = this.completedVisitsWithResults[0];
                } else if (this.currentVisitId) {
                    for (let i = 0; i < this.completedVisitsWithResults.length; i++) {
                        if (this.completedVisitsWithResults[i].Id == this.currentVisitId) {
                            this.currentVisit = this.completedVisitsWithResults[i];
                            break;
                        }
                    }
                }

                if (this.onLoad) this.showSpinner = false;
                if (this.showResultSpinner) {
                    this.showResultSpinner = false;
                }
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
        this.showResultSpinner = true;
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
    }

    handleBackToVisitList() {
        if (this.isMobile || this.isTablet) {
            window.history.replaceState(null, null, '?vrlistHome');
            this.urlString = window.location.href;
            this.currentVisit = '';
            this.currentVisitId = '';
            if (window.location.href.includes('pvId')) {
                const custEvent = new CustomEvent('visitclick', {
                    detail: false
                });
                this.dispatchEvent(custEvent);
            } else {
                const custEvent = new CustomEvent('visitclick', {
                    detail: true
                });
                this.dispatchEvent(custEvent);
            }
        }
    }
}