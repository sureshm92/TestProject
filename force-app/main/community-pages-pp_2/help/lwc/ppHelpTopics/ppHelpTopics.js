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
    @api currentContact;
    @api helpTopicOptions;
    @api selectedTopicSetting;
    @api helpTopicSettings;

    labels = {
        ERROR_MESSAGE,
        PP_SELECT_FAQ
    };
    @api participantPicklistvalues;
    @api sitePicklistvalues;
    renderedCallback() {}
    connectedCallback() {
        console.log('userMode from Help', this.userMode);
        console.log('communityTemplate from Help', this.communityTemplate);
    }

    handleQueryChange(event) {
        //alert(event.detail);
        //alert(this.helpTopicSettings[event.detail].displaySolution);
        this.selectedTopicSetting = this.helpTopicSettings[event.detail];
    }
}
