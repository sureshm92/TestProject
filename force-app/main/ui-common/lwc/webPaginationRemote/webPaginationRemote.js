/**
 * Created by Yulia Yakushenkova on 12/2/2019.
 */

import {LightningElement, api, track} from 'lwc';
import labelName from '@salesforce/label/c.PG_FP_L_of';

export default class WebPaginationRemote extends LightningElement {

    //Attributes--------------------------------------------------------------------------------------------------------
    @api currentPage;
    @track totalPages;

    @api
    get allRecordsCount() {
        return this._allRecordsCount;
    }
    set allRecordsCount(value) {
        this._allRecordsCount = value;
        this.calcTotalPages();
    }

    @api
    get entriesOnPage() {
        return this._entriesOnPage;
    }
    set entriesOnPage(value) {
        this._entriesOnPage = value;
        this.calcTotalPages();
    }

    //Inner methods-----------------------------------------------------------------------------------------------------
    connectedCallback() {
        this.calcTotalPages();
    }

    calcTotalPages() {
        this.totalPages = Math.ceil(this.allRecordsCount / this.entriesOnPage);
    }

    nextPageClick() {
        if(this.currentPage < this.totalPages) this.currentPage += 1;

        const changeEvent = new CustomEvent('change', {});
        this.dispatchEvent(changeEvent);
    }

    prevPageClick() {
        if(this.currentPage > 1) this.currentPage -= 1;

        const changeEvent = new CustomEvent('change', {});
        this.dispatchEvent(changeEvent);
    }

    //Expressions for html attributes-----------------------------------------------------------------------------------
    get positiveTotalPages() {
        return this.totalPages > 0;
    }

    get currentPagesOfTotalPages() {
        return this.currentPage + ' ' + labelName + ' ' + this.totalPages;
    }

    get previousBtnCss(){
        return 'previous-btn slds-button slds-button_neutral' + (this.currentPage === 1 ? ' disabled' : '');
    }

    get nextBtnCss(){
        return 'next-btn slds-button slds-button_neutral' + (this.currentPage === (this.totalPages === 0 ? 1 : this.totalPages) ? ' disabled' : '');
    }
}