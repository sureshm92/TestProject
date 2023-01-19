import { LightningElement,api } from 'lwc';

export default class PpResourceMultimedia extends LightningElement {
    @api resourcedData = [];
    @api desktop = false;
    resourcePresent = false;
    renderedCallback() {
        this.initializeData();
    }

    initializeData() {
        console.log('+++++++++123'+JSON.stringify(this.resourcedData));
        if(this.resourcedData != undefined && this.resourcedData.length >0 ){
            this.resourcePresent = true;
        }
    }
    navigateResources() {
        let subDomain = communityService.getSubDomain();
        let detailLink = window.location.origin + subDomain + '/s/resources';

        /* const config = {
            type: 'standard__webPage',

            attributes: {
                url: detailLink
            }
        };

        this[NavigationMixin.GenerateUrl](config).then((url) => {
            window.open(url, '_self');
        }); */
        communityService.navigateToPage('resources');
    }
}