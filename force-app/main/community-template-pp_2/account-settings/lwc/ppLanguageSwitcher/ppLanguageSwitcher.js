import { LightningElement, api } from 'lwc';
import PG_Login_H_Language_Options from '@salesforce/label/c.PG_Login_H_Language_Options';
import PG_Login_H_Language_Description from '@salesforce/label/c.PG_Login_H_Language_Description';
import PG_AS_F_Preferred_Language from '@salesforce/label/c.PG_AS_F_Preferred_Language';
import PP_AS_F_Preferred_Language_Help_Text from '@salesforce/label/c.PP_AS_F_Preferred_Language_Help_Text';
import PP_AS_F_2nd_Choice_Language_Help_Text from '@salesforce/label/c.PP_AS_F_2nd_Choice_Language_Help_Text';
import PP_AS_F_3rd_Choice_Language_Help_Text from '@salesforce/label/c.PP_AS_F_3rd_Choice_Language_Help_Text';
import PG_AS_F_Locale_For_Date_Format from '@salesforce/label/c.PG_AS_F_Locale_For_Date_Format';
import PG_Login_H_Residence_Region from '@salesforce/label/c.PG_Login_H_Residence_Region';
import PE_Country from '@salesforce/label/c.PE_Country';
import PE_State from '@salesforce/label/c.PE_State';
import PP_AS_F_Zip_Postal_Code from '@salesforce/label/c.PP_AS_F_Zip_Postal_Code';
import PG_AC_Select from '@salesforce/label/c.PG_AC_Select';
import PP_Profile_Update_Success from '@salesforce/label/c.PP_Profile_Update_Success';
import PP_Preferred_Time_Zone from '@salesforce/label/c.PP_Preferred_Time_Zone';
import PP_Time_Zone_and_Location from '@salesforce/label/c.PP_Time_Zone_and_Location';
import PP_Third_Language from '@salesforce/label/c.PP_Third_Language';
import PP_Second_Language from '@salesforce/label/c.PP_Second_Language';
import PP_Language_and_Location from '@salesforce/label/c.PP_Language_and_Location';
import BTN_Save from '@salesforce/label/c.BTN_Save';
import BACK from '@salesforce/label/c.Back';

import getInitData from '@salesforce/apex/PP_LanguageSwitcherRemote.getInitData';
import changeLanguage from '@salesforce/apex/PP_LanguageSwitcherRemote.changeLanguage';

export default class PpLanguageSwitcher extends LightningElement {
    @api userMode;
    @api isRTL = false;
    @api isMobile = false;
    @api isDelegate = false;
    @api personWrapper;
    @api contactSectionData;

    saveButton;

    countriesLVList;
    statesByCountryMap;
    personSnapshot;
    isStateChanged;
    previousCC;
    statesLVList;

    spinner;

    selectedSecondLang;
    selectedLocale;
    selectedCountry;
    selectedState;
    selectedZip;

    languages;
    optionalLanguages;
    locales;
    timezones;

    isInitialized = false;
    languageKey;
    previousValue;
    secondLangKey;
    thirdLangKey;
    localeKey;
    timezoneKey;
    prevTimeZoneKey;
    prevLocaleKey;

    stateComboboxEle;

    flagChangeInForm = false;

    label = {
        PG_Login_H_Language_Options,
        PP_Language_and_Location,
        PG_Login_H_Language_Description,
        PG_AS_F_Preferred_Language,
        PP_AS_F_Preferred_Language_Help_Text,
        BTN_Save,
        PP_AS_F_2nd_Choice_Language_Help_Text,
        PP_AS_F_3rd_Choice_Language_Help_Text,
        PG_AS_F_Locale_For_Date_Format,
        PG_Login_H_Residence_Region,
        PE_Country,
        PE_State,
        PP_AS_F_Zip_Postal_Code,
        PG_AC_Select,
        PP_Third_Language,
        PP_Second_Language,
        PP_Preferred_Time_Zone,
        PP_Time_Zone_and_Location,
        PP_Profile_Update_Success,
        BACK
    };

    get headerPanelClass() {
        return this.isMobile ? 'header-panel-mobile' : 'header-panel';
    }

    get cardRTL() {
        return this.isRTL ? 'cardRTL pp-tooltip' : 'pp-tooltip';
    }

    get reNewMargin() {
        return this.isRTL ? 'slds-form-element margin-lr-15Plus' : 'slds-form-element margin-lr-15';
    }

    get iconChevron() {
        return 'icon-chevron-left';
    }

    renderedCallback() {
        if (!this.isInitialized) {
            this.spinner = this.template.querySelector('c-web-spinner');
            this.spinner ? this.spinner.show() : '';
            this.initializeData();
        }
    }

    initializeData() {
        getInitData()
            .then((returnValue) => {
                let initData = JSON.parse(returnValue);

                let sectionData = JSON.parse(JSON.stringify(this.contactSectionData));

                this.countriesLVList = sectionData.countriesLVList;
                this.statesByCountryMap = sectionData.statesByCountryMap;

                this.setPersonSnapshot();
                this.personWrapper = JSON.parse(JSON.stringify(this.personWrapper));

                this.previousCC = this.personWrapper.mailingCC;
                this.statesLVList = sectionData.statesByCountryMap[this.personWrapper.mailingCC];
                this.selectedZip = this.personWrapper.zip;

                this.selectedCountry = this.personWrapper.mailingCC;
                this.selectedState = this.personWrapper.mailingSC;

                this.languages = initData.languages;
                this.optionalLanguages = initData.optionalLanguages;
                this.locales = initData.locales;
                this.timezones = initData.timezones;

                // Remove null key for optionalLanguages : TEMP FIX - need fix from backend: Second Language
                initData.optionalLanguages[0].value = 'none';

                this.languageKey = initData.languageKey;
                this.previousValue = initData.languageKey;
                this.secondLangKey = initData.secondLangKey;
                this.thirdLangKey = initData.thirdLangKey;
                this.localeKey = initData.localeKey;
                this.timezoneKey = initData.timezoneKey;
                this.prevTimeZoneKey = initData.timezoneKey;
                this.prevLocaleKey = initData.localeKey;

                // Change null key for optionalLanguages currentSelectedOption: TEMP FIX - need fix from backend: Second Language and third language
                if (initData.secondLangKey == null) {
                    this.secondLangKey = 'none';
                }
                if (initData.thirdLangKey == null) {
                    this.thirdLangKey = 'none';
                }
                this.isInitialized = true;
                if (this.statesLVList && this.statesLVList.length == 0) {
                    this.stateComboboxEle = this.template.querySelector(
                        '[data-id="lang-state-ele"]'
                    );
                    this.disableStateCombobox();
                }
                this.spinner.hide();
            })
            .catch((error) => {
                communityService.showToast('', 'error', 'Failed To read the Data...', 100);
                this.spinner.hide();
            });
    }

    disableStateCombobox() {
        this.statesLVList.length == 0
            ? (this.stateComboboxEle.disabled = true)
            : (this.stateComboboxEle.disabled = false);
    }

    doCheckFieldsValidity(event) {
        this.flagChangeInForm = true;
        this.personWrapper.mailingCC = event.target.value;
        this.selectedCountry = this.personWrapper.mailingCC;
        this.selectedState = '';
        if (this.personWrapper.mailingCC !== this.previousCC) {
            let states = this.statesByCountryMap[this.personWrapper.mailingCC];
            this.statesLVList = states;
            this.previousCC = this.personWrapper.mailingCC;
            if (this.statesLVList.length == 0) {
                this.personWrapper.mailingSC = null;
            } else {
                this.personWrapper.mailingSC = this.statesLVList[0].value;
                this.selectedState = this.statesLVList[0].value;
            }
        }

        this.isInputValid();
        // Disable state field if this.statesLVList is blank
        let stateComboboxEle = this.template.querySelector('[data-id="lang-state-ele"]');
        this.statesLVList.length == 0
            ? (stateComboboxEle.disabled = true)
            : (stateComboboxEle.disabled = false);
    }

    doPrefLangChange(event) {
        this.languageKey = event.target.value;
        this.flagChangeInForm = true;
        this.isInputValid();
    }

    doSecondLangChange(event) {
        this.flagChangeInForm = true;
        this.secondLangKey = event.target.value;
        this.isInputValid();
    }

    doThirdLangChange(event) {
        this.flagChangeInForm = true;
        this.thirdLangKey = event.target.value;
        this.isInputValid();
    }

    doPrefTimeZoneChange(event) {
        this.flagChangeInForm = true;
        this.timezoneKey = event.target.value;
        this.isInputValid();
    }

    doLocaleChange(event) {
        this.flagChangeInForm = true;
        this.localeKey = event.target.value;
        this.isInputValid();
    }

    doStateChange(event) {
        this.flagChangeInForm = true;
        this.selectedState = event.target.value;
        this.isInputValid();
    }

    doZipChange(event) {
        this.flagChangeInForm = true;
        this.selectedZip = event.target.value;
        this.isInputValid();
    }

    // Helper Functions
    setPersonSnapshot() {
        let personWrapper = JSON.parse(JSON.stringify(this.personWrapper));
        if (!personWrapper.mailingCC) personWrapper.mailingCC = '';
        if (!personWrapper.mailingSC) personWrapper.mailingSC = '';
        if (!personWrapper.mailingCountry) personWrapper.mailingCountry = '';
        if (!personWrapper.mailingStreet) personWrapper.mailingStreet = '';
        if (!personWrapper.mailingCity) personWrapper.mailingCity = '';
        if (!personWrapper.mailingState) personWrapper.mailingState = '';
        if (!personWrapper.zip) personWrapper.zip = '';

        this.personSnapshot = JSON.stringify(personWrapper);
        this.isStateChanged = false;
    }

    doChangeLanguage() {
        if (!this.isInitialized) return;

        let languageKey = this.languageKey; //this.languageKey;
        let previousLangaugeKey = this.previousValue;
        let countryName, stateName, zipcode;
        let isUserModeParticipant = false;
        if (this.userMode == 'Participant') {
            countryName = this.selectedCountry;
            stateName = this.selectedState;
            zipcode = this.selectedZip;
            isUserModeParticipant = true;
        }

        let secondLangKey = this.secondLangKey;
        let thirdLangKey = this.thirdLangKey;

        secondLangKey == 'none' ? (secondLangKey = '') : '';
        thirdLangKey == 'none' ? (thirdLangKey = '') : '';
        let localeKey = this.localeKey;
        let timezoneKey = this.timezoneKey;
        this.spinner.show();

        if (this.userMode == 'Participant') {
            let tempcountries = this.countriesLVList;
            let value = this.selectedCountry; // component.find('pFieldCountry').get('v.value');
            var index;
            if (tempcountries != null && tempcountries != undefined) {
                for (var i = 0; i < tempcountries.length; ++i) {
                    if (tempcountries[i].value == value) {
                        index = i;
                        break;
                    }
                }
                console.log(index);
                countryName = index >= 0 ? tempcountries[index].label : null;
            }
            let tempstates = this.statesLVList;
            let statevalue = this.selectedState; //component.find('pFieldState').get('v.value');
            var stateindex;
            if (tempstates != null && tempstates != undefined) {
                for (var i = 0; i < tempstates.length; ++i) {
                    if (tempstates[i].value == statevalue) {
                        stateindex = i;
                        break;
                    }
                }
                stateName = stateindex >= 0 ? tempstates[stateindex].label : null;
            }
        }

        changeLanguage({
            languageKey: languageKey,
            secondLangKey: secondLangKey,
            thirdLangKey: thirdLangKey,
            localeKey: localeKey,
            timezoneKey: timezoneKey,
            countryName: countryName,
            stateName: stateName,
            zipcode: zipcode,
            isUserModeParticipant: isUserModeParticipant
        })
            .then((returnValue) => {
                this.spinner.hide();
                communityService.showToast(
                    '',
                    'success',
                    this.label.PP_Profile_Update_Success,
                    100
                );
                communityService.navigateToPage('account-settings?lang-loc');
                if (
                    previousLangaugeKey != languageKey ||
                    localeKey != this.prevLocaleKey ||
                    timezoneKey != this.prevTimeZoneKey
                ) {
                    communityService.reloadPage();
                }
            })
            .catch((error) => {
                communityService.showToast('', 'error', 'Failed To save the Data...', 100);
                this.spinner.hide();
            });
    }

    isInputValid() {
        let languageKey = this.languageKey;
        let localeKey = this.localeKey;
        let timezoneKey = this.timezoneKey;
        let country = this.selectedCountry;
        let statevalue = this.selectedState;
        let statesLVList = this.statesLVList;

        if (
            languageKey == null ||
            languageKey == undefined ||
            languageKey.length == 0 ||
            localeKey == null ||
            localeKey == undefined ||
            localeKey.length == 0 ||
            timezoneKey == null ||
            timezoneKey == undefined ||
            timezoneKey.length == 0 ||
            country == null ||
            country == undefined ||
            country.length == 0 ||
            (statesLVList.length != 0 && statevalue == '') ||
            !this.flagChangeInForm
        ) {
            this.disableSaveButton();
        } else {
            this.enableSaveButton();
        }
    }

    disableSaveButton() {
        this.saveButton != null ? (this.saveButton.disabled = true) : '';
    }

    enableSaveButton() {
        this.saveButton != null ? this.saveButton.removeAttribute('disabled') : '';
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
