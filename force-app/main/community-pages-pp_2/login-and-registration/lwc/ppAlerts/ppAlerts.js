import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import CONTINUE from '@salesforce/label/c.Continue';

import getAlerts from '@salesforce/apex/AlertsRemote.getAlerts';
import setAlertViewed from '@salesforce/apex/AlertsRemote.setAlertViewed';

export default class PpAlerts extends LightningElement {
    alerts;
    currentAlert;
    currentAlertIndex = 0;
    userMode;

    spinner;
    isInitialized = false;
    isRTL = false;

    labels = { CONTINUE };

    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                if (!this.isInitialized) {
                    this.initializeData();
                }
            })
            .catch((error) => {
                this.showToast(error.message, error.message, 'error');
            });
    }

    get currentAlertData() {
        return this.currentAlert && this.currentAlert.title ? true : false;
    }

    get isAlertChanged() {
        return this.currentAlert &&
            (this.currentAlert.code == 'Welcome_To_The_PH_PP' ||
                this.currentAlert.code == 'Welcome_To_The_PH_Delegate_PP')
            ? false
            : true;
    }

    initializeData() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) {
            this.spinner.show();
        }

        if (rtlLanguages.includes(communityService.getLanguage())) {
            this.isRTL = true;
        }
        this.userMode = communityService.getUserMode();
        getAlerts({ userMode: this.userMode })
            .then((result) => {
                this.alerts = JSON.parse(result);
                if (this.alerts.length > 0) {
                    this.currentAlert = this.alerts[this.currentAlertIndex];
                }
                this.isInitialized = true;
                this.spinner.hide();
            })
            .catch((error) => {
                this.showToast(error.message, error.message, 'error');
            });
    }

    handleContinue() {
        if (this.currentAlert) {
            setAlertViewed({ alertId: this.currentAlert.id })
                .then((result) => {})
                .catch((error) => {
                    this.showToast(error.message, error.message, 'error');
                });
        }
        this.currentAlertIndex++;
        if (this.alerts.length >= this.currentAlertIndex) {
            this.currentAlert = this.alerts[this.currentAlertIndex];
        } else {
            this.isInitialized = false;
        }
    }

    @api forceRefresh() {
        this.isInitialized = false;
        this.initializeData();
    }

    showToast(titleText, messageText, variantType) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: titleText,
                message: '',
                variant: variantType
            })
        );
    }
}
