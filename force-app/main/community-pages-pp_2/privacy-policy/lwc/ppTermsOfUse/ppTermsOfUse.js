import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import formFactor from '@salesforce/client/formFactor';
import TU_HEADER from '@salesforce/label/c.CPD_Terms_of_Use';
import LAST_UPDATED from '@salesforce/label/c.Last_Updated_On';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import CHAPTER from '@salesforce/label/c.Chapter';
import getPortalTcData from '@salesforce/apex/TermsAndConditionsRemote.getPortalTcData';
import getTrialTcData from '@salesforce/apex/TermsAndConditionsRemote.getTrialTcData';
import PP_Theme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';
import Core_Theme from '@salesforce/resourceUrl/Community_CSS_Core';
import Proxima_Nova from '@salesforce/resourceUrl/proximanova';

export default class PpTermsOfUse extends LightningElement {
    isRTL = false;
    isPortalTC = true;
    isInitialised = false;
    options = [];
    lanCode;
    tcId;
    lastUpdated;
    ppRichText;
    @track currentHeaderLabel = '';
    spinner;

    labels = {
        TU_HEADER,
        ERROR_MESSAGE,
        LAST_UPDATED,
        CHAPTER
    };

    connectedCallback() {
        Promise.all([
            loadScript(this, RR_COMMUNITY_JS),
            loadStyle(this, PP_Theme),
            loadStyle(this, Core_Theme),
            loadStyle(this, Proxima_Nova + '/proximanova.css')
        ])
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

        let paramLanguage = communityService.getUrlParameter('language');
        let lanCode = communityService.getUrlParameter('lanCode');
        let cTPId = communityService.getUrlParameter('id');
        if (cTPId) {
            this.isPortalTC = false;
        }

        if (
            rtlLanguages.includes(communityService.getLanguage()) ||
            (paramLanguage && rtlLanguages.includes(paramLanguage)) ||
            (lanCode && rtlLanguages.includes(lanCode))
        ) {
            this.isRTL = true;
        }

        if (this.isPortalTC) {
            let userDefalutTC = communityService.getUrlParameter('default') ? true : false;
            let HasIQVIAStudiesPI = communityService.getHasIQVIAStudiesPI() ? true : false;
            getPortalTcData({ useDefaultCommunity: userDefalutTC && HasIQVIAStudiesPI })
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
                    this.initializeTCData(tcData);
                })
                .catch((error) => {
                    this.showErrorToast(this.labels.ERROR_MESSAGE, error.message, 'error');
                });
        } else {
            getTrialTcData({ ctpId: cTPId })
                .then((result) => {
                    let tcData = JSON.parse(result);
                    this.initializeTCData(tcData);
                })
                .catch((error) => {
                    this.showErrorToast(this.labels.ERROR_MESSAGE, error.message, 'error');
                });
        }
    }

    get isMobile() {
        return formFactor !== 'Large' ? true : false;
    }

    get headerDesktopClass() {
        return this.isRTL
            ? 'slds-col slds-size_3-of-12 tc-text slds-p-left_large tc-header rtl'
            : 'slds-col slds-size_3-of-12 tc-text tc-header';
    }

    get headerScrollerClass() {
        return this.isRTL ? 'header-scroller rtl' : 'header-scroller';
    }

    get richContentClass() {
        return this.isRTL ? 'rich-content rtl' : 'rich-content';
    }

    get titleContentClass() {
        return this.isMobile
            ? 'slds-hide'
            : 'slds-grid slds-grid_vertical-align-start title-content';
    }

    get lastUpdatedDesktopClass() {
        return this.isMobile
            ? 'slds-hide'
            : 'slds-col slds-size_8-of-12 last-updated slds-p-right_large';
    }

    get privacyHeader() {
        return this.isRTL ? 'privacy-header rtl' : 'privacy-header';
    }

    get lastUpdatedDateClass() {
        return this.isRTL
            ? 'slds-col slds-size_1-of-1 slds-p-top_xx-small rtl'
            : 'slds-col slds-size_1-of-1 slds-p-top_xx-small';
    }

    get comboboxClass() {
        return this.isRTL
            ? 'slds-col slds-size_1-of-1 slds-p-around_medium slds-p-top_none header-combobox slds-text-align_right'
            : 'slds-col slds-size_1-of-1 slds-p-around_medium slds-p-top_none header-combobox';
    }

    get chapterClass() {
        return this.isRTL
            ? 'slds-p-bottom_x-small sub-header slds-p-top_medium rtl'
            : 'slds-p-bottom_x-small sub-header slds-p-top_medium';
    }

    get dropdownClass() {
        return this.isRTL ? 'dropdown rtl' : 'dropdown';
    }

    get tcContainerClass() {
        return this.isRTL
            ? 'tc-container slds-p-top_medium slds-p-left_medium rtl'
            : 'tc-container slds-p-top_medium slds-p-left_medium';
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

    initializeTCData(tcData) {
        this.tcId = tcData.tc.Id;
        this.tcRichText = tcData.tc.T_C_Text__c;
        this.lastUpdated = tcData.tc.Last_Updated_on__c;
        let headerLists = tcData.tc.Policy_Headers__c.split('\r\n');
        let headerOptions = [];
        headerLists.map((name, index) => {
            let headerOption = {
                label: name,
                value: name
            };
            headerOptions = [...headerOptions, headerOption];
        });
        this.options = headerOptions;
        this.currentHeaderLabel = this.options[0].label;

        if (this.tcRichText) {
            this.tcRichText = this.tcRichText.replace(/<ul>/g, '<ul style="list-style: disc;">');
            this.tcRichText = this.tcRichText.replace(
                '<strong><u>' + this.currentHeaderLabel + '</u></strong>',
                '<a data-id="startheader"></a>' +
                    '<strong><u>' +
                    this.currentHeaderLabel +
                    '</u></strong>'
            );
            if (this.isRTL) {
                this.tcRichText = this.tcRichText.replace(
                    /<li style="text-align: right;">/g,
                    '<li style="text-align: right;margin-right: 5%;">'
                );
                this.tcRichText = this.tcRichText.replace(
                    /<li>/g,
                    '<li style="margin-right: 5%;">'
                );
            } else {
                this.tcRichText = this.tcRichText.replace(/<li>/g, '<li style="margin-left: 5%;">');
            }
            let tcContent = '';
            if (this.isMobile) {
                tcContent = this.template.querySelector('[data-id="tcRichText"]');
            } else {
                tcContent = this.template.querySelector('[data-id="tcRichTextD"]');
            }
            if (tcContent) {
                tcContent.innerHTML = this.tcRichText;
            }
            if (this.spinner) {
                this.spinner.hide();
            }
        }
    }

    navigateToSelectedHeader(event) {
        let selectedHeader = event.currentTarget.dataset.header;
        console.log(
            '🚀 ~ file: ppTermsOfUse.js ~ line 232 ~ PpTermsOfUse ~ navigateToSelectedHeader ~ selectedHeader',
            selectedHeader
        );
        if (selectedHeader) {
            if (selectedHeader.includes("'")) {
                selectedHeader = selectedHeader.replace("'", '&#39;');
            }

            let newValue = this.tcRichText.replace(
                '<strong><u>' + selectedHeader + '</u></strong>',
                '<strong><u>' + selectedHeader + '</u></strong>' + '<a data-id="currentheader"></a>'
            );
            if (this.isMobile) {
                this.template.querySelector('[data-id="tcRichText"]').innerHTML = newValue;
            } else {
                this.template.querySelector('[data-id="tcRichTextD"]').innerHTML = newValue;
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
                ? (this.template.querySelector('[data-id="tcRichText"]').scrollTop = offsetPosition)
                : (this.template.querySelector('[data-id="tcRichTextD"]').scrollTop =
                      offsetPosition);
            this.currentHeaderLabel = event.currentTarget.dataset.label;
        }
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
