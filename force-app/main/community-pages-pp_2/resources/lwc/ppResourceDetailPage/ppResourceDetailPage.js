import { LightningElement, track, wire } from 'lwc';
import setResourceAction from '@salesforce/apex/ResourceRemote.setResourceAction';
import getResourceDetails from '@salesforce/apex/ResourcesDetailRemote.getResourcesByIdNew';
import getUnsortedResources from '@salesforce/apex/ResourceRemote.getUnsortedResourcesByType';
import getPastStudyResources from '@salesforce/apex/ResourceRemote.getPastStudyResources';
import getDataWrapper from '@salesforce/apex/RelevantLinksRemote.getDataWrapper';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import VERSION from '@salesforce/label/c.Version_date';
import POSTING from '@salesforce/label/c.Posting_date';
import Back_To_Resources from '@salesforce/label/c.Link_Back_To_Resources';
import Back_To_PastStudies from '@salesforce/label/c.Back_to_Past_Studies_and_Programs';
import Back_To_Home from '@salesforce/label/c.Link_Back_To_Home';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';

import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';

import messageChannel from '@salesforce/messageChannel/ppLightningMessageService__c';
import {
    publish,
    subscribe,
    unsubscribe,
    createMessageContext,
    releaseMessageContext,
    APPLICATION_SCOPE
} from 'lightning/messageService';

export default class PpResourceDetailPage extends NavigationMixin(LightningElement) {
    // @wire(MessageContext)
    // messageContext;
    messageContext = createMessageContext();

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
        Back_To_Home,
        Back_To_PastStudies
    };
    isMultimedia = false;
    isArticleVideo = false;
    @track landscape = false;
    pe;
    paststudyname;
    desktop = true;
    spinner;
    resourceForPostingDate = ['Article', 'Video', 'Multimedia'];
    resourcesData;
    suggestedArticlesData;
    isInvalidResource = false;
    mediaContent = false;
    displaySection = "";
    backButtonLandscape = "";
    televisit = false;
    backtopaststudies = false;
    backToRes = pp_community_icons + '/' + 'back_to_resources.png';

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
    get paststudieslinkLabel() {
        return this.label.Back_To_PastStudies;
    }
    timeInterval() {
        setInterval(() => {
            this.televisit = sessionStorage.getItem("televistActive");
            console.log("TELEVISIT ACTIVE: " + this.televisit);
        }, 1000);
    }

    get backButtonLandscapeTop(){
        if(this.televisit == "true"){
            return "back-to-res-televisit";
        }
        else{
            return "back-to-res";
        }
    }

    get iframeAdjustTop(){
        if(this.televisit == "true"){
            return "mt-8";
        }
    }


    disconnectedCallback(){
        this.publishResourceType(false);
    }

    /** Lifecycle hooks **/
    connectedCallback() {
        //get resource parameters from url
        this.timeInterval();
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        this.resourceId = urlParams.get('resourceid');
        this.resourceType = urlParams.get('resourcetype');
        this.showHomePage = urlParams.get('showHomePage');
        this.pe = urlParams.get('pe');
        this.paststudyname = urlParams.get('studyname');
        this.publishResourceType(true);

        // Logic for portrait mode and landscape mode - hide content in case of mediaContent is true
 
        (this.mediaContent == true) ? this.displaySection = "portrait-mode" :  this.displaySection = "";

        (this.mediaContent == true) ? this.backButtonLandscape = "" : this.backButtonLandscape = "hidden";

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

    publishResourceType(flag){
        if(this.resourceType == "Multimedia" || this.resourceType == "Video"){
            flag ? this.mediaContent = true : this.mediaContent = false;
            const returnPayload = {
                mediaContent: this.mediaContent
            };
            publish(this.messageContext, messageChannel, returnPayload);

        }else if(this.resourceType != "Multimedia" || this.resourceType != "Video"){
            this.mediaContent = false;
            const returnPayload = {
                mediaContent: this.mediaContent
            };
            publish(this.messageContext, messageChannel, returnPayload);
        }
    }

    /** Methods **/
    async initializeData() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) {
            this.spinner.show();
        }
        this.isArticleVideo = this.resourceType == 'Article' || this.resourceType == 'Video';

        let participantData = communityService.getParticipantData();
        if (this.resourceType == 'Relevant_Link') {
            getDataWrapper({ sortByCOI: false })
                .then((returnValue) => {
                    let initData = JSON.parse(JSON.stringify(returnValue));
                    let linksWrappers = [];
                    let link;
                    initData.resources.forEach((resObj) => {
                        linksWrappers.push(resObj.resource);
                    });
                    if (
                        linksWrappers &&
                        linksWrappers.some((resource) => {
                            let returnValue = false;
                            if (resource.Id === this.resourceId) {
                                link = resource.URL__c;
                                returnValue = true;
                            }
                            return returnValue;
                        })
                    ) {
                        window.location.href = link;
                        if (communityService.isMobileSDK() ) {
                            this[NavigationMixin.Navigate]({
                                type: 'comm__namedPage',
                                attributes: {
                                    pageName: 'home'
                                }
                            })
                        }
                        this.isInitialized=true;
                    } else {
                        this.isInvalidResource = true;
                        this.isInitialized = true;
                    }
                })
                .catch((error) => {
                    this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
                });
        }else if(this.pe){
            this.backtopaststudies = true;
            getPastStudyResources({
                resourceType:
                    this.resourceType == 'Article' || this.resourceType == 'Video'
                        ? 'Article;Video'
                        : this.resourceType,
                participantData: JSON.stringify(participantData),
                peId :this.pe
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
                                    (resourceData.Content_Class__c == 'Study-Specific' ||
                                        this.isDocument)
                                ) {
                                    this.studyTitle = this.paststudyname;
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
        }else {
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
                            resourceType: this.resourceType,
                            participantData: JSON.stringify(participantData)
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
    }

    handleDocumentLoad() {
        let updates = true;
        this.documentLink =
            'mobile-pdf-viewer?resId=' +
            this.resourceId +
            '&lang=' +
            this.langCode +
            '&updates=' +
            updates;
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
            })
        } else if (FORM_FACTOR == 'Large') {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'resources'
                }
            })
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
            })
        }
        this.publishResourceType(false);
    }

    handleBackToPastStudies(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'past-studies'
            }
        })
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

    goBackToPrevPage() {
        window.history.back();
    }
}
