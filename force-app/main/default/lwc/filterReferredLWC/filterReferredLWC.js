import { LightningElement, api, track } from 'lwc';
// importing Custom Label
import RPR_Date_Range from '@salesforce/label/c.RPR_Date_Range';
import RPR_Select_Range from '@salesforce/label/c.RPR_Select_Range';
import RPR_Review_Results from '@salesforce/label/c.RPR_Review_Results';
import RPR_Select_Results from '@salesforce/label/c.RPR_Select_Results';
import RPR_Patient_Status from '@salesforce/label/c.RPR_Patient_Status';
import RPR_Exclusion_Reason from '@salesforce/label/c.RPR_Exclusion_Reason';
import RPR_Select_Reason from '@salesforce/label/c.RPR_Select_Reason';
import RPR_Select_Status from '@salesforce/label/c.RPR_Select_Status';
import RPR_Clear_All from '@salesforce/label/c.RPR_Clear_All';
import RPR_Apply from '@salesforce/label/c.RPR_Apply';
import BTN_Close from '@salesforce/label/c.BTN_Close';
import RPR_Studies from '@salesforce/label/c.RPR_Studies';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import setFilterData from '@salesforce/apex/RPRecordReviewFilterController.setFilterData';
import getFilterPEDetails from '@salesforce/apex/RPRecordReviewFilterController.getFilterPEDetails';
export default class FilterReferredLWC extends LightningElement {
    filterData;
    @api isdisabled = false;
    @api userMode;
    @api delegateId;
    @track filter = {
        selectedStudies: [],
        selectedExclusionReason: null,
        selectedDateRangeValue: null,
        selectedReviewResult: null,
        selectedPatientStatus: 'Include for referring',
        trialIds: []
    };
    label = {
        RPR_Date_Range,
        RPR_Select_Range,
        RPR_Review_Results,
        RPR_Select_Results,
        RPR_Exclusion_Reason,
        RPR_Select_Reason,
        RPR_Patient_Status,
        RPR_Select_Status,
        RPR_Apply,
        BTN_Close,
        RPR_Studies,
        RPR_Clear_All
    };
    connectedCallback() {
       
        loadScript(this, RR_COMMUNITY_JS).then(() => {
            let uMode = communityService.getUserMode();
            console.log(uMode);
            this.userMode = uMode;
            let delId = communityService.getDelegateId();
            console.log(delId);
            this.delegateId = delId;
            setFilterData({ userMode: this.userMode, delegateId: this.delegateId })
                .then((response) => {
                    this.filterData = response;
                    this.filter.trialIds = this.filterData.trialIds;
                })
                .catch((error) => {
                    console.log('Error: ' + error);
                });
        });
    }
    handleExcludeReasonChange(event) {
        this.filter.selectedExclusionReason = event.target.value;
    }
    handleDateRangeChange(event) {
        this.filter.selectedDateRangeValue = event.target.value;
    }
    handleReviewResultChange(event) {
        this.filter.selectedReviewResult = event.target.value;
    }
    handlePatientStatusChange(event) {
        this.filter.selectedPatientStatus = event.target.value;console.log('filter->'+event.target.value);
    }
    applyFilterClick() {
        let studies = this.template.querySelector('c-mutli-select-picklist-l-w-c').selectedvalues;
        this.filter.selectedStudies = studies;
        let jsonFilter = JSON.stringify(this.filter);
        console.log(jsonFilter); 

        let patstatus = this.filter.selectedPatientStatus;
        let isExcluded = false;
        if(patstatus == 'Exclude from referring'){
            isExcluded = true;
        }else{
            isExcluded = false;
        }
        const selectedEvent = new CustomEvent("progressvaluechange", {
          detail: isExcluded
        });
        this.dispatchEvent(selectedEvent);

        getFilterPEDetails({ filterJSON: jsonFilter, delegateId:this.delegateId })
            .then((response) => {
                console.log(response);
                let filterApplyMap = { filterRecords: response, isFilterApplied: true };
                const filterApplyEvent = new CustomEvent('filterapply', { detail: filterApplyMap });
                this.dispatchEvent(filterApplyEvent);

            })
            .catch((error) => {
                console.log(error);
                console.log('error');
            });
    }
    cancelFilter() {
        let filterApplyMap = { filterRecords: [], isFilterApplied: false };
        const filterApplyEvent = new CustomEvent('filterapply', filterApplyMap);
        this.dispatchEvent(filterApplyEvent);
    }
    clearFilter() {
        this.filter.selectedStudies = [];
        this.filter.selectedExclusionReason = null;
        this.filter.selectedDateRangeValue = null;
        this.filter.selectedReviewResult = null;
        this.filter.selectedPatientStatus = 'Include for referring';
        this.filter.trialIds = this.filterData.trialIds;
        this.template.querySelector('c-mutli-select-picklist-l-w-c').selectedvalues = [];
        this.template.querySelector('c-mutli-select-picklist-l-w-c').refreshOrginalList();
        const clearFilterEvent = new CustomEvent('clearfilter');
        this.dispatchEvent(clearFilterEvent);
    }
}