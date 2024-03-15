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
import PP_Visit_Result_Toggle_Helptext from '@salesforce/label/c.PP_Visit_Result_Toggle_Helptext';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import mobileTemplate from './ppVisResContainerResultsPageMobile.html';
import tabletTemplate from './ppVisResContainerResultsPageTablet.html';
import desktopTemplate from './ppVisResContainerResultsPage.html';
import FORM_FACTOR from '@salesforce/client/formFactor';
import Back from '@salesforce/label/c.BTN_Back';
import UNSCHEDULED_VISIT from '@salesforce/label/c.StudyVisit_Unscheduled_Visit';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import Visit_Results_Tab_Vitals from '@salesforce/label/c.Visit_Results_Tab_Vitals';
import Visit_Results_Tab_Labs from '@salesforce/label/c.Visit_Results_Tab_Labs';
import Visit_Results_Tab_Biomarkers from '@salesforce/label/c.Visit_Results_Tab_Biomarkers';
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
        Biomarkers_Toggle_Off,
        Back,
        PP_Visit_Result_Toggle_Helptext,
        UNSCHEDULED_VISIT,
        Visit_Results_Tab_Vitals,
        Visit_Results_Tab_Labs,
        Visit_Results_Tab_Biomarkers
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
    showToggleSpinner = false;
    showTabSpinner;
    onLoad = true;
    patientVisitNam;
    isRTL = false;
    isIpadPortrait = false;
    isIpadLandscape = false;
    toggleOffHeart = pp_icons + '/' + 'heart_Icon.svg';

    @api
    get selectedVisit() {
        return this.currentVisit;
    }
    set selectedVisit(value) {
        this.currentVisit = value;
        this.showSpinner = true;
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
        this.peId = communityService.getParticipantData().pe.Id;
        this.isRTL = rtlLanguages.includes(communityService.getLanguage()) ? true : false;
        if (!this.isDesktop) {
            this.initializeData();
        }
        this.isIpadPortraitView();
        this.isIpadLandscapeView();
        window.addEventListener('orientationchange', this.onOrientationChange);
    }
    onOrientationChange = () => {
        this.isIpadPortraitView();
        this.isIpadLandscapeView();
    };
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

    get patientVisitName() {
        let name;
        if (this.selectedVisit) {
            if (this.currentVisit.Is_Adhoc__c) name = this.label.UNSCHEDULED_VISIT;
            else name = this.currentVisit.Visit__r.Patient_Portal_Name__c;
        }
        this.patientVisitNam = name;
        return name;
    }

    get completedDate() {
        return this.selectedVisit ? this.currentVisit.Completed_Date__c : '';
    }

    get isInitialized() {
        return this.patientVisitWrapper && this.currentVisit ? true : false;
    }
    get isIpadView(){
        return this.isIpadPortrait || this.isIpadLandscape;
    }
    get visitNameHeaderClass(){
        return (this.isIpadPortrait || this.isIpadLandscape)?'slds-col slds-size_3-of-3 slds-float_left slds-p-horizontal_none':'slds-col slds-size_2-of-3 slds-float_left slds-p-horizontal_none';
    }
    checkButtonClass() {
        if (this.visResultTypeTabs.length == 1) {
            this.selectedResultType = this.visResultTypeTabs[0];
        } else if (this.visResultTypeTabs.length == 2) {
            this.group2 = true;
            if (this.visResultTypeTabs.includes(this.label.Visit_Results_Tab_Vitals)) {
                this.Button1Label = this.label.Visit_Results_Tab_Vitals;
                this.Button2Label = this.visResultTypeTabs.includes(this.label.Visit_Results_Tab_Labs) ? this.label.Visit_Results_Tab_Labs : this.label.Visit_Results_Tab_Biomarkers;
                this.selectedResultType = this.label.Visit_Results_Tab_Vitals;
            } else {
                this.Button1Label = this.label.Visit_Results_Tab_Labs;
                this.Button2Label = this.label.Visit_Results_Tab_Biomarkers;
                this.selectedResultType = this.label.Visit_Results_Tab_Labs;
            }
            this.isButton1Group2 = true;
            this.isButton2Group2 = false;
        } else {
            this.group3 = true;
            this.isButton1Group3 = true;
            this.isButton2Group3 = false;
            this.isButton3Group3 = false;
            this.Button1Label = this.label.Visit_Results_Tab_Vitals;
            this.Button2Label = this.label.Visit_Results_Tab_Labs;
            this.Button3Label = this.label.Visit_Results_Tab_Biomarkers;
            this.selectedResultType = this.label.Visit_Results_Tab_Vitals;
        }
    }
    get toggleLabel() {
        if (this.selectedResultType === this.label.Visit_Results_Tab_Vitals) {
            return this.label.Show_Vitals;
        } else if (this.selectedResultType === this.label.Visit_Results_Tab_Labs) {
            return this.label.Show_Labs;
        } else if (this.selectedResultType === this.label.Visit_Results_Tab_Biomarkers) {
            return this.label.Show_Biomarkers;
        }
    }
    get toggleValue() {
        if (this.selectedResultType === this.label.Visit_Results_Tab_Vitals) {
            return this.isVitalsToggleOn;
        } else if (this.selectedResultType === this.label.Visit_Results_Tab_Labs) {
            return this.isLabsToggleOn;
        } else if (this.selectedResultType === this.label.Visit_Results_Tab_Biomarkers) {
            return this.isBiomarkersToggleOn;
        }
    }
    get isVitalsSelected() {
        return this.selectedResultType === this.label.Visit_Results_Tab_Vitals;
    }

    get isLabsSelected() {
        return this.selectedResultType === this.label.Visit_Results_Tab_Labs;
    }

    get isBiomarkersSelected() {
        return this.selectedResultType === this.label.Visit_Results_Tab_Biomarkers;
    }

    get isVitalsSelected() {
        return this.selectedResultType === this.label.Visit_Results_Tab_Vitals;
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
    get currentVisitId() {
        return this.currentVisit.Id;
    }
    get button1Group2Class() {
        return this.isButton1Group2
            ? 'slds-button group-button1 primaryBtn'
            : 'slds-button group-button1 secondaryBtn';
    }
    get button2Group2Class() {
        return this.isButton2Group2
            ? 'slds-button group-button3 primaryBtn'
            : 'slds-button group-button3 secondaryBtn';
    }
    get button1Group3Class() {
        return this.isButton1Group3
            ? 'slds-button group-button1 primaryBtn'
            : 'slds-button group-button1 secondaryBtn';
    }
    get button2Group3Class() {
        return this.isButton2Group3
            ? 'slds-button group-button2 primaryBtn'
            : 'slds-button group-button2 secondaryBtn';
    }
    get button3Group3Class() {
        return this.isButton3Group3
            ? 'slds-button group-button3 primaryBtn'
            : 'slds-button group-button3 secondaryBtn';
    }

    handleVRToggle(event) {
        this.showToggleSpinner = true;
        modifiedSwitchToggleRemote({
            visitResultsMode: this.selectedResultType,
            isToggleOn: event.target.checked
        })
            .then((result) => {
                if (this.selectedResultType === this.label.Visit_Results_Tab_Vitals) {
                    this.isVitalsToggleOn = !this.isVitalsToggleOn;
                } else if (this.selectedResultType === this.label.Visit_Results_Tab_Labs) {
                    this.isLabsToggleOn = !this.isLabsToggleOn;
                } else if (this.selectedResultType === this.label.Visit_Results_Tab_Biomarkers) {
                    this.isBiomarkersToggleOn = !this.isBiomarkersToggleOn;
                }
                this.showToggleSpinner = false;
                this.initialised = true;
            })
            .catch((error) => {
                console.error('Error occured here', error.message, 'error');
                this.showToggleSpinner = false;
                this.initialised = true;
            });
    }
    initializeData() {
        this.showSpinner = true;
        if (!communityService.isDummy()) {
            if (this.patientVisitWrapper) {
                let result = this.patientVisitWrapper;
                this.validVisitResults = result.isVisitResultsAvailable;
                if (this.validVisitResults == true) {
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
                    this.showTabSpinner = false;
                    this.visitResultTypeWithSubTypes = result.visitResultWithSubTypesCTP;
                } else if (this.validVisitResults == false) {
                    this.showSpinner = false;
                    this.showTabSpinner = false;
                }
            }
        }
    }
    get resultTypeDisclaimer() {
        if (this.selectedResultType === this.label.Visit_Results_Tab_Vitals) {
            return this.label.Visit_Results_Tab_Vit_Disclaimer;
        } else if (this.selectedResultType === this.label.Visit_Results_Tab_Labs) {
            return this.label.Visit_Results_Tab_Lab_Disclaimer;
        } else if (this.selectedResultType === this.label.Visit_Results_Tab_Biomarkers) {
            return this.label.Visit_Results_Tab_Bio_Disclaimer;
        }
    }

    handleNavigation() {
        const custEvent = new CustomEvent('navigateback', {
            detail: true
        });
        this.dispatchEvent(custEvent);
    }
    isIpadPortraitView() {
        let orientation = screen.orientation.type;
        let portrait = true;
        if (orientation === 'landscape-primary') {
            portrait = false;
        }
        if (window.innerWidth >= 768 && window.innerWidth < 1279 && portrait) {
            if (/iphone|ipad|ipod/i.test(navigator.userAgent.toLowerCase())) {
                this.isIpadPortrait = true;
                return true;
            } else if (/macintel|iPad Simulator/i.test(navigator.platform.toLowerCase())) {
                this.isIpadPortrait = true;
                return true;
            }
        } else {
            this.isIpadPortrait = false;
        }
        return false;
    }
    isIpadLandscapeView() {
        let orientation = screen.orientation.type;
        let landscape = false;
        if (orientation === 'landscape-primary') {
            landscape = true;
        }
        if (window.innerWidth >= 768 && window.innerWidth < 1279 && landscape) {
            if (/iphone|ipad|ipod/i.test(navigator.userAgent.toLowerCase())) {
                this.isIpadLandscape = true;
                return true;
            } else if (/macintel|iPad Simulator/i.test(navigator.platform.toLowerCase())) {
                this.isIpadLandscape = true;
                return true;
            }
        }
        this.isIpadLandscape = false;
        return false;
    }
}