import { LightningElement, api } from 'lwc';
import getInitDataNew from '@salesforce/apex/RelevantLinksRemote.getInitDataNew';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
import DEVICE from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PpDiscoverLinks extends LightningElement {
    isInitialized = false;
    isAvailable = false;
    linksWrappers = [];
    discoverEmptyState = false;
    desktop = true;
    isRendered = false;
    @api toggleExplore = false;

    open_new_tab = pp_community_icons + '/' + 'open_in_new.png';
    empty_state = pp_community_icons + '/' + 'discover_empty.png';

    get cardContainerHeight() {
        if (!this.toggleExplore) {
            return 'card-container card-container-height-medium';
        } else if (this.toggleExplore) {
            return 'card-container card-container-height-small';
        } else {
            return 'card-container';
        }
    }

    connectedCallback() {
        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);
    }

    renderedCallback() {
        if (!this.isRendered) {
            this.isRendered = true;
            this.spinner = this.template.querySelector('c-web-spinner');
            this.spinner ? this.spinner.show() : '';
            this.initializeData();
        }
    }

    initializeData() {
        getInitDataNew()
            .then((returnValue) => {
                this.isInitialized = true;

                let initData = JSON.parse(JSON.stringify(returnValue));

                initData.resources.forEach((resObj) => {
                    this.linksWrappers.push(resObj.resource);
                });
                this.spinner.hide();
                this.linksWrappers.length == 0
                    ? (this.discoverEmptyState = true)
                    : (this.discoverEmptyState = false);
            })
            .catch((error) => {
                this.showErrorToast('Error occured', error.message, 'error');
                this.spinner.hide();
            });
    }

    openLink(event) {
        window.open(event.currentTarget.dataset.link, '_blank');
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
