import { LightningElement, api, track } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import mobileTemplate from './ppVisitResultTypeInfoMobile.html';
import tabletTemplate from './ppVisitResultTypeInfoTablet.html';
import desktopTemplate from './ppVisitResultTypeInfo.html';
import getInitDataPP from '@salesforce/apex/VisitResultsRemote.getInitDataPP';
import switchToggleRemoteForPP from '@salesforce/apex/VisitResultsRemote.switchToggleRemoteForPP';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import Visit_Results_Tab_Vit_Disclaimer from '@salesforce/label/c.Visit_Results_Tab_Vit_Disclaimer';
import Visit_Results_Tab_Lab_Disclaimer from '@salesforce/label/c.Visit_Results_Tab_Lab_Disclaimer';
import Visit_Results_Tab_Bio_Disclaimer from '@salesforce/label/c.Visit_Results_Tab_Bio_Disclaimer';
import Show_Vitals from '@salesforce/label/c.Show_Vitals';
import Show_Labs from '@salesforce/label/c.Show_Labs';
import Show_Biomarkers from '@salesforce/label/c.Show_Biomarkers';
import No_Vitals_Available from '@salesforce/label/c.No_Vitals_Available';
import No_Labs_Available from '@salesforce/label/c.No_Labs_Available';
import No_Biomarkers_Available from '@salesforce/label/c.No_Biomarkers_Available';
import Vitals_Toggle_Off from '@salesforce/label/c.Vitals_Toggle_Off';
import Labs_Toggle_Off from '@salesforce/label/c.Labs_Toggle_Off';
import Biomarkers_Toggle_Off from '@salesforce/label/c.Biomarkers_Toggle_Off';
import No_Visit_Results_Available from '@salesforce/label/c.No_Visit_Results_Available';

export default class PpVisitResultTypeInfo extends LightningElement {
    labels = {
        Visit_Results_Tab_Vit_Disclaimer,
        Visit_Results_Tab_Lab_Disclaimer,
        Visit_Results_Tab_Bio_Disclaimer,
        Show_Vitals,
        Show_Labs,
        Show_Biomarkers,
        No_Vitals_Available,
        No_Labs_Available,
        No_Biomarkers_Available,
        Vitals_Toggle_Off,
        Labs_Toggle_Off,
        Biomarkers_Toggle_Off,
        No_Visit_Results_Available
    };
    visitResultTypeOptions = [];

    visitResultImagePI = pp_icons + '/' + 'VisitPageResultImage.png';
    noVisitResultsAvailable = pp_icons + '/' + 'results_Illustration.svg';
    toggleOffHeart = pp_icons + '/' + 'heart_Icon.svg';

    @track validVisitResults = false;

    @api participantMailingCC;
    @api ctpId;
    @api ctpSharingTiming;
    @api patientVisitId;

    selectedResultType = 'Vitals';
    showSpinner = true;
    isVitalsToggleOn = false;
    isLabsToggleOn = false;
    isBiomarkersToggleOn = false;
    //update after making last apex call
    isVitalsAvailable = false;
    isLabsAvailable = false;
    isBiomarkersAvailable = false;

    get isDesktop() {
        return FORM_FACTOR === 'Large' ? true : false;
    }

    get isTablet() {
        return FORM_FACTOR === 'Medium' ? true : false;
    }

    get isMobile() {
        return FORM_FACTOR === 'Small' ? true : false;
    }

    connectedCallback() {
        this.initializeData();
    }

    initializeData() {
        if (!communityService.isDummy()) {
            getInitDataPP({
                ctpSharingTiming: this.ctpSharingTiming,
                patientVisitId: this.patientVisitId
            })
                .then((result) => {
                    console.log('rk:::', result);
                    this.validVisitResults = result.isVisitResultsAvailable;
                    if (this.validVisitResults) {
                        if (
                            result.visitResultsGroupNamesCTP &&
                            result.visitResultsGroupNamesCTP.length
                        ) {
                            for (let i = result.visitResultsGroupNamesCTP.length; i > 0; i--) {
                                let resultTypeOption = {
                                    label: result.visitResultsGroupNamesCTP[i - 1],
                                    value: result.visitResultsGroupNamesCTP[i - 1],
                                    itemClass: 'dropdown-li'
                                };
                                this.visitResultTypeOptions = [
                                    ...this.visitResultTypeOptions,
                                    resultTypeOption
                                ];
                            }
                            this.selectedResultType = this.visitResultTypeOptions
                                ? this.visitResultTypeOptions[0].value
                                : '';
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
                    }
                    this.showSpinner = false;
                })
                .catch((error) => {
                    console.error(error);
                    this.showErrorToast('Error occured here', error.message, 'error');
                });
        }
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

    get resultTypeDisclaimer() {
        if (this.selectedResultType === 'Vitals') {
            return this.labels.Visit_Results_Tab_Vit_Disclaimer;
        } else if (this.selectedResultType === 'Labs') {
            return this.labels.Visit_Results_Tab_Lab_Disclaimer;
        } else if (this.selectedResultType === 'Biomarkers') {
            return this.labels.Visit_Results_Tab_Bio_Disclaimer;
        }
    }

    get toggleLabel() {
        if (this.selectedResultType === 'Vitals') {
            return this.labels.Show_Vitals;
        } else if (this.selectedResultType === 'Labs') {
            return this.labels.Show_Labs;
        } else if (this.selectedResultType === 'Biomarkers') {
            return this.labels.Show_Biomarkers;
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

    get toggleValue() {
        if (this.selectedResultType === 'Vitals') {
            return this.isVitalsToggleOn;
        } else if (this.selectedResultType === 'Labs') {
            return this.isLabsToggleOn;
        } else if (this.selectedResultType === 'Biomarkers') {
            return this.isBiomarkersToggleOn;
        }
    }

    handleVRToggle(event) {
        this.showSpinner = true;
        if (this.selectedResultType === 'Vitals') {
            this.isVitalsToggleOn = event.target.checked;
        } else if (this.selectedResultType === 'Labs') {
            this.isLabsToggleOn = event.target.checked;
        } else if (this.selectedResultType === 'Biomarkers') {
            this.isBiomarkersToggleOn = event.target.checked;
        }
        //apex call to update toggle
        switchToggleRemoteForPP({
            visitResultsMode: this.selectedResultType,
            isToggleOn: event.target.checked
        })
            .then((result) => {
                this.showSpinner = false;
            })
            .catch((error) => {
                console.error(error);
                this.showErrorToast('Error occured here', error.message, 'error');
                this.showSpinner = false;
            });
    }

    handleVRTypeChange(event) {
        this.selectedResultType = event.detail;
    }

    showErrorToast(titleText, messageText, variantType) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: titleText,
                message: '',
                variant: variantType
            })
        );
    }
}
