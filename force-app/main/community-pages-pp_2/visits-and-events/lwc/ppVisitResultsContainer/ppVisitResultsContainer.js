import { LightningElement, api, track } from 'lwc';
import No_Vitals_Available from '@salesforce/label/c.No_Vitals_Available';
import No_Labs_Available from '@salesforce/label/c.No_Labs_Available';
import No_Biomarkers_Available from '@salesforce/label/c.No_Biomarkers_Available';
import More_Results from '@salesforce/label/c.PP_More_Results';
import Visit_Result_Group_MetabolicPanel from '@salesforce/label/c.Visit_Result_Group_MetabolicPanel';
import Visit_Result_Group_Hematology from '@salesforce/label/c.Visit_Result_Group_Hematology';
import Visit_Result_Group_FastingLipidProfile from '@salesforce/label/c.Visit_Result_Group_FastingLipidProfile';

import ppVisitResultsWrapper from '@salesforce/apex/PP_VisitResultsService.ppVisitResultsWrapper';
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
    visitResultsListVitals;
    visitResultsListForLabs;
    visitResultsListBio;
    labsHeading;
    totalLabResults = 0;
    totalVitalResults = 0;
    totalBioResults = 0;
    setInitialLabResults = true;
    maxResultsToDisp = 4;
    minResultsToDisp = 1;
    @track showMoreResults;
    @track showMoreText;
    // showSpinner;

    connectedCallback() {
        //  this.showSpinner = true;
        this.participantMailingCC = communityService.getParticipantData().pe.Participant__r.Mailing_Country_Code__c;
        this.ctpId = communityService.getParticipantData().pe.Clinical_Trial_Profile__c;
        this.initializeData();
    }

    initializeData() {
        if (!communityService.isDummy()) {
            ppVisitResultsWrapper({
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
                                this.visitResultsListForLabs = resultsWrapper[i].resWrappers;
                                this.labsHeading =
                                    resultsWrapper[i].resultsModeName == 'MetabolicPanel'
                                        ? Visit_Result_Group_MetabolicPanel
                                        : resultsWrapper[i].resultsModeName == 'Hematology'
                                        ? Visit_Result_Group_Hematology
                                        : Visit_Result_Group_FastingLipidProfile;

                                this.isLabsResultsAvailable = true;
                                this.setInitialLabResults = false;
                            }
                            this.totalLabResults = resultsWrapper[i].isResultsAvailable
                                ? this.totalLabResults + resultsWrapper[i].resWrappers.length
                                : this.totalLabResults;
                        }
                        //    this.calculateRemainingVisResults(this.totalLabResults);
                    } else if (this.selectedResultType == 'Vitals') {
                        for (let i = 0; i < resultsWrapper.length; i++) {
                            if (resultsWrapper[i].isResultsAvailable) {
                                this.visitResultsListVitals = resultsWrapper[i].resWrappers;
                                this.totalVitalResults =
                                    this.totalVitalResults + resultsWrapper[i].resWrappers.length;
                            }
                        }
                        //   this.calculateRemainingVisResults(this.totalVitalResults);
                    } else {
                        for (let i = 0; i < resultsWrapper.length; i++) {
                            if (resultsWrapper[i].isResultsAvailable) {
                                this.visitResultsListBio = resultsWrapper[i].resWrappers;
                                this.totalBioResults =
                                    this.totalBioResults + resultsWrapper[i].resWrappers.length;
                            }
                        }
                        //   this.calculateRemainingVisResults(this.totalBioResults);
                    }
                    // this.showSpinner = false;
                })
                .catch((error) => {
                    console.error(error);
                });
        }
    }
    calculateRemainingVisResults(totalResultsLength) {
        let remainingResults;
        this.showMoreResults = totalResultsLength > this.maxResultsToDisp ? true : false;
        if (this.showMoreResults) {
            remainingResults = this.totalResultsLength - this.maxResultsToDisp;
            this.showMoreText = '+' + remainingResults + More_Results;
        }
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
        return this.totalLabResults > 0 ? true : false;
    }

    get isLabsResults() {
        return this.totalVitalResults > 0 ? true : false;
    }

    get isBiomarkersResults() {
        return this.totalBioResults > 0 ? true : false;
    }
}
