/**
 * Created by Ranjit Ravindranath 5/20/2021
 */
import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import {
    loadScript
} from 'lightning/platformResourceLoader';
import downloadPdf from '@salesforce/label/c.Download_PDF_pp';
import lastUpdatedText from '@salesforce/label/c.Last_Updated_pp_text';
import ppHeaderLabel from '@salesforce/label/c.Email_Footer_Privacy_Policy'; //Email_Footer_Privacy_Policy
import ppLabel from '@salesforce/label/c.Footer_Link_Privacy_Policy';
import headerLabel from '@salesforce/label/c.Privacypolicy_pdf_headers';
import getPrivacyPolicy from '@salesforce/apex/TermsAndConditionsRemote.getTC';
import generatePDF from '@salesforce/apex/TermsAndConditionsRemote.generatePDF';
import LOFI_LOGIN_ICONS from '@salesforce/resourceUrl/Lofi_Login_Icons';


export default class PrivacyPolicyViewer extends LightningElement {
    @track selectedItem = 'reports_recent';
    @track currentContent = 'reports_recent';
    @api isModalOpen;
    @api testing;
    @track ppRichText;
    @track listOfHeaders = [];
    @track paraList = [];
    @api defaultCommunityBoolean;
    @track pdfId;
    @track dwnldUrl;
    @track headerLogo;
    @track lastUpdated;
    @track empNames = [];
    currentPageReference = null;
    closePrivacyPolicyTab = false;
    defaultCommunityBoolean = true;
    tcId;
    attachment;

    headerLogo = LOFI_LOGIN_ICONS + '/favicon_darkblue_64.svg';
    labels = {
        ppLabel,
        ppHeaderLabel,
        lastUpdatedText,
        downloadPdf
    };

    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    navigateToHomePage(event) {
        var needle = event.currentTarget.dataset.value;

        var newValue = this.ppRichText.replace(needle, needle + '<a data-id="imhere"></a>');
        this.template.querySelector('[data-id="text"]').innerHTML = newValue;

        var myElement = this.template.querySelector('[data-id="imhere"]');
        if (myElement != null) myElement.scrollIntoView({
            behavior: "smooth",
            block: "center"
        });
    }


    saveAsPdf() {
        generatePDF({
                ppId: this.tcId
            })
            .then((result) => {
                location.href = result;
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            });
    }
    renderedCallback() {

        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner.show();
        if (this.ppRichText) {
            this.spinner.hide();
        }
        var myElement = this.template.querySelector('[data-id="text"]');
        myElement.innerHTML = this.ppRichText;
    }
    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                let userDefalutTC = communityService.getUrlParameter('default') ? true : false;
                let HasIQVIAStudiesPI = communityService.getHasIQVIAStudiesPI() ? true : false;
                let ppGetter = getPrivacyPolicy({
                        code: 'PrivacyPolicy',
                        languageCode: communityService.getUrlParameter('language'),
                        useDefaultCommunity: HasIQVIAStudiesPI && userDefalutTC //this.defaultCommunityBoolean
                    })
                    .then((result) => {
                        let tcData = JSON.parse(result);
                        this.tcId = tcData.tc.Id;
                        this.ppRichText = tcData.tc.T_C_Text__c;
                        this.lastUpdated = tcData.tc.Last_Updated_on__c;
                        var lists = tcData.tc.Policy_Headers__c.split("\r\n");
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
                    .catch((error) => {
                        console.log(JSON.stringify(error));
                    });
            })
            .catch((error) => {
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