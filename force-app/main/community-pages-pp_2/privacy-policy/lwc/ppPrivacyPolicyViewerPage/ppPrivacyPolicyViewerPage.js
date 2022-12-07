import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import getPrivacyPolicy from '@salesforce/apex/TermsAndConditionsRemote.getPPTC';
import generatePDF from '@salesforce/apex/TermsAndConditionsRemote.generatePDF';
import formFactor from '@salesforce/client/formFactor';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import PP_HEADER from '@salesforce/label/c.Email_Footer_Privacy_Policy';
import LAST_UPDATED from '@salesforce/label/c.Last_Updated_On';
import CHAPTER from '@salesforce/label/c.Chapter';
import DOWNLOAD_AS_PDF from '@salesforce/label/c.Download_PP_as_PDF';
import { CurrentPageReference } from 'lightning/navigation';
import PP_Theme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';
import Core_Theme from '@salesforce/resourceUrl/Community_CSS_Core';
import Proxima_Nova from '@salesforce/resourceUrl/proximanova';

export default class PpPrivacyPolicyViewerPage extends LightningElement {
    lanCode;
    tcId;
    lastUpdated;
    isLoggedinUser;
    @api isRTL;
    @api ctpId;
    currentPageReference = null;
    urlStateParameters = null;
    studyId = null;
    ppRichText;
    @track listOfHeaders = [];
    empNames = [];
    options = [];
    @track currentHeader = '';
    @track currentHeaderLabel = '';
    labels = {
        PP_HEADER,
        LAST_UPDATED,
        CHAPTER,
        DOWNLOAD_AS_PDF
    };

    connectedCallback() {
        Promise.all([
            loadScript(this, RR_COMMUNITY_JS),
            loadStyle(this, PP_Theme),
            loadStyle(this, Core_Theme),
            loadStyle(this, Proxima_Nova + '/proximanova.css')
        ])
            .then(() => {
                this.loadPrivacyPolicy();
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Loading RR_COMMUNITY_JS',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.ctpId = this.urlStateParameters.id || null;
    }

    loadPrivacyPolicy() {
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner.show();

        let userDefalutTC = communityService.getUrlParameter('default') ? true : false;
        let HasIQVIAStudiesPI = communityService.getHasIQVIAStudiesPI() ? true : false;

        getPrivacyPolicy({
            code: 'PrivacyPolicy',
            languageCode: communityService.getUrlParameter('language'),
            useDefaultCommunity: HasIQVIAStudiesPI && userDefalutTC,
            ctId: this.ctpId
        })
            .then((result) => {
                let tcData = JSON.parse(result);
                this.lanCode = communityService.getUrlParameter('lanCode')
                    ? communityService.getUrlParameter('lanCode')
                    : null;
                if (
                    rtlLanguages.includes(communityService.getLanguage()) ||
                    rtlLanguages.includes(this.lanCode)
                ) {
                    this.isRTL = true;
                }
                this.tcId = tcData.tc.Id;
                this.ppRichText = tcData.tc.T_C_Text__c;
                this.lastUpdated = tcData.tc.Last_Updated_on__c;
                let headerLists = tcData.tc.Policy_Headers__c.split('\r\n');
                this.empNames = headerLists;
                let headerOptions = [];
                this.empNames.map((name, index) => {
                    let headerLabel = index + 1 + '. ' + name;
                    let headerOption = {
                        label: headerLabel,
                        value: name
                    };
                    headerOptions = [...headerOptions, headerOption];
                });
                this.options = headerOptions;
                this.currentHeader = this.options[0].value;
                this.currentHeaderLabel = this.options[0].label;

                if (this.ppRichText) {
                    this.ppRichText = this.ppRichText.replace(
                        /<ul>/g,
                        '<ul style="list-style: disc;">'
                    );

                    this.ppRichText = this.ppRichText.replace(
                        '<strong><u>' + this.currentHeader + '</u></strong>',
                        '<a data-id="startheader"></a>' +
                            '<strong><u>' +
                            this.currentHeader +
                            '</u></strong>'
                    );
                    if (this.isRTL) {
                        this.ppRichText = this.ppRichText.replace(
                            /<li style="text-align: right;">/g,
                            '<li style="text-align: right;margin-right: 5%;">'
                        );
                        this.ppRichText = this.ppRichText.replace(
                            /<li>/g,
                            '<li style="margin-right: 5%;">'
                        );
                    } else {
                        this.ppRichText = this.ppRichText.replace(
                            /<li>/g,
                            '<li style="margin-left: 5%;">'
                        );
                    }
                    let ppContent = '';
                    if (this.isMobile) {
                        ppContent = this.template.querySelector('[data-id="ppRichText"]');
                    } else {
                        ppContent = this.template.querySelector('[data-id="ppRichTextD"]');
                    }
                    if (ppContent) {
                        ppContent.innerHTML = this.ppRichText;
                        this.spinner.hide();
                    }
                }
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            });
    }

    get isMobile() {
        return formFactor !== 'Large' ? true : false;
    }

    get headerContainer() {
        return this.isMobile
            ? 'header-container slds-grid slds-wrap slds-p-left_medium slds-p-right_medium'
            : 'slds-grid slds-gutters slds-p-around_medium';
    }

    get headerDesktopClass() {
        return this.isRTL
            ? 'slds-col slds-size_3-of-12 tc-text tc-text-rtl slds-p-right_large rtl'
            : 'slds-col slds-size_3-of-12 tc-text';
    }

    get headerScrollerClass() {
        return this.isRTL ? 'header-scroller rtl' : 'header-scroller';
    }

    get richContentClass() {
        return this.isRTL ? 'rich-content rtl' : 'rich-content';
    }

    get headerLabel() {
        return this.isMobile
            ? 'slds-col slds-size_1-of-1'
            : 'slds-col slds-size_1-of-3 slds-align_absolute-center';
    }

    get privacyHeader() {
        return this.isRTL ? 'privacy-header rtl' : 'privacy-header';
    }

    get ppAcceptedDate() {
        return this.isMobile
            ? 'slds-col slds-size_1-of-1 slds-p-top_medium'
            : 'slds-col slds-size_2-of-3 slds-align_absolute-center slds-hide';
    }

    get lastUpdatedDateClass() {
        return this.isRTL
            ? 'slds-col slds-size_1-of-1 slds-p-top_xx-small rtl'
            : 'slds-col slds-size_1-of-1 slds-p-top_xx-small';
    }

    get chapterClass() {
        return this.isRTL
            ? 'slds-p-top_small slds-p-bottom_x-small sub-header rtl'
            : 'slds-p-top_small slds-p-bottom_x-small sub-header';
    }

    get dropdownClass() {
        return this.isRTL ? 'dropdown rtl' : 'dropdown';
    }

    get acceptedDateLabel() {
        return this.isMobile ? 'sub-header' : 'sub-header slds-text-align_right';
    }

    get comboboxClass() {
        return this.isRTL
            ? 'slds-col slds-size_1-of-1 slds-p-around_medium slds-p-top_none header-combobox slds-text-align_right'
            : 'slds-col slds-size_1-of-1 slds-p-around_medium slds-p-top_none header-combobox';
    }

    get headerComboboxClass() {
        return this.isRTL ? 'pp-header-combobox rtl' : 'pp-header-combobox';
    }

    get ppBodyContentClass() {
        return this.isMobile
            ? 'pp-body-content slds-m-left_medium slds-m-right_medium'
            : 'pp-body-content slds-m-left_medium slds-m-right_medium';
    }

    get ppContentClass() {
        return this.isRTL
            ? 'pp-content slds-p-top_medium slds-p-left_medium rtl'
            : 'pp-content slds-p-top_medium slds-p-left_medium';
    }

    navigateToSelectedHeader(event) {
        let selectedHeader = event.currentTarget.dataset.header;
        if (selectedHeader) {
            if (selectedHeader.includes("'")) {
                selectedHeader = selectedHeader.replace("'", '&#39;');
            }
            let newValue = this.ppRichText.replace(
                '<strong><u>' + selectedHeader + '</u></strong>',
                '<strong><u>' + selectedHeader + '</u></strong>' + '<a data-id="currentheader"></a>'
            );
            if (this.isMobile) {
                this.template.querySelector('[data-id="ppRichText"]').innerHTML = newValue;
            } else {
                this.template.querySelector('[data-id="ppRichTextD"]').innerHTML = newValue;
                this.template.querySelector('.slds-is-active')
                    ? this.template
                          .querySelector('.slds-is-active')
                          .classList.remove('slds-is-active')
                    : '';
                let headerLabel = event.currentTarget.dataset.header;
                this.template
                    .querySelector(`[data-header="${headerLabel}"]`)
                    .classList.add('slds-is-active');
            }

            let myElement = this.template.querySelector('[data-id="currentheader"]');
            let startElement = this.template.querySelector('[data-id="startheader"]');

            let headerOffset = startElement ? startElement.offsetTop : 90;
            let elementPosition = myElement.offsetTop;

            let offsetPosition = elementPosition - headerOffset;
            this.isMobile
                ? (this.template.querySelector('[data-id="ppRichText"]').scrollTop = offsetPosition)
                : (this.template.querySelector('[data-id="ppRichTextD"]').scrollTop =
                      offsetPosition);
            this.currentHeaderLabel = event.currentTarget.dataset.label;
        }
    }

    downloadPPAsPDF() {
        generatePDF({
            ppId: this.tcId
        })
            .then((result) => {
                location.href = result;
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Unable to Download Privacy Policy PDF',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }

    toggleElement() {
        let ddMenu = this.template.querySelector('[data-id="dropdown-menu"]');
        ddMenu.classList.toggle('active');
    }

    removeElementFocus() {
        let ddMenu = this.template.querySelector('[data-id="dropdown-menu"]');
        ddMenu.classList.remove('active');
    }
}
