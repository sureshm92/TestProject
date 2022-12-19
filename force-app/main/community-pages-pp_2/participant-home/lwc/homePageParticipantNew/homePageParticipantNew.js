import { LightningElement, api, track } from 'lwc';
import getParticipantData from '@salesforce/apex/HomePageParticipantRemote.getInitDataAndCount';
import DEVICE from '@salesforce/client/formFactor';
// importing Custom Label
import PPWELCOME from '@salesforce/label/c.PP_Welcome';
import VISITS from '@salesforce/label/c.PG_SW_Tab_Visits';
import EVENTS from '@salesforce/label/c.PG_SW_Tab_Events';

export default class HomePageParticipantNew extends LightningElement {
    label = {
        PPWELCOME,
        VISITS,
        EVENTS
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
    updatesSection = false;
    @track showVisitCardMobile = false;
    updateSize;
    desktop = true;
    isDelegateSelfview = false;
    @track taskList = false;

    get showProgramOverview() {
        return this.clinicalrecord || this.isDelegateSelfview ? true : false;
    }

    connectedCallback() {
        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner ? this.spinner.show() : '';
        this.initializeData();
    }

    initializeData() {
        getParticipantData()
            .then((result) => {
                this.isInitialized = true;
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
                            this.clinicalrecord =
                                this.participantState.pe.Clinical_Trial_Profile__r;
                            // Check if Program toggle is or study workspcae on ctp
                            this.isProgram = this.clinicalrecord.Is_Program__c;

                            this.showVisitCard =
                                this.clinicalrecord.Patient_Portal_Enabled__c && this.clinicalrecord.Visits_are_Available__c &&
                                res.pvCount != null &&
                                res.pvCount != undefined &&
                                res.pvCount > 0;
                        }
                    }
                    if (this.desktop != true) {
                        this.updatesSection = true;
                    }
                    //For Delegate Self view
                    this.isDelegateSelfview =
                        this.participantState.value == 'ALUMNI' ||
                        (this.participantState.hasPatientDelegates &&
                            !this.participantState.isDelegate);
                }
                this.spinner.hide();
            })
            .catch((error) => {
                this.showErrorToast('Error occured', error.message, 'error');
                this.spinner.hide();
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
        }
        this.taskList = true;
    }

    showVisitCardOnMobile() {
        if (this.desktop != true) {
            this.showVisitCardMobile = true;
            this.updatesSection = false;
        }
        this.taskList = false;
    }

    showUpdatesOnMobile() {
        if (this.desktop != true) {
            this.updatesSection = true;
        }
        this.taskList = false;
        this.showVisitCardMobile = false;
    }

    updateCounter(event) {
        this.counter = event.detail.counter;
        this.displayCounter = event.detail.displayCounter;
    }
}
