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
    @track end = false;

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
        //this.setRecordsToDisplay();
    }

    calcTotalPages() {
        this.totalPages = Math.ceil(this.allRecordsCount / this.entriesOnPage);
    }

    nextPageClick() {
        if (this.currentPage < this.totalPages) this.currentPage += 1;

        const changeEvent = new CustomEvent('change', {});
        this.dispatchEvent(changeEvent);
    }

    prevPageClick() {
        if (this.currentPage > 1) this.currentPage -= 1;

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
    @api
    setRecordsToDisplay() {
        this.recordsToDisplay = [];
        if (!this.entriesOnPage) this.entriesOnPage = this.allRecordsCount;

        let begin = (this.currentPage - 1) * this.recordsPerPage;
        let end = begin + this.recordsPerPage;
        if (this.allRecordsCount == 0) {
            this.startRecord = this.allRecordsCount;
        } else if (begin < this.allRecordsCount) {
            this.startRecord = begin + 1;
        } else if (this.allRecordsCount <= 10) {
            this.startRecord = 1;
        }

        this.endRecord = end > this.allRecordsCount ? this.allRecordsCount : end;

        this.end = end > this.allRecordsCount ? true : false;

        for (
            let i = (this.currentPage - 1) * this.entriesOnPage;
            i < this.currentPage * this.entriesOnPage;
            i++
        ) {
            if (i === this.allRecordsCount) break;
            this.recordsToDisplay.push(this.records[i]);
        }
        this.dispatchEvent(new CustomEvent('paginatorchange', { detail: this.recordsToDisplay })); //Send records to display on table to the parent component
    }
}
