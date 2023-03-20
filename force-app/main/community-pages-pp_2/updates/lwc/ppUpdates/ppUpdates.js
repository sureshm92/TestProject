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
    @track resourcedData = [];
    resourcePresent = false;
    desktop = true;
    isInitialized = false;
    counter;
    counterLabel;
    displayCounter = false;
    open_new_tab = pp_community_icons + '/' + 'open_in_new.png';
    empty_state = pp_community_icons + '/' + 'empty_updates.PNG';
    link_state = pp_community_icons + '/' + 'linkssvg.svg';
    isRendered = false;
    offset = 0;
    limit = 4;
    callServer=true;
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
        this.callServer = false;
        console.log('limit : '+this.limit);
        console.log('offset : '+this.offset);
        console.log('desktop : '+this.desktop);
        console.log('showvisitsection : '+this.showvisitsection);
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner.show();
        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);
        this.getCount();
        this.getUpdates();
    }
    getCount(){
        getSendResultCount()
            .then((returnValue) => {
                this.counter = returnValue;
                this.displayCounter = true;
                if(this.counter<100){
                    this.counterLabel = this.counter;
                }else{
                    this.counterLabel = '99+';
                }
            })
            .catch((error) => {
                console.log('error message 1'+error.message);
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
                this.spinner.hide();
            });
    }
    getUpdates(){
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner.show();
        console.log('offset : '+this.offset);
        console.log('limit : '+this.limit);
        getSendResultUpdates({ offsets: this.offset, limits: this.limit })
            .then((returnValue) => {
                console.log('getSendResultUpdates : '+JSON.stringify(returnValue));
                this.resourcePresent = true;
                returnValue.forEach((resObj) => {
                    if (
                        resObj.contentType == 'Article' ||
                        resObj.contentType == 'Video'
                    ) {
                        resObj.isExplore = true;
                    } else if (resObj.contentType == 'Study_Document') {
                        resObj.isDoc = true;
                    } else if (resObj.contentType == 'Multimedia') {
                        resObj.isMultimedia = true;
                    } else if(resObj.contentType == 'Relevant_Link') {
                        resObj.isLink = true;
                    }else if(resObj.contentType == 'Televisit') {
                        resObj.isTelevisit = true;
                    }
                });
                this.resourcedData = [...this.resourcedData, ...returnValue];
                this.offset += this.limit;
                this.spinner.hide();
                this.callServer = true;
                console.log('getSendResultUpdates : '+JSON.stringify(returnValue));
            })
            .catch((error) => {
                console.log('error message 2'+error.message);
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
                this.spinner.hide();
            });
    }
    handleScroll(event) {
        console.log('scroll');
        const container = event.target;
        const { scrollLeft, scrollWidth, clientWidth } = container;
        console.log('scrollLeft '+scrollLeft);
        //console.log('clientWidth '+Math.ceil(1.045));
        console.log('clientWidth '+clientWidth);
        console.log('scrollWidth '+scrollWidth);
        if ( (this.counter > this.offset) && this.callServer && (scrollLeft + clientWidth + 1>= scrollWidth) ) {
            this.getUpdates();
        }
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
/*
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
    */
}
