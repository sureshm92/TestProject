import { LightningElement, api, track } from 'lwc';
import LOCALE from '@salesforce/i18n/locale';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import communityPPTheme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';
import LOFI_LOGIN_ICONS from '@salesforce/resourceUrl/Lofi_Login_Icons';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';

export default class PpHelp extends LightningElement {
    isInitialized = false;
    userMode;
    isRTL = false;
    isDelegate = false;
    spinner;
    enableStyle;
    communityTemplate;

    renderedCallback() {}
    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                Promise.all([loadStyle(this, communityPPTheme)])
                    .then(() => {
                        console.log('------promise all-----');
                        this.spinner = this.template.querySelector('c-web-spinner');
                        this.spinner.show();
                        this.initializeData();
                    })
                    .catch((error) => {
                        console.log('err', error);
                    });
            })
            .catch((error) => {
                this.showToast(this.labels.ERROR_MESSAGE, error.message, 'error');
            });
    }
    initializeData() {
        console.log('-----------initializeData-----------');
        if (!communityService.isDummy()) {
            this.userMode = communityService.getUserMode();
            this.isDelegate = communityService.isDelegate();
            this.communityTemplate = communityService.getCurrentCommunityTemplateName();
            this.isRTL = rtlLanguages.includes(communityService.getLanguage()) ? true : false;
            this.enableStyle = this.isRTL == true ? 'rtl-container-help' : '';
            this.isInitialized = communityService.isInitialized();
            if (this.isInitialized) {
                this.spinner.hide();
            }
        } else {
            let stub = this.template.querySelector('c-builder-stub');
            stub.setPageName('cppHelp');
        }
    }
}
