import { LightningElement, api } from 'lwc';
import DEVICE from '@salesforce/client/formFactor';
export default class PpDetailPageResourceItem extends LightningElement {
    @api resourceType;
    @api resourceLink;
    showArticle = false;
    showVideo = false;
    isThumbnailPresent = false;
    desktop;
    connectedCallback() {
        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) {
            this.spinner.show();
        }
        this.isThumbnailPresent = this.resourceLink ? true : false;
        if (this.spinner) {
            this.spinner.show();
        }
        if (this.resourceType == 'Article') {
            this.showArticle = true;
        }
        if (this.resourceType == 'Video') {
            this.showVideo = true;
        }
        if (this.spinner) {
            this.spinner.hide();
        }
    }
    handleError() {
        this.isThumbnailPresent = false;
    }
}
