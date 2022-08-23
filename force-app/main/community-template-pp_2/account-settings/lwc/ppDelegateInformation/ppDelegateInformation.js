import { LightningElement, api, track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import communityPPTheme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';

import DELEGATE_INFO from '@salesforce/label/c.PP_AS_Delegate_Header';
import WITHDRAW_INFO from '@salesforce/label/c.PP_Withdraw_Delegate';
import WITHDRAW_BUTTON from '@salesforce/label/c.PG_PST_L_Delegates_Withdraw_From_Delegate';
import REMOVE_DELEGATE from '@salesforce/label/c.PP_AS_Delegate_Remove';
import DELEGATE_REMOVED_MESSAGE from '@salesforce/label/c.PP_AS_Delegate_Removed';

import getPatientFirstName from '@salesforce/apex/PatientDelegateRemote.getYourPatientFirstName';
import getPatientLastName from '@salesforce/apex/PatientDelegateRemote.getYourPatientLastName';
import withdrawDelegate from '@salesforce/apex/PatientDelegateRemote.withdrawDelegate';
import getLogOutUrl from '@salesforce/apex/PatientDelegateRemote.getLogOutUrl';
export default class PpDelegateInformation extends LightningElement {
    isInitialized = false;
    removeDelegate = false;
    spinner;
    delegateModal;
    @api userMode = '';
    @api delegateContact;
    @api isMobile = false;
    @api isRTL = false;
    patientFirstName = '';
    patientLastName = '';

    labels = {
        DELEGATE_INFO,
        REMOVE_DELEGATE,
        DELEGATE_REMOVED_MESSAGE,
        WITHDRAW_INFO,
        WITHDRAW_BUTTON
    };

    delegateInformation = '';
    withdrawInformation = '';

    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                Promise.all([loadStyle(this, communityPPTheme)])
                    .then(() => {
                        this.spinner = this.template.querySelector('c-web-spinner');
                        this.spinner.show();
                        this.initializeData();
                    })
                    .catch((error) => {
                        console.log(error.message);
                    });
            })
            .catch((error) => {
                this.showToast(this.labels.ERROR_MESSAGE, error.message, 'error');
            });
    }

    initializeData() {
        getPatientFirstName()
            .then((result) => {
                this.patientFirstName = result;
                getPatientLastName()
                    .then((resultLName) => {
                        this.patientLastName = resultLName;
                        this.initializeLabels();
                        this.isInitialized = true;
                        this.spinner.hide();
                    })
                    .catch((err) => {
                        this.showToast(err.message, err.message, 'error');
                    });
            })
            .catch((error) => {
                this.showToast(error.message, error.message, 'error');
            });
    }

    /**Add Styles to Dynamic Labels */
    initializeLabels() {
        this.delegateInformation = this.labels.DELEGATE_INFO.replace(
            '##PatientFirstName',
            this.patientFirstName
        );
        this.delegateInformation = this.delegateInformation.replace(
            '##PatientLastName',
            this.patientLastName
        );
        this.withdrawInformation = this.labels.WITHDRAW_INFO.replace(
            '##PatientFirstName',
            this.patientFirstName
        );
    }

    /**CSS Getters START*/

    get bodyContainerClass() {
        return this.isMobile
            ? 'slds-grid slds-wrap slds-gutters slds-m-horizontal_none slds-p-around_medium del-info-container'
            : 'slds-grid slds-wrap slds-gutters slds-m-horizontal_none slds-p-around_medium del-info-container desktop-width';
    }

    get withdrawButtonContainerClass() {
        return this.isMobile
            ? 'slds-form-element slds-col slds-size_7-of-7 slds-p-vertical_x-small slds-p-horizontal_none'
            : 'slds-form-element slds-col slds-size_4-of-7 slds-p-vertical_x-small slds-p-horizontal_none';
    }

    get withdrawButtonClass() {
        return this.isMobile
            ? 'slds-button slds-button_brand withdraw-button slds-p-vertical_xxxx-small full-width'
            : 'slds-button slds-button_brand withdraw-button slds-p-vertical_xxxx-small';
    }

    /**CSS Getters END*/

    handleWithdrawModal() {
        this.removeDelegate = true;
    }

    handleRemoveDelegate() {
        this.spinner.show();
        withdrawDelegate({ contactId: this.delegateContact.Id, removeHimself: true })
            .then((result) => {
                this.showToast(this.labels.DELEGATE_REMOVED_MESSAGE, '', 'success');
                setTimeout(() => {
                    this.handleLogout();
                }, 2000);
            })
            .catch((error) => {
                this.showToast(error.message, error.message, 'error');
            });
    }

    handleLogout() {
        getLogOutUrl()
            .then((result) => {
                this.spinner.hide();
                window.location.replace(result + '/secur/logout.jsp');
            })
            .catch((error) => {
                this.showToast(error.message, error.message, 'error');
            });
    }

    handleModalClose() {
        this.removeDelegate = false;
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

    disconnectedCallback() {
        this.isInitialized = false;
    }
}
