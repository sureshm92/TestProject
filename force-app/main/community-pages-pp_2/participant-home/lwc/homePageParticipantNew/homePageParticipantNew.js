import { LightningElement, api, track } from 'lwc';
import getParticipantData from '@salesforce/apex/HomePageParticipantRemote.getInitDataAndCount';
import showProgress from '@salesforce/apex/PP_ProgressBarUtility.showProgress';
import DEVICE from '@salesforce/client/formFactor';
import getisRTL from '@salesforce/apex/PreferenceManagementController.getIsRTL';
// importing Custom Label
import PPWELCOME from '@salesforce/label/c.PP_Welcome';
import VISITS from '@salesforce/label/c.PG_SW_Tab_Visits';
import EVENTS from '@salesforce/label/c.PG_SW_Tab_Events';
import TELEVISITS from '@salesforce/label/c.Televisits';
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
import CheckIfTelevisitToggleOnForDelegate from '@salesforce/apex/PPTelevisitUpcomingTileController.CheckIfTelevisitToggleOnForDelegate';
import CheckIfTelevisitToggleOnForAlumni from '@salesforce/apex/PPTelevisitUpcomingTileController.CheckIfTelevisitToggleOnForAlumni';

export default class HomePageParticipantNew extends LightningElement {
    label = {
        PPWELCOME,
        VISITS,
        EVENTS,
        TELEVISITS,
        Upcoming,
        Updates,
        Tasks,
        Progress,
        Upcoming_Caps,
        MY_PROGRESS_Caps
    };
    counter;
    enableCards = [];
    displayCounter = false;
    participantState;
    clinicalrecord;
    error;
    userName = 'Sarah';
    @api currentMode;
    spinner;
    @api isRTL;
    isInitialized = false;
    isProgram = false;
    showVisitCard = false;
    showProgress = false;
    showTelevisitCard = false;
    @track showTelevisitCardDelegate = false;
    @track showTelevisitCardAlumni = false;
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
    showProgressMobile = true;
    get showProgramOverview() {
        return this.clinicalrecord || this.isDelegateSelfview ? true : false;
    }
    get cardPadding() {        
            return 'slds-col slds-m-horizontal_xxx-small';        
    }

    get upcomingPaddingStyle() {
        return this.isRTL 
            ? 'around-small-custom' 
            : 'around-small-custom around-right-zero';
    }

    get visitButtonStyle() {
        if(this.isTelevisits)
        {
            return this.isRTL 
            ? 'slds-button slds-button_neutral visit-button inactive-button-background border-radius-rtl' 
            : 'slds-button slds-button_neutral visit-button inactive-button-background border-radius';
        } else{
            return this.isRTL 
            ? 'slds-button slds-button_neutral visit-button active-button-background border-radius-rtl' 
            : 'slds-button slds-button_neutral visit-button active-button-background border-radius';
        }
    }

    get televisitButtonStyle() {
        if(this.isTelevisits)
        {
            return this.isRTL 
            ? 'slds-button slds-button_brand televisit-button active-button-background border-radius' 
            : 'slds-button slds-button_brand televisit-button active-button-background border-radius-rtl';
        } else{
            return this.isRTL 
            ? 'slds-button slds-button_brand televisit-button inactive-button-background border-radius' 
            : 'slds-button slds-button_brand televisit-button inactive-button-background border-radius-rtl';
        }
    }

    get studyProgramOverviewBoxStyle() {
        return this.isRTL 
            ? 'slds-p-vertical_small slds-m-left_large mr-auto' 
            : 'slds-p-vertical_small slds-m-left_large';
    }
    connectedCallback() {
        DEVICE == 'Large' ? (this.desktop = true) : (this.desktop = false);
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner ? this.spinner.show() : '';
        this.initialLoadTime = new Date().toISOString().slice(0, -5).replace('T', ' ');
        this.getVisitsPreviewAndCount();
        //this.getVisits();
        this.getUpdatesCount();
        this.initializeData();
            getisRTL()
                .then((data) => {
                    this.isRTL = data;
                    console.log('rtl--->'+this.isRTL);
                })
                .catch(function (error) {
                    console.error('Error RTL: ' + JSON.stringify(error));
                });
    }
    get tabletUpcomingCard() {
        if (DEVICE == 'Medium') {
            return 'upcoming-card slds-m-around_small tablet-margin slds-size_4-of-6';
        } else {
            return 'upcoming-card slds-m-around_small';
        }
    }
    get tabletProgressTab() {
        if (DEVICE == 'Medium') {
            return 'progressTab tablet-margin slds-size_4-of-6';
        } else {
            return 'progressTab';
        }
    }

    getVisitsPreviewAndCount() {
        setTimeout(() => {
            getVisitsPreviewAndCount({})
                .then((result) => {
                    let visitDetails = result.visitPreviewList;
                    if (visitDetails != null && visitDetails.length != 0 && visitDetails != '') {
                        this.isUpcomingVisitDetails = true;
                    } else {
                        this.isUpcomingVisitDetails = false;
                    }
                    this.getVisits();
                })
                .catch((error) => {
                    this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
                });
        }, 15);
    }

    getVisits() {
        setTimeout(() => {
            getVisits({ communityMode: 'IQVIA Patient Portal', userMode: 'Participant' })
                .then((result) => {
                    var televisitInformation = JSON.parse(result);
                    if (televisitInformation.length > 0) {
                        this.isUpcomingTelevisitVisitDetails = true;
                    } else {
                        this.isUpcomingTelevisitVisitDetails = false;
                    }
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
        }, 22);
    }

    getUpdatesCount() {
        setTimeout(() => {
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
                    this.showErrorToast(
                        'Error occured',
                        error.message,
                        'error',
                        '5000',
                        'dismissable'
                    );
                    if (this.spinner) {
                        this.spinner.hide();
                    }
                });
        }, 8);
    }

    initializeData() {
        setTimeout(() => {
            getParticipantData()
                .then((result) => {
                    this.spinner ? this.spinner.hide() : '';
                    this.showSpinner = false;
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
                                this.clinicalrecord = this.participantState.pe.Clinical_Trial_Profile__r;
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

                            this.showSpinner = true;
                            this.showUpcomingSection = false;

                            if (this.participantState.hasPatientDelegates)
                                this.CheckIfTelevisitToggleOnForDelegate();
                            else this.CheckIfTelevisitToggleOnForAlumni();
                        }

                        if (this.desktop != true) {
                            this.updatesSection = true;
                            // this.showVisitCardMobile = true;
                            this.enableCards.push('updates');
                            this.enableCards.push('task');
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
                        if (this.isDelegateSelfview) {
                            this.showBiggerUpdatesSection();
                        }
                    }
                    this.isInitialized = true;
                    if (this.showUpcomingSection) {
                        this.enableCards.push('upcoming');
                    }
                    if (!this.desktop && this.participantState.pe) {
                        showProgress({ peId: this.participantState.pe.Id })
                            .then((result) => {
                                this.showProgressMobile = result;
                                if (this.showProgressMobile) {
                                    this.enableCards.push('my-progress');
                                    this.cardNavigation();
                                }
                            })
                            .catch((error) => {
                                this.showErrorToast(
                                    'Error occured',
                                    error.message,
                                    'error',
                                    '5000',
                                    'dismissable'
                                );
                            });
                    }
                    this.cardNavigation();
                })
                .catch((error) => {
                    this.showErrorToast(
                        'Error occured',
                        error.message,
                        'error',
                        '5000',
                        'dismissable'
                    );
                    this.spinner ? this.spinner.hide() : '';
                });
        }, 40);
    }
    cardNavigation() {
        if (!this.desktop) {
            const queryString = window.location.href;
            if (queryString.includes('upcoming') && this.enableCards.includes('upcoming')) {
                this.showVisitCardOnMobile();
            }

            if (queryString.includes('my-progress') && this.enableCards.includes('my-progress')) {
                this.showProgressMob();
            }
            if (queryString.includes('task') && this.enableCards.includes('task')) {
                this.showTaskList();
            }
            if (queryString.includes('updates') && this.enableCards.includes('updates')) {
                this.showUpdatesOnMobile();
            }
        }
    }
    CheckIfTelevisitToggleOnForDelegate() {
        this.showSpinner = true;
        this.showUpcomingSection = false;
        CheckIfTelevisitToggleOnForDelegate()
            .then((result) => {
                this.showSpinner = false;
                this.showTelevisitCardDelegate = result;
                if (this.isDelegateSelfview && !this.showTelevisitCardDelegate) {
                    this.showUpcomingSection = false;
                    if (this.desktop != true) {
                        this.showVisitCardMobile = false;
                    }
                } else {
                    this.showUpcomingSection = true;
                    this.enableCards.push('upcoming');
                    this.cardNavigation();
                }
            })
            .catch((error) => {
                console.log('Error :', error);
            });
    }

    CheckIfTelevisitToggleOnForAlumni() {
        this.showSpinner = true;
        this.showUpcomingSection = false;
        CheckIfTelevisitToggleOnForAlumni()
            .then((result) => {
                this.showSpinner = false;
                this.showTelevisitCardAlumni = result;
                if (this.isDelegateSelfview && !this.showTelevisitCardAlumni) {
                    this.showUpcomingSection = false;
                    if (this.desktop != true) {
                        this.showVisitCardMobile = false;
                    }
                } else {
                    this.showUpcomingSection = true;
                    this.enableCards.push('upcoming');
                    this.cardNavigation();
                }
            })
            .catch((error) => {
                console.log('Error :', error);
            });
    }

    renderedCallback() {
        if (this.isInitialized == true) {
            this.spinner = this.template.querySelector('c-web-spinner');
        }
    }

    showTaskList() {
        window.history.replaceState(null, null, '?task');
        const queryString = window.location.href;
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
        window.history.replaceState(null, null, '?upcoming');
    }

    showUpdatesOnMobile() {
        if (this.desktop != true) {
            this.updatesSection = true;
        }
        this.taskList = false;
        this.showVisitCardMobile = false;
        this.showProgress = false;
        window.history.replaceState(null, null, '?updates');
    }

    showProgressMob() {
        if (this.desktop != true) {
            this.showVisitCardMobile = false;
            this.updatesSection = false;
            this.taskList = false;
        }
        this.showProgress = true;
        window.history.replaceState(null, null, '?my-progress');
    }
    get progressIcon() {
        if (this.showProgress) {
            return 'icon-progress progressIconPosition';
        }
        return 'icon-progress';
    }
    get progressIconSize() {
        if (this.showProgress) {
            return 'xlarge';
        }
        return 'progress';
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