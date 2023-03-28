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
import refresh from '@salesforce/label/c.PP_Update_Refresh';
export default class PpUpdates extends NavigationMixin(LightningElement) {
    @api desktop;
    @api showvisitsection;
    linksWrappers = [];
    @track resourcedData = [];
    resourcePresent = false;
    desktop = true;
    isInitialized = false;
    counter = 0;
    counterLabel = 0;
    displayCounter = false;
    open_new_tab = pp_community_icons + '/' + 'open_in_new.png';
    empty_state = pp_community_icons + '/' + 'empty_updates.PNG';
    link_state = pp_community_icons + '/' + 'linkssvg.svg';
    refresh_icon = pp_community_icons + '/' + 'refresh_Icon.svg';
    isRendered = false;
    offset = 0;
    limit = 4;
    label = {
        updatesLabel,
        viewAllResource,
        caughtup,
        refresh
    };
    timer;

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
        this.getCount();
    }
    getCount() {
        getSendResultCount()
            .then((returnValue) => {
                this.counter = returnValue;
                if (this.counter < 100 && this.counter > 0) {
                    this.displayCounter = true;
                    this.counterLabel = this.counter;
                    this.resourcePresent = true;
                } else if (this.counter >= 100) {
                    this.displayCounter = true;
                    this.counterLabel = '99+';
                    this.resourcePresent = true;
                }else if(this.counter <= 0){
                    this.resourcePresent = false;
                    this.displayCounter = false;
                }
                this.getUpdates();
            })
            .catch((error) => {
                console.log('counter failed');
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
                this.spinner.hide();
            });
    }
    getUpdates() {
        this.spinner = this.template.querySelector('c-web-spinner');
        getSendResultUpdates({ offsets: this.offset, limits: this.limit })
            .then((returnValue) => {
                returnValue.forEach((resObj) => {
                    if (resObj.contentType == 'Article' || resObj.contentType == 'Video') {
                        resObj.isExplore = true;
                    } else if (resObj.contentType == 'Study_Document') {
                        resObj.isDoc = true;
                    } else if (resObj.contentType == 'Multimedia') {
                        resObj.isMultimedia = true;
                    } else if (resObj.contentType == 'Relevant_Link') {
                        resObj.isLink = true;
                    } else if (resObj.contentType == 'Televisit') {
                        resObj.isTelevisit = true;
                    }
                });
                this.resourcedData = [...this.resourcedData, ...returnValue];
                if (this.resourcedData.length > 0) {
                    this.resourcePresent = true;
                }
                this.offset += this.limit;
                if (this.showvisitsection) {
                    this.addVerticalScroll();
                } else {
                    this.addHorizontalScroll();
                }
                this.spinner.hide();
            })
            .catch((error) => {
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
                this.spinner.hide();
            });
    }
    addHorizontalScroll() {
        if (this.counter > 4 && this.desktop && !this.showvisitsection) {
            const myDiv = this.template.querySelector('.resouce-container-horizontal');
            myDiv.classList.add('horizontal-scroll');
        }
    }
    addVerticalScroll() {
        if (this.counter > 4 && this.desktop && this.showvisitsection) {
            const myDiv = this.template.querySelector('.custom-padding');
            myDiv.classList.add('vertical-scroll');
        }
    }
    handleScroll(event) {
        const container = event.target;
        const { scrollLeft, scrollWidth, clientWidth } = container;
        if (this.counter > this.offset && Math.ceil(scrollLeft) + clientWidth + 20 >= scrollWidth) {
            this.spinner = this.template.querySelector('c-web-spinner');
            this.spinner.show();
            clearTimeout(this.timer);
            this.timer = setTimeout(() => {
                this.getUpdates();
            }, 1000);
        }
    }
    handleVerticalScroll(event) {
        const container = event.target;
        const { scrollTop, scrollHeight, clientHeight } = container;
        if (this.counter > this.offset && scrollTop + clientHeight + 20 >= scrollHeight) {
            this.spinner = this.template.querySelector('c-web-spinner');
            this.spinner.show();
            clearTimeout(this.timer);
            this.timer = setTimeout(() => {
                this.getUpdates();
            }, 1000);
        }
    }
    refresh() {
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner.show();
        this.counter = 0;
        this.displayCounter = false;
        this.offset = 0;
        this.limit = 4;
        this.resourcedData = [];
        clearTimeout(this.timer);
        this.timer = setTimeout(() => {
            this.initializeData(); 
        }, 1000);
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
}