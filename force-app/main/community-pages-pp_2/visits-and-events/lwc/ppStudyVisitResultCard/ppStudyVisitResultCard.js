import { LightningElement, wire, api, track } from 'lwc';
import resultsCheck from '@salesforce/label/c.Visit_Check_Result';
import results from '@salesforce/label/c.Visit_Result';
import viewAllResults from '@salesforce/label/c.Visits_View_All_Results';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import { NavigationMixin } from 'lightning/navigation';
import formFactor from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import visitResultSharingByGroupAndMode from '@salesforce/apex/StudyDetailViewController.visitResultSharingByGroupAndMode';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';

import messagingChannel from '@salesforce/messageChannel/ppVisResults__c';

export default class PpStudyVisitResultCard extends NavigationMixin(LightningElement) {
    label = {
        resultsCheck,
        viewAllResults,
        results
    };

    showVisResults = false;
    participantState;
    selectedResult;
    @track availableTabs = [];
    visitResultSMap = [];
    visitResultSharings;
    isMobile = false;
    isTablet = false;
    isDesktop = false;

    visitimage1 = pp_icons + '/' + 'VisitPageResultImage.png';
    resultsIllustration = pp_icons + '/' + 'results_Illustration.svg';

    subscription = null;
    @api patientVisitId;
    @api ctpSharingTiming;
    @api isPastVisit = false;
    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        if (formFactor === 'Small') {
            this.isMobile = true;
            this.isTablet = false;
            this.isDesktop = false;
        } else if (formFactor === 'Medium') {
            this.isTablet = true;
            this.isMobile = false;
            this.isDesktop = false;
        } else if (formFactor === 'Large') {
            this.isDesktop = true;
            this.isTablet = false;
            this.isMobile = false;
        }
        this.initializeData();
    }
    initializeData() {
        if (!communityService.isDummy()) {
            if (this.isDesktop) {
                console.log('rk::ctpSharingTiming', this.ctpSharingTiming);
                this.showVisResults = communityService.getVisResultsAvailable();
            } else {
                this.handleSubscribe();
            }
            this.participantState = communityService.getCurrentCommunityMode().participantState;
            if (this.participantState !== 'ALUMNI') {
                this.fetchVisibleResultTab();
            }
        }
    }

    fetchVisibleResultTab() {
        visitResultSharingByGroupAndMode({})
            .then((result) => {
                this.visitResultSharings = result;
                let options = [];
                for (var key in this.visitResultSharings) {
                    options.push({ label: key, value: key });
                }
                if (options) {
                    this.availableTabs = options;
                    this.selectedResult = this.availableTabs[0].value;
                }
            })
            .catch((error) => {
                console.log('error', error);
            });
    }
    handleChange(event) {
        this.selectedResult = event.detail.value;
    }
    get isMobileOrTablet() {
        return this.isDesktop ? false : true;
    }

    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(
            this.messageContext,
            messagingChannel,
            (message) => this.handleMessage(message),
            { scope: APPLICATION_SCOPE }
        );
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleMessage(message) {
        if (message) {
            this.showVisResults = message.isVisResultsAvailable;
        }
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    navigateToMyResults() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'results'
            }
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
