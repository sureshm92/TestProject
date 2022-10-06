import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getResources from '@salesforce/apex/ResourceRemote.getResources';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';

export default class PpResourceEngage extends LightningElement {
    //@api vars
    @api isRtl = false;
    @api desktop = false;
    resourcesData;
    //Boolean vars
    isInitialized = false;

    connectedCallback() {
        this.initializeData();
    }
    initializeData() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) {
            this.spinner.show();
        }
        getResources({ resourceType: 'Article;Video', resourceMode: 'Default' })
            .then((result) => {
               let allResources = result;
                console.log('ResourceData-->' + JSON.stringify(allResources.wrappers, null, 2));
                this.resourcesData= allResources.wrappers;
            })
            .catch((error) => {
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
            });
        this.isInitialized = true;
        if (this.spinner) {
            this.spinner.hide();
        }
    }
    showErrorToast(titleText, messageText, variantType) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: titleText,
                message: messageText,
                variant: variantType
            })
        );
    }
}
