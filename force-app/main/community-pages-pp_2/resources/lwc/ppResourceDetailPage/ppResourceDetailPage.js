import { LightningElement } from 'lwc';
import setResourceAction from '@salesforce/apex/ResourceRemote.setResourceAction';
import getResourceDetails from '@salesforce/apex/ResourcesDetailRemote.getResourcesById';
import getCtpName from '@salesforce/apex/ParticipantStateRemote.getInitData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import VERSION from '@salesforce/label/c.Version_date';
import Back_To_Resources from '@salesforce/label/c.Link_Back_To_Resources';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
export default class PpResourceDetailPage extends NavigationMixin(LightningElement) {
    userTimezone = TIME_ZONE;
    isInitialized = false;
    resourceType;
    resourceId;
    resourceTitle;
    resUploadDate;
    resourceLink;
    isFavourite = false;
    resourceSummary;
    isVoted = false;
    isDocument = false;
    langCode;
    documentLink;
    studyTitle = '';
    state;
    label = {
        VERSION,
        Back_To_Resources
    };
    isMultimedia = false;
    isArticleVideo = false;
    spinner;

    connectedCallback() {
        //get resource parameters from url
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        this.resourceId = urlParams.get('resourceid');
        this.resourceType = urlParams.get('resourcetype');
        this.state = urlParams.get('state');
        if (this.resourceType == 'Study_Document') {
            this.langCode = urlParams.get('lang');
            this.isDocument = true;
        }

        this.initializeData();
    }

    get showSpinner() {
        return !this.isInitialized;
    }

    async initializeData() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) {
            this.spinner.show();
        }

        //get clicked resource details
        getResourceDetails({
            resourceId: this.resourceId,
            resourceType: this.resourceType
        })
            .then((result) => {
                let resourceData = result.wrappers[0].resource;
                this.resUploadDate = resourceData.Version_Date__c;
                this.resourceTitle = resourceData.Title__c;
                this.resourceSummary = resourceData.Body__c;
                this.isArticleVideo =
                    this.resourceType == 'Article' || this.resourceType == 'Video';
                this.resourceLink =
                    this.resourceType == 'Article' ? resourceData.Image__c : resourceData.Video__c;
                if (this.resourceType == 'Multimedia') {
                    this.resourceLink = resourceData.Multimedia__c;
                    this.resourceType = 'Video';
                    this.isMultimedia = true;
                }
                this.isFavourite = result.wrappers[0].isFavorite;
                this.isVoted = result.wrappers[0].isVoted;

                //get study Title
                if (
                    this.state != 'ALUMNI' &&
                    (resourceData.Content_Class__c == 'Study-Specific' || this.isDocument)
                ) {
                    getCtpName({})
                        .then((result) => {
                            let data = JSON.parse(result);
                            this.studyTitle =
                                data.pi?.pe?.Clinical_Trial_Profile__r?.Study_Code_Name__c;
                            if (this.isDocument) {
                                this.handleDocumentLoad();
                            }
                            this.isInitialized = true;
                        })
                        .catch((error) => {
                            this.showErrorToast(this.labels.ERROR_MESSAGE, error.message, 'error');
                        });
                }
            })
            .catch((error) => {
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
            })
            .finally(() => {
                if (this.spinner) {
                    this.spinner.hide();
                }
            });
    }

    handleDocumentLoad() {
        let subDomain = communityService.getSubDomain();
        if (FORM_FACTOR == 'Large') {
            if (subDomain) {
                this.documentLink =
                    subDomain +
                    '/apex/RRPDFViewer?resourceId=' +
                    this.resourceId +
                    '&language=' +
                    this.langCode;
            }
        } else {
            let updates = true;
            this.documentLink =
                'mobile-pdf-viewer?resId=' +
                this.resourceId +
                '&lang=' +
                this.langCode +
                '&updates=' +
                updates;
        }
    }

    handleBackClick() {
        let pageLink;
        let subDomain = communityService.getSubDomain();
        if (FORM_FACTOR == 'Large') {
            pageLink = window.location.origin + subDomain + '/s/resources';
        } else {
            let resType;
            if (this.isMultimedia) {
                resType = 'engage';
            } else if (this.resourceType == 'Study_Document') {
                resType = 'documents';
            } else if (this.resourceType == 'Video' || this.resourceType == 'Article') {
                resType = 'explore';
            }
            pageLink = window.location.origin + subDomain + '/s/resources?resType=' + resType;
        }
        const config = {
            type: 'standard__webPage',

            attributes: {
                url: pageLink
            }
        };

        this[NavigationMixin.GenerateUrl](config).then((url) => {
            sessionStorage.setItem('Cookies', 'Accepted');
            window.open(url, '_self');
        });
    }

    handleFavourite() {
        this.isFavourite = !this.isFavourite;
        setResourceAction({
            resourceId: this.resourceId,
            isFavorite: this.isFavourite,
            isVoted: false
        })
            .then((result) => {})
            .catch((error) => {
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
            });
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
}
