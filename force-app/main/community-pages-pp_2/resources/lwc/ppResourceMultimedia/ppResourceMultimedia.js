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
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'resources'
            }
        });
    }
}
