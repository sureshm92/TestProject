import { LightningElement } from 'lwc';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import noItemToDisplay from '@salesforce/label/c.PG_VP_L_No_Items_display';
import myResults from '@salesforce/label/c.PP_Tab_Results';
import formFactor from '@salesforce/client/formFactor';

export default class PpMyResultsCard extends LightningElement {
    resultsIllustration = pp_icons + '/' + 'results_Illustration.svg';
    label = { noItemToDisplay, myResults };
    isMobile = false;
    isTablet = false;
    isDesktop = false;

    connectedCallback() {
        if (formFactor === 'Small') {
            this.isMobile = true;
            this.isTablet = false;
            this.isDesktop = false;
        } else if (formFactor === 'Medium') {
            this.isTablet = true;
            this.isMobile = false;
            this.isDesktop = false;
        } else if (formFactor === 'Large') {
            this.isDesktop = true;
            this.isTablet = false;
            this.isMobile = false;
        }
    }
}
