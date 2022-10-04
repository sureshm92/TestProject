import { LightningElement } from 'lwc';
import resultsCheck from '@salesforce/label/c.Visit_Check_Result';
import viewAllResults from '@salesforce/label/c.Visits_View_All_Results';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';

export default class PpStudyVisitResultCard extends LightningElement {
    label = {
        resultsCheck,
        viewAllResults
    };

    visitimage1 = pp_icons + '/' + 'VisitPageResultImage.png';
}