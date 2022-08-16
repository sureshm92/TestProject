import { LightningElement, api } from 'lwc';

import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import communityPPTheme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';

import PG_Login_H_Language_Options from '@salesforce/label/c.PG_Login_H_Language_Options';
import PG_Login_H_Language_Description from '@salesforce/label/c.PG_Login_H_Language_Description';
import PG_AS_F_Preferred_Language from '@salesforce/label/c.PG_AS_F_Preferred_Language';
import PG_AS_F_Preferred_Language_Help_Text from '@salesforce/label/c.PG_AS_F_Preferred_Language_Help_Text';
import PG_AS_F_2nd_Choice_Language_Help_Text from '@salesforce/label/c.PG_AS_F_2nd_Choice_Language_Help_Text';
import PG_AS_F_3rd_Choice_Language from '@salesforce/label/c.PG_AS_F_3rd_Choice_Language';
import PG_AS_F_Locale_For_Date_Format from '@salesforce/label/c.PG_AS_F_Locale_For_Date_Format';
import PG_Login_H_Residence_Region from '@salesforce/label/c.PG_Login_H_Residence_Region';
import PE_Country from '@salesforce/label/c.PE_Country';
import PE_State from '@salesforce/label/c.PE_State';
import PG_AS_F_Zip_Postal_Code from '@salesforce/label/c.PG_AS_F_Zip_Postal_Code';


import getInitData from '@salesforce/apex/PP_LanguageSwitcherRemote.getInitData';

export default class PpLanguageSwitcher extends LightningElement {
    
    @api userMode;
    @api isRTL = false;
    @api isMobile = false;
    @api isDelegate = false;
    @api personWrapper;
    @api contactSectionData;

    countriesLVList;
    statesByCountryMap;
    personSnapshot;
    isStateChanged

    spinner;

    languages;
    optionalLanguages;
    locales;
    timezones;

    isInitialized = false;
    languageKey;
    previousValue;
    secondLangKey;
    thirdLangKey;
    localeKey
    timezoneKey;
    prevTimeZoneKey;
    prevLocaleKey;    

    label = {
        PG_Login_H_Language_Options,
        PG_Login_H_Language_Description,
        PG_AS_F_Preferred_Language,
        PG_AS_F_Preferred_Language_Help_Text,
        PG_AS_F_2nd_Choice_Language_Help_Text,
        PG_AS_F_3rd_Choice_Language,
        PG_AS_F_Locale_For_Date_Format,
        PG_Login_H_Residence_Region,
        PE_Country,
        PE_State,
        PG_AS_F_Zip_Postal_Code
    }

    get headerPanelClass() {
        return this.isMobile ? 'header-panel-mobile' : 'header-panel';
    }

    get cardRTL() {
        return this.isRTL ? 'cardRTL' : '';
    }

    get reNewMargin(){
        return this.isRTL ? 'slds-form-element margin-lr-15Plus' : 'slds-form-element margin-lr-15';
    }
    
    connectedCallback(){
        loadScript(this, RR_COMMUNITY_JS)
        .then(() => {
            Promise.all([loadStyle(this, communityPPTheme)])
                .then(() => {  
                    this.spinner = this.template.querySelector('c-web-spinner');
                    this.spinner ? this.spinner.show() : "";
                    this.initializeData();
                })
                .catch((error) => {
                    console.log(error.body.message);
                });
        })
        .catch((error) => {
            communityService.showToast('error', 'error', error.message, 100);
        });

       
    }

    initializeData(){
        getInitData()
        .then((returnValue) => {
            this.isInitialized = true;
            let initData = JSON.parse(returnValue);

            let sectionData = JSON.parse(JSON.stringify(this.contactSectionData));

            this.countriesLVList = sectionData.countriesLVList;
            this.statesByCountryMap = sectionData.statesByCountryMap;
          
            this.setPersonSnapshot();
            this.personWrapper = JSON.parse(JSON.stringify(this.personWrapper));

            this.previousCC = this.personWrapper.mailingCC;
            this.statesLVList = sectionData.statesByCountryMap[this.personWrapper.mailingCC];

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
            if(initData.secondLangKey == null){this.secondLangKey = 'none';}
            if(initData.thirdLangKey == null){this.thirdLangKey = 'none';}
            
            this.spinner.hide();
            
        })
        .catch((error) => {
            communityService.showToast('error', 'error', 'Failed To read the hjhhk...', 100);
            this.spinner.hide();
        });
    }

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
}