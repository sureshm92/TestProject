import { LightningElement } from 'lwc';
import setResourceAction from '@salesforce/apex/ResourceRemote.setResourceAction';
import getResourceDetails from '@salesforce/apex/ResourcesDetailRemote.getResourcesById';
import getCtpName from '@salesforce/apex/ParticipantStateRemote.getInitData';
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
    studyTitle;
    label = {
        Uploaded,
        Back_To_Resources
    };

    connectedCallback() {
        //get resource parameters from url
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        this.resourceId = urlParams.get('resourceid');
        this.resourceType = urlParams.get('resourcetype');
        this.initializeData();
    }
    initializeData() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) {
            this.spinner.show();
        }
        //get study Title
        getCtpName({})
            .then((result) => {
                let data = JSON.parse(result);
                this.studyTitle=data.pi?.pe?.Clinical_Trial_Profile__r?.Study_Title__c;
            })
            .catch((error) => {
                this.showErrorToast(this.labels.ERROR_MESSAGE, error.message, 'error');
            });
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
                this.resourceLink =
                    this.resourceType == 'Article' ? resourceData.Image__c : resourceData.Video__c;
                this.isFavourite = result.wrappers[0].isFavorite;
                this.isVoted = result.wrappers[0].isVoted;
                this.isDocument = this.resourceType == 'Document' ? true : false;
                this.isInitialized = true;
            })
            .catch((error) => {
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
            });

        if (this.spinner) {
            this.spinner.hide();
        }
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
