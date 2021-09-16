import { LightningElement, track, wire, api } from 'lwc';
import getPEDetails from '@salesforce/apex/RPRecordReviewLogController.getPEDetails';
import community_icon from '@salesforce/resourceUrl/rr_community_icons';
import { refreshApex } from '@salesforce/apex';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';

export default class RP_NonReferredTable extends NavigationMixin(LightningElement) {
    @api userMode;
    @api delegateId;
    @api hidePatientTabComp = false;
    isLoading = false;
    data = [];
    @track error;
    @track showTable = false; //Used to render table after we get the data from apex controller
    noFilterRecords = false;
    recordsToDisplay = []; //Records to be displayed on the page
    @track rowNumberOffset; //Row number
    @track isModalOpen = false;
    masterData = [];
    @track masterFilterData = [];
    //get icons from static resource to be displayed on the page
    refresh_icon = community_icon + '/Refresh_Icons.png';
    filter_icon = community_icon + '/NoFilterApplied.svg';
    isFilterApplied = false;
    showFilterModal = false;
    disableFilter = false;
    searchValue = '';
    @track apexRefreshList = [];
    @api isProfilePage;
    @api isBulkProfilePage;
    @api browserstore;
    @api isExcludedforReferring = false;
    @api allRecords;
    isPaginationApplied = false;
    isSelectAll = false;
    @api peRecordList;

    constructor() {
        super();
        this.isLoading = true;
    }

    connectedCallback() {
        this.getDetailsApex();
    }

    @api
    getPatientRecords() {
        var panginationRecList = [];
        var allRecList = [];

        let paginationRecord = JSON.parse(JSON.stringify(this.recordsToDisplay));        
        for (var i = 0; i < paginationRecord.length; i++) {
            if(paginationRecord[i].peRec.Id == this.peRecordList[0].peRecord.Id){
                paginationRecord[i].peRec.Patient_ID__c = this.peRecordList[0].peRecord.Patient_ID__c;
                paginationRecord[i].peRec.Participant_Surname__c = this.peRecordList[0].peRecord.Participant_Surname__c;
                paginationRecord[i].doBFormat = this.peRecordList[0].peRecord.Birth_Month__c+'/'+this.peRecordList[0].peRecord.YOB__c;
            }
            panginationRecList.push(paginationRecord[i]);
        }

        let allRecords = JSON.parse(JSON.stringify(this.data));        
        for (var i = 0; i < allRecords.length; i++) {
            if(allRecords[i].peRec.Id == this.peRecordList[0].peRecord.Id){
                allRecords[i].peRec.Patient_ID__c = this.peRecordList[0].peRecord.Patient_ID__c;
                allRecords[i].peRec.Participant_Surname__c = this.peRecordList[0].peRecord.Participant_Surname__c;
                allRecords[i].doBFormat = this.peRecordList[0].peRecord.Birth_Month__c+'/'+this.peRecordList[0].peRecord.YOB__c;
            }
            allRecList.push(allRecords[i]);
        }
        this.recordsToDisplay = [];
        this.recordsToDisplay = panginationRecList;   

        this.data = [];
        this.data = allRecList;   

    }

    getDetailsApex() {
        getPEDetails()
            .then((result) => {
                this.allRecords = result;
                let includedRecords = result.filter(function(include) {
                return include.peRec.Participant_Status__c != "Excluded from Referring"; });
                this.apexRefreshList = includedRecords;
                this.data = includedRecords;
                this.masterData = includedRecords;
                this.recordsToDisplay = includedRecords;
                this.error = undefined;
                this.isExcludedforReferring = false;
                //for empty records check
                if (this.recordsToDisplay.length > 0) {
                    this.showTable = true;
                } else {
                    this.showTable = false;
                }
                this.isLoading = false;
            })
            .catch((error) => {
                console.log(error);
            });
    }

    handleExcludeRecords(event) {
       this.isExcludedforReferring = event.detail;
       console.log('Event Triggered---->'+this.isExcludedforReferring);
    }

    /*
    @wire(getPEDetails) peList(result) {
        this.isLoading = true;
        if (result.data) {
            this.data = result.data;
            this.masterData = result.data;
            this.recordsToDisplay = result.data;
            this.error = undefined;
            //for empty records check
            if (this.recordsToDisplay.length > 0) {
                this.showTable = true;
            } else {
                this.showTable = false;
            }
            this.isLoading = false;
        } else if (result.error) {
            this.error = result.error;
            alert(JSON.stringify(this.error));
            this.data = undefined;
            this.isLoading = false;
        }
    }*/
    //Capture the event fired from the paginator component
    handlePaginatorChange(event) {
        this.recordsToDisplay = event.detail;
        this.rowNumberOffset = this.recordsToDisplay[0].rowNumber - 1;
    }

    // Select the all rows
    allRowSelected(event) {
        var allRecords = [];
        var paginationList = [];
        var peIds = [];
        this.isSelectAll = true;
        for (var i = 0; i < this.data.length; i++) {
            let row = Object.assign({}, this.data[i]);
            row.isChecked = event.target.checked;
            allRecords.push(row);
            peIds.push(row.peRec.Id);
        }

        for (var i = 0; i < this.recordsToDisplay.length; i++) {
            let row = Object.assign({}, this.recordsToDisplay[i]);
            row.isChecked = event.target.checked;
            paginationList.push(row);
        }

        this.recordsToDisplay = [];
        this.data = [];
        this.recordsToDisplay = paginationList;
        this.data = allRecords;

        if (event.target.checked == true) {
            this.isBulkProfilePage = true;
            const selectedvalue = { peIds: peIds, isBulkProfilePage: this.isBulkProfilePage };
            const selectedEvent = new CustomEvent('selectrecordevent', { detail: selectedvalue });
            this.dispatchEvent(selectedEvent);
        } else {
            this.isBulkProfilePage = false;
            const selectedvalue = { isBulkProfilePage: this.isBulkProfilePage };
            const selectedEvent = new CustomEvent('selectrecordevent', { detail: selectedvalue });
            this.dispatchEvent(selectedEvent);
        }
    }
    get filterIconClass() {
        return this.isFilterApplied ? 'filterIcon' : 'unFilterIcon';
    }
    get filterVisible() {
        return this.showFilterModal ? 'slds-show' : 'slds-hide';
    }
    doRecordSelection(event) {
        var allRecords = [];
        var paginationList = [];
        var ctpId;
        console.log('selectall'+this.isSelectAll);
        this.isSelectAll = false;
        console.log('selectall'+this.isSelectAll);
        for (var i = 0; i < this.data.length; i++) {
            let row = Object.assign({}, this.data[i]);
            row.isChecked = false;
            if (row.peRec.Id === event.target.dataset.id && event.target.checked == true) {
                row.isChecked = true;
                ctpId = row.peRec.Study_Site__r.Clinical_Trial_Profile__c;
            }
            allRecords.push(row);
        }
        for (var i = 0; i < this.recordsToDisplay.length; i++) {
            let row = Object.assign({}, this.recordsToDisplay[i]);
            row.isChecked = false;

            if (row.peRec.Id === event.target.dataset.id && event.target.checked == true) {
                row.isChecked = true;
            }
            paginationList.push(row);
        }
        this.recordsToDisplay = [];
        this.data = [];
        this.recordsToDisplay = paginationList;
        this.data = allRecords;

        var peIds = [];
        var ctpIds = [];
        for (var i = 0; i < this.data.length; i++) {
            let row = Object.assign({}, this.data[i]);
            if (row.isChecked === true) {
                peIds.push(row.peRec.Id);
            }
        }
        if (peIds.length > 1) {
            //refreshApex(this.apexRefreshList);
            //eval("$A.get('e.force:refreshView').fire();");
            this.isBulkProfilePage = true;
            const selectedvalue = {
                peIds: peIds,
                ctpIds: ctpIds,
                isBulkProfilePage: this.isBulkProfilePage
            };
            const selectedEvent = new CustomEvent('selectrecordevent', { detail: selectedvalue });
            this.dispatchEvent(selectedEvent);
        } else if (peIds.length == 1) {
            this.isProfilePage = true;
            let selectedId = event.target.dataset.id;
            const selectedvalue = {
                peId: selectedId,
                ctpId: ctpId,
                isProfilePage: this.isProfilePage
            };
            const selectedEvent = new CustomEvent('selectrecordevent', { detail: selectedvalue });
            this.dispatchEvent(selectedEvent);
        } else if (peIds.length == 0) {
            this.isProfilePage = false;
            this.isBulkProfilePage = false;

            let selectedId = event.target.dataset.id;
            const selectedvalue = {
                peId: selectedId,
                ctpId: ctpId,
                isProfilePage: this.isProfilePage,
                isBulkProfilePage: this.isBulkProfilePage
            };
            const selectedEvent = new CustomEvent('selectrecordevent', { detail: selectedvalue });
            this.dispatchEvent(selectedEvent);
        }
    }

    //Open model for refresh
    openModal() {
        this.isModalOpen = true;
    }
    //close model for refresh
    closeModal() {
        this.isModalOpen = false;
    }
    openFilterModal() {
        this.showFilterModal = true;
    }
    //Refresh page
    refreshComponent(event) {
        refreshApex(this.apexRefreshList);
        //eval("$A.get('e.force:refreshView').fire();");
        eval("$A.get('e.force:refreshView').fire();");

        // this.dispatchEvent(new CustomEvent("tablerefreshevent"));
    }
    handleFilterApply(event) {
        this.showFilterModal = false;
        if (event.detail.isFilterApplied) {
            this.isFilterApplied = true;
            this.filter_icon = community_icon + '/FilterApplied.svg';
            let filterValue = event.detail.filterRecords;
            this.redirectoOverviewPage();
            this.masterFilterData = filterValue;
            this.data = filterValue;
            this.recordsToDisplay = filterValue;
            this.isPaginationApplied = false;
        }
    }

    handleSearch(event) {
        this.searchValue = event.target.value;
        console.log(this.searchValue);
        console.log(this.data.length);
        console.log(this.recordsToDisplay.length);
        let recddis;
        let allRec;
        /*if (this.isFilterApplied) {
            recddis = this.masterFilterData;
            allRec = this.masterFilterData;
        } else {*/
            recddis = this.masterData;
            allRec = this.masterData;
        //}
        
        if (this.searchValue.length > 0) {
            this.disableFilter = true;
            if (this.searchValue.length > 2) {
                if(!this.isExcludedforReferring){
                    console.log('Include Search');
                    let includedRecords = recddis.filter(function(include) {
                        return include.peRec.Participant_Status__c != "Excluded from Referring"; });
                        allRec = includedRecords;  
                }else{
                    console.log('Exclude Search');
                    let excludedRecords = this.allRecords.filter(function(ex) {
                        return ex.peRec.Participant_Status__c == "Excluded from Referring"; });
                        allRec = excludedRecords;   
                }
              
                recddis = allRec.filter((rec) =>
                    JSON.stringify(rec).toLowerCase().includes(this.searchValue.toLowerCase())
                );
                this.recordsToDisplay = recddis;
                this.data = recddis;
                this.template.querySelector('c-rppagination').setPageNumber();
                console.log(this.data.length);
                console.log(this.recordsToDisplay.length);
                this.isPaginationApplied = false;
            } /**else {
                this.data = allRec;
                this.recordsToDisplay = allRec;
                this.isPaginationApplied = false;
            }**/
        }
        if (this.searchValue.length == 0) {
            this.disableFilter = false;
            if (this.isFilterApplied) {
                this.data = this.masterFilterData;
                this.recordsToDisplay = this.masterFilterData;
            } else {
                this.data = allRec;
                this.recordsToDisplay = allRec;
            }
            this.isPaginationApplied = false;
        }
        this.redirectoOverviewPage();
    }
    redirectoOverviewPage() {
        const selectedEvent = new CustomEvent('selectrecordevent', { detail: {} });
        this.dispatchEvent(selectedEvent);
        this.template.querySelector('[data-id="checkAll"]').checked = false;
    }
    handleClearFilter(event) {
        //this.showFilterModal = false;
        this.isFilterApplied = false;
        this.disableFilter = false;
        this.searchValue = '';
        this.filter_icon = community_icon + '/NoFilterApplied.svg';
        this.redirectoOverviewPage();
        this.data = this.masterData;
        this.recordsToDisplay = this.masterData;
        this.isPaginationApplied = false;
    }

    renderedCallback() {
        if (!this.isPaginationApplied) {
            if (this.data.length == 0) {
                this.noFilterRecords = true;
            } else {
                this.noFilterRecords = false;
            }
            this.template.querySelector('c-rppagination').setRecordsToDisplay();
            this.isPaginationApplied = true;
        }
    }

    hanldeProgressValueChange(event) {
        refreshApex(this.apexRefreshList);
        eval("$A.get('e.force:refreshView').fire();");
    }
}