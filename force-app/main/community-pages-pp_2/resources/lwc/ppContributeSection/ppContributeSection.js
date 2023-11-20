import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CHANGE_PREFERENCES from '@salesforce/label/c.PP_Change_Preferences';
import { NavigationMixin } from 'lightning/navigation';
import PP_Share_Article from '@salesforce/label/c.PP_Share_Article';
import CONTRIBUTE from '@salesforce/label/c.PP_Resources_Contribute';
import URLLINK from '@salesforce/label/c.PP_Resource_URL_Placeholder';
import SUBMIT from '@salesforce/label/c.PP_Submit_Button';
import createArticle from '@salesforce/apex/ResourceRemote.createArticlesSubmitted';
import SUCCESS from '@salesforce/label/c.PP_Resource_Submit';
import FORM_FACTOR from '@salesforce/client/formFactor';
import PASTE_URL from '@salesforce/label/c.PP_Paste_URL';
import PP_URL_Error from '@salesforce/label/c.PP_URL_Error';
import getisRTL from '@salesforce/apex/HomePageParticipantRemote.getIsRTL';

export default class PpContributeSection extends NavigationMixin(LightningElement) {
    labels = {
        CHANGE_PREFERENCES,
        PP_Share_Article,
        CONTRIBUTE,
        URLLINK,
        SUBMIT,
        SUCCESS,
        PASTE_URL,
        PP_URL_Error
    };
    redirecturl = '';
    enableSave = false;
    disableSave = true;
    @track textValue;
    labelPasteURL;
    showSection = true;
    isRTL = false;

    connectedCallback() {
        this.labelPasteURL = FORM_FACTOR !== 'Large' ? PASTE_URL : URLLINK;
        if (communityService.isInitialized()) {
            if (
                communityService.getCurrentCommunityMode().participantState == 'PARTICIPANT' &&
                communityService.getCurrentCommunityMode().isDelegate
            ) {
                this.showSection = false;
            } else {
                this.showSection = true;
            }
        }
        getisRTL()
            .then((data) => {
                this.isRTL = data;
            })
            .catch(function (error) {
                console.error('Error RTL: ' + JSON.stringify(error));
            });
            console.log('the isRTL value is ' + this.isRTL);
    }

    get isMobile() {
        return FORM_FACTOR !== 'Large' ? true : false;
    }

    get inputGridSize() {
        return this.isMobile ? '9' : '10';
    }

    get buttonGridSize() {
        return this.isMobile ? '3' : '2';
    }

    get padSubmitButtonMobile() {
        if(this.isRTL && this.isMobile){
            return 'slds-var-p-top_x-small resource-btn profile-info-btn-mobile submit-button-rtl';
        }
        else{
            return 'slds-var-p-top_x-small resource-btn profile-info-btn-mobile';
        }
    }

    handleChangePreference() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'account-settings'
            },
            state: {
                changePref: null
            }
        });
    }

    handleUrlValidation(event) {
        var inputValue = this.template.querySelector('lightning-input[data-input]').value;
        var urlField = this.template.querySelector('lightning-input[data-input]');
        var validURLregex =
            /^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:\?#[\]@!\$&\(\)\*\+,;=.]+$/;
        var validregex =
            /^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/gm;
        if (inputValue) {
            if (validURLregex.test(inputValue) || validregex.test(inputValue)) {
                urlField.setCustomValidity(' ');
                this.disableSave = false;
            } else {
                this.disableSave = true;
            }
        } else {
            urlField.setCustomValidity(' ');
            this.disableSave = true;
        }
        urlField.reportValidity();
    }

    handleUrlValidationBlur(event) {
        var inputValue = this.template.querySelector('lightning-input[data-input]').value;
        var urlField = this.template.querySelector('lightning-input[data-input]');
        var validURLregex =
            /^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:\?#[\]@!\$&\(\)\*\+,;=.]+$/;
        var validregex =
            /^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/gm;
        if (inputValue) {
            if (validURLregex.test(inputValue) || validregex.test(inputValue)) {
                urlField.setCustomValidity(' ');
                this.disableSave = false;
            } else {
                urlField.setCustomValidity(this.labels.PP_URL_Error);
                this.disableSave = true;
            }
        } else {
            urlField.setCustomValidity(' ');
            this.disableSave = true;
        }
        urlField.reportValidity();
    }

    handleCreateArticles(event) {
        this.disableSave = true;
        var inputurl = this.template.querySelector('lightning-input[data-input]').value;
        if (inputurl) {
            createArticle({
                url: inputurl
            })
                .then((result) => {
                    this.showErrorToast('', this.labels.SUCCESS, 'success');
                    this.disableSave = true;
                    this.textValue = '';
                })
                .catch((error) => {
                    this.showErrorToast('Error occured', error.message, 'error');
                });
        } else {
            var urlField = this.template.querySelector('lightning-input[data-input]');
            this.disableSave = true;
            urlField.reportValidity();
        }
        this.template.querySelector('lightning-input[data-name="urlvalue"]').value = null;
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
    get saveButtonClass() {
        return this.disableSave ? 'task-save-btn-opacity' : 'task-save-btn';
    }
}
