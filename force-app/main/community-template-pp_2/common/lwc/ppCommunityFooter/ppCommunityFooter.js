//Created by Chetna Chauhan
import { api, LightningElement, track } from 'lwc';
import getInitData from '@salesforce/apex/HomePageParticipantRemote.getInitData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import PRIVACY_POLICY from '@salesforce/label/c.Footer_Link_Privacy_Policy';
import TERMS_OF_USE from '@salesforce/label/c.Footer_Link_Terms_Of_Use';
import CPRA_DoNotSell_PatientPortal from '@salesforce/label/c.CPRA_DoNotSell_PatientPortal';
import ABOUT_IQVIA from '@salesforce/label/c.Footer_Link_About_IQVIA';
import COPYRIGHT from '@salesforce/label/c.Footer_T_Copyright';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import CONTACT_SUPPORT from '@salesforce/label/c.PP_Contact_Support';
import Janssen_Community_Template_Name from '@salesforce/label/c.Janssen_Community_Template_Name';

export default class PpCommunityFooter extends LightningElement {
    //String var
    sponser;
    retUrl = '';
    communityType;
    tcLink = '';
    ctpId;
    privacyLabel;
    privacyLink;
    termsOfUseLabel;
    CPRALinkToredirect;

    //Boolean var
    defaultTC = false;
    isGSK = false;
    initialized = false;
    isRTL = false;
    isCPRAAvailable = false;
    showmodal = false;

    studysite;

    labels = {
        PRIVACY_POLICY,
        TERMS_OF_USE,
        ABOUT_IQVIA,
        COPYRIGHT,
        ERROR_MESSAGE,
        CPRA_DoNotSell_PatientPortal,
        CONTACT_SUPPORT,
        Janssen_Community_Template_Name
    };

    connectedCallback() {
        this.initializeData();
    }
    initializeData() {
        let sponsor = communityService.getCurrentSponsorName();
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
        setTimeout(() => {
            getInitData({})
                .then((result) => {
                    let ps = JSON.parse(result);
                    console.log('>>isJanseenAlumniloggedin>>'+ps.isJanseenAlumniloggedin);
                    if (ps.objCPRA) {
                        this.isCPRAAvailable = true;
                        this.CPRALinkToredirect = ps.objCPRA.Link_to_redirect__c;
                    }
                    if (ps.ctp != null) {
                        this.studysite = ps.pe.Study_Site__r;
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
                        if(ps.ctp.CommunityTemplate__c == 'Janssen' && ps.ctp.PPTemplate__c == 'PP 2.0')
                        {
                            this.sponsor = this.labels.Janssen_Community_Template_Name;
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
                        if(ps.isJanseenAlumniloggedin)
                        {
                            this.sponsor = this.labels.Janssen_Community_Template_Name;    
                        }
                    }
                    this.privacyLabel = this.sponsor
                        ? this.sponsor + ' ' + this.labels.PRIVACY_POLICY
                        : this.labels.PRIVACY_POLICY;
                     this.termsOfUseLabel = this.sponsor
                        ? this.sponsor + ' ' + this.labels.TERMS_OF_USE
                        : this.labels.TERMS_OF_USE;
                    this.initialized = true;
                })
                .catch((error) => {
                    this.showErrorToast(this.labels.ERROR_MESSAGE, error.message, 'error');
                });
        }, 100);

        // this.privacyLabel = this.sponsor
        //     ? this.sponsor + ' ' + this.labels.PRIVACY_POLICY
        //     : this.labels.PRIVACY_POLICY;
        // this.termsOfUseLabel = this.sponsor
        //     ? this.sponsor + ' ' + this.labels.TERMS_OF_USE
        //     : this.labels.TERMS_OF_USE;
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
    @api forceRefresh() {
        this.initialized = false;
        this.initializeData();
    }
    get footerClass() {
        return this.isRTL ? 'rrc-footer rtl' : 'rrc-footer';
    }
    //show contact support link for Participant and delegate when switches to Active/Half Alumni Participant view.
    get showContactSupportLink() {
        let currentMode = communityService.getCurrentCommunityMode();
        let isActiveOrHalfAlumniPart =
            currentMode.userMode === 'Participant' &&
            currentMode.participantState !== 'ALUMNI' &&
            currentMode.currentPE != null;
        let isDelInActiveOrHalfAlumniPartView =
            currentMode.userMode === 'Participant' &&
            currentMode.participantState === 'ALUMNI' &&
            currentMode.isDelegate &&
            currentMode.currentPE != null;

        return this.initialized && (isActiveOrHalfAlumniPart || isDelInActiveOrHalfAlumniPartView)
            ? true
            : false;
    }
    openContactSupportModal() {
        this.showmodal = true;
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
    handleModalClose() {
        this.showmodal = false;
    }
}