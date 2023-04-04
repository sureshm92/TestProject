import { LightningElement, track } from 'lwc';
import setResourceAction from '@salesforce/apex/ResourceRemote.setResourceAction';
import getResourceDetails from '@salesforce/apex/ResourcesDetailRemote.getResourcesById';
import getUnsortedResources from '@salesforce/apex/ResourceRemote.getUnsortedResourcesByType';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import VERSION from '@salesforce/label/c.Version_date';
import POSTING from '@salesforce/label/c.Posting_date';
import Back_To_Resources from '@salesforce/label/c.Link_Back_To_Resources';
import Back_To_Home from '@salesforce/label/c.Link_Back_To_Home';
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
    showHomePage = false;
    studyTitle = '';
    state;
    label = {
        VERSION,
        POSTING,
        Back_To_Resources,
        Back_To_Home
    };
    isMultimedia = false;
    isArticleVideo = false;
    @track landscape = false;

    desktop = true;
    spinner;
    resourceForPostingDate = ['Article', 'Video', 'Multimedia'];
    resourcesData;
    suggestedArticlesData;
    isInvalidResource = false;

    /*******Getters******************/

    get showSpinner() {
        return !this.isInitialized;
    }

    get showPostingDate() {
        if (this.resourceForPostingDate.includes(this.resourceType)) {
            return true;
        }
        return false;
    }

    get showPostingOrVersionLabel() {
        if (this.resourceForPostingDate.includes(this.resourceType)) {
            return this.label.POSTING;
        }
        return this.label.VERSION;
    }

    get isSuggestedArticlesVisible() {
        return this.isArticleVideo && this.suggestedArticlesData;
    }

    get linkLabel() {
        return this.showHomePage ? this.label.Back_To_Home : this.label.Back_To_Resources;
    }
    connectedCallback() {
        //get resource parameters from url
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        this.resourceId = urlParams.get('resourceid');
        this.resourceType = urlParams.get('resourcetype');
        this.showHomePage = urlParams.get('showHomePage');

        this.state = urlParams.get('state');
        if (this.resourceType == 'Study_Document') {
            this.langCode = urlParams.get('lang');
            this.isDocument = true;
        }

        switch (FORM_FACTOR) {
            case 'Small':
                this.desktop = false;
                break;
            case 'Medium':
                this.desktop = true;
                break;
            case 'Large':
                this.desktop = true;
                break;
        }

        this.initializeData();
    }

    async initializeData() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) {
            this.spinner.show();
        }
        this.isArticleVideo = this.resourceType == 'Article' || this.resourceType == 'Video';
        //if (!communityService.isInitialized()) return;

        let participantData = communityService.getParticipantData();
        getUnsortedResources({
            resourceType:
                this.resourceType == 'Article' || this.resourceType == 'Video'
                    ? 'Article;Video'
                    : this.resourceType,
            participantData: JSON.stringify(participantData)
        })
            .then((result) => {
                this.resourcesData = result;
                if (this.isArticleVideo) {
                    this.suggestedArticlesData = result;
                }
                if (
                    !this.resourcesData.wrappers.some(
                        (wrapper) => wrapper.resource.Id === this.resourceId
                    )
                ) {
                    this.isInvalidResource = true;
                    this.isInitialized = true;
                } else {
                    //get clicked resource details
                    getResourceDetails({
                        resourceId: this.resourceId,
                        resourceType: this.resourceType
                    })
                        .then((result) => {
                            let resourceData = result.wrappers[0].resource;
                            this.resUploadDate = this.resourceForPostingDate.includes(
                                this.resourceType
                            )
                                ? resourceData.Posting_Date__c
                                : resourceData.Version_Date__c;
                            this.resourceTitle = resourceData.Title__c;
                            this.resourceSummary = resourceData.Body__c;
                            this.resourceLink =
                                this.resourceType == 'Article'
                                    ? resourceData.Image__c
                                    : resourceData.Video__c;
                            if (this.resourceType == 'Multimedia') {
                                this.resourceLink = resourceData.Multimedia__c;
                                this.isMultimedia = true;
                            }
                            this.isFavourite = result.wrappers[0].isFavorite;
                            this.isVoted = result.wrappers[0].isVoted;

                            //get study Title
                            if (
                                this.state != 'ALUMNI' &&
                                (resourceData.Content_Class__c == 'Study-Specific' ||
                                    this.isDocument)
                            ) {
                                this.studyTitle =
                                    communityService.getParticipantData()?.ctp?.Study_Code_Name__c;
                                if (this.isDocument) {
                                    this.handleDocumentLoad();
                                }
                            }
                            this.isInitialized = true;
                        })
                        .catch((error) => {
                            this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
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

    handleBackClick(event) {
        let backToHome;
        if (event) {
            backToHome = event.detail.backToHome;
        }
        if (this.showHomePage || backToHome) {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'home'
                }
            });
        } else if (FORM_FACTOR == 'Large') {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'resources'
                }
            });
        } else {
            let resType;
            if (this.isMultimedia) {
                resType = 'engage';
            } else if (this.resourceType == 'Study_Document') {
                resType = 'documents';
            } else if (this.resourceType == 'Video' || this.resourceType == 'Article') {
                resType = 'explore';
            }
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'resources'
                },
                state: {
                    resType: resType
                }
            });
        }
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
