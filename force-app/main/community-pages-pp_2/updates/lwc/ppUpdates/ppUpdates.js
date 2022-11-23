import { LightningElement, track } from 'lwc';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import communityPPTheme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';

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

        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                Promise.all([loadStyle(this, communityPPTheme)])
                    .then(() => {
                        this.spinner = this.template.querySelector('c-web-spinner');
                        this.spinner ? this.spinner.show() : '';
                        // Getting data for Updates section. For now only Links data is fetched
                        // Need backend work to filter data as per AC on rel links, articles, videos, documents
                        this.initializeData();
                    })
                    .catch((error) => {
                        console.log(error.body.message);
                    });
            })
            .catch((error) => {
                communityService.showToast('', 'error', error.message, 100);
            });
    }

    initializeData() {
        getInitDataNew()
            .then((returnValue) => {
                this.isInitialized = true;
                let initData = JSON.parse(JSON.stringify(returnValue));
                initData.resources.forEach((resObj) => {
                    this.linksWrappers.push(resObj.resource);
                });
                this.linksWrappers.length == 0
                    ? (this.discoverEmptyState = true)
                    : (this.discoverEmptyState = false);
                this.getUpdates(JSON.stringify(returnValue));
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
                    if (
                        resObj.Content_Type__c == 'Article' ||
                        resObj.Content_Type__c == 'Video'
                    ) {
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
