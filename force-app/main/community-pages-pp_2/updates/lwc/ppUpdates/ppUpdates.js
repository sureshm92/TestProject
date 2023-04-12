import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSendResultUpdates from '@salesforce/apex/PPUpdatesController.getSendResultUpdates';
import getSendResultCount from '@salesforce/apex/PPUpdatesController.getSendResultCount';
import removeCard from '@salesforce/apex/PPUpdatesController.removeUpdateCard';
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
    @api counter;
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
    get countOvalStyle() {
        if (this.counter >= 10) {
            return 'update-counter-oval-2 slds-align_absolute-center';
        } else {
            return 'update-counter-oval-1 slds-align_absolute-center';
        }
    }

    get countStyle() {
        if (this.counter >= 10) {
            return 'update-count-2';
        } else {
            return 'update-count-1';
        }
    }
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
        this.showCounterCheck();
        this.getUpdates();
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
                console.log('error message : ' + error?.message);
                this.spinner.hide();
            });
    }
    refreshUpdatesData() {
        getSendResultCount()
            .then((returnValue) => {
                this.counter = returnValue;
                this.showCounterCheck();
                this.getUpdates();
            })
            .catch((error) => {
                console.log('error message : ' + error?.message);
                this.spinner.hide();
            });
    }
    addHorizontalScroll() {
        if (this.counter > 4 && this.desktop && !this.showvisitsection) {
            var scrollDiv = this.template.querySelector('[data-id = "horz_scroll"]');
            scrollDiv.classList.add('horizontal-scroll');
        } else if (this.counter <= 4 && this.desktop && !this.showvisitsection) {
            const myDiv = this.template.querySelector('.horizontal-scroll');
            if (myDiv) {
                myDiv.classList.remove('horizontal-scroll');
            }
        }
    }
    addVerticalScroll() {
        if (this.counter > 4 && this.desktop && this.showvisitsection) {
            var scrollDiv = this.template.querySelector('[data-id = "vert_scroll"]');
            scrollDiv.classList.add('vertical-scroll');
        } else if (this.counter <= 4 && this.desktop && this.showvisitsection) {
            const myDiv = this.template.querySelector('.vertical-scroll');
            if (myDiv) {
                myDiv.classList.remove('vertical-scroll');
            }
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
            this.refreshUpdatesData();
        }, 1000);
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
    handleRemoveCard(event) {
        const sendResultId = event.detail.sendResultId;
        removeCard({ sendResultId: sendResultId })
            .then((returnValue) => {})
            .catch((error) => {
                console.log('error message ' + error?.message);
            });
    }
    showCounterCheck() {
        if (this.counter < 100 && this.counter > 0) {
            this.displayCounter = true;
            this.counterLabel = this.counter;
            this.resourcePresent = true;
        } else if (this.counter >= 100) {
            this.displayCounter = true;
            this.counterLabel = '99+';
            this.resourcePresent = true;
        } else if (this.counter <= 0) {
            this.resourcePresent = false;
            this.displayCounter = false;
        }
    }
}
