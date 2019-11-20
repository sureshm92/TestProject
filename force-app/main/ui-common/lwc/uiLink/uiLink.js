/**
 * Created by Igor Malyuta on 18.11.2019.
 */

import {LightningElement, api, track, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class UiLink extends NavigationMixin(LightningElement) {

    @api label;
    @api page;
    @api classCss = '';
    @api maxWidth;

    currentPage;
    pageUrl;
    pageState;

    connectedCallback() {
        this.currentPage = window.location.href + this.page;
        let pagePart = this.page.split('?');
        this.pageUrl = pagePart[0];

        this.pageState = {};
        let query = pagePart[1].split('&');
        for(let pq in query){
            let param = query[pq].split('=');
            this.pageState[param[0]] = param[1];
        }
    }

    handleClick(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: this.pageUrl
            },
            state: this.pageState
        });
    }

    //Expressions for html attributes-----------------------------------------------------------------------------------
    get cssClass() {
        return this.classCss + ' rr-link ' +
            (this.maxWidth !== undefined ? 'limit-width' : '') +
            (this.label !== undefined ? ' only-text' : '');
    }

    get cssStyle() {
        return this.maxWidth !== undefined ? 'max-width: ' + this.maxWidth : '';
    }

    get linkLabel() {
        return this.body === undefined ? this.label : this.body;
    }
}