import { LightningElement, api } from 'lwc';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
import helpfulLinks from '@salesforce/label/c.Helpful_Links';
import Open_In_New_Tab from '@salesforce/label/c.PP_Open_In_New_Tab';
import removeCard from '@salesforce/apex/PPUpdatesController.removeUpdateCard';
export default class PpLinkUpdates extends LightningElement {
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
        window.open(event.currentTarget.dataset.link, '_blank');
    }
    removeCardHandler(){
        const targetRecId = this.linkData.targetRecordId;
        removeCard({targetRecordId : targetRecId})
        .then((returnValue) => {
        })
        .catch((error) => {
            //console.log('error message 1'+error.message);
            this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
            this.spinner.hide();
        });
    }
}
