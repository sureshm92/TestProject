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
            this.showButton = false;
        }
    }

    get cardStyle() {
        return this.resourceType == 'Article' || this.resourceType == 'Video'
            ? 'slds-grid slds-grid_vertical slds-grid_vertical-align-center card-container medium'
            : 'slds-grid slds-grid_vertical slds-grid_vertical-align-center slds-grid_align-center card-container elongate';
    }
    get imageStyle() {
        return this.resourceType == 'Article' || this.resourceType == 'Video'
            ? 'slds-col slds-m-top_x-large'
            : 'slds-col';
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
