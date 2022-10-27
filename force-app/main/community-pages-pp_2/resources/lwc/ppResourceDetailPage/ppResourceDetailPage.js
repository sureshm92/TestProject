import { LightningElement, api, track, wire } from 'lwc';
import setResourceAction from '@salesforce/apex/ResourceRemote.setResourceAction';
import getResourceDetails from '@salesforce/apex/ResourcesDetailRemote.getResourcesById';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import Uploaded from '@salesforce/label/c.Resource_Uploaded';
import Back_To_Resources from '@salesforce/label/c.Link_Back_To_Resources';

export default class PpResourceDetailPage extends LightningElement {
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
    label = {
        Uploaded,
        Back_To_Resources
    };

    connectedCallback() {
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        this.resourceId = urlParams.get('resourceid');
        this.resourceType = urlParams.get('resourcetype');
        if (this.resourceType == 'Study_Document') {
            this.langCode = urlParams.get('lang');
            this.isDocument = true;
        }
        this.initializeData();
    }
    initializeData() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) {
            this.spinner.show();
        }
        getResourceDetails({
            resourceId: this.resourceId,
            resourceType: this.resourceType
        })
            .then((result) => {
                let resourceData = result.wrappers[0].resource;
                this.resUploadDate = resourceData.Version_Date__c;
                this.resourceTitle = resourceData.Title__c;
                this.resourceSummary = resourceData.Body__c;
                this.resourceLink =
                    this.resourceType == 'Article' ? resourceData.Image__c : resourceData.Video__c;
                this.isFavourite = result.wrappers[0].isFavorite;
                this.isVoted = result.wrappers[0].isVoted;
                if (this.isDocument) {
                    this.handleDocumentLoad();
                }
            })
            .catch((error) => {
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
            });
        this.isInitialized = true;

        if (this.spinner) {
            this.spinner.hide();
        }
    }

    handleDocumentLoad() {
        this.documentLink =
            '/apex/RRPDFViewer?resourceId=' + this.resourceId + '&language=' + this.langCode;
    }

    handleBackClick() {
        let pageLink = window.location.origin + '/pp/s/resources';
        window.location.assign(pageLink);
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
