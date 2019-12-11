/**
 * Created by Igor Malyuta on 29.11.2019.
 */

import {LightningElement, track} from 'lwc';

export default class LwcTestPage extends LightningElement {

    currentPage = 1;
    totalPages;
    @track allRecordsCount = 20;

    @track queryTerm;

    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            this.queryTerm = evt.target.value;
        }
    }

    handleShow() {
        this.template.querySelector('c-web-popup').show();
    }

    doShare() {
        alert('Share@');
    }

    doCancel() {
        this.template.querySelector('c-web-popup').hide();
    }

    changePagination(evt) {
        this.allRecordsCount++;
    }

    doChange() {
        console.log('Change Pagination' + this.allRecordsCount);
    }
}