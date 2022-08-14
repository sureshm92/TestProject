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
    isInitialized = true;

    @api userMode;
    @api isRTL = false;
    @api isMobile = false;
    @api isDelegate = false;

    spinner;

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
            this.isInitialized = true;
            let initData = JSON.parse(returnValue);
            this.spinner.hide();
        })
        .catch((error) => {
            communityService.showToast('error', 'error', 'Failed To read the Data...', 100);
            this.spinner.hide();
        });
    }
}