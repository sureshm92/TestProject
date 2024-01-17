import { LightningElement, api } from 'lwc';
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
    isIPAD;
    connectedCallback() {
        this.isIpad();
    }
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

    get openNewTabCss() {
        return  this.isIPAD
            ? 'open-tab-horizontal hide-icon'
            : 'open-tab-horizontal' ;
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
        if (/ipad|ipod/i.test(navigator.userAgent.toLowerCase())) {
            this.isIPAD=true;
        } else if (/macintel/i.test(navigator.platform.toLowerCase())) {  
            this.isIPAD=true;      
        }else{
            this.isIPAD=false;
        }
    }
}
