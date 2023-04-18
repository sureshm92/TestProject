import { LightningElement, api, track } from 'lwc';
import getParticipantData from '@salesforce/apex/HomePageParticipantRemote.getInitDataAndCount';
import DEVICE from '@salesforce/client/formFactor';
// importing Custom Label
import PPWELCOME from '@salesforce/label/c.PP_Welcome';
import VISITS from '@salesforce/label/c.PG_SW_Tab_Visits';
import EVENTS from '@salesforce/label/c.PG_SW_Tab_Events';
import Upcoming from '@salesforce/label/c.Visits_Upcoming';
import Upcoming_Caps from '@salesforce/label/c.PP_Upcoming_Caps';
import Updates from '@salesforce/label/c.Updates_Label';
import Tasks from '@salesforce/label/c.PG_SW_Tab_Tasks';
import Progress from '@salesforce/label/c.PP_Progress';
import MY_PROGRESS_Caps from '@salesforce/label/c.PP_MY_PROGRESS_Caps';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getVisitsPreviewAndCount from '@salesforce/apex/ParticipantVisitsRemote.getVisitsPreviewAndCount';
import getVisits from '@salesforce/apex/PPTelevisitUpcomingTileController.getVisits';
import getSendResultCount from '@salesforce/apex/PPUpdatesController.getSendResultCount';

export default class HomePageParticipantNew extends LightningElement {
    label = {
        PPWELCOME,
        VISITS,
        EVENTS,
        Upcoming,
        Updates,
        Tasks,
        Progress,
        Upcoming_Caps,
        MY_PROGRESS_Caps
    };
    counter;
    displayCounter = false;
    participantState;
    clinicalrecord;
    error;
    userName = 'Sarah';
    @api currentMode;
    spinner;
    isInitialized = false;
    isProgram = false;
    showVisitCard = false;
    showProgress = false;
    showTelevisitCard = false;
    updatesSection = false;
    @track showVisitCardMobile = false;
    updateSize;
    desktop = true;
    isDelegateSelfview = false;
    @track taskList = false;
    showSpinner = true;
    homeIllustration = pp_icons + '/' + 'HomePage_Illustration.svg';
    homeIllustrationMble = pp_icons + '/' + 'HomePage_Illustration_Mble.svg';
    isTelevisits = false;
    showUpcomingSection = true;
    isUpcomingVisitDetails;
    isUpcomingTelevisitVisitDetails;
    marginbottom = '';
    studysite;
    counterLabel;
    initialLoadTime;
    updateCardLayoutSize = 4;
    updateCardLayoutClass = 'around-small-custom';
    updateCardLayoutSmall = true;
    progressBarLayoutClass = 'around-small-custom around-right-zero';

    get showProgramOverview() {
        return this.clinicalrecord || this.isDelegateSelfview ? true : false;
    }

    connectedCallback() {
        DEVICE == 'Large' ? (this.desktop = true) : (this.desktop = false);
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner ? this.spinner.show() : '';
        this.initialLoadTime = new Date().toISOString().slice(0, -5).replace('T', ' ');
        this.getVisitsPreviewAndCount();
        this.getVisits();
        this.getUpdatesCount();
        this.initializeData();
    }

    getVisitsPreviewAndCount() {
        getVisitsPreviewAndCount({})
            .then((result) => {
                let visitDetails = result.visitPreviewList;
                if (visitDetails != null && visitDetails.length != 0 && visitDetails != '') {
                    this.isUpcomingVisitDetails = true;
                } else {
                    this.isUpcomingVisitDetails = false;
                }
                console.log('Visit :', this.isUpcomingVisitDetails);
            })
            .catch((error) => {
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
            });
    }

    getVisits() {
        getVisits({ communityMode: 'IQVIA Patient Portal', userMode: 'Participant' })
            .then((result) => {
                console.log('result', result);
                var televisitInformation = JSON.parse(result);
                if (televisitInformation.length > 0) {
                    this.isUpcomingTelevisitVisitDetails = true;
                } else {
                    this.isUpcomingTelevisitVisitDetails = false;
                }
                console.log('Televisit :', this.isUpcomingTelevisitVisitDetails);
                if (!this.isUpcomingVisitDetails && this.isUpcomingTelevisitVisitDetails) {
                    this.isTelevisits = true;
                    this.marginbottom = 'marginbottom';
                } else {
                    //this.isTelevisits = false;
                }
            })
            .catch((error) => {
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
            });
    }

    getUpdatesCount() {
        getSendResultCount({ initialLoadTime: this.initialLoadTime })
            .then((returnValue) => {
                this.counter = returnValue;
                if (this.counter < 100 && this.counter > 0) {
                    this.displayCounter = true;
                    this.counterLabel = this.counter;
                } else if (this.counter >= 100) {
                    this.displayCounter = true;
                    this.counterLabel = '99+';
                } else if (this.counter <= 0) {
                    this.displayCounter = false;
                }
            })
            .catch((error) => {
                console.log('error message : ' + error?.message);
                this.showErrorToast('Error occured', error.message, 'error', '5000', 'dismissable');
                this.spinner.hide();
            });
    }

    initializeData() {
        getParticipantData()
            .then((result) => {
                if (result) {
                    let res = JSON.parse(result);
                    this.participantState = res.pState;
                    if (this.participantState) {
                        let username = this.currentMode.groupLabel;
                        let firstName = username.substring(0, username.indexOf(' '));

                        this.userName = this.label.PPWELCOME + ', ' + firstName + '!';
                    }
                    if (this.participantState.pe) {
                        if (this.participantState.pe.Clinical_Trial_Profile__r) {
                            this.studysite = this.participantState.pe.Study_Site__r;
                            this.clinicalrecord =
                                this.participantState.pe.Clinical_Trial_Profile__r;
                            // Check if Program toggle is or study workspcae on ctp
                            this.isProgram = this.clinicalrecord.Is_Program__c;

                            this.showVisitCard =
                                this.clinicalrecord.Patient_Portal_Enabled__c &&
                                this.clinicalrecord.Visits_are_Available__c &&
                                res.pvCount != null &&
                                res.pvCount != undefined &&
                                res.pvCount > 0;
                        }
                        //this.showTelevisitCard = this.clinicalrecord.Televisit_Vendor_is_Available__c;
                        if (
                            this.clinicalrecord.Televisit_Vendor_is_Available__c &&
                            res.televisitVendorAvailable
                        ) {
                            this.showTelevisitCard = true;
                        } else {
                            this.showTelevisitCard = false;
                            this.isTelevisits = false;
                            this.marginbottom = '';
                        }
                        console.log(
                            'Televisit Toggle',
                            this.clinicalrecord.Televisit_Vendor_is_Available__c
                        );
                        console.log('Televisit Vendor', res.televisitVendorAvailable);
                        if (this.showTelevisitCard && !this.showVisitCard) {
                            this.isTelevisits = true;
                            this.marginbottom = 'marginbottom';
                        }
                    } else if (
                        this.participantState.value == 'ALUMNI' ||
                        (this.participantState.hasPatientDelegates &&
                            !this.participantState.isDelegate)
                    ) {
                        this.showTelevisitCard = true;
                        this.isTelevisits = true;
                        this.marginbottom = 'marginbottom';
                    }
                    if (this.desktop != true) {
                        //this.updatesSection = true;
                        this.showVisitCardMobile = true;
                    }

                    if (!this.showTelevisitCard && !this.showVisitCard) {
                        this.showUpcomingSection = false;
                        if (this.desktop != true) {
                            this.updatesSection = true;
                            this.showVisitCardMobile = false;
                        }
                    }

                    //For Delegate Self view
                    this.isDelegateSelfview =
                        this.participantState.value == 'ALUMNI' ||
                        (this.participantState.hasPatientDelegates &&
                            !this.participantState.isDelegate &&
                            !this.participantState.pe);
                }
                this.isInitialized = true;
                this.spinner ? this.spinner.hide() : '';
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showErrorToast('Error occured', error.message, 'error', '5000', 'dismissable');
                this.spinner ? this.spinner.hide() : '';
            });
    }

    renderedCallback() {
        if (this.isInitialized == true) {
            this.spinner = this.template.querySelector('c-web-spinner');
        }
    }

    showTaskList() {
        if (this.desktop != true) {
            this.showVisitCardMobile = false;
            this.updatesSection = false;
            this.showProgress = false;
        }
        this.taskList = true;
    }

    showVisitCardOnMobile() {
        if (this.desktop != true) {
            this.showVisitCardMobile = true;
            this.updatesSection = false;
            this.showProgress = false;
        }
        this.taskList = false;
    }

    showUpdatesOnMobile() {
        if (this.desktop != true) {
            this.updatesSection = true;
        }
        this.taskList = false;
        this.showVisitCardMobile = false;
        this.showProgress = false;
    }

    showProgressMob() {
        if (this.desktop != true) {
            this.showVisitCardMobile = false;
            this.updatesSection = false;
            this.taskList = false;
        }
        this.showProgress = true;
    }
    get progressIcon() {
        if (this.showProgress) {
            return 'icon-updates taskIconPosition';
        }
        return 'icon-updates';
    }

    updateCounter(event) {
        this.counter = event.detail.counter;
        this.displayCounter = event.detail.displayCounter;
    }
    showErrorToast(titleval, messageval, variantval, durationval, modeval) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: titleval,
                message: messageval,
                variant: variantval,
                duration: durationval,
                mode: modeval
            })
        );
    }

    visitsTab() {
        this.isTelevisits = false;
        this.marginbottom = '';
    }

    televisitsTab() {
        this.isTelevisits = true;
        this.marginbottom = 'marginbottom';
    }

    showBiggerUpdatesSection() {
        this.updateCardLayoutSize = 8;
        this.updateCardLayoutClass = 'around-small-custom around-right-zero';
        this.updateCardLayoutSmall = false;
        this.progressBarLayoutClass = 'slds-hide';
    }
}
