import { LightningElement, api } from 'lwc';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
import View_Results from '@salesforce/label/c.View_Results';
import New_Visit_Results_Now_Available from '@salesforce/label/c.New_Visit_Results_Now_Available';
import { NavigationMixin } from 'lightning/navigation';
import basePathName from '@salesforce/community/basePath';
import DEVICE from '@salesforce/client/formFactor';
export default class PPVisitResultUpdates extends NavigationMixin(LightningElement) {
    @api linkData;
    @api showVisitSection;
    @api desktop;
    open_new_tab = pp_community_icons + '/' + 'open_in_new.png';
    results_Illustration = pp_community_icons + '/' + 'results_Illustration.svg';
    label = {
        View_Results,
        New_Visit_Results_Now_Available
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
        let visitresultdetailpageurl = window.location.origin + basePathName + '/results';
        const config = {
            type: 'standard__webPage',
            attributes: {
                url: visitresultdetailpageurl
            }
        };
        this[NavigationMixin.GenerateUrl](config).then((url) => {
            window.open(url, '_self');
        });
    }
    removeCardHandler() {
        const removeCardEvent = new CustomEvent('removecard', {
            detail: { sendResultId: this.linkData.sendResultId }
        });
        this.dispatchEvent(removeCardEvent);
    }
}
