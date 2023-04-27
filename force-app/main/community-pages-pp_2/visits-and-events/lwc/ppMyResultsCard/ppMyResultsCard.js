import { LightningElement } from 'lwc';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import noItemToDisplay from '@salesforce/label/c.PG_VP_L_No_Items_display';
import myResults from '@salesforce/label/c.PP_Tab_Results';
import formFactor from '@salesforce/client/formFactor';

export default class PpMyResultsCard extends LightningElement {
    resultsIllustration = pp_icons + '/' + 'results_Illustration.svg';
    label = { noItemToDisplay, myResults };
    showResultsinTablet;
    showResultsinMobile;
    showResultsinDesktop;

    connectedCallback() {
        if (formFactor == 'Large') this.showResultsinDesktop = true;
        else if (formFactor == 'Medium') this.showResultsinTablet = true;
        else this.showResultsinMobile = true;
    }

    get isDesktop() {
        return formFactor == 'Large';
    }

    get isMobile() {
        return formFactor == 'Small';
    }

    get isTablet() {
        return formFactor == 'Medium';
    }

    get resultClassDesktop() {
        return this.showResultsinDesktop ? 'my-results' : 'hide-results';
    }

    get resultClassTablet() {
        return this.showResultsinTablet ? 'my-results' : 'hide-results';
    }

    get resultClassMobile() {
        return this.showResultsinMobile ? 'my-results' : 'hide-results';
    }

    handleShowResultsHeader(event) {
        if (this.isMobile) this.showResultsinMobile = false;
        else if (this.isTablet) this.showResultsinTablet = false;
    }
}
