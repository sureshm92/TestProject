import { LightningElement, api } from 'lwc';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
import { NavigationMixin } from 'lightning/navigation';
import PP_View_Televisits from '@salesforce/label/c.PP_View_Televisits';
import PP_Scheduled_Televisit from '@salesforce/label/c.PP_Scheduled_Televisit';
import PP_Rescheduled_Televisit from '@salesforce/label/c.PP_Rescheduled_Televisit';
export default class PpTelevisitUpdates extends NavigationMixin(LightningElement) {
    @api televisitData;
    @api showVisitSection;
    @api desktop;
    televisit_image = pp_community_icons + '/' + 'televisit_Update_illustration.svg';
    label = {
        PP_View_Televisits,
        PP_Scheduled_Televisit,
        PP_Rescheduled_Televisit
    };
    get televisitTitle() {
        console.log('this.televisitData.televisitType : ' + this.televisitData.televisitType);
        if (this.televisitData.televisitType == 'Scheduled') {
            return this.label.PP_Scheduled_Televisit;
        } else if (this.televisitData.televisitType == 'Rescheduled') {
            return this.label.PP_Rescheduled_Televisit;
        }
    }
    openLink(event) {
        console.log('televisit clicked');
        this.removeCardHandler();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'televisit'
            }
        });
    }

    removeCardHandler() {
        const removeCardEvent = new CustomEvent('removecard', {
            detail: { sendResultId: this.televisitData.sendResultId }
        });
        this.dispatchEvent(removeCardEvent);
    }
}
