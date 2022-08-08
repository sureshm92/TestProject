import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import formFactor from '@salesforce/client/formFactor';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';

export default class PpPageAccountSettings extends LightningElement {
    isInitialized = false;
    userMode;
    isRTL = false;
    isDelegate = false;
    spinner;

    labels = { ERROR_MESSAGE };

    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                this.spinner = this.template.querySelector('c-web-spinner');
                this.spinner.show();
                this.initializeData();
            })
            .catch((error) => {
                this.showErrorToast(this.labels.ERROR_MESSAGE, error.message, 'error');
            });
    }

    get isMobile() {
        return formFactor !== 'Large' ? true : false;
    }

    renderedCallback() {}

    initializeData() {
        if (!communityService.isDummy()) {
            this.userMode = communityService.getUserMode();
            this.isDelegate = communityService.isDelegate();
            this.isRTL = rtlLanguages.includes(communityService.getLanguage()) ? true : false;
            this.isInitialized = communityService.isInitialized();
            if (this.isInitialized) {
                this.spinner.hide();
            }
        } else {
            let stub = this.template.querySelector('c-builder-stub');
            stub.setPageName('cppAccountSettings');
        }
    }

    showErrorToast(titleText, messageText, variantType) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: titleText,
                message: messageText,
                variant: variantType
            })
        );
    }
}
