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
import load_more from '@salesforce/label/c.PP_Load_More';
export default class PpUpdates extends NavigationMixin(LightningElement) {
    @api desktop;
    @api showvisitsection;
    @api counter;
    linksWrappers = [];
    @track resourcedData = [];
    resourcePresent = false;
    desktop = true;
    isInitialized = false;
    open_new_tab = pp_community_icons + '/' + 'open_in_new.png';
    empty_state = pp_community_icons + '/' + 'empty_updates.PNG';
    link_state = pp_community_icons + '/' + 'linkssvg.svg';
    refresh_icon = pp_community_icons + '/' + 'refresh_Icon.svg';
    loadmore_icon = pp_community_icons + '/' + 'down.svg';
    isRendered = false;
    offset = 0;
    limit = 4;
    label = {
        updatesLabel,
        viewAllResource,
        caughtup,
        refresh,
        load_more
    };
    timer;
    initialLoadTime;
    loadMoreValue;
    get showloadMore() {
        if (this.counter > 4 && this.loadMoreValue && this.counter > this.offset) {
            return true;
        } else {
            return false;
        }
    }
    get hor_scroll() {
        if (this.counter > 4 && this.desktop && !this.showvisitsection) {
            return 'slds-grid horizontal-scroll';
        } else if (this.counter <= 4 && this.desktop && !this.showvisitsection) {
            return 'slds-grid';
        }
    }
    get ver_scroll() {
        if (this.counter > 4 && this.desktop && this.showvisitsection) {
            return 'slds-card__body slds-card__body_inner custom-padding vertical-scroll';
        } else if (this.counter <= 4 && this.desktop && this.showvisitsection) {
            return 'slds-card__body slds-card__body_inner custom-padding';
        }
    }
    get displayCounter() {
        if (this.counter > 0) {
            return true;
        } else {
            return false;
        }
    }
    get counterLabel() {
        if (this.counter < 100 && this.counter > 0) {
            return this.counter;
        } else if (this.counter >= 100) {
            return '99+';
        }
    }
    renderedCallback() {
        if (!this.isRendered) {
            this.initialLoadTime = new Date().toISOString().slice(0, -5).replace('T', ' ');
            this.isRendered = true;
            this.initializeData();
        }
    }

    initializeData() {
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner.show();
        DEVICE == 'Large' ? (this.desktop = true) : (this.desktop = false);
        this.getCount();
    }
    getCount() {
        this.getUpdates();
    }
    getUpdates() {
        this.spinner = this.template.querySelector('c-web-spinner');
        getSendResultUpdates({
            offsets: this.offset,
            limits: this.limit,
            initialLoadTime: this.initialLoadTime
        })
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
                    } else if (resObj.contentType == 'VisitResult') {
                        resObj.isVisitResult = true;
                    } else {
                        resObj.isMultimedia = true;
                    }
                });
                this.resourcedData = [...this.resourcedData, ...returnValue];
                if (this.resourcedData.length > 0) {
                    this.resourcePresent = true;
                }
                this.offset += this.limit;
                this.loadMoreValue = true;
                this.spinner.hide();
            })
            .catch((error) => {
                console.log('error message : ' + JSON.stringify(error));
                this.spinner.hide();
            });
    }
    refreshUpdatesData() {
        getSendResultCount({ initialLoadTime: this.initialLoadTime })
            .then((returnValue) => {
                this.counter = returnValue;
                this.getUpdates();
            })
            .catch((error) => {
                console.log('error message : ' + JSON.stringify(error));
                this.spinner.hide();
            });
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
        this.initialLoadTime = new Date().toISOString().slice(0, -5).replace('T', ' ');
        this.counter = 0;
        this.offset = 0;
        this.limit = 4;
        this.resourcedData = [];
        clearTimeout(this.timer);
        this.timer = setTimeout(() => {
            this.refreshUpdatesData();
        }, 1000);
    }
    loadMore() {
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner.show();
        this.getUpdates();
    }
    handleRemoveCard(event) {
        const sendResultId = event.detail.sendResultId;
        removeCard({ sendResultId: sendResultId })
            .then((returnValue) => {})
            .catch((error) => {
                console.log('error message ' + JSON.stringify(error));
            });
    }
}
