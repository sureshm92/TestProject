import { LightningElement, api, track } from 'lwc';
import getVisitResultsWrapperModified from '@salesforce/apex/ModifiedVisitResultsRemote.getVisitResultsWrapperModified';
import Visit_Result_Group_MetabolicPanel from '@salesforce/label/c.Visit_Result_Group_MetabolicPanel';
import Visit_Result_Group_Hematology from '@salesforce/label/c.Visit_Result_Group_Hematology';
import Visit_Result_Group_FastingLipidProfile from '@salesforce/label/c.Visit_Result_Group_FastingLipidProfile';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import No_Vitals_Available from '@salesforce/label/c.No_Vitals_Available';
import No_Labs_Available from '@salesforce/label/c.No_Labs_Available';
import No_Biomarkers_Available from '@salesforce/label/c.No_Biomarkers_Available';
import FORM_FACTOR from '@salesforce/client/formFactor';
import mobileTemplate from './ppVisitResultSectionMobile.html';
import tabletTemplate from './ppVisitResultSectionTablet.html';
import desktopTemplate from './ppVisitResultSection.html';
import Visit_Results_Tab_Panel_Disclaimer from '@salesforce/label/c.Visit_Results_Tab_Panel_Disclaimer';
import removeUpdateCardForVisitResult from '@salesforce/apex/PPUpdatesController.removeUpdateCardForVisitResult';

export default class PpVisitResultSection extends LightningElement {
    @api selectedResultType;
    @api patientVisit;
    @api visitResultTypeWithSubTypes;
    @track visitResultsBio;
    @track visitResultsVitals;
    @track visitResultsMetabolicPanel;
    @track visitResultsHematology;
    @track visitResultsFastingLipidProfile;
    @track isMetabolicPanel;
    @track isHeamatology;
    @track isFastLipProfile;
    @track isVitalsResultsAvailable = false;
    @track isBioResultsAvailable;
    @track isLabsResultsAvailable = false;
    @track initialised = false;
    @track visResultsList;
    isTablet=false;
    isLandscape = false;
    tabResultCardClass = 'slds-col slds-size_8-of-12 slds-p-right_small slds-p-left_none slds-p-bottom_small card-center-ipad';
    landscapeResultCardClass = 'slds-col slds-size_1-of-2 slds-p-right_small slds-p-left_none slds-p-bottom_small';
    desktopResultCardClass = 'slds-col slds-size_4-of-12 slds-p-right_small slds-p-left_none slds-p-bottom_small';
    label = {
        Visit_Result_Group_MetabolicPanel,
        Visit_Result_Group_Hematology,
        Visit_Result_Group_FastingLipidProfile,
        No_Vitals_Available,
        No_Labs_Available,
        No_Biomarkers_Available,
        Visit_Results_Tab_Panel_Disclaimer
    };
    showSpinner = true;
    noVisitResultsAvailable = pp_icons + '/' + 'results_Illustration.svg';

    connectedCallback() {
        //this.getResultsData();
        this.removeUpdatesCardForVisitResult();
        this.isTabletMenu();
        this.isIpadLandscape();
        window.addEventListener('orientationchange', this.onOrientationChange);
    }
    onOrientationChange = () => {
        this.isIpadLandscape();
        this.isTabletMenu();
    };
    get visitResultCardClass(){
        return this.isTablet ? this.tabResultCardClass : (this.isLandscape? this.landscapeResultCardClass : this.desktopResultCardClass);
    }
    get isVitalsSelected() {
        return this.selectedResultType == 'Vitals';
    }

    get isLabsSelected() {
        return this.selectedResultType == 'Labs';
    }

    get isBiomarkersSelected() {
        return this.selectedResultType == 'Biomarkers';
    }

    @api
    get selectedVisit() {
        return this.patientVisit;
    }
    set selectedVisit(value) {
        this.patientVisit = value;
        this.getResultsData();
    }

    get labsResultsAvailable() {
        return this.isMetabolicPanel
            ? true
            : this.isHeamatology
            ? true
            : this.isFastLipProfile
            ? true
            : false;
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

    get isTab() {
        return FORM_FACTOR == 'Medium';
    }
    removeUpdatesCardForVisitResult() {
        let participantContactId = communityService.getParticipantData().pe.Participant_Contact__c;
        let partEnrollemntId = communityService.getParticipantData().pe.Id;
        removeUpdateCardForVisitResult({
            contactId: participantContactId,
            peId: partEnrollemntId,
            patientVisitId: this.patientVisit.Id
        })
            .then((result) => {})
            .catch((error) => {
                console.error('Error when updating send results' + error + JSON.stringify(error));
            });
    }
    getResultsData() {
        this.showSpinner = true;
        this.participantMailingCC = communityService.getParticipantData().pe.Participant__r.Mailing_Country_Code__c;
        this.ctpId = communityService.getParticipantData().pe.Clinical_Trial_Profile__c;
        getVisitResultsWrapperModified({
            ctpId: this.ctpId,
            patientVisitId: this.patientVisit.Id,
            participantMailingCC: this.participantMailingCC,
            allVisResultCategories: this.visitResultTypeWithSubTypes,
            visitResultsMode: this.selectedResultType
        })
            .then((result) => {
                let resultsWrapper = result;
                this.visResultsList = result;
                if (this.selectedResultType == 'Labs') {
                    for (let i = 0; i < resultsWrapper.length; i++) {
                        if (resultsWrapper[i].isResultsAvailable) {
                            if (resultsWrapper[i].resultsModeName == 'Metabolic Panel') {
                                this.isMetabolicPanel = true;
                                this.visitResultsMetabolicPanel = resultsWrapper[i].resWrappers;
                            } else if (resultsWrapper[i].resultsModeName == 'Hematology') {
                                this.isHeamatology = true;
                                this.visitResultsHematology = resultsWrapper[i].resWrappers;
                            } else {
                                this.isFastLipProfile = true;
                                this.visitResultsFastingLipidProfile =
                                    resultsWrapper[i].resWrappers;
                            }
                        }
                    }
                } else if (this.selectedResultType == 'Vitals') {
                    for (let i = 0; i < resultsWrapper.length; i++) {
                        if (resultsWrapper[i].isResultsAvailable) {
                            this.visitResultsVitals = resultsWrapper[i].resWrappers;
                            this.isVitalsResultsAvailable = true;
                        } else this.isVitalsResultsAvailable = false;
                    }
                } else {
                    for (let i = 0; i < resultsWrapper.length; i++) {
                        if (resultsWrapper[i].isResultsAvailable) {
                            this.visitResultsBio = resultsWrapper[i].resWrappers;
                            this.isBioResultsAvailable = true;
                        } else this.isBioResultsAvailable = false;
                    }
                }

                this.showSpinner = false;
                this.initialised = true;
            })
            .catch((error) => {
                console.error('Error when loading visit results' + error + JSON.stringify(error));
                this.showSpinner = false;
                this.initialised = true;
            });
    }
    isTabletMenu() {
        //alert('coming');
        let orientation = screen.orientation.type;
        let portrait = true;
        if (orientation === 'landscape-primary') {
            portrait = false;
        }
        if (window.innerWidth >= 768 && window.innerWidth < 1279 && portrait) {
            if (/iphone|ipad|ipod/i.test(navigator.userAgent.toLowerCase())) {
                this.isTablet = true;
                return true;
            } else if (/macintel|iPad Simulator/i.test(navigator.platform.toLowerCase())) {
                this.isTablet = true;
                return true;
            }
        } else {
            this.isTablet = false;
        }
        return false;
    }
    isIpadLandscape() {
        let orientation = screen.orientation.type;
        let landscape = false;
        if (orientation === 'landscape-primary') {
            landscape = true;
        }
        if (window.innerWidth >= 768 && window.innerWidth < 1279 && landscape) {
            if (/iphone|ipad|ipod/i.test(navigator.userAgent.toLowerCase())) {
                this.isLandscape = true;
                return true;
            } else if (/macintel|iPad Simulator/i.test(navigator.platform.toLowerCase())) {
                this.isLandscape = true;
                return true;
            }
        }
        this.isLandscape = false;
        return false;
    }
}
