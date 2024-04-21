import { LightningElement,track,api } from 'lwc';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import { loadScript } from 'lightning/platformResourceLoader';
import rrCommunity from '@salesforce/resourceUrl/rr_community_js';
import formFactor from '@salesforce/client/formFactor';

export default class CustomToastMessage extends LightningElement {
    isDesktop;
    @track message;
    @track title;
    @track mode;
    @track variant;
    @track showToastBar = false;
    motivationalicon = pp_icons + '/' + 'motivationalMessage_icon.svg';

    connectedCallback() {
        formFactor != 'Small' ? (this.isDesktop = true) : (this.isDesktop = false);
        console.log('The Desktop is form Factor'+this.isDesktop);
        if (!this.loaded) {
            loadScript(this, rrCommunity).then(() => {
                if (communityService.isMobileSDK()) {
                     this.isDesktop = false;
                }
            });
        }
    }
    
    @api
    showToast(titleText, messageText, variantType, mode) {
        this.title = titleText;
        this.message = messageText;
        this.variant=variantType;
        this.mode=mode;
        this.showToastBar = true;
    }
    closeModel() {
        this.showToastBar = false;
        this.message = '';
    }
}