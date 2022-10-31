import { LightningElement, api } from 'lwc';

export default class PpDetailPageResourceItem extends LightningElement {
    @api resourceType;
    @api resourceLink;
    showArticle = false;
    showVideo = false;
    showDocument = false;
    connectedCallback() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) {
            this.spinner.show();
        }
        if (this.resourceType == 'Article') {
            this.showArticle = true;
        }
        if (this.resourceType == 'Video') {
            this.showVideo = true;
        }
        if (this.resourceType == 'Document') {
            this.showDocument = true;
        }
        if (this.spinner) {
            this.spinner.hide();
        }
    }
}
