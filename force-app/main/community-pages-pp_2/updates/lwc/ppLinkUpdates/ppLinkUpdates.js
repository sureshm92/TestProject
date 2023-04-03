import { LightningElement, api } from 'lwc';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
import helpfulLinks from '@salesforce/label/c.Helpful_Links';
import Open_In_New_Tab from '@salesforce/label/c.PP_Open_In_New_Tab';
import removeCard from '@salesforce/apex/PPUpdatesController.removeUpdateCard';
import { NavigationMixin } from 'lightning/navigation';
export default class PpLinkUpdates extends NavigationMixin(LightningElement){
    @api linkData;
    @api showVisitSection;
    @api desktop;
    open_new_tab = pp_community_icons + '/' + 'open_in_new.png';
    link_state = pp_community_icons + '/' + 'linkssvg.svg';
    label = {
        helpfulLinks,
        Open_In_New_Tab
    };

    openLink(event) {
        this.removeCardHandler();
        let states;
        if (communityService.isInitialized()) {
            states = communityService.getCurrentCommunityMode().participantState;
        }
        console.log('coming here 1'+this.linkData.recId);
        console.log('coming here 1'+this.linkData.resourceDevRecordType);
        console.log('coming here 1'+states);
        this[NavigationMixin.GenerateUrl]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'resource-detail'
            },
            state: {
                resourceid: this.linkData.recId,
                resourcetype: this.linkData.resourceDevRecordType,
                state: states,
                showHomePage : 'true'
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }
    removeCardHandler(){
        const targetRecId = this.linkData.targetRecordId;
        removeCard({targetRecordId : targetRecId})
        .then((returnValue) => {
        })
        .catch((error) => {
            console.log('error message '+error?.message);
        });
    }
}
