import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getSendResultUpdates from '@salesforce/apex/PPUpdatesController.getSendResultUpdates';
import getSendResultCount from '@salesforce/apex/PPUpdatesController.getSendResultCount';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
import DEVICE from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import updatesLabel from '@salesforce/label/c.Updates_Label';
import viewAllResource from '@salesforce/label/c.View_All_Resource';
import caughtup from '@salesforce/label/c.Caught_up';
export default class PpUpdates extends NavigationMixin(LightningElement) {
    @api desktop;
    @api showvisitsection;
    linksWrappers = [];
    resourcedData = [];
    resourcePresent = false;
    desktop = true;
    isInitialized = false;
    counter;
    displayCounter = false;
    open_new_tab = pp_community_icons + '/' + 'open_in_new.png';
    empty_state = pp_community_icons + '/' + 'empty_updates.PNG';
    link_state = pp_community_icons + '/' + 'linkssvg.svg';
    isRendered = false;
    label = {
        updatesLabel,
        viewAllResource,
        caughtup
    };

    renderedCallback() {
        if (!this.isRendered) {
            this.isRendered = true;
            this.initializeData();
        }
    }

    initializeData() {
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner.show();
        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);
        getSendResultCount()
            .then((returnValue) => {
                this.counter = returnValue;
                this.displayCounter = true;
            })
            .catch((error) => {
                console.log('error message');
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
                this.spinner.hide();
            });
        getSendResultUpdates()
            .then((returnValue) => {
                this.spinner.hide();
                console.log('getSendResultUpdates : '+JSON.stringify(returnValue));
                this.resourcePresent = true;
                this.resourcedData = returnValue;
                this.resourcedData.forEach((resObj) => {
                    if (
                        resObj.contentType == 'Article' ||
                        resObj.contentType == 'Video'
                    ) {
                        resObj.isExplore = true;
                    } else if (resObj.contentType == 'Study_Document') {
                        resObj.isDoc = true;
                    } else if (resObj.contentType == 'Multimedia') {
                        resObj.isMultimedia = true;
                    } else {
                        resObj.isLink = true;
                    }
                });
                console.log('getSendResultUpdates : '+JSON.stringify(returnValue));
            })
            .catch((error) => {
                console.log('error message');
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
                this.spinner.hide();
            });
    }

    openLink(event) {
        window.open(event.currentTarget.dataset.link, '_blank');
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
