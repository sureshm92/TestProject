import { LightningElement, api } from 'lwc';
import DEVICE from '@salesforce/client/formFactor';
export default class PpDetailPageResourceItem extends LightningElement {
    @api resourceType;
    @api resourceLink;
    showArticle = false;
    showVideo = false;
    isThumbnailPresent = false;
    desktop;
    showSpinner = false;
    connectedCallback() {
        this.showSpinner = true;
        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);

        this.isThumbnailPresent = this.resourceLink ? true : false;
        if (this.resourceType == 'Article') {
            this.showArticle = true;
        }
        if (this.resourceType == 'Video') {
            this.showVideo = true;
        }
        this.showSpinner = false;
    }
    handleError() {
        this.isThumbnailPresent = false;
    }
}
