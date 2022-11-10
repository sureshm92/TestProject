import { LightningElement, api } from 'lwc';

export default class PpDetailPageResourceItem extends LightningElement {
    @api resourceType;
    @api resourceLink;
    showArticle = false;
    showVideo = false;
    isThumbnailPresent = false;

    connectedCallback() {
        this.spinner = this.template.querySelector('c-web-spinner');
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
