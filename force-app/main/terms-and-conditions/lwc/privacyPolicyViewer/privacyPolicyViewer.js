/**
 * Created by Ranjit Ravindranath 5/20/2021
 */
import { LightningElement, track, api, wire } from 'lwc';
import lwcStyleResource from '@salesforce/resourceUrl/lwcCss';
import downloadPdf from '@salesforce/label/c.Download_PDF_pp';
import lastUpdatedText from '@salesforce/label/c.Last_Updated_pp_text';
import okBtn from '@salesforce/label/c.BTN_OK'; //BTN_OK
import ppHeaderLabel from '@salesforce/label/c.Email_Footer_Privacy_Policy';
import janssenHeaderLabel from '@salesforce/label/c.Footer_Link_Privacy_Policy_Janssen';
import ppLabel from '@salesforce/label/c.Lofi_Login_Footer_Policies';
import headerLabel from '@salesforce/label/c.Privacypolicy_pdf_headers';
import getPrivacyPolicy from '@salesforce/apex/TermsAndConditionsRemote.getTC';
import generatePDF from '@salesforce/apex/TermsAndConditionsRemote.generatePDF';
import formFactor from '@salesforce/client/formFactor';
import LOFI_LOGIN_ICONS from '@salesforce/resourceUrl/Lofi_Login_Icons'; //Lofi_Login_Icons newIqviaLogo

export default class PrivacyPolicyViewer extends LightningElement {
    @api isModalOpen;
    @api isRtl;
    @api isCommunityFooter;
    @api commPref = false;
    @track ppRichText;
    @track listOfHeaders = [];
    @track paraList = [];
    @api defaultCommunityBoolean;
    @track pdfId;
    @track dwnldUrl;
    @track headerLogo;
    @track lastUpdated;
    @track empNames = [];
    @track logoCss;
    @track logoClass;
    @track headerLogoCss;
    @track ppHeaderClass;
    @track dateTextClass;
    @track numberingStyle;
    @track vertNavClass;
    @track vertNavSize;
    @track textboxStyle;
    @track richTextStyle = 'richTextArea slds-size_1-of-1';
    @track closeStyle = 'closeIcon closeIcon1';
    @track frmFactor = false;
    currentPageReference = null;
    closePrivacyPolicyTab = false;
    defaultCommunityBoolean = true;
    tcId;
    attachment;

    headerLogoCss = 'headerAndLogo slds-size_1-of-1';
    logoClass = 'logo';
    ppHeaderClass = 'ppHeader';
    dateTextClass = 'dateText';
    numberingStyle = 'margin-left: -12px;padding: 0px;';
    vertNavClass = 'vertNav';
    vertNavSize = 8;
    textboxStyle = 'padding-right: 0px;word-break: break-word;';
    headerLogo = LOFI_LOGIN_ICONS + '/favicon_darkblue_64.svg';
    labels = {
        ppLabel,
        ppHeaderLabel,
        okBtn,
        lastUpdatedText,
        downloadPdf,
        janssenHeaderLabel
    };

    logoCss = 'width: 72px; height: 72px';

    @api communityTypeName;

    get isJanssen() {
        return this.communityTypeName === 'Janssen';
    }

    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        const closeEvt = new CustomEvent('closePpModal');
        this.dispatchEvent(closeEvt);

        const closeEvtLwc = new CustomEvent('closeprivacypolicy');
        this.dispatchEvent(closeEvtLwc);

        this.isModalOpen = false;
    }
    navigateToHomePage(event) {
        var needle = event.currentTarget.dataset.value;
        if (needle.includes("'")) {
            needle = needle.replace("'", '&#39;');
        }
        var newValue = this.ppRichText.replace(
            needle,
            '<p class="imhere" data-id="imhere"></p>' + needle
        );
        this.template.querySelector('[data-id="text"]').innerHTML = newValue;
        let myElement = this.template.querySelector('[data-id="imhere"]');
        var headerOffset = 75;
        var elementPosition = myElement.offsetTop; //getBoundingClientRect().top;
        var offsetPosition = elementPosition - headerOffset;
        this.template.querySelector('[data-id="scroller"]').scrollTop = offsetPosition;
    }

    saveAsPdf() {
        this.spinner.show();
        generatePDF({
            ppId: this.tcId
        })
            .then((result) => {
                this.spinner.hide();
                location.href = result;
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            });
    }
    handleSelect(event) {
        //console.log('label: ');
    }
    renderedCallback() {
        if (this.isModalOpen) {
            this.spinner = this.template.querySelector('c-web-spinner');
            var myElement = this.template.querySelector('[data-id="text"]');
            this.ppRichText = this.ppRichText.replace(/<ul>/g, '<ul style="list-style: disc;">');
            if (this.isRtl) {
                this.ppRichText = this.ppRichText.replace(
                    /<li>/g,
                    '<li style="margin-right: 5%;">'
                );
            } else {
                this.ppRichText = this.ppRichText.replace(/<li>/g, '<li style="margin-left: 5%;">');
            }
            myElement.innerHTML = this.ppRichText;
            if (this.isRtl) {
                this.headerLogoCss = 'headerAndLogo slds-size_1-of-1';
                this.logoClass = 'logoRTL';
                this.ppHeaderClass = 'ppHeaderRTL';
                this.dateTextClass = 'dateTextRTL';
                this.numberingStyle = 'margin-right: -12px;padding: 0px;';
                this.vertNavClass = 'vertNavRTL';
                this.textboxStyle = 'padding-left: 0px;word-break: break-word;';
                this.richTextStyle = 'richTextAreaRTL slds-size_1-of-1';
                this.closeStyle = 'closeIconRTL closeIcon1RTL';
            }
            if (formFactor != 'Large') {
                this.frmFactor = true;
                this.vertNavSize = 12;
                this.template.querySelector('[data-id="vertNav"]').style.display = 'none';
                this.logoCss = 'width: 72px;height: 50px;vertical-align: bottom;padding-top: 34%;';
            } else {
                this.frmFactor = false;
            }
        }
    }

    connectedCallback() {
        let userDefalutTC = communityService.getUrlParameter('default') ? true : false;
        let HasIQVIAStudiesPI = communityService.getHasIQVIAStudiesPI() ? true : false;
        let useDefaultCommunityTemp = HasIQVIAStudiesPI && userDefalutTC;
        if (this.commPref) {
            useDefaultCommunityTemp = true;
        }
        let ppGetter = getPrivacyPolicy({
            code: 'PrivacyPolicy',
            languageCode: communityService.getUrlParameter('language')
                ? communityService.getUrlParameter('language')
                : null,
            useDefaultCommunity: useDefaultCommunityTemp
        })
            .then((result) => {
                let tcData = JSON.parse(result);
                this.tcId = tcData.tc.Id;
                this.ppRichText = tcData.tc.T_C_Text__c;
                this.lastUpdated = tcData.tc.Last_Updated_on__c;
                var lists = tcData.tc.Policy_Headers__c.split('\r\n');
                var psrsList;
                var psrsList1;

                this.empNames = lists;
                this.listOfHeaders = this.empNames.map((name, index) => {
                    return { name, sno: index + 1 };
                });
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            });
    }
}
