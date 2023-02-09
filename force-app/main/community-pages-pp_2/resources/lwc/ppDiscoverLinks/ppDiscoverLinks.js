import { LightningElement, api } from 'lwc';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
import DEVICE from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LINKS_EMPTY from '@salesforce/label/c.Discover_Links_Empty';

export default class PpDiscoverLinks extends LightningElement {
    isInitialized = false;
    isAvailable = false;
    @api linksWrappers=[];
    @api discoverEmptyState;
    desktop = true;
    isRendered = false;
    @api toggleExplore = false;
    label = {
        LINKS_EMPTY
    };

    open_new_tab = pp_community_icons + '/' + 'open_in_new.png';
    empty_state = pp_community_icons + '/' + 'discover_empty.png';

    get cardContainerHeight() {
        if (!this.toggleExplore) {
            return 'card-container card-container-height-medium';
        } else if (this.toggleExplore) {
            return 'card-container card-container-height-small slds-p-horizontal_x-small';
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
            this.isInitialized = true;
        }
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
