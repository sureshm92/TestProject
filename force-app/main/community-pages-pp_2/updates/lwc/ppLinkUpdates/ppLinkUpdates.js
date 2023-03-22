import { LightningElement, api } from 'lwc';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
import helpfulLinks from '@salesforce/label/c.Helpful_Links';

export default class PpLinkUpdates extends LightningElement {
    @api linkData;
    @api showVisitSection;
    @api desktop;
    open_new_tab = pp_community_icons + '/' + 'open_in_new.png';
    link_state = pp_community_icons + '/' + 'linkssvg.svg';
    label = {
        helpfulLinks
    };

    openLink(event) {
        console.log('open link');
        console.log('open link : '+this.linkData.targetRecordId);
        const customEvent = new CustomEvent('removecard', {
            detail: {
                targetRecordId: this.linkData.targetRecordId
            }
        });
        this.dispatchEvent(customEvent);
        window.open(event.currentTarget.dataset.link, '_blank');
    }
}
