//Created by Chetna Chauhan
import { api, LightningElement } from 'lwc';
import getInitData from '@salesforce/apex/HomePageParticipantRemote.getInitData';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import PRIVACY_POLICY from '@salesforce/label/c.Footer_Link_Privacy_Policy';
import TERMS_OF_USE from '@salesforce/label/c.Footer_Link_Terms_Of_Use';
import ABOUT_IQVIA from '@salesforce/label/c.Footer_Link_About_IQVIA';
import COPYRIGHT from '@salesforce/label/c.Footer_T_Copyright';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
export default class PpCommunityFooter extends LightningElement {
    //String var
    sponser;
    retUrl = '';
    communityType;
    @api tcLink = '';
    @api ctpId;
    @api privacyLabel;
    @api privacyLink;
    @api termsOfUseLabel;

    //Boolean var
    defaultTC = false;
    isGSK = false;
    initialized = false;
    isRTL = false;

    labels = {
        PRIVACY_POLICY,
        TERMS_OF_USE,
        ABOUT_IQVIA,
        COPYRIGHT,
        ERROR_MESSAGE
    };

    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                this.initializeData();
            })
            .catch((error) => {
                this.showErrorToast(this.labels.ERROR_MESSAGE, error.message, 'error');
            });
    }
    initializeData() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) {
            this.spinner.show();
        }

        let sponsor = communityService.getCurrentSponsorName();

        //let isGsk = communityService.getCommunityURLPathPrefix().includes("/gsk");
        /*if (communityService.getCurrentCommunityName() == 'GSK Community') {
            this.isGsk = true;
        } else if (
            communityService.getCurrentCommunityName() == 'Janssen Community' ||
            communityService.getCommunityName().includes('Janssen')
        ) {
            this.communityType = 'Janssen';
        }*/
        let currentPage = communityService.getPageName();
        let hasIQVIAStudiesPI = communityService.getHasIQVIAStudiesPI();
        const pagesWithSharedPrivacyPolicy = communityService.getPagesWithSharedPrivacyPolicy();

        this.defaultTC = pagesWithSharedPrivacyPolicy.has(currentPage) && hasIQVIAStudiesPI;
        this.sponsor = sponsor;
        this.retUrl = communityService.createRetString();
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
        //getting ctp terms of use and privacy policy if exists
        getInitData({})
            .then((result) => {
                let ps = JSON.parse(result);
                //console.log(JSON.parse(result));
                this.initialized = true;
                if (ps.ctp != null) {
                    if (ps.ctp.Terms_And_Conditions_ID__c != null) {
                        this.ctpId = ps.ctp.Id;
                        var tclink =
                            'terms-and-conditions?id=' +
                            ps.ctp.Id +
                            '&ret=' +
                            communityService.createRetString();

                        this.tcLink = tclink;
                    } else {
                        this.tcLink =
                            'terms-and-conditions?ret=' +
                            this.retUrl +
                            (this.defaultTC ? '&amp;' + 'default=true' : '');
                    }

                    if (ps.ctp.Privacy_Policy_ID__c != null) {
                        this.privacyLink =
                            'privacy-policy?id=' +
                            ps.ctp.Id +
                            '&ret=' +
                            communityService.createRetString();
                    } else {
                        this.privacyLink = this.defaultTC
                            ? 'privacy-policy?ret=' + this.retUrl + '&amp;' + 'default=true'
                            : 'privacy-policy?ret=' + this.retUrl;
                    }
                } else {
                    //if not patient portal then
                    this.tcLink =
                        'terms-and-conditions?ret=' +
                        this.retUrl +
                        (this.defaultTC ? '&amp;' + 'default=true' : '');
                    this.privacyLink = this.defaultTC
                        ? 'privacy-policy?ret=' + this.retUrl + '&amp;' + 'default=true'
                        : 'privacy-policy?ret=' + this.retUrl;
                }
            })
            .catch((error) => {
                this.showErrorToast(this.labels.ERROR_MESSAGE, error.message, 'error');
            });
        if (this.spinner) {
            this.spinner.hide();
        }

        this.privacyLabel = this.sponser
            ? this.sponser + ' ' + this.labels.PRIVACY_POLICY
            : this.labels.PRIVACY_POLICY;
        this.termsOfUseLabel = this.sponsor
            ? this.sponser + ' ' + this.labels.TERMS_OF_USE
            : this.labels.TERMS_OF_USE;
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
    get footerClass() {
        return this.isRTL ? 'rrc-footer rtl' : 'rrc-footer';
    }
}
