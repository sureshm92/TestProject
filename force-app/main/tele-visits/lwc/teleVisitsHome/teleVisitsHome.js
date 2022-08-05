import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import NAVIGATION_HOME from '@salesforce/label/c.Navigation_Home';
import FORM_FACTOR from '@salesforce/client/formFactor';
import TV_TITLE from '@salesforce/label/c.Home_Page_Tele_Visit_Details_Tab';
import getisRTL from '@salesforce/apex/ParticipantVisitsRemote.getIsRTL';
import { loadScript } from 'lightning/platformResourceLoader';
import rrCommunity from '@salesforce/resourceUrl/rr_community_js';

export default class TeleVisitsHome extends NavigationMixin(LightningElement) {
    isRTL;
    loaded = false;
    isMobileApp = false;

    labels = {
        NAVIGATION_HOME,
        TV_TITLE
    };

    connectedCallback() {
        if (!this.loaded) {
            loadScript(this, rrCommunity).then(() => {
                if (communityService.isMobileSDK()) {
                    this.isMobileApp = true;
                }
            });
            getisRTL()
                .then((data) => {
                    this.isRTL = data;
                })
                .catch(function (error) {
                    console.error('Error: ' + JSON.stringify(error));
                });
        }
    }

    get containerClass() {
        return this.isRTL ? 'cardRTL' : '';
    }

    get isDesktop() {
        return FORM_FACTOR === 'Large';
    }

    get iconChevron() {
        return 'utility:chevron' + (this.isRTL ? 'left' : 'right');
    }

    navigateToHome() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
    }
}