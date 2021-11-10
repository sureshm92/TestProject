import { LightningElement, track, wire, api } from 'lwc';
import getPEDetails from '@salesforce/apex/RPRecordReviewLogController.getPEDetails';
import community_icon from '@salesforce/resourceUrl/rr_community_icons';
import { refreshApex } from '@salesforce/apex';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import CC_Btn_Search from '@salesforce/label/c.CC_Btn_Search';
import RH_RP_Patient_ID from '@salesforce/label/c.RH_RP_Patient_ID';
import RH_RP_Last_Name from '@salesforce/label/c.RH_RP_Last_Name';
import RH_RP_MM_YYYY from '@salesforce/label/c.RH_RP_MM_YYYY';
import RH_RP_No_Item_To_Display from '@salesforce/label/c.RH_RP_No_Item_To_Display';
import BTN_Close from '@salesforce/label/c.BTN_Close';
import RH_RP_Refresh_page from '@salesforce/label/c.RH_RP_Refresh_page';
import RH_RP_Want_to_Refresh_Page from '@salesforce/label/c.RH_RP_Want_to_Refresh_Page';
import Cancel from '@salesforce/label/c.Cancel';
import BTN_OK from '@salesforce/label/c.BTN_OK';

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
    searchData = [];
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

    label = {
        CC_Btn_Search,
        RH_RP_Patient_ID,
        RH_RP_Last_Name,
        RH_RP_MM_YYYY,
        RH_RP_No_Item_To_Display,
        BTN_Close,
        RH_RP_Refresh_page,
        RH_RP_Want_to_Refresh_Page,
        Cancel,
        BTN_OK
    };

    constructor() {
        super();
        this.isLoading = true;
    }

    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
        .then(() => {
            this.userMode = communityService.getUserMode();
            this.delegateId = communityService.getDelegateId();
        }).then(() => {
            this.getDetailsApex();
        }).catch((error) => {
            console.log('Error: ' + error);
        });
       
    }

    @api
    getPatientRecords() {
        var panginationRecList = [];
        var allRecList = [];

        let paginationRecord = JSON.parse(JSON.stringify(this.recordsToDisplay));        
        for (var i = 0; i < paginationRecord.length; i++) {
            if(paginationRecord[i].peRec.Id == this.peRecordList[0].peRecord.Id){
                paginationRecord[i].peRec.Patient_ID__c = this.peRecordList[0].peRecord.Patient_ID__c;
                paginationRecord[i].peRec.Participant_Name__c = this.peRecordList[0].peRecord.Participant_Name__c;
                paginationRecord[i].peRec.Participant_Surname__c = this.peRecordList[0].peRecord.Participant_Surname__c;

                if(this.peRecordList[0].peRecord.Birth_Month__c != '' && this.peRecordList[0].peRecord.Birth_Month__c != undefined
                    && this.peRecordList[0].peRecord.Birth_Month__c != null){
                    paginationRecord[i].doBFormat = this.peRecordList[0].peRecord.Birth_Month__c+'/'+this.peRecordList[0].peRecord.YOB__c;
                }
                else {
                    paginationRecord[i].doBFormat = this.peRecordList[0].peRecord.YOB__c;
                }
            }
            panginationRecList.push(paginationRecord[i]);
        }

        let allRecords = JSON.parse(JSON.stringify(this.data));        
        for (var i = 0; i < allRecords.length; i++) {
            if(allRecords[i].peRec.Id == this.peRecordList[0].peRecord.Id){
                allRecords[i].peRec.Patient_ID__c = this.peRecordList[0].peRecord.Patient_ID__c;
                paginationRecord[i].peRec.Participant_Surname__c = this.peRecordList[0].peRecord.Participant_Surname__c;
                allRecords[i].peRec.Participant_Name__c = this.peRecordList[0].peRecord.Participant_Name__c;
                if(this.peRecordList[0].peRecord.Birth_Month__c != '' && this.peRecordList[0].peRecord.Birth_Month__c != undefined
                    && this.peRecordList[0].peRecord.Birth_Month__c != null){
                        allRecords[i].doBFormat = this.peRecordList[0].peRecord.Birth_Month__c+'/'+this.peRecordList[0].peRecord.YOB__c;
                }
                else {
                    allRecords[i].doBFormat = this.peRecordList[0].peRecord.YOB__c;
                }
            }
            allRecList.push(allRecords[i]);
        }
        this.recordsToDisplay = [];
        this.recordsToDisplay = panginationRecList;   

        this.data = [];
        this.data = allRecList;   
    }

    @api
    getOnExcludeIncluderefresh() {
        this.recordsToDisplay = this.recordsToDisplay.filter(element => element.peRec.Id !== this.peRecordList[0].peRecord.Id );
        
        var sts = '';
        if(this.isExcludedforReferring){
           sts ='Pending Referral'
        }else{
           sts ='Excluded from Referring'
        }
       let state = this.searchData;
       var index = state.findIndex(project => project.peRec.Id === this.peRecordList[0].peRecord.Id);
       this.searchData[index].peRec.Participant_Status__c = sts;
     
        
        this.data = this.data.filter(element => element.peRec.Id !== this.peRecordList[0].peRecord.Id);
        this.redirectoOverviewPage();
        this.template.querySelector('c-rppagination').records = this.data;
        this.template.querySelector('c-rppagination').totalRecords = this.data.length;
        //this.template.querySelector('c-rppagination').setRecordsToDisplay();
        this.template.querySelector('c-rppagination').refreshPageNumber();
        if (this.data.length == 0) {
            this.noFilterRecords = true;
        } else {
            this.noFilterRecords = false;
        }
    }

    @api bulkPeIds;

    @api
    getOnbBulkExcludeIncluderefresh() {
        for(let i = 0; i < this.bulkPeIds.length; i++){
            this.recordsToDisplay = this.recordsToDisplay.filter(element => element.peRec.Id !== this.bulkPeIds[i]);
        }
        var sts = '';
        if(this.isExcludedforReferring){
           sts ='Pending Referral'
        }else{
           sts ='Excluded from Referring'
        }
        for(let i = 0; i < this.bulkPeIds.length; i++){
            let state = this.searchData;
            var index = state.findIndex(project => project.peRec.Id === this.bulkPeIds[i]);
            this.searchData[index].peRec.Participant_Status__c = sts;
        }
        for(let i = 0; i < this.bulkPeIds.length; i++){
            this.data = this.data.filter(element => element.peRec.Id !== this.bulkPeIds[i]);
        }
        this.redirectoOverviewPage();
        this.template.querySelector('c-rppagination').records = this.data;
        this.template.querySelector('c-rppagination').totalRecords = this.data.length;
        this.template.querySelector('c-rppagination').refreshPageNumber();
        if (this.data.length == 0) {
            this.noFilterRecords = true;
        } else {
            this.noFilterRecords = false;
        }
    }

    getDetailsApex() {
        getPEDetails({ userMode: this.userMode, delegateId: this.delegateId })
            .then((result) => {
                this.allRecords = result;
                let includedRecords = result.filter(function(include) {
                return include.peRec.Participant_Status__c != "Excluded from Referring"; });
                this.apexRefreshList = includedRecords;
                this.data = includedRecords;
                this.masterData = includedRecords;
                this.searchData = result;
                this.recordsToDisplay = includedRecords;
                this.error = undefined;
                this.isExcludedforReferring = false;
                //for empty records check
                if (this.recordsToDisplay.length > 0) {
                    this.showTable = true;
                } else {
                    this.showTable = true;
                }
                this.isLoading = false;
            })
            .catch((error) => {
                console.log(error);
            });
    }

    handleExcludeRecords(event) {
       this.isExcludedforReferring = event.detail;
    }

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
        var verifyFilterValue;
        
        for (var i = 0; i < this.data.length; i++) {
            let row = Object.assign({}, this.data[i]);
            row.isChecked = event.target.checked;
            allRecords.push(row);
            peIds.push(row.peRec.Id);
        }

        for (var i = 0; i < this.recordsToDisplay.length; i++) {
            let row = Object.assign({}, this.recordsToDisplay[i]);
            row.isChecked = event.target.checked;
            verifyFilterValue = row.peRec.Participant_Status__c;
            paginationList.push(row);
        }

        this.recordsToDisplay = [];
        this.data = [];
        this.recordsToDisplay = paginationList;
        this.data = allRecords;

        if (event.target.checked == true) {
            this.isBulkProfilePage = true;
            const selectedvalue = { peIds: peIds, isBulkProfilePage: this.isBulkProfilePage, verifyFilterValue: verifyFilterValue };
            const selectedEvent = new CustomEvent('selectrecordevent', { detail: selectedvalue});
            this.dispatchEvent(selectedEvent);
            if(this.noFilterRecords){
            const selectedEvent1 = new CustomEvent('selected', { });
            this.dispatchEvent(selectedEvent1);
            }
        } else {
            this.isBulkProfilePage = false;
            const selectedvalue = { 
                isBulkProfilePage: this.isBulkProfilePage,
            };
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
        var selectPeId = '';
        this.isSelectAll = false;
        var verifyFilterValue;

        for (var i = 0; i < this.data.length; i++) {
            let row = Object.assign({}, this.data[i]);

            if (row.peRec.Id === event.target.dataset.id) {
                if(event.target.checked) {
                    row.isChecked = true;
                    ctpId = row.peRec.Study_Site__r.Clinical_Trial_Profile__c;
                    selectPeId = row.peRec.Id;    
                    verifyFilterValue = row.peRec.Participant_Status__c;
                }
                else{
                    row.isChecked = false;
                    verifyFilterValue = row.peRec.Participant_Status__c;
                }
            }
            allRecords.push(row);
        }
        for (var i = 0; i < this.recordsToDisplay.length; i++) {
            let row = Object.assign({}, this.recordsToDisplay[i]);
            if (row.peRec.Id === event.target.dataset.id ) {
                if(event.target.checked) {
                    row.isChecked = true;
                    selectPeId = row.peRec.Id;
                    verifyFilterValue = row.peRec.Participant_Status__c;
                }
                else{
                    row.isChecked = false;
                    verifyFilterValue = row.peRec.Participant_Status__c;
                }
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
            if (row.isChecked) {
                peIds.push(row.peRec.Id);
            }
        }
        if(peIds.length == 1){
            selectPeId = peIds[0];
        }
        if (peIds.length > 1) {
            this.isBulkProfilePage = true;
            const selectedvalue = {
                peIds: peIds,
                ctpIds: ctpIds,
                isBulkProfilePage: this.isBulkProfilePage,
                verifyFilterValue: verifyFilterValue 
            };
            const selectedEvent = new CustomEvent('selectrecordevent', { detail: selectedvalue });
            this.dispatchEvent(selectedEvent);
        } 
        else if (peIds.length == 1) {
            this.isProfilePage = true;
            const selectedvalue = {
                peId: selectPeId,
                ctpId: ctpId,
                isProfilePage: this.isProfilePage
            };
            const selectedEvent = new CustomEvent('selectrecordevent', { detail: selectedvalue });
            this.dispatchEvent(selectedEvent);
        } 
        else if (peIds.length == 0) {
            this.isProfilePage = false;
            this.isBulkProfilePage = false;
            const selectedvalue = {
                peId: selectPeId,
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
        eval("$A.get('e.force:refreshView').fire();");
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
            this.template.querySelector('c-rppagination').setPageNumber();

        }
    }

    handleSearch(event) {
        this.searchValue = event.target.value;
        let recddis;
        let allRec;
        /*if (this.isFilterApplied) {
            recddis = this.masterFilterData;
            allRec = this.masterFilterData;
        } else {*/
            //recddis = this.masterData;
            //allRec = this.masterData;
        //}
        recddis = this.searchData;
        allRec = this.searchData;

        
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
                
               recddis = allRec
                .filter(rec => (rec.peRec.Patient_ID__c  != undefined  && rec.peRec.Patient_ID__c.toLowerCase().includes(this.searchValue.toLowerCase())) || 
                    (rec.peRec.Participant_Name__c != undefined && rec.peRec.Participant_Name__c.toLowerCase().includes(this.searchValue.toLowerCase())) ||
                    (rec.peRec.Participant_Surname__c != undefined && rec.peRec.Participant_Surname__c.toLowerCase().includes(this.searchValue.toLowerCase())) ||
                    (rec.peRec.YOB__c != undefined && rec.peRec.YOB__c.toLowerCase().includes(this.searchValue.toLowerCase())) ||
                    (rec.peRec.Birth_Month__c != undefined && rec.peRec.Birth_Month__c.toLowerCase().includes(this.searchValue.toLowerCase())) 
                );

                this.recordsToDisplay = recddis;
                this.data = recddis;
                this.template.querySelector('c-rppagination').setPageNumber();
                this.isPaginationApplied = false;
            } 
        }
        if (this.searchValue.length == 0) {
            this.disableFilter = false;
            if (this.isFilterApplied) {
                this.data = this.masterFilterData;
                this.recordsToDisplay = this.masterFilterData;
            } else {
                //this.data = allRec;
                //this.recordsToDisplay = allRec;
                this.data = this.masterData;
                this.recordsToDisplay = this.masterData;
                
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