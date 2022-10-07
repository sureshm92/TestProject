import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Documents extends NavigationMixin(LightningElement) {
    @api title;
    @api versiondate;
    @api id;
    @api thumbnail;

    handleNavigate() {
        let detailLink =
            window.location.origin + '/pp/s/resource-detail' + '?resourceid=' + this.id;

        const config = {
            type: 'standard__webPage',

            attributes: {
                url: detailLink
            }
        };

        this[NavigationMixin.GenerateUrl](config).then((url) => {
            window.open(url, '_self');
        });
    }
}
