import { LightningElement, api, track } from 'lwc';
import community_icon from '@salesforce/resourceUrl/rr_community_icons';
import RH_RP_Items from '@salesforce/label/c.RH_RP_Items';
import RH_RP_of from '@salesforce/label/c.RH_RP_of';
import RH_RP_Page from '@salesforce/label/c.RH_RP_Page';

const DELAY = 300;
const recordsPerPage = 10;
const pageNumber = 1;
const showIt = 'visibility:visible';
const hideIt = 'visibility:hidden'; //visibility keeps the component space, but display:none doesn't
export default class Paginator extends LightningElement {
    @api showSearchBox = false; //Show/hide search box; valid values are true/false
    @api showPagination; //Show/hide pagination; valid values are true/false
    //@api pageSizeOptions = recordsPerPage; //Page size options; valid values are array of integers
    @api totalRecords; //Total no.of records; valid type is Integer
    @api records; //All records available in the data table; valid type is Array
    @track pageSize; //No.of records to be displayed per page
    @track totalPages; //Total no.of pages
    @track pageNumber = pageNumber; //Page number
    @track searchKey; //Search Input
    @track controlPagination = showIt;
    @track controlPrevious = hideIt; //Controls the visibility of Previous page button
    @track controlNext = showIt; //Controls the visibility of Next page button
    recordsToDisplay = []; //Records to be displayed on the page
    @track recordsPerPage = recordsPerPage;

    @track firstDisabled = false;
    @track nextDisabled = false;
    @track lastDisabled = false;
    @track previousDisabled = false;

    @track startRecord;
    @track endRecord;
    @track end = false;

    label = {
        RH_RP_Items,
        RH_RP_of,
        RH_RP_Page
    };

    left_arrow = community_icon + '/left-arrow.svg';
    first_page_arrow = community_icon + '/first-page-arrow.svg';

    //Called after the component finishes inserting to DOM
    connectedCallback() {
        if (this.recordsPerPage > 0) {
            this.pageSize = this.recordsPerPage;
            this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        } else {
            this.pageSize = this.totalRecords;
            this.showPagination = false;
        }
        this.controlPagination = this.showPagination === false ? hideIt : showIt;
        this.setRecordsToDisplay();
    }

    handleRecordsPerPage(event) {
        this.records = event.target.value;
    }

    setRecords(event) {
        this.setRecordsToDisplay();
    }
    handlePageNumberChange(event) {
        let totalpgs =  Math.ceil(this.totalRecords / this.pageSize)
        if (event.target.value > 0 && event.target.value <= totalpgs ){
            this.pageNumber =  parseInt(event.target.value) ;
            this.setRecordsToDisplay();
        }
        else if (!event.target.value) {
            this.pageNumber = this.pageNumber;
            this.setRecordsToDisplay();
        }else if (event.target.value > totalpgs){
            this.pageNumber = totalpgs;
            this.setRecordsToDisplay();
        }
    }
    previousPage() {
        if (this.pageNumber > 1) {
            this.pageNumber = this.pageNumber - 1;
            this.setRecordsToDisplay();
        }
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.setRecordsToDisplay();
    }
    firstPage() {
        this.pageNumber = 1;
        this.setRecordsToDisplay();
    }

    lastPage() {
        this.pageNumber = this.totalRecords;
        this.setRecordsToDisplay();
    }
    @api
    setPageNumber() {
        this.pageNumber = 1;
    }
    @api
    refreshPageNumber() {
        let currentpgno =  this.pageNumber ;
        if(currentpgno > Math.ceil(this.totalRecords / this.pageSize)){
            //this.pageNumber =  this.pageNumber - 1;
            this.pageNumber =  Math.ceil(this.totalRecords / this.pageSize);
        }
        this.setRecordsToDisplay();
    }
    @api
    setRecordsToDisplay() {

        if (this.totalRecords == 0) {
            this.showPagination = false;
        } else {
            this.showPagination = true;
        }
        this.recordsToDisplay = [];
        if (!this.pageSize) this.pageSize = this.totalRecords;
       
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);

        let begin = (this.pageNumber - 1) * this.recordsPerPage;
        let end = begin + this.recordsPerPage;
        if (this.totalRecords == 0) {
            this.startRecord = this.totalRecords;
        } else if (begin < this.totalRecords) {
            this.startRecord = begin + 1;
        }else if(this.totalRecords <= 10){
            this.startRecord = 1;
        }

        this.endRecord = end > this.totalRecords ? this.totalRecords : end;
    
        this.end = end > this.totalRecords ? true : false;
        this.setPaginationControls();

        for (
            let i = (this.pageNumber - 1) * this.pageSize;
            i < this.pageNumber * this.pageSize;
            i++
        ) {
            if (i === this.totalRecords) break;
            this.recordsToDisplay.push(this.records[i]);
        }
        this.dispatchEvent(new CustomEvent('paginatorchange', { detail: this.recordsToDisplay })); //Send records to display on table to the parent component
    }

    changeStyle1 = false;
    changeStyle2 = false;
    changeStyle3 = false;


    get class1(){
        return this.changeStyle1 ? 'first-page-arrow-button-icon-s2': 'first-page-arrow-button-icon-s1';
    }

    get class2(){
        return this.changeStyle2 ? 'iconColorChange1': 'iconColorChange2';
    }

    get class3(){
        return this.changeStyle3 ? 'iconColorChange2': 'iconColorChange1';
    }


    setPaginationControls() {
        this.changeStyle1 = false;
        this.changeStyle2 = false;
        this.changeStyle3 = false;

        //Control Pre/Next buttons visibility by Total 
        if (this.pageNumber === 1) {
            this.changeStyle1 = true;
        }
        else if (this.totalPages > 1) {
            this.changeStyle2 = true;
        }
        else if (this.pageNumber == this.totalPages) {
            this.changeStyle3 = true;
        }
        if (this.totalPages === 1) {
            this.firstDisabled = true;
            this.nextDisabled = true;
            this.lastDisabled = true;
            this.previousDisabled = true;
        } else if (this.totalPages > 1) {
            this.firstDisabled = false;
            this.nextDisabled = false;
            this.lastDisabled = false;
            this.previousDisabled = false;
            
        }
        //Control Pre/Next buttons visibility by Page number
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
            this.lastDisabled = true;
            this.previousDisabled = true;        
        } 
        else if (this.pageNumber >= this.totalPages) {
            this.changeStyle3 = true;

            this.pageNumber = this.totalPages;
            this.firstDisabled = true;
            this.nextDisabled = true;
        }
        //Control Pre/Next buttons visibility by Pagination visibility
        if (this.controlPagination === hideIt) {
            this.controlPrevious = hideIt;
            this.controlNext = hideIt;
        }
    }

    setPaginationControls1() {
        //Control Pre/Next buttons visibility by Total pages
        if (this.totalPages === 1) {
            this.controlPrevious = hideIt;
            this.controlNext = hideIt;
        } else if (this.totalPages > 1) {
            this.controlPrevious = showIt;
            this.controlNext = showIt;
        }
        //Control Pre/Next buttons visibility by Page number
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
            this.controlPrevious = hideIt;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
            this.controlNext = hideIt;
        }
        //Control Pre/Next buttons visibility by Pagination visibility
        if (this.controlPagination === hideIt) {
            this.controlPrevious = hideIt;
            this.controlNext = hideIt;
        }
    }
    handleKeyChange(event) {
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        if (searchKey) {
            this.delayTimeout = setTimeout(() => {
                this.controlPagination = hideIt;
                this.setPaginationControls();

                this.searchKey = searchKey;
                //Use other field name here in place of 'Name' field if you want to search by other field
                //this.recordsToDisplay = this.records.filter(rec => rec.includes(searchKey));
                //Search with any column value (Updated as per the feedback)
                this.recordsToDisplay = this.records.filter((rec) =>
                    JSON.stringify(rec).includes(searchKey)
                );
                if (Array.isArray(this.recordsToDisplay) && this.recordsToDisplay.length > 0)
                    this.dispatchEvent(
                        new CustomEvent('paginatorchange', { detail: this.recordsToDisplay })
                    ); //Send records to display on table to the parent component
            }, DELAY);
        } else {
            this.controlPagination = showIt;
            this.setRecordsToDisplay();
        }
    }
}