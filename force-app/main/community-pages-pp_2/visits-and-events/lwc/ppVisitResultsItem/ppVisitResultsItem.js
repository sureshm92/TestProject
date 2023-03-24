import { LightningElement, api } from 'lwc';
import No_Vitals_Available from '@salesforce/label/c.No_Vitals_Available';
import No_Labs_Available from '@salesforce/label/c.No_Labs_Available';
import No_Biomarkers_Available from '@salesforce/label/c.No_Biomarkers_Available';
import ppVisitResultsWrapper from '@salesforce/apex/PP_VisitResultsService.ppVisitResultsWrapper';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';

export default class PpVisitResultsItem extends LightningElement {
    labels = {
        No_Vitals_Available,
        No_Labs_Available,
        No_Biomarkers_Available
    };

    @api patientVisitId;
    @api visitResultTypeWithSubType;
    @api selectedResultType;
    participantMailingCC;
    ctpId;
    noVisitResultsAvailable = pp_icons + '/' + 'results_Illustration.svg';
    isVitalsResultsAvailable = false;
    isLabsResultsAvailable = false;
    isBiomarkersResultsAvailable = false;
    visitResultsList;
    visitResultsListForLabs;
    labsHeading;
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
                allVisResultCategories: this.visitResultTypeWithSubType,
                visitResultsMode: this.selectedResultType
            })
                .then((result) => {
                    let resultsWrapper = result;
                    if (this.selectedResultType == 'Labs') {
                        for (let i = 0; i < resultsWrapper.length; i++) {
                            console.log('JJ ' + resultsWrapper[i]);
                            if (resultsWrapper[i].isResultsAvailable) {
                                this.visitResultsListForLabs = resultsWrapper[i].resWrappers;
                                this.labsHeading = resultsWrapper[i].resultsModeName;
                                this.isLabsResultsAvailable = true;
                                break;
                            }
                            this.isLabsResultsAvailable = false;
                        }
                    } else {
                        for (let i = 0; i < resultsWrapper.length; i++) {
                            console.log('JJ ' + JSON.stringify(resultsWrapper[i]));
                            if (resultsWrapper[i].isResultsAvailable) {
                                this.isVitalsResultsAvailable =
                                    this.selectedResultType == 'Vitals' ? true : false;
                                this.isBiomarkersResultsAvailable =
                                    this.selectedResultType == 'Biomarkers' ? true : false;
                                this.visitResultsList = resultsWrapper[i].resWrappers;
                            }
                        }
                    }
                    // this.showSpinner = false;
                })
                .catch((error) => {
                    console.error(error);
                });
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
}
