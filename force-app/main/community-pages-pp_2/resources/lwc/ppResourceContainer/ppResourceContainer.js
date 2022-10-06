import { LightningElement, api, track } from 'lwc';
import setResourceAction from '@salesforce/apex/ResourceRemote.setResourceAction';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import { NavigationMixin } from 'lightning/navigation';

export default class PpResourceContainer extends NavigationMixin(LightningElement) {
    userTimezone = TIME_ZONE;
    //@api vars
    @api isRtl = false;
    @api desktop = false;
    @api thumbnail;
    @api resourceType;
    @api resourceId;
    @api resourceTitle;
    @api resUploadDate;
    @api isFavourite = false;
    @api resourceSummary;
    @api isVoted=false;

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
        console.log('resourceid-->' + this.resourceId);
        console.log('key-->' + this.key);
        this.isInitialized = true;
        if (this.spinner) {
            this.spinner.hide();
        }
    }
    handleNavigate() {
        let detailLink =
            window.location.origin + '/pp/s/resource-detail' + '?resourceid=' + this.resourceId;

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
    handleFavourite() {
        this.isFavourite=!this.isFavourite;
        setResourceAction({ resourceId: this.resourceId, isFavorite: this.isFavourite, isVoted: false })
            .then((result) => {
                
            })
            .catch((error) => {
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
            });
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
