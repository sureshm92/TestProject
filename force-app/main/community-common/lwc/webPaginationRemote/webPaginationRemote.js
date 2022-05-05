/**
 * Created by Yulia Yakushenkova on 12/2/2019.
 */

import { LightningElement, api, track } from 'lwc';
import labelName from '@salesforce/label/c.PG_FP_L_of';

export default class WebPaginationRemote extends LightningElement {
    //Attributes--------------------------------------------------------------------------------------------------------
    @api currentPage;
    @track totalPages;
    recordsToDisplay = [];
    _allRecordsCount;
    @track _recordsList;
    _entriesOnPage;

    @api
    get recordsCount() {
        return this._allRecordsCount;
    }
    set recordsCount(value) {
        this._allRecordsCount = value;
    }

    @api
    get recordsList() {
        return this._recordsList;
    }
    set recordsList(value) {
        this.handleChange(value);
    }
    handleChange(value) {
        this._recordsList = JSON.parse(JSON.stringify(value));
        this.currentPage = 1;
        this.calcTotalPages();
    }
    @api
    get entries() {
        return this._entriesOnPage;
    }
    set entries(value) {
        this._entriesOnPage = value;
    }

    //Inner methods-----------------------------------------------------------------------------------------------------

    calcTotalPages() {
        this.allRecordsCount = this._recordsList.length;
        this.totalPages = Math.ceil(this.allRecordsCount / this._entriesOnPage);
        this._allRecordsCount = this._recordsList.length;
        this.loadTabRecords();
    }

    nextPageClick() {
        if (this.currentPage <= this.totalPages) this.currentPage = this.currentPage + 1;
        this.loadTabRecords();
    }

    prevPageClick() {
        if (this.currentPage > 1) this.currentPage -= 1;
        this.loadTabRecords();
    }

    //Expressions for html attributes-----------------------------------------------------------------------------------
    get positiveTotalPages() {
        return this.totalPages > 0;
    }

    get currentPagesOfTotalPages() {
        return this.currentPage + ' ' + labelName + ' ' + this.totalPages;
    }

    get previousBtnCss() {
        return (
            'previous-btn slds-button slds-button_neutral' +
            (this.currentPage === 1 ? ' disabled' : '')
        );
    }

    get nextBtnCss() {
        return (
            'next-btn slds-button slds-button_neutral' +
            (this.currentPage === (this.totalPages === 0 ? 1 : this.totalPages) ? ' disabled' : '')
        );
    }

    loadTabRecords() {
        this.recordsToDisplay = [];
        for (
            let i = (this.currentPage - 1) * this._entriesOnPage;
            i < this.currentPage * this._entriesOnPage;
            i++
        ) {
            if (i === this.allRecordsCount) break;
            this.recordsToDisplay.push(this._recordsList[i]);
        }
        this.dispatchEvent(new CustomEvent('paginatorchange', { detail: this.recordsToDisplay }));
    }
}
