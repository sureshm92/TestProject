import { LightningElement, api, track } from 'lwc';
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

export default class PpHelp extends LightningElement {
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
                getHelpInitData({ userMode: this.userMode, communityName: this.communityTemplate })
                    .then((result) => {
                        console.log('result from help', result);
                        var initData = JSON.parse(result);
                        this.currentContact = initData.userContact.currentContact;
                        this.helpTopicOptions = initData.helpTopicOptions;
                        this.helpTopicSettings = initData.helpTopicSettings;
                        this.participantPicklistvalues = initData.participantEnrollOptions;
                        this.sitePicklistvalues = initData.siteOptions;
                        this.quickReference = initData.quickReference;
                        console.log('current contact', this.currentContact);
                        console.log('helpTopicOptions', this.helpTopicOptions);
                        console.log('participantPicklistvalues', this.participantPicklistvalues);
                        console.log('sitePicklistvalues', this.sitePicklistvalues);
                        console.log('helpTopicSettings', this.helpTopicSettings);
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
    openQuickReference() {
        /**alert('openQuickReference');
        var webViewer = pdfjs_dist + '/web/viewer.html';
        console.log('webViewer', webViewer);
        console.log('participant_user_guide', participant_user_guide);
        window.open(webViewer + '?file=' + participant_user_guide, '_blank');
        /**window.open(
            webViewer +
                '?file=' +
                $A.get('$Resource.' + quickReference) +
                '&fileName=' +
                $A.get('$Label.c.Quick_Reference_Card'),
            '_blank'
        ); **/
        var webViewer = pdfjs_dist + '/web/viewer.html';
        console.log('webViewer', webViewer);
        // console.log('participant_user_guide', participant_user_guide);

        getResourceURL({ resourceName: 'RP_user_guide' }).then((result) => {
            console.log('ur;ll;;', result);
            window.open(webViewer + '?file=' + result, '_blank');
        });
    }
}
