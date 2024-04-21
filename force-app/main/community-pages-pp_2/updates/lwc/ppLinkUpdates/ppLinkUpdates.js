import { LightningElement, api,track } from 'lwc';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
import helpfulLinks from '@salesforce/label/c.Helpful_Links';
import Open_In_New_Tab from '@salesforce/label/c.PP_Open_In_New_Tab';
import { NavigationMixin } from 'lightning/navigation';
import DEVICE from '@salesforce/client/formFactor';
export default class PpLinkUpdates extends NavigationMixin(LightningElement) {
    @api linkData;
    @api showVisitSection;
    @api desktop;
    open_new_tab = pp_community_icons + '/' + 'open_in_new.png';
    link_state = pp_community_icons + '/' + 'linkssvg.svg';
    label = {
        helpfulLinks,
        Open_In_New_Tab
    };
    @track isIPAD;
    connectedCallback() {
        this.isIpad();
        window.addEventListener('orientationchange', this.onOrientationChange);
    }
    
    onOrientationChange = () => {
        this.isIpad();
    };
    get cardElement() {
        if (DEVICE == 'Medium') {
            return 'slds-col slds-size_3-of-12 card-element';
        } else {
            return 'slds-col slds-size_2-of-6 card-element';
        }
    }
    get cardDataElement() {
        if (DEVICE == 'Medium') {
            return 'slds-col slds-size_9-of-12';
        } else {
            return 'slds-col slds-size_4-of-6';
        }
    }

   
    openLink(event) {
        this.removeCardHandler();
        let participantState;
        if (communityService.isInitialized()) {
            participantState = communityService.getCurrentCommunityMode().participantState;
        }
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'resource-detail'
            },
            state: {
                resourceid: this.linkData.recId,
                resourcetype: this.linkData.resourceDevRecordType,
                state: participantState,
                showHomePage: true
            }
        }).then((url) => {
            window.open(url, '_blank');
        });
    }
    removeCardHandler() {
        const removeCardEvent = new CustomEvent('removecard', {
            detail: { sendResultId: this.linkData.sendResultId }
        });
        this.dispatchEvent(removeCardEvent);
    }
    isIpad(){
        let orientation = screen.orientation.type;
        let portrait = true;
        if (orientation === 'landscape-primary') {
            portrait = false;
        }
        if (window.innerWidth >= 768 && window.innerWidth < 1279 && portrait) {
            if (/iphone|ipad|ipod/i.test(navigator.userAgent.toLowerCase())) {
                this.isIPAD = true;
                return true;
            } else if (/macintel|iPad Simulator/i.test(navigator.platform.toLowerCase())) {
                this.isIPAD = true;
                return true;
            }
        } else {
            this.isIPAD = false;
        }
        return false; 
    }
}
