import { LightningElement, api } from 'lwc';

export default class PpDetailPageResourceItem extends LightningElement {
    @api resourceType;
    @api resourceLink;
    showArticle = false;
    showVideo = false;
    showDocument = false;
    connectedCallback() {
        if (this.resourceType == 'Article') {
            this.showArticle = true;
        }
        if (this.resourceType == 'Video') {
            this.showVideo = true;
        }
        if (this.resourceType == 'Document') {
            this.showDocument = true;
        }
    }
}
