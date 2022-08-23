import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import getHelpInitData from '@salesforce/apex/HelpController.getHelpInitData';
import PP_SELECT_FAQ from '@salesforce/label/c.PP_Select_FAQ';

export default class PpHelpTopics extends LightningElement {
    @api userMode;
    @api communityTemplate;
    @api isRTL;
    currentContact;
    helpTopicOptions;
    selectedTopicSetting;

    labels = {
        ERROR_MESSAGE,
        PP_SELECT_FAQ
    };

    participantPicklistvalues;
    sitePicklistvalues;
    renderedCallback() {}
    connectedCallback() {
        console.log('userMode from Help', this.userMode);
        console.log('communityTemplate from Help', this.communityTemplate);

        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                this.initializeData();
            })
            .catch((error) => {
                this.showToast(this.labels.ERROR_MESSAGE, error.message, 'error');
            });
    }
    initializeData() {
        getHelpInitData({ userMode: this.userMode, communityName: this.communityTemplate })
            .then((result) => {
                console.log('result from help', result);
                var initData = JSON.parse(result);
                this.currentContact = initData.userContact.currentContact;
                this.helpTopicOptions = initData.helpTopicOptions;
                this.helpTopicSettings = initData.helpTopicSettings;
                this.participantPicklistvalues = initData.participantEnrollOptions;
                this.sitePicklistvalues = initData.siteOptions;
                console.log('current contact', this.currentContact);
                console.log('helpTopicOptions', this.helpTopicOptions);
                console.log('participantPicklistvalues', this.participantPicklistvalues);
                console.log('sitePicklistvalues', this.sitePicklistvalues);
                console.log('helpTopicSettings', this.helpTopicSettings);
            })
            .catch((error) => {
                console.log('errpr', error);
            });
    }
    handleQueryChange(event) {
        //alert(event.detail);
        //alert(this.helpTopicSettings[event.detail].displaySolution);
        this.selectedTopicSetting = this.helpTopicSettings[event.detail];
    }
}
