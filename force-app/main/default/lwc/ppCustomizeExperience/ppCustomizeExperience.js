import { LightningElement, api, track } from 'lwc';

import rr_community_icons from '@salesforce/resourceUrl/rr_community_icons';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import communityPPTheme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';

import PP_Condition_of_Interest_title from '@salesforce/label/c.PP_Condition_of_Interest_title';
import PP_Customize_Exp_Description from '@salesforce/label/c.PP_Customize_Exp_Description';
import PP_Customize_search_text from '@salesforce/label/c.PP_Customize_search_text';
import BTN_Save from '@salesforce/label/c.BTN_Save';
import Task_Subject_Select_COI_PP from '@salesforce/label/c.Task_Subject_Select_COI_PP';
import BACK from '@salesforce/label/c.Back';
import PP_Profile_Update_Success from '@salesforce/label/c.PP_Profile_Update_Success';

import getInitData from '@salesforce/apex/SearchConditionsOfInterestRemote.getConditionOfInterest';
import searchConditionOfInterest from '@salesforce/apex/SearchConditionsOfInterestRemote.searchConditionOfInterest';
import deleteCOIMethod from '@salesforce/apex/SearchConditionsOfInterestRemote.deleteCOI';
import upsertListCoi from '@salesforce/apex/SearchConditionsOfInterestRemote.upsertListCoi';
import createSubscribeConnection from '@salesforce/apex/SearchConditionsOfInterestRemote.createSubscribeConnection';

export default class PpCustomizeExperience extends LightningElement {
    @api userMode;
    @api isRTL = false;
    @api isMobile = false;
    @api isDelegate = false;

    @track conditionOfInterestList = [];
    @track conditionsOfInterestTemp = []; // list of selected values
    @track displayedItems = [];
    @track searchInput;
    @track selectedValues = [];

    spinner;
    isInitialized = false;
    isValueChanged =  false;

    label = {
        PP_Condition_of_Interest_title,
        PP_Customize_Exp_Description,
        PP_Customize_search_text,
        BTN_Save,
        BACK,
        PP_Profile_Update_Success,
        Task_Subject_Select_COI_PP
    };

    itemshow = false;
    showmenu = false;
    bypass;

    closeIcon = pp_icons + '/' + 'close-circle.svg' + '#' + 'close-circle-icon';

    // Component padding
    get headerPanelClass() {
        return this.isMobile ? 'header-panel-mobile' : 'header-panel';
    }

    get cardRTL() {
        return this.isRTL ? 'cardRTL' : '';
    }

    get eyeIcon() {
        return 'icon-eye';
    }

    get iconEye() {
        return 'cursor';
    }

    get showSearchOutput() {
        return this.showmenu && this.itemshow ? true : false;
    }

    get iconPosition() {
        return this.isRTL ? 'badge-rtl' : 'badge';
    }

    get pillMargin() {
        return this.isRTL ? 'pill-margin-rtl mb-15' : 'pill-margin mb-15';
    }

    get iconChevron() {
        return 'icon-chevron-left';
    }

    get isSaveDisabled() {
        if (
            this.isValueChanged
        ) {
            return false;
        } else {
            return true;
        }
    }
    
    renderedCallback() {
        if (this.isInitialized == true) {
            this.spinner = this.template.querySelector('c-web-spinner');
        }
    }
    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                Promise.all([loadStyle(this, communityPPTheme)])
                    .then(() => {
                        this.spinner = this.template.querySelector('c-web-spinner');
                        this.spinner ? this.spinner.show() : '';
                        this.initializeData();
                    })
                    .catch((error) => {
                        console.log(error.body.message);
                    });
            })
            .catch((error) => {
                communityService.showToast('', 'error', error.message, 100);
            });
    }

    initializeData(){        
        getInitData()
            .then((returnValue) => {
                console.log('success', returnValue);
                this.isInitialized = true;
                this.conditionOfInterestList = JSON.parse(JSON.stringify(returnValue));
                let copy = JSON.parse(JSON.stringify(this.conditionOfInterestList));
                this.conditionsOfInterestTemp = copy;
                //console.log(this.conditionsOfInterestTemp[0].coi.Id);
                window.setTimeout(() => {
                    this.callhelper(coival);                    
                }, 500);
                this.spinner.hide();
            })
            .catch((error) => {
                console.log('error');
                communityService.showToast('', 'error', error.message, 100);
                this.spinner.hide();
            });
    }

    bulkSearch(event) {
        let coival = event.detail.value;
        this.searchInput = coival;
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
                communityService.showToast('', 'error', error.message, 100);
            });
    }

    handleRemove(event) {
        event.preventDefault();
        let removedPill = event.currentTarget.getAttribute('data-name');
        //alert(removedPill);
        this.handleClearPill(removedPill);
        this.isValueChanged = JSON.stringify(this.displayedItems) == JSON.stringify(this.conditionOfInterestList) ? false : true;
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

    handleChange(event) {
        let taList = this.conditionsOfInterestTemp;
        let inputValue = event.target.name;
		let check =this.conditionOfInterestList;
        var capturedCheckboxName = inputValue;
        var selectedCheckBoxes = this.selectedValues;
        let uncheckedValues = [];
        let finalSelectedvalues = [];
        let copy = JSON.parse(JSON.stringify(this.conditionOfInterestList));
			if(check.length <5){
					this.isValueChanged = false;
			}
        if (!event.target.checked) {
            for (let i = 0; i < taList.length; i++) {
                if (
                    taList[i].coi.Therapeutic_Area__r.Name ===
                    capturedCheckboxName.coi.Therapeutic_Area__r.Name
                ) {
                    uncheckedValues.push(capturedCheckboxName.coi.Therapeutic_Area__r.Name);
                }
            }
            if (uncheckedValues) {
                for (let j = 0; j < taList.length; j++) {
                    if (uncheckedValues.includes(taList[j].coi.Therapeutic_Area__r.Name)) {
                    } else {
                        finalSelectedvalues.push(taList[j]);
                    }
                }
                taList = finalSelectedvalues;
		     }				
        } else if (taList.length < 5) {
            selectedCheckBoxes.push(capturedCheckboxName);
            taList.push(capturedCheckboxName);
        } else {
            event.target.checked = false;				
        }
        this.conditionsOfInterestTemp = taList;
        this.isValueChanged =  JSON.stringify(this.conditionsOfInterestTemp) == JSON.stringify(copy)? false : true ;
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

    saveElement() {
        const deleteCOI = this.conditionOfInterestList;
        this.conditionsOfInterestTemp.sort(function (a, b) {
            return a.Condition_Of_Interest_Order__c - b.Condition_Of_Interest_Order__c;
        });

        let deleteCoiId = [];
        for (var i = deleteCOI.length - 1; i >= 0; i--) {
            for (var j = 0; j < this.conditionsOfInterestTemp.length; j++) {
                if (
                    deleteCOI[i] &&
                    deleteCOI[i].coi.Id == this.conditionsOfInterestTemp[j].coi.Id
                ) {
                    deleteCOI.splice(i, 1);
                }
            }
        }
        if (deleteCOI) {
            deleteCoiId = deleteCOI.map(function (e) {
                return e.coi.Id;
            });
        }
        if (deleteCoiId) {
            deleteCOIMethod({
                coiIds: deleteCoiId
            });
        }
        let copy = JSON.parse(JSON.stringify(this.conditionsOfInterestTemp));
        this.conditionsOfInterest = copy;
        let arr = [];
        this.searchInput = '';
        this.saveCOIs();
        communityService.showToast('', 'success', this.label.PP_Profile_Update_Success, 100);
        //communityService.navigateToPage('account-settings?changePref');
        this.isValueChanged = false;
    }
    saveCOIs() {
        let coiWrapperList = this.conditionsOfInterest;
        let coiList = [];
        var bool = false;
        for (let i = 0; i < coiWrapperList.length; i++) {
            let coi = coiWrapperList[i].coi;
            coi.Condition_Of_Interest_Order__c = i + 1;
            coiList.push(coi);
            bool = true;
        }
        if (bool) {
            upsertListCoi({
                cois: coiList
            })
                .then((returnValue) => {
                    let coiSaveWrapperList = [];

                    returnValue.forEach(function (e) {
                        let coiSave = {};
                        coiSave.isSelected = true;
                        coiSave.coi = e;
                        coiSaveWrapperList.push(coiSave);
                    });
                    var tempt = this.displayedItems;
                    if (coiSaveWrapperList.size > 0) {
                        this.displayedItems = coiSaveWrapperList;
                        this.showPills = true;
                    }
                    this.showmenu = false;
                    this.conditionOfInterestList = coiSaveWrapperList;
                    this.spinner.hide();
                })
                .catch((error) => {
                    console.log('error');
                    communityService.showToast('', 'error', error.message, 100);
                    this.spinner.hide();
                });
            createSubscribeConnection({
                cois: coiList
            });
        }
    }
}
