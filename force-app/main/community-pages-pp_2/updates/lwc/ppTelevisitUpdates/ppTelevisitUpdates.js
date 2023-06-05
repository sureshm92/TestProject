import { LightningElement, api } from 'lwc';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
import { NavigationMixin } from 'lightning/navigation';
import PP_View_Televisits from '@salesforce/label/c.PP_View_Televisits';
import PP_Scheduled_Televisit from '@salesforce/label/c.PP_Scheduled_Televisit';
import PP_Rescheduled_Televisit from '@salesforce/label/c.PP_Rescheduled_Televisit';
import PP_Canceled_Televisit from '@salesforce/label/c.PP_Canceled_Televisit';
import DEVICE from '@salesforce/client/formFactor';
export default class PpTelevisitUpdates extends NavigationMixin(LightningElement) {
    @api televisitData;
    @api showVisitSection;
    @api desktop;
    televisit_image = pp_community_icons + '/' + 'televisit_Update_illustration.svg';
    label = {
        PP_View_Televisits,
        PP_Scheduled_Televisit,
        PP_Rescheduled_Televisit,
        PP_Canceled_Televisit
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
    get televisitTitle() {
        console.log('this.televisitData.televisitType : ' + this.televisitData.televisitType);
        switch (this.televisitData.televisitType) {
            case 'Scheduled':
                return this.label.PP_Scheduled_Televisit;
            case 'Rescheduled':
                return this.label.PP_Rescheduled_Televisit;
            case 'Canceled':
                return this.label.PP_Canceled_Televisit;
        }
    }
    openLink(event) {
        console.log('televisit clicked');
        if (this.televisitData.televisitType != 'Canceled') {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'televisit'
                }
            });
        } else {
            this.removeCardHandler();
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'televisit'
                },
                state: {
                    ispast: true
                }
            });
        }
    }

    removeCardHandler() {
        const removeCardEvent = new CustomEvent('removecard', {
            detail: { sendResultId: this.televisitData.sendResultId }
        });
        this.dispatchEvent(removeCardEvent);
    }
}
