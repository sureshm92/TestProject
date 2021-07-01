/**
 * Created by Ranjit Ravindranath 5/20/2021
 */
import { LightningElement, track, api, wire } from 'lwc';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import downloadPdf from '@salesforce/label/c.Download_PDF_pp';
import lastUpdatedText from '@salesforce/label/c.Last_Updated_pp_text';
import ppHeaderLabel from '@salesforce/label/c.Email_Footer_Privacy_Policy'; //Email_Footer_Privacy_Policy
import ppLabel from '@salesforce/label/c.Footer_Link_Privacy_Policy';
import rtlLanguages from '@salesforce/label/c.RTL_Languages'; //BTN_Close
import backBtn from '@salesforce/label/c.BTN_Close';
import headerLabel from '@salesforce/label/c.Privacypolicy_pdf_headers';
import getPrivacyPolicy from '@salesforce/apex/TermsAndConditionsRemote.getTC';
import generatePDF from '@salesforce/apex/TermsAndConditionsRemote.generatePDF';
import LOFI_LOGIN_ICONS from '@salesforce/resourceUrl/Lofi_Login_Icons';
import formFactor from '@salesforce/client/formFactor';

export default class PrivacyPolicyViewer extends LightningElement {
    @track selectedItem = 'reports_recent';
    @track currentContent = 'reports_recent';
    @api isModalOpen;
    @api testing;
    @track isRTL;
    @track ppRichText;
    @track listOfHeaders = [];
    @track paraList = [];
    @api defaultCommunityBoolean;
    @track pdfId;
    @track dwnldUrl;
    @track headerLogo;
    @track headerAndLogoClass;
    @track lastUpdated;
    @track empNames = [];
    @track outerContainerClass = 'outerContainer';
    @track bodyWrapper = 'bodyWrapper';
    @track wrapCss;
    @track logoClass = 'logo';
    @track ppHeaderClass = 'ppHeader';
    @track headerAndLogoClass = 'headerAndLogo';
    @track frmFactor = false;
    @track isLoggedinUser;
    currentPageReference = null;
    closePrivacyPolicyTab = false;
    defaultCommunityBoolean = true;
    lanCode;
    tcId;
    attachment;

    headerLogo = LOFI_LOGIN_ICONS + '/favicon_darkblue_64.svg';
    headerAndLogoClass = 'headerAndLogo slds-size_5-of-6';
    labels = {
        ppLabel,
        ppHeaderLabel,
        lastUpdatedText,
        downloadPdf,
        backBtn
    };

    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        //communityService.preLoginPageRedirection(window.location.href, '');
        window.close();
    }
    goBack() {
        var retString = communityService.getUrlParameter('ret');
        if ((retString !== 'terms-and-conditions' && retString) || retString === '') {
            var retPage = communityService.getRetPage(retString);
            communityService.navigateToPage(retPage);
        } else {
            communityService.navigateToPage('');
        }
    }
    navigateToHomePage(event) {
        var needle = event.currentTarget.dataset.value;
        if (needle.includes("'")) {
            needle = needle.replace("'", '&#39;');
        }
        var newValue = this.ppRichText.replace(needle, needle + '<a data-id="imhere"></a>');
        this.template.querySelector('[data-id="text"]').innerHTML = newValue;

        var myElement = this.template.querySelector('[data-id="imhere"]');
        var headerOffset = 30;
        var elementPosition = myElement.offsetTop; //getBoundingClientRect().top;
        var offsetPosition = elementPosition - headerOffset;
        this.template.querySelector('[data-id="bdyWrpr"]').scrollTop = offsetPosition;
        /*if (myElement != null) myElement.scrollIntoView({
            behavior: "smooth",
            block: "center"
        });*/
    }

    saveAsPdf() {
        generatePDF({
            ppId: this.tcId
        })
            .then(result => {
                location.href = result;
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            });
    }
    renderedCallback() {
        var retString = communityService.getUrlParameter('ret');
        if ((retString !== 'terms-and-conditions' && retString) || retString === '') {
            this.isLoggedinUser = true;
        } else if (!communityService.isDummy()) {
            this.isLoggedinUser = true;
        } else {
            this.isLoggedinUser = false;
        }

        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner.show();
        if (this.ppRichText) {
            this.spinner.hide();
        }
        var myElement = this.template.querySelector('[data-id="text"]');
        this.ppRichText = this.ppRichText.replace(/<ul>/g, '<ul style="list-style: disc;">');
        this.ppRichText = this.ppRichText.replace(/<li>/g, '<li style="margin-left: 2.5%;">');
        myElement.innerHTML = this.ppRichText;
        if (this.lanCode != null) {
            if (rtlLanguages.includes(this.lanCode)) {
                this.isRTL = true;
            }
        }
        if (this.isRTL) {
            this.outerContainerClass = 'outerContainerRTL';
            this.bodyWrapper = 'bodyWrapperRTL';
            this.wrapCss = 'padding-right: 0px;';
            this.logoClass = 'logoRTL';
            this.headerAndLogoClass = 'headerAndLogoRTL';
            this.ppHeaderClass = 'ppHeaderRTL';
        }
        if (formFactor != 'Large') {
            this.frmFactor = true;
            this.headerAndLogoClass = 'headerAndLogo';
            this.template.querySelector('[data-id="vertNav"]').style.display = 'none';
            this.template.querySelector('[data-id="bdyWrpr"]').style.left = '0%';
        } else {
            this.frmFactor = false;
        }
    }
    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                this.lanCode = communityService.getUrlParameter('lanCode')
                    ? communityService.getUrlParameter('lanCode')
                    : null;
                if (rtlLanguages.includes(communityService.getLanguage())) {
                    this.isRTL = true;
                }
                let userDefalutTC = communityService.getUrlParameter('default') ? true : false;
                let HasIQVIAStudiesPI = communityService.getHasIQVIAStudiesPI() ? true : false;
                let ppGetter = getPrivacyPolicy({
                    code: 'PrivacyPolicy',
                    languageCode: communityService.getUrlParameter('language'),
                    useDefaultCommunity: HasIQVIAStudiesPI && userDefalutTC //this.defaultCommunityBoolean
                })
                    .then(result => {
                        let tcData = JSON.parse(result);
                        this.tcId = tcData.tc.Id;
                        this.ppRichText = tcData.tc.T_C_Text__c;
                        this.lastUpdated = tcData.tc.Last_Updated_on__c;
                        var lists = tcData.tc.Policy_Headers__c.split('\r\n');
                        var psrsList;
                        var psrsList1;

                        this.empNames = lists;
                        this.listOfHeaders = this.empNames.map((name, index) => {
                            return {
                                name,
                                sno: index + 1
                            };
                        });
                    })
                    .catch(error => {
                        console.log(JSON.stringify(error));
                    });
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading RR_COMMUNITY_JS',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }
}
