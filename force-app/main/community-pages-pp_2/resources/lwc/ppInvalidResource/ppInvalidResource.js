import { LightningElement, api } from 'lwc';
import PP_Invalid_Resource from '@salesforce/label/c.PP_Invalid_Resource';
import PP_Available_Resources from '@salesforce/label/c.PP_Available_Resources';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
export default class PpInvalidResource extends LightningElement {
    @api resourceType;
    showButton = true;
    invalidResource = pp_community_icons + '/' + 'invalidResource.svg';
    label = { PP_Invalid_Resource, PP_Available_Resources };

    connectedCallback() {
        if (this.resourceType == 'Article' || this.resourceType == 'Video') {
            showButton = false;
        }
    }

    handleViewResources() {
        const viewResources = new CustomEvent('viewresources', {
            detail: {
                backToHome: false
            }
        });
        this.dispatchEvent(viewResources);
    }
}
