import { LightningElement, api, track } from 'lwc';
import No_Vitals_Available from '@salesforce/label/c.No_Vitals_Available';
import No_Labs_Available from '@salesforce/label/c.No_Labs_Available';
import No_Biomarkers_Available from '@salesforce/label/c.No_Biomarkers_Available';
import More_Results from '@salesforce/label/c.PP_More_Results';
import Visit_Result_Group_MetabolicPanel from '@salesforce/label/c.Visit_Result_Group_MetabolicPanel';
import Visit_Result_Group_Hematology from '@salesforce/label/c.Visit_Result_Group_Hematology';
import Visit_Result_Group_FastingLipidProfile from '@salesforce/label/c.Visit_Result_Group_FastingLipidProfile';
import FORM_FACTOR from '@salesforce/client/formFactor';
import mobileTemplate from './ppVisitResultsContainerMobile.html';
import tabletTemplate from './ppVisitResultsContainerTablet.html';
import desktopTemplate from './ppVisitResultsContainer.html';
import getVisitResultsWrapperModified from '@salesforce/apex/Modified_VisitResultsRemote.getVisitResultsWrapperModified';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';

export default class PpVisitResultsContainer extends LightningElement {
    labels = {
        No_Vitals_Available,
        No_Labs_Available,
        No_Biomarkers_Available,
        More_Results,
        Visit_Result_Group_FastingLipidProfile,
        Visit_Result_Group_Hematology,
        Visit_Result_Group_MetabolicPanel
    };

    @api patientVisitId;
    @api visitResultTypeWithSubTypes;
    @api selectedResultType;
    participantMailingCC;
    ctpId;
    noVisitResultsAvailable = pp_icons + '/' + 'results_Illustration.svg';
    isVitalsResultsAvailable = false;
    isLabsResultsAvailable = false;
    isBiomarkersResultsAvailable = false;
    actualVisitResultsListVitals;
    actualVisitResultsListForLabs;
    actualVisitResultsListBio;
    visitResultsListVitals;
    visitResultsListForLabs;
    visitResultsListBio;
    labsHeading;
    totalLabResults = 0;
    totalVitalResults = 0;
    totalBioResults = 0;
    setInitialLabResults = true;
    maxResultsToDisp = 4;
    sliceStartValue = 0;
    sliceEndValue = 4;
    minResultsToDisp = 1;
    @track showMoreResults;
    @track showMoreText;
    showSpinner = true;

    connectedCallback() {
        this.showSpinner = true;
        this.participantMailingCC = communityService.getParticipantData().pe.Participant__r.Mailing_Country_Code__c;
        this.ctpId = communityService.getParticipantData().pe.Clinical_Trial_Profile__c;
        this.initializeData();
    }

    initializeData() {
        if (!communityService.isDummy()) {
            getVisitResultsWrapperModified({
                ctpId: this.ctpId,
                patientVisitId: this.patientVisitId,
                participantMailingCC: this.participantMailingCC,
                allVisResultCategories: this.visitResultTypeWithSubTypes,
                visitResultsMode: this.selectedResultType
            })
                .then((result) => {
                    let resultsWrapper = result;
                    if (this.selectedResultType == 'Labs') {
                        for (let i = 0; i < resultsWrapper.length; i++) {
                            if (this.setInitialLabResults && resultsWrapper[i].isResultsAvailable) {
                                this.actualVisitResultsListForLabs =
                                    resultsWrapper[i].resWrappersSorted;
                                this.visitResultsListForLabs = this.formResultsToDisplay(
                                    this.actualVisitResultsListForLabs
                                );
                                this.labsHeading =
                                    resultsWrapper[i].resultsModeName == 'Metabolic Panel'
                                        ? Visit_Result_Group_MetabolicPanel
                                        : resultsWrapper[i].resultsModeName == 'Hematology'
                                        ? Visit_Result_Group_Hematology
                                        : Visit_Result_Group_FastingLipidProfile;

                                this.isLabsResultsAvailable = true;
                                this.setInitialLabResults = false;
                            }
                            this.totalLabResults = resultsWrapper[i].isResultsAvailable
                                ? this.totalLabResults + resultsWrapper[i].resWrappersSorted.length
                                : this.totalLabResults;
                        }
                        this.calculateRemainingVisResults(this.totalLabResults);
                    } else if (this.selectedResultType == 'Vitals') {
                        for (let i = 0; i < resultsWrapper.length; i++) {
                            if (resultsWrapper[i].isResultsAvailable) {
                                this.actualVisitResultsListVitals =
                                    resultsWrapper[i].resWrappersSorted;
                                this.totalVitalResults =
                                    this.totalVitalResults +
                                    resultsWrapper[i].resWrappersSorted.length;
                                this.visitResultsListVitals = this.formResultsToDisplay(
                                    this.actualVisitResultsListVitals
                                );
                            }
                        }
                        this.calculateRemainingVisResults(this.totalVitalResults);
                    } else {
                        for (let i = 0; i < resultsWrapper.length; i++) {
                            if (resultsWrapper[i].isResultsAvailable) {
                                this.actualVisitResultsListBio =
                                    resultsWrapper[i].resWrappersSorted;
                                this.totalBioResults =
                                    this.totalBioResults +
                                    resultsWrapper[i].resWrappersSorted.length;
                                this.visitResultsListBio = this.formResultsToDisplay(
                                    this.actualVisitResultsListBio
                                );
                            }
                        }
                        this.calculateRemainingVisResults(this.totalBioResults);
                    }
                    this.showSpinner = false;
                })
                .catch((error) => {
                    console.error(
                        'Error when loading visit results' + error + JSON.stringify(error)
                    );
                    this.showSpinner = false;
                });
        }
    }
    calculateRemainingVisResults(totalResultsLength) {
        let remainingResults = 0;
        this.showMoreResults = totalResultsLength > this.maxResultsToDisp ? true : false;
        if (this.showMoreResults) {
            remainingResults = totalResultsLength - this.maxResultsToDisp;
            this.showMoreText = '+' + ' ' + remainingResults + ' ' + More_Results;
        }
    }
    formResultsToDisplay(actualVisitResults) {
        let finalVisResults;
        if (actualVisitResults.length > 4) {
            finalVisResults = actualVisitResults.slice(this.sliceStartValue, this.sliceEndValue);
        } else finalVisResults = actualVisitResults;
        return finalVisResults;
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
    get isVitalsResults() {
        return this.totalVitalResults > 0 ? true : false;
    }

    get isLabsResults() {
        return this.totalLabResults > 0 ? true : false;
    }

    get isBiomarkersResults() {
        return this.totalBioResults > 0 ? true : false;
    }
    get isDesktop() {
        return FORM_FACTOR === 'Large' ? true : false;
    }

    get isTablet() {
        return FORM_FACTOR === 'Medium' ? true : false;
    }

    get isMobile() {
        return FORM_FACTOR === 'Small' ? true : false;
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
}
