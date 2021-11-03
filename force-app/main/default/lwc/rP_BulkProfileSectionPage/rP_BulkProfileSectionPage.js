import { LightningElement, api } from 'lwc';
import RH_RP_info from '@salesforce/label/c.RH_RP_info';
import RH_RP_select_single_patient from '@salesforce/label/c.RH_RP_select_single_patient';
import BTN_Close from '@salesforce/label/c.BTN_Close';
import RH_RP_Exclude_Record from '@salesforce/label/c.RH_RP_Exclude_Record';
import RH_RP_exclude_this_patient from '@salesforce/label/c.RH_RP_exclude_this_patient';
import Cancel from '@salesforce/label/c.Cancel';
import BTN_OK from '@salesforce/label/c.BTN_OK';
import RH_RP_Include_Record from '@salesforce/label/c.RH_RP_Include_Record';
import RH_RP_want_to_include_patients from '@salesforce/label/c.RH_RP_want_to_include_patients';
import RH_RP_Excluded_Successfully from '@salesforce/label/c.RH_RP_Excluded_Successfully';
import RH_RP_has_been_excluded from '@salesforce/label/c.RH_RP_has_been_excluded';
import RH_RP_included_successfully from '@salesforce/label/c.RH_RP_included_successfully';
import RH_RP_Exclude_From_Referring from '@salesforce/label/c.RH_RP_Exclude_From_Referring';
import RH_RP_Include_From_Referring from '@salesforce/label/c.RH_RP_Include_From_Referring';
import RH_RP_Exclude from '@salesforce/label/c.RH_RP_Exclude';
import RH_RP_Include from '@salesforce/label/c.RH_RP_Include';
import RH_RP_Bulk_Excluded_Successfully from '@salesforce/label/c.RH_RP_Bulk_Excluded_Successfully';
import RH_RP_Bulk_included_successfully from '@salesforce/label/c.RH_RP_Bulk_included_successfully';
import RH_RP_Export_to_excel from '@salesforce/label/c.RH_RP_Export_to_excel';
import RH_RP_Outreach_Email from '@salesforce/label/c.RH_RP_Outreach_Email';
import RH_RP_Export_downloadable_log from '@salesforce/label/c.RH_RP_Export_downloadable_log';
import RH_RP_Bulk_Action from '@salesforce/label/c.RH_RP_Bulk_Action';
import RH_RP_OutreachEmail from '@salesforce/label/c.RH_RP_OutreachEmail';
import RH_RP_Patients_Selected from '@salesforce/label/c.RH_RP_Patients_Selected';
import { loadScript } from 'lightning/platformResourceLoader';
import rrCommunity from '@salesforce/resourceUrl/rr_community_js';

import RH_RP_has_been_included from '@salesforce/label/c.RH_RP_has_been_included';
import excludeStatus from '@salesforce/apex/RPRecordReviewLogController.bulkChangeStatusToExcludeFromReferring';
import includeStatus from '@salesforce/apex/RPRecordReviewLogController.bulkUndoChangeStatusToExcludeFromReferring';
import getExportRecords from '@salesforce/apex/RPRecordReviewLogController.getExportRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import icon_chevron_up_white from '@salesforce/resourceUrl/icon_chevron_up_white'

export default class RP_BulkProfileSectionPage extends LightningElement {

    label = {
        RH_RP_info,
        RH_RP_select_single_patient,
        BTN_Close,
        RH_RP_Exclude_Record,
        RH_RP_exclude_this_patient,
        Cancel,
        BTN_OK,
        RH_RP_Include_Record,
        RH_RP_want_to_include_patients,
        RH_RP_Excluded_Successfully,
        RH_RP_has_been_excluded,
        RH_RP_included_successfully,
        RH_RP_has_been_included,
        RH_RP_Exclude_From_Referring,
        RH_RP_Include_From_Referring,
        RH_RP_Exclude,
        RH_RP_Include,
        RH_RP_Bulk_Excluded_Successfully,
        RH_RP_Bulk_included_successfully,
        RH_RP_Export_to_excel,
        RH_RP_Outreach_Email,
        RH_RP_Export_downloadable_log,
        RH_RP_Bulk_Action,
        RH_RP_OutreachEmail,
        RH_RP_Patients_Selected
    };

    @api usermode; 
    @api delegateid; 
    @api isLoading; 
    @api peIds; 
    @api ctpIds;
    @api peRecordList =[];
    @api totalRecords = 0;
    @api verifyFilterValue;
    @api peList;
    @api isaccessLevelthree = false;
    @api disableExceldownload = false;

    

    openExclude = false;
    openInclude = false;
    disableButton = false;
    showExclude = false;
    topIcon = icon_chevron_up_white;


    connectedCallback() {
        this.totalRecords = this.peIds.length; 
        if(this.verifyFilterValue != "Excluded from Referring"){
            this.showExclude = false;
        }
        else{
            this.showExclude = true;
        }
    }

    goTop(){
        window.scrollTo({
            top: 100,
            behavior: 'smooth'
          });
    }

    openExcludeModal(){
        this.openExclude = true;
    }
    @api
    noRecords() {
        this.isaccessLevelthree = true;
        this.disableExceldownload = true;
    }
    closeExcludeModal() {
        this.openExclude = false;
    }
    
    openIncludeModal(){
        this.openInclude = true;
    }
    
    closeIncludeModal() {
        this.openInclude = false;
    }

    excludBulkepatient(){
        this.disableButton = true;
        excludeStatus({participantEnrollmentIds: this.peIds})
        .then((result) => { 
            this.showSuccessToast(this.label.RH_RP_Bulk_Excluded_Successfully);
            this.openExclude = false;
        })
        .catch((error) => {
            this.errors = error;
            console.log(error);
            this.disableButton = false;
        })
        .finally(() => {
            //eval("$A.get('e.force:refreshView').fire();");
            const selectedvalue = {bulkPeIds: this.peIds};
            const selectedEvent = new CustomEvent('bulkincludeexcluderefresh', { detail: selectedvalue });
            this.dispatchEvent(selectedEvent);
        })
    }

    includeBulkpatient(){
        this.disableButton = true;
        includeStatus({participantEnrollmentIds: this.peIds})
        .then((result) => {
            this.showSuccessToast(this.label.RH_RP_Bulk_included_successfully);
        })
        .catch((error) => {
            this.errors = error;
            console.log(error);
            this.disableButton = false;
        })
        .finally(() => {
            this.openInclude = false;
            const selectedvalue =  {bulkPeIds: this.peIds};
            const selectedEvent = new CustomEvent('bulkincludeexcluderefresh', { detail: selectedvalue });
            this.dispatchEvent(selectedEvent);
        })
    }
    exportBulkepatient(){
       if(communityService.isMobileSDK()){
        const evt = new ShowToastEvent({
            title: '',
            message: 'Opening this link is only supported using the web browser experience',
            variant: 'info',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
       }else{
        getExportRecords({participantEnrollmentIds: this.peIds})
        .then((result) => {
              this.peList = result;
        })
        .then(() => {
           this.downloadasExcel();
        })
        .catch((error) => {
            this.errors = error;
            console.log(error);
        })
       } 
    }
    downloadasExcel() {  
      let columnHeader = ["Study Code Name","Participant Profile Name", "Patient ID","Participant Status","Participant Status Last Changed Date","Last Added Notes","Outreach Email","Pre-screening 1 Status","Pre-screening 1 Completed by","Pre-screening Date","Referred Date","Referral Completed by","Referral Source","Study Site Name","Investigator Name","Status Change Reason","Last Status Changed Notes","MRN Id"]; 
      let queryFields = ["StudyCodeName","Name", "PatientID","ParticipantStatus","ParticipantStatusLastChangedDt","LastAddedNotes","OutreachMail","PreScreeningStatus","PreScreeningCompletedby","PreScreeningdate","Referreddate","ReferralCompletedby","ReferralSource","StudySiteName","InvestigatorName","StatusChangeReason","LastStatusChangedNotes","MRNID"]; 
      var jsonRecordsData = this.peList;  
      let csvIterativeData;  
      let csvSeperator;  
      let newLineCharacter;  
      csvSeperator = ",";  
      newLineCharacter = "\n";  
      csvIterativeData = "";  
      csvIterativeData += columnHeader.join(csvSeperator);  
      csvIterativeData += newLineCharacter;  
      for (let i = 0; i < jsonRecordsData.length; i++) {  
        let counter = 0;  
        for (let iteratorObj in queryFields) {  
          let dataKey = queryFields[iteratorObj];  
          if (counter > 0) {  csvIterativeData += csvSeperator;  }  
          if (  jsonRecordsData[i][dataKey] !== null &&  
            jsonRecordsData[i][dataKey] !== undefined  
          ) {  csvIterativeData += '"' + jsonRecordsData[i][dataKey] + '"';  
          } else {  csvIterativeData += '""';  
          }  
          counter++;  
        }  
        csvIterativeData += newLineCharacter;  
      }  
        let downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvIterativeData);
        downloadElement.target = '_self';
        downloadElement.download = 'Patient Records.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click(); 

    }

    showSuccessToast(messageRec){
        const evt = new ShowToastEvent({
            title: 'Success Message',
            message: messageRec,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showSendOutreach = false;
    openOutreach(){
        this.showSendOutreach = true;
    }
    closeOutreachdModal(){
        this.showSendOutreach = false;
    }
}