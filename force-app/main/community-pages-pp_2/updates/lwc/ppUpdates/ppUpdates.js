import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getInitDataNew from '@salesforce/apex/RelevantLinksRemote.getInitDataNew';
import getUpdateResources from '@salesforce/apex/ResourceRemote.getUpdateResources';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
import DEVICE from '@salesforce/client/formFactor';

export default class PpUpdates extends LightningElement {
    isInitialized = false;
    isAvailable = false;
    @track linksWrappers = [];
    discoverEmptyState = false;
    desktop = true;
    @track updateData = [];

    // documents
    documentList = [];
    documents = [];
    documentPresent;

    open_new_tab = pp_community_icons + '/' + 'open_in_new.png';
    empty_state = pp_community_icons + '/' + 'discover_empty.png';

    connectedCallback() {
        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);

        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner ? this.spinner.show() : '';
        this.initializeData();
    }

    initializeData() {
        getInitDataNew().then((returnValue) => {
            this.isInitialized = true;
            let initData = JSON.parse(JSON.stringify(returnValue));
            console.log('initData----->' + JSON.stringify(initData));
            initData.resources.forEach((resObj) => {
                this.linksWrappers.push(resObj.resource);
            });
            this.linksWrappers.length == 0
                ? (this.discoverEmptyState = true)
                : (this.discoverEmptyState = false);
            let therapeuticAssignmentsList = [];
            let therapeuticAssignments = {
                resource: '',
                id: '',
                therapeuticArea: ''
            };

            initData.resources.forEach((resObj) => {
                resObj.resource.Therapeutic_Area_Assignments__r?.forEach((therapeuticArea) => {
                    therapeuticAssignments.resource = therapeuticArea.Resource__c;
                    therapeuticAssignments.id = therapeuticArea.Id;
                    therapeuticAssignments.therapeuticArea = therapeuticArea.Therapeutic_Area__c;
                    therapeuticAssignmentsList.push(therapeuticAssignments);
                });

                resObj.therapeuticAssignments = therapeuticAssignmentsList;
                therapeuticAssignmentsList = [];
                delete resObj.resource.Therapeutic_Area_Assignments__r;
            });
            this.getUpdates(JSON.stringify(initData));
            this.spinner.hide();
        })
        .catch((error) => {
            communityService.showToast('', 'error', 'Failed To read the Data111...', 100);
            this.spinner.hide();
        });
    }

    openLink(event) {
        window.open(event.currentTarget.dataset.link, '_blank');
    }

    async getUpdates(returnValue) {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) {
            this.spinner.show();
        }
        await getUpdateResources({ linkWrapperText: returnValue })
            .then((result) => {
                console.log('updates-->' + JSON.stringify(result, null, 2));
                let data = JSON.parse(JSON.stringify(result));
                data.resources.forEach((resObj) => {
                    this.updateData.push(resObj.resource);
                });
                this.updateData.forEach((resObj) => {
                    if (resObj.Content_Type__c == 'Article' || resObj.Content_Type__c == 'Video') {
                        resObj.isExplore = true;
                    } else if (resObj.Content_Type__c == 'Study_Document') {
                        resObj.isDoc = true;
                    } else {
                        resObj.isLink = true;
                    }
                });
                console.log('updates2-->' + JSON.stringify(this.updateData, null, 2));
            })
            .catch((error) => {
                this.showErrorToast('Error occured', error.message, 'error');
            });
        if (this.spinner) {
            this.spinner.hide();
        }
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
