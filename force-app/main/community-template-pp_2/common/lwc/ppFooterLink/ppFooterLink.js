import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import myResource from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';

export default class ppFooterLink extends NavigationMixin(LightningElement) {
    @api label;
    @api page;
    @api link;

    onClick(event) {
        loadScript(this, myResource)
            .then(() => console.log('Loaded Resource'))
            .catch((error) => console.log(error));

        var link = this.page;
        if (link) {
            link = '/' + link + '?ret=' + window.communityService.createRetString();
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
            localStorage.setItem('Cookies', 'Accepted');
            window.open(url, '_blank');
        });
    }
}
