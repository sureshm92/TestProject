import { LightningElement, api, track } from 'lwc';
import getVisitResultsWrapperModified from '@salesforce/apex/ModifiedVisitResultsRemote.getVisitResultsWrapperModified';
import Visit_Result_Group_MetabolicPanel from '@salesforce/label/c.Visit_Result_Group_MetabolicPanel';
import Visit_Result_Group_Hematology from '@salesforce/label/c.Visit_Result_Group_Hematology';
import Visit_Result_Group_FastingLipidProfile from '@salesforce/label/c.Visit_Result_Group_FastingLipidProfile';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import No_Vitals_Available from '@salesforce/label/c.No_Vitals_Available';
import No_Labs_Available from '@salesforce/label/c.No_Labs_Available';
import No_Biomarkers_Available from '@salesforce/label/c.No_Biomarkers_Available';

import Visit_Results_Tab_Panel_Disclaimer from '@salesforce/label/c.Visit_Results_Tab_Panel_Disclaimer';

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
        this.getResultsData();
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

    getResultsData() {
        console.log('JJ GGGG' + this.selectedResultType);
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
                console.log('JJ GGGG' + JSON.stringify(result));
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
                    this.isLabsResultsAvailable = resultsWrapper.length > 0 ? true : false;
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
}
