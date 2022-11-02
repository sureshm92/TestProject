import { LightningElement, api, track } from 'lwc';
import setResourceAction from '@salesforce/apex/ResourceRemote.setResourceAction';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import { NavigationMixin } from 'lightning/navigation';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import Uploaded from '@salesforce/label/c.Resource_Uploaded';
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
    @api isVoted = false;

    label = {
        Uploaded
    };

    handleNavigate() {
        let detailLink =
            window.location.origin +
            '/pp/s/resource-detail' +
            '?resourceid=' +
            this.resourceId +
            '&resourcetype=' +
            this.resourceType;

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
        this.isFavourite = !this.isFavourite;
        setResourceAction({
            resourceId: this.resourceId,
            isFavorite: this.isFavourite,
            isVoted: false
        })
            .then((result) => {})
            .catch((error) => {
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
            });
            const favourite = new CustomEvent('favourite', {
                detail: {
                    isFavourite: this.isFavourite,
                    resourceId: this.resourceId
                }
            });
            this.dispatchEvent(favourite);
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
    handleDate(event) {
        this.initialDateLoaded = true;
        this.dt = event.target.value;
        this.tm = '';
        if (!this.dt) {
            this.timeOnlyPresent = true;
            this.tm = event.target.value;
            const nulldatetime = new CustomEvent('nulldatetime', {
                detail: {
                    compdate: this.dt,
                    comptime: this.tm
                }
            });
            this.dispatchEvent(nulldatetime);}}
}
