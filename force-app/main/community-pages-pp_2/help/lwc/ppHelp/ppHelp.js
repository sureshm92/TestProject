import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import LOCALE from '@salesforce/i18n/locale';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import communityPPTheme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';
import LOFI_LOGIN_ICONS from '@salesforce/resourceUrl/Lofi_Login_Icons';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import pdfjs_dist from '@salesforce/resourceUrl/pdfjs_dist';
import participant_user_guide from '@salesforce/resourceUrl/Participant_user_guide';
import getHelpInitData from '@salesforce/apex/HelpController.getHelpInitData';
import getResourceURL from '@salesforce/apex/HelpController.getResourceURL';
import helpResponse from '@salesforce/label/c.PP_HelpResponse';
import accountSettings from '@salesforce/label/c.PP_Account_Settings';
import updateProfileResponse from '@salesforce/label/c.PP_UpdateProfileResponse';
import helpFAQlabel from '@salesforce/label/c.Help_FAQ';
import helpEmergencyLabel from '@salesforce/label/c.Help_Emergency_Contact';
import helpLabel from '@salesforce/label/c.Navigation_Help';

import rr_community_icons from '@salesforce/resourceUrl/rr_community_icons';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import DEVICE from '@salesforce/client/formFactor';

export default class PpHelp extends NavigationMixin(LightningElement) {
    isInitialized = false;
    userMode;
    isRTL = false;
    isDelegate = false;
    spinner;
    enableStyle;
    communityTemplate;
    quickReference;
    currentContact;
    helpTopicOptions;
    helpTopicSettings;
    participantPicklistvalues;
    sitePicklistvalues;
    showGetSupport;

    isMobile = false;
    label = {
        helpResponse,
        accountSettings,
        updateProfileResponse,
        helpFAQlabel,
        helpEmergencyLabel,
        helpLabel
    };

    //exclamation_green = rr_community_icons + '/' + 'status-exclamation.svg';
    help_section_icon = pp_icons + '/' + 'help-section-icon.png';
    exclamation = pp_icons + '/' + 'status-exclamation-icon.png';
    homeSvg = rr_community_icons + '/' + 'icons.svg' + '#' + 'icon-home-pplite-new';

    get cardRTL() {
        return this.isRTL ? 'cardRTL' : '';
    }

    get headerPanelClass() {
        return this.isMobile ? 'header-panel-mobile' : '';
    }
    get rightColumnClass() {
        return this.isMobile ? 'header-panel-mobile' : 'header-panel';
    }
    get leftColPadding() {
        return this.isRTL ? 'mb-15 leftColumn-RTL' : 'mb-15 leftColumn';
    }

    get breadCrumMobile() {
        return this.isRTL ? 'mr-10' : '';
    }

    handleHomePage() {
        communityService.navigateToPage('');
    }

    renderedCallback() {}
    connectedCallback() {
        let currentDelgId = communityService.getCurrentCommunityMode().currentDelegateId;
        this.showGetSupport = currentDelgId == null ? true : false;
        DEVICE != 'Small' ? (this.isMobile = false) : (this.isMobile = true);
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                Promise.all([loadStyle(this, communityPPTheme)])
                    .then(() => {
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
        if (!communityService.isDummy()) {
            this.userMode = communityService.getUserMode();
            this.isDelegate = communityService.isDelegate();
            this.communityTemplate = communityService.getCurrentCommunityTemplateName();
            this.isRTL = rtlLanguages.includes(communityService.getLanguage()) ? true : false;
            this.enableStyle = this.isRTL == true ? 'rtl-container-help' : '';
            this.isInitialized = communityService.isInitialized();
            if (this.isInitialized) {
                getHelpInitData({ userMode: this.userMode, communityName: this.communityTemplate })
                    .then((result) => {
                        var initData = JSON.parse(result);
                        this.currentContact = initData.userContact.currentContact;
                        this.helpTopicOptions = initData.helpTopicOptions;
                        this.helpTopicSettings = initData.helpTopicSettings;
                        this.participantPicklistvalues = initData.participantEnrollOptions;
                        this.sitePicklistvalues = initData.siteOptions;
                        this.quickReference = initData.quickReference;
                        this.spinner.hide();
                    })
                    .catch((error) => {
                        console.log('error', error);
                    });
            }
        } else {
            let stub = this.template.querySelector('c-builder-stub');
            stub.setPageName('cppHelp');
        }
    }

    navigateToAccSettings() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'account-settings'
            }
        });
    }
}
