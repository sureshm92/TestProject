import { LightningElement, track } from 'lwc';
import resourcesDesktop from './ppResourceDesktopPage.html';
import resourcesMobile from './ppResourceMobilePage.html';
import DEVICE from '@salesforce/client/formFactor';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import getTrialDetail from '@salesforce/apex/StudyDetailViewController.getTrialDetail';
import getLinksData from '@salesforce/apex/RelevantLinksRemote.getInitData';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import RELEVANT_LINKS from '@salesforce/label/c.Home_Page_RelevantLinks_Title';
import DISCOVER_TITLE from '@salesforce/label/c.Discover_Title';
import ENGAGE from '@salesforce/label/c.PP_Resource_Engage';
import EXPLORE from '@salesforce/label/c.PP_Resource_Explore';
import DOCUMENTS from '@salesforce/label/c.PP_Resource_Documents';
import FIND_ANSWERS from '@salesforce/label/c.PP_Resource_Answers';
import RESOURCES from '@salesforce/label/c.PG_SW_Tab_Resources';
import CHANGE_PREFERENCES from '@salesforce/label/c.PP_Change_Preferences';
import basePathName from '@salesforce/community/basePath';
import { NavigationMixin } from 'lightning/navigation';

export default class PpResourceContainerPage extends NavigationMixin(LightningElement) {
    //boolean var
    desktop = true;
    isRTL = false;
    isInitialized = false;
    toggleExplore = false;
    toggleLinks = false;
    toggleDocs = false;
    //labels
    labels = {
        RESOURCES,
        RELEVANT_LINKS,
        ERROR_MESSAGE,
        ENGAGE,
        EXPLORE,
        DOCUMENTS,
        FIND_ANSWERS,
        DISCOVER_TITLE,
        CHANGE_PREFERENCES
    };
    @track linksData;
    @track trialdata;
    redirecturl = '';
    disableSave = true;
    @track textValue;

    get cardRTL() {
        return this.isRTL ? 'cardRTL' : '';
    }

    connectedCallback() {
        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                this.initializeData();
            })
            .catch((error) => {
                this.showErrorToast(this.labels.ERROR_MESSAGE, error.message, 'error');
            });
    }
    //template toggle
    render() {
        return this.desktop ? resourcesDesktop : resourcesMobile;
    }
    async initializeData() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) {
            this.spinner.show();
        }
        if (communityService.isInitialized()) {
            var recId = communityService.getUrlParameter('id');
            var userMode = communityService.getUserMode();
            console.log('mode-->' + communityService.getUserMode());
            //language support
            let paramLanguage = communityService.getUrlParameter('language');
            let lanCode = communityService.getUrlParameter('lanCode');

            if (
                rtlLanguages.includes(communityService.getLanguage()) ||
                (paramLanguage && rtlLanguages.includes(paramLanguage)) ||
                (lanCode && rtlLanguages.includes(lanCode))
            ) {
                this.isRTL = true;
            }
            let result = await getTrialDetail({ trialId: recId, userMode: userMode }).catch(
                (error) => {
                    this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
                }
            );
            this.linksData = await getLinksData({}).catch((error) => {
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
            });

            this.trialdata = JSON.parse(result);
            //cards toggle logic
            if (communityService.getParticipantState() == 'PARTICIPANT') {
                this.toggleExplore = this.trialdata?.trial?.Video_And_Articles_Are_Available__c;
                this.toggleDocs = this.trialdata?.trial?.Study_Documents_Are_Available__c;
                this.toggleLinks = this.linksData?.linksAvailable;
            } else {
                this.toggleExplore = true;
                this.toggleLinks = true;
            }
            this.isInitialized = true;
        }

        if (this.spinner) {
            this.spinner.hide();
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
    handleChangePreference() {
        this.redirecturl = window.location.origin + basePathName + '/account-settings?changePref';
        const config = {
            type: 'standard__webPage',
            attributes: {
                url: this.redirecturl
            }
        };
        this[NavigationMixin.GenerateUrl](config).then((url) => {
            window.open(url, '_self');
        });
    }
    //refresh toggles on community mode change 
    @api forceRefresh(){
        
        if (communityService.getParticipantState() == 'PARTICIPANT') {
            this.toggleExplore = this.trialdata?.trial?.Video_And_Articles_Are_Available__c;
            this.toggleDocs = this.trialdata?.trial?.Study_Documents_Are_Available__c;
            this.toggleLinks = this.linksData?.linksAvailable;
        } else {
            this.toggleExplore = true;
            this.toggleLinks = true;
        }

    }
}
