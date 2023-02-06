import { LightningElement, api } from 'lwc';

export default class PpResourceMultimedia extends LightningElement {
    @api resourcedData = [];
    @api desktop = false;
    resourcePresent = false;
    renderedCallback() {
        this.initializeData();
    }

    initializeData() {
        if (this.resourcedData != undefined && this.resourcedData.length > 0) {
            this.resourcePresent = true;
        }
    }
    navigateResources() {
        let subDomain = communityService.getSubDomain();
        let detailLink = window.location.origin + subDomain + '/s/resources';

        const config = {
            type: 'standard__webPage',

            attributes: {
                url: detailLink
            }
        };

        this[NavigationMixin.GenerateUrl](config).then((url) => {
            sessionStorage.setItem('Cookies', 'Accepted');
            window.open(url, '_self');
        });
    }
}
