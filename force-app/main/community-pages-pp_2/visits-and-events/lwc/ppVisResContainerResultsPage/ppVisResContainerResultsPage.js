import { LightningElement, api, track } from 'lwc';
import Visit_Results_Tab_Vit_Disclaimer from '@salesforce/label/c.Visit_Results_Tab_Vit_Disclaimer';
import Visit_Results_Tab_Lab_Disclaimer from '@salesforce/label/c.Visit_Results_Tab_Lab_Disclaimer';
import Visit_Results_Tab_Bio_Disclaimer from '@salesforce/label/c.Visit_Results_Tab_Bio_Disclaimer';
import PP_Download_Results_Data from '@salesforce/label/c.PP_Download_Results_Data';
import modifiedSwitchToggleRemote from '@salesforce/apex/ModifiedVisitResultsRemote.modifiedSwitchToggleRemote';
import Show_Vitals from '@salesforce/label/c.Show_Vitals';
import Show_Labs from '@salesforce/label/c.Show_Labs';
import Show_Biomarkers from '@salesforce/label/c.Show_Biomarkers';
import Vitals_Toggle_Off from '@salesforce/label/c.Vitals_Toggle_Off';
import Labs_Toggle_Off from '@salesforce/label/c.Labs_Toggle_Off';
import Biomarkers_Toggle_Off from '@salesforce/label/c.Biomarkers_Toggle_Off';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import mobileTemplate from './ppVisResContainerResultsPageMobile.html';
import tabletTemplate from './ppVisResContainerResultsPageTablet.html';
import desktopTemplate from './ppVisResContainerResultsPage.html';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class PpMyResultsContainer extends LightningElement {
    label = {
        PP_Download_Results_Data,
        Visit_Results_Tab_Vit_Disclaimer,
        Visit_Results_Tab_Lab_Disclaimer,
        Visit_Results_Tab_Bio_Disclaimer,
        Show_Vitals,
        Show_Labs,
        Show_Biomarkers,
        Vitals_Toggle_Off,
        Labs_Toggle_Off,
        Biomarkers_Toggle_Off
    };
    group2;
    group3;
    isButton1Group2 = false;
    isButton2Group2 = false;
    isButton1Group3 = false;
    isButton2Group3 = false;
    isButton3Group3 = false;
    Button1Label;
    Button2Label;
    Button3Label;
    showSpinner = true;
    @track patientVisitWrapper;
    @track currentVisit;
    visitResultTypeWithSubTypes;
    isVitalsToggleOn = false;
    isLabsToggleOn = false;
    isBiomarkersToggleOn = false;
    visResultTypeTabs;
    selectedResultType;
    userTimezone = TIME_ZONE;
    participantMailingCC;
    ctpId;
    resultsWrapper;
    initialised = false;
    @track showSpinnerResults;

    toggleOffHeart = pp_icons + '/' + 'heart_Icon.svg';

    @api
    get selectedVisit() {
        return this.currentVisit;
    }
    set selectedVisit(value) {
        this.currentVisit = value;
        this.initializeData();
    }

    @api
    get visitsDetails() {
        return this.patientVisitWrapper;
    }
    set visitsDetails(value) {
        this.patientVisitWrapper = value;
    }
    connectedCallback() {
        this.showSpinner = true;
        this.initializeData();
    }

    get showTabs() {
        return this.visResultTypeTabs.length > 1 ? true : false;
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
    get isDesktop() {
        return FORM_FACTOR == 'Large';
    }

    get isMobile() {
        return FORM_FACTOR == 'Small';
    }

    get isTablet() {
        return FORM_FACTOR == 'Medium';
    }
    checkButtonClass() {
        if (this.visResultTypeTabs.length == 1) {
            this.selectedResultType = this.visResultTypeTabs[0];
        } else if (this.visResultTypeTabs.length == 2) {
            this.group2 = true;
            if (this.visResultTypeTabs.includes('Vitals')) {
                this.Button1Label = 'Vitals';
                this.Button2Label = this.visResultTypeTabs.includes('Labs') ? 'Labs' : 'Biomarkers';
                this.selectedResultType = 'Vitals';
            } else {
                this.Button1Label = 'Labs';
                this.Button2Label = 'Biomarkers';
                this.selectedResultType = 'Labs';
            }
            this.isButton1Group2 = true;
            this.isButton2Group2 = false;
        } else {
            this.group3 = true;
            this.isButton1Group3 = true;
            this.isButton2Group3 = false;
            this.isButton3Group3 = false;
            this.Button1Label = 'Vitals';
            this.Button2Label = 'Labs';
            this.Button3Label = 'Biomarkers';
            this.selectedResultType = 'Vitals';
        }
    }
    get toggleLabel() {
        if (this.selectedResultType === 'Vitals') {
            return this.label.Show_Vitals;
        } else if (this.selectedResultType === 'Labs') {
            return this.label.Show_Labs;
        } else if (this.selectedResultType === 'Biomarkers') {
            return this.label.Show_Biomarkers;
        }
    }
    get toggleValue() {
        if (this.selectedResultType === 'Vitals') {
            return this.isVitalsToggleOn;
        } else if (this.selectedResultType === 'Labs') {
            return this.isLabsToggleOn;
        } else if (this.selectedResultType === 'Biomarkers') {
            return this.isBiomarkersToggleOn;
        }
    }
    get isVitalsSelected() {
        return this.selectedResultType === 'Vitals';
    }

    get isLabsSelected() {
        return this.selectedResultType === 'Labs';
    }

    get isBiomarkersSelected() {
        return this.selectedResultType === 'Biomarkers';
    }

    get isVitalsSelected() {
        return this.selectedResultType === 'Vitals';
    }
    handleResultTypeSelection(event) {
        this.showSpinnerResults = true;
        this.selectedResultType = event.target.value;
        if (event.target.name == 'Button1Group2') {
            this.isButton1Group2 = true;
            this.isButton2Group2 = false;
            this.isButton1Group3 = false;
            this.isButton2Group3 = false;
            this.isButton3Group3 = false;
        } else if (event.target.name == 'Button2Group2') {
            this.isButton1Group2 = false;
            this.isButton2Group2 = true;
            this.isButton1Group3 = false;
            this.isButton2Group3 = false;
            this.isButton3Group3 = false;
        } else if (event.target.name == 'Button1Group3') {
            this.isButton1Group2 = false;
            this.isButton2Group2 = false;
            this.isButton1Group3 = true;
            this.isButton2Group3 = false;
            this.isButton3Group3 = false;
        } else if (event.target.name == 'Button2Group3') {
            this.isButton1Group2 = false;
            this.isButton2Group2 = false;
            this.isButton1Group3 = false;
            this.isButton2Group3 = true;
            this.isButton3Group3 = false;
        } else if (event.target.name == 'Button3Group3') {
            this.isButton1Group2 = false;
            this.isButton2Group2 = false;
            this.isButton1Group3 = false;
            this.isButton2Group3 = false;
            this.isButton3Group3 = true;
        }
        this.showSpinnerResults = false;
    }
    get button1Group2Class() {
        return this.isButton1Group2
            ? 'slds-button group-button1 active-btn'
            : 'slds-button group-button1 inactive-btn';
    }
    get button2Group2Class() {
        return this.isButton2Group2
            ? 'slds-button group-button3 active-btn'
            : 'slds-button group-button3 inactive-btn';
    }
    get button1Group3Class() {
        return this.isButton1Group3
            ? 'slds-button group-button1 active-btn'
            : 'slds-button group-button1 inactive-btn';
    }
    get button2Group3Class() {
        return this.isButton2Group3
            ? 'slds-button group-button2 active-btn'
            : 'slds-button group-button2 inactive-btn';
    }
    get button3Group3Class() {
        return this.isButton3Group3
            ? 'slds-button group-button3 active-btn'
            : 'slds-button group-button3 inactive-btn';
    }

    handleVRToggle(event) {
        this.showSpinner = true;
        modifiedSwitchToggleRemote({
            visitResultsMode: this.selectedResultType,
            isToggleOn: event.target.checked
        })
            .then((result) => {
                if (this.selectedResultType === 'Vitals') {
                    this.isVitalsToggleOn = !this.isVitalsToggleOn;
                } else if (this.selectedResultType === 'Labs') {
                    this.isLabsToggleOn = !this.isLabsToggleOn;
                } else if (this.selectedResultType === 'Biomarkers') {
                    this.isBiomarkersToggleOn = !this.isBiomarkersToggleOn;
                }
                this.showSpinner = false;
                this.initialised = true;
            })
            .catch((error) => {
                console.error('Error occured here', error.message, 'error');
                this.showSpinner = false;
                this.initialised = true;
            });
    }
    initializeData() {
        if (!communityService.isDummy()) {
            if (this.patientVisitWrapper) {
                let result = this.patientVisitWrapper;
                this.validVisitResults = result.isVisitResultsAvailable;
                if (this.validVisitResults) {
                    if (
                        result.visitResultsGroupNamesCTP &&
                        result.visitResultsGroupNamesCTP.length
                    ) {
                        this.visResultTypeTabs = result.visitResultsGroupNamesCTP;
                        this.checkButtonClass();
                    }
                    this.isVitalsToggleOn = result.toggleStateForVitals
                        ? result.toggleStateForVitals
                        : false;
                    this.isLabsToggleOn = result.toggleStateForLabs
                        ? result.toggleStateForLabs
                        : false;
                    this.isBiomarkersToggleOn = result.toggleStateForBiomarkers
                        ? result.toggleStateForBiomarkers
                        : false;
                    this.showSpinner = false;
                    this.initialised = true;
                    this.visitResultTypeWithSubTypes = result.visitResultWithSubTypesCTP;
                } else {
                    this.showSpinner = false;
                    this.initialised = true;
                }
            }
        }
    }
    get resultTypeDisclaimer() {
        if (this.selectedResultType === 'Vitals') {
            return this.label.Visit_Results_Tab_Vit_Disclaimer;
        } else if (this.selectedResultType === 'Labs') {
            return this.label.Visit_Results_Tab_Lab_Disclaimer;
        } else if (this.selectedResultType === 'Biomarkers') {
            return this.label.Visit_Results_Tab_Bio_Disclaimer;
        }
    }

    handleNavigation() {
        const custEvent = new CustomEvent('navigateback', {
            detail: true
        });
        this.dispatchEvent(custEvent);
    }
}
