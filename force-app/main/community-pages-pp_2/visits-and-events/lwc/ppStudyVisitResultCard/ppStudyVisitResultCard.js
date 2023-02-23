import { LightningElement, wire } from 'lwc';
import resultsCheck from '@salesforce/label/c.Visit_Check_Result';
import results from '@salesforce/label/c.Visit_Result';
import viewAllResults from '@salesforce/label/c.Visits_View_All_Results';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import { NavigationMixin } from 'lightning/navigation';

export default class PpStudyVisitResultCard extends NavigationMixin(LightningElement) {
    label = {
        resultsCheck,
        viewAllResults,
        results
    };

    showVisResults;
    participantState;

    visitimage1 = pp_icons + '/' + 'VisitPageResultImage.png';
    resultsIllustration = pp_icons + '/' + 'results_Illustration.svg';
    connectedCallback() {
        this.initializeData();
    }

    initializeData() {
        if (!communityService.isDummy()) {
            this.showVisResults = communityService.getVisResultsAvailable();
        }
    }

    navigateToMyResults() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'results'
            }
        });
    }
}
