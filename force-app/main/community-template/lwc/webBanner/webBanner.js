import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';

export default class WebBanner extends LightningElement {
    @track isTRL;
    @api bodyText;
    @api toDisplay;

    label = {
        rtlLanguages
    };
    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                console.log('RR_COMMUNITY_JS loaded');
                let language = communityService.getUrlParameter('language');
                let label = this.label;
                this.isRTL = label.rtlLanguages.includes(language);
                this.isMobileApp = communityService.isMobileSDK();
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading RR_COMMUNITY_JS',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }
}
