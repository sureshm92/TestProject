import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import TIME_ZONE from '@salesforce/i18n/timeZone';

export default class PpSuggestedArticles extends NavigationMixin(LightningElement) {
    userTimezone = TIME_ZONE;
    resourcesData = [];
    showData = false;
    firstrender = true;
    @api resid;
    showRight = false;
    state;
    resTypeMap = new Map();
    scrollby = 729;
    dataWrapper;
    @api
    get suggestedArticlesData() {
        return this.dataWrapper;
    }
    set suggestedArticlesData(value) {
        this.dataWrapper = value;
        for (var i = 0; i < value.wrappers.length; i++) {
            if (this.resid != value.wrappers[i].resource.Id) {
                this.resourcesData.push(value.wrappers[i]);
                this.resTypeMap.set(
                    value.wrappers[i].resource.Id,
                    value.wrappers[i].resource.Content_Type__c
                );
            }
        }
        if (this.resourcesData.length > 0) this.showData = true;
    }
    renderedCallback() {
        if (this.template.querySelector('.topdiv')) {
            this.template
                .querySelector('.topdiv')
                .addEventListener('scroll', () => this.checkChevrons());
            var contents = this.template.querySelector('.topdiv');
            var divWidth = contents.offsetWidth;
            var scrollwidth = contents.scrollWidth;
            if (divWidth != scrollwidth) {
                this.showRight = true;
            }
            if (divWidth < 300) {
                this.scrollby = 243;
            }
        }
    }
    goLeft() {
        if (this.showRight) {
            var contents = this.template.querySelector('.topdiv');
            contents.scrollLeft -= this.scrollby;
            if (contents.scrollLeft <= this.scrollby) {
                this.template.querySelector('.chevronL').className = 'chevronL disableCursor';
            }
            this.template.querySelector('.chevronR').className = 'chevronR';
        }
    }
    goRight() {
        if (this.showRight) {
            var contents = this.template.querySelector('.topdiv');
            contents.scrollLeft += this.scrollby;
            this.template.querySelector('.chevronL').className = 'chevronL';

            var newScrollLeft = contents.scrollLeft;
            var divWidth = contents.offsetWidth;
            var scrollwidth = contents.scrollWidth;
            if (scrollwidth - divWidth - newScrollLeft < this.scrollby) {
                this.template.querySelector('.chevronR').className = 'chevronR disableCursor';
            }
        }
    }
    checkChevrons() {
        clearTimeout(this.timeoutId);
        this.timeoutId = setTimeout(this.doValidateChevron.bind(this), 750);
    }
    doValidateChevron() {
        var contents = this.template.querySelector('.topdiv');
        var newScrollLeft = contents.scrollLeft;
        var divWidth = contents.offsetWidth;
        var scrollwidth = contents.scrollWidth;
        if (scrollwidth - divWidth - newScrollLeft < 1) {
            this.template.querySelector('.chevronR').className = 'chevronR disableCursor';
        } else {
            this.template.querySelector('.chevronR').className = 'chevronR';
        }
        if (contents.scrollLeft == 0) {
            this.template.querySelector('.chevronL').className = 'chevronL disableCursor';
        } else {
            this.template.querySelector('.chevronL').className = 'chevronL';
        }
    }
    navigateToRes(event) {
        let detailLink =
            window.location.origin +
            '/pp/s/resource-detail' +
            '?resourceid=' +
            event.currentTarget.dataset.id +
            '&resourcetype=' +
            this.resTypeMap.get(event.currentTarget.dataset.id) +
            '&state=' +
            this.state;
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
