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

    // landscape = false;

    get modeOfIframeStyle(){
        return this.resourceType == 'Multimedia' ? "multimedia_landscape" : "multimedia_landscape";
    }

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
        if (this.resourceType == 'Multimedia') {
            this.showVideo = true;
        }
        this.showSpinner = false;

        // window.addEventListener("orientationchange", function() {
        //     console.log("the orientation of the device is now " + screen.orientation.angle);
        //     screen.orientation.angle > 0 ? this.landscape = true : this.landscape = false; 
        // });
    }
    handleError() {
        this.isThumbnailPresent = false;
    }
    
}