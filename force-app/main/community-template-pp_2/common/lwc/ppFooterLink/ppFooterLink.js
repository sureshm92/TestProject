import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import CCPA_icon from '@salesforce/resourceUrl/CCPA_icon';

export default class ppFooterLink extends NavigationMixin(LightningElement) {
    @api label;
    @api page;
    @api link;
    @api iscpraAvailable;
    CCPA_icon = CCPA_icon;

    onClick(event) {
        var link = this.page;
        if (link) {
            link = '/' + link + '?ret=' + communityService.createRetString();
        } else {
            link = this.link;
        }

        const config = {
            type: 'standard__webPage',

            attributes: {
                url: link
            }
        };

        this[NavigationMixin.GenerateUrl](config).then((url) => {
            // localStorage.setItem('Cookies', 'Accepted');
            window.open(url, '_blank');
        });
    }
}
