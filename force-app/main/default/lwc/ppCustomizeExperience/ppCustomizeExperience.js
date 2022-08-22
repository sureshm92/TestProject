import { LightningElement, api, track } from 'lwc';

import rr_community_icons from '@salesforce/resourceUrl/rr_community_icons';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import communityPPTheme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';

import PP_Condition_of_Interest_title from '@salesforce/label/c.PP_Condition_of_Interest_title';
import PP_Customize_Exp_Description from '@salesforce/label/c.PP_Customize_Exp_Description';
import PP_Customize_search_text from '@salesforce/label/c.PP_Customize_search_text';
import BTN_Save from '@salesforce/label/c.BTN_Save';
import BACK from '@salesforce/label/c.Back';

import getInitData from '@salesforce/apex/SearchConditionsOfInterestRemote.getConditionOfInterest';
import searchConditionOfInterest from '@salesforce/apex/SearchConditionsOfInterestRemote.searchConditionOfInterest';

export default class PpCustomizeExperience extends LightningElement {

    @api userMode;
    @api isRTL = false;
    @api isMobile = false;
    @api isDelegate = false;

    @track conditionOfInterestList = [];
    @track conditionsOfInterestTemp = []; // list of selected values
    @track displayedItems = [];

    spinner;
    isInitialized = false;

    label = {
        PP_Condition_of_Interest_title,
        PP_Customize_Exp_Description,
        PP_Customize_search_text,
        BTN_Save,
        BACK
    };

    itemshow = false;
    showmenu = false;
    bypass;

    // Component padding
    get headerPanelClass() {
        return this.isMobile ? 'header-panel-mobile' : 'header-panel';
    }

    get cardRTL() {
        return this.isRTL ? 'cardRTL' : '';
    }

    get eyeIcon(){
        return "icon-eye";
    }

    get iconEye(){
        return "cursor";
    }

    get showSearchOutput(){
        return (this.showmenu && this.itemshow) ? true : false;
    }

    get iconPosition(){
        return this.isRTL ? 'badge-rtl' : 'badge';
    }

    get pillMargin(){
        return this.isRTL ? 'pill-margin-rtl mb-15' : 'pill-margin mb-15';
    }

    get iconChevron() {
        return 'icon-chevron-left';
    }

    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                Promise.all([loadStyle(this, communityPPTheme)])
                    .then(() => {
                        this.spinner = this.template.querySelector('c-web-spinner');
                        this.spinner ? this.spinner.show() : '';
                    })
                    .catch((error) => {
                        console.log(error.body.message);
                    });
            })
            .catch((error) => {
                communityService.showToast('error', 'error', error.message, 100);
            });

        getInitData()
            .then((returnValue) => {
                console.log('success', returnValue);
                this.isInitialized = true;
                this.conditionOfInterestList = returnValue;
                let copy = JSON.parse(JSON.stringify(this.conditionOfInterestList));
                this.conditionsOfInterestTemp = copy;
                console.log(this.conditionsOfInterestTemp[0].coi.Id);
                window.setTimeout(() => {
                    this.callhelper(coival);
                }, 500);
                this.spinner.hide();
            })
            .catch((error) => {
                console.log('error');
                communityService.showToast('error', 'error', error.message, 100);
                this.spinner.hide();
            });
    }

    bulkSearch(event) {
        let coival = event.detail.value;
        if (coival) {
            this.itemshow = true;
        } else {
            this.itemshow = false;
        }
        this.showmenu = true;
        if (this.bypass) {
            return;
        } else {
            this.bypass = true;
            window.setTimeout(() => {
                this.callhelper(coival);
            }, 500);
        }
    }

    callhelper(coival) {
        //alert('called');
        this.bypass = false;
        this.spinner.show();
        searchConditionOfInterest({
            nameTA: coival
        })
            .then((returnValue) => {
                let coiList = [];
                coiList = this.conditionsOfInterestTemp;
                let coiWrappers = returnValue;
                var unselecteditems = [];
                coiWrappers.forEach(function (coiWrapper) {
                    if (
                        coiList.some(function (coiEl) {
                            return (
                                coiEl.coi.Therapeutic_Area__c === coiWrapper.coi.Therapeutic_Area__c
                            );
                        })
                    ) {
                        coiWrapper.isSelected = true;
                    }
                });

                if (coiWrappers) {
                    for (let i = 0; i < coiWrappers.length; i++) {
                        if (!coiWrappers[i].isSelected) {
                            unselecteditems.push(coiWrappers[i]);
                        }
                    }
                }
                this.spinner.hide();
                this.displayedItems = unselecteditems;
            })
            .catch((error) => {
                communityService.showToast('error', 'error', error.message, 100);
            });
    }

    handleRemove(event) {
        event.preventDefault();
        let removedPill = event.currentTarget.getAttribute("data-name");
        alert(removedPill);
        this.handleClearPill(removedPill);
    }

    handleClearPill(removedPill) {
        let pills = this.conditionsOfInterestTemp;
        let selectedPills = [];
        for (var i = 0; i < pills.length; i++) {
            if (removedPill === pills[i].coi.Therapeutic_Area__r.Name) {
                selectedPills.push(pills[i]);
                pills.splice(i, 1);
                break;
            }
        }
        this.conditionsOfInterestTemp = pills;
        this.displayedItems = pills;
        this.showmenu = false;
    }

    handleChange(){
        alert("TODO: need to write the code");
    }

    showMenuBar(event) {
        if (event.target.dataset.header) {
            this.dispatchEvent(
                new CustomEvent('shownavmenubar', {
                    detail: {
                        header: event.target.dataset.header
                    }
                })
            );
            this.isInitialized = false;
        }
    }
}