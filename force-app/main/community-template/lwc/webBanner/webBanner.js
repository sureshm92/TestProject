import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import privacyPolicyText from '@salesforce/label/c.Lofi_Login_Footer_Policies';
export default class WebBanner extends LightningElement {
    //Attributes--------------------------------------------------------------------------------------------------------
    @api bodyText;
    @api showClose = false;
    @api closeCallback;
    @api showBanner = false;
    @api isRTL;
    @api isMobileView = false;
    @track isInitialized = false;
    @track bodyTextTwo;

    label = {
        privacyPolicyText
    };
    //Public methods----------------------------------------------------------------------------------------------------
    @api show() {
        this.showBanner = true;
    }

    @api hide() {
        this.showBanner = false;
        communityService.setCookie('RRCookies', 'agreed');
    }

    @api cancel() {
        this.doCancel();
    }

    //Inner methods-----------------------------------------------------------------------------------------------------
    doCancel() {
        this.hide();
        if (this.closeCallback) this.closeCallback();
    }
    @api openModalPopup() {
        this.hide();
        const filters = true;
        const selectedEvent = new CustomEvent('openModal', {
            detail: { filters }
        });
        // Fire the custom event
        this.dispatchEvent(selectedEvent);
    }
    renderedCallback() {
        console.log('this.bodyText: ' + this.bodyText);
        if (this.bodyText != null && this.bodyTextTwo == null) {
            var firstPart = this.bodyText.split('##privacyPolicyURL.');
            this.bodyText = firstPart[0];
            this.bodyTextTwo = firstPart[1];
        }
    }

    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                console.log('RR_COMMUNITY_JS loaded');
                let rrCookies = communityService.getCookie('RRCookies');
                if (!rrCookies) {
                    this.show();
                    this.template.addEventListener('click', this.hide);
                    setTimeout(() => {
                        this.hide();
                    }, 20000);
                }
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading RR_COMMUNITY_JS',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }

    //Expressions for html attributes-----------------------------------------------------------------------------------
    get modalClass() {
        return this.showBanner ? 'transition-show' : '';
    }

    get iconButtonClass() {
        //slds-modal__close
        return (
            'button-close' +
            (this.showClose ? '' : ' slds-hide') +
            (navigator.userAgent.match(/iPhone/i) ? ' p-mobile-close' : '') +
            (this.isRTL ? ' flip-close' : '')
        );
    }

    get containerClass() {
        return 'p-container' + (this.isRTL ? ' align-rtl' : '');
    }

    get iconBellClass() {
        return 'icon-bell' + (this.isRTL ? ' flip-bell' : '');
    }

    get backDropClass() {
        return 'slds-backdrop' + (this.showBanner ? ' slds-backdrop--open' : '');
    }
}
