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
import RH_RP_has_been_included from '@salesforce/label/c.RH_RP_has_been_included';
import excludeStatus from '@salesforce/apex/RPRecordReviewLogController.bulkChangeStatusToExcludeFromReferring';
import includeStatus from '@salesforce/apex/RPRecordReviewLogController.bulkUndoChangeStatusToExcludeFromReferring';
import getExportRecords from '@salesforce/apex/RPRecordReviewLogController.getExportRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

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
        RH_RP_Include
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

    openExclude = false;
    openInclude = false;
    disableButton = false;
    showExclude = false;
    connectedCallback() {
        this.totalRecords = this.peIds.length; 

        if(this.verifyFilterValue != "Excluded from Referring"){
            this.showExclude = false;
        }
        else{
            this.showExclude = true;
        }
    }

    openExcludeModal(){
        this.openExclude = true;
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
            this.showSuccessToast(this.label.RH_RP_Excluded_Successfully);
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
            this.showSuccessToast(this.label.RH_RP_included_successfully);
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
    downloadasExcel() {  
      let columnHeader = ["Participant Profile Name", "MRN Id","Patient ID","Referred Date","Study Code Name", "Study Site Name","Investigator Name","Participant Status","Status Change Reason","Participant Status Last Changed Date","Last Status Changed Notes","Pre-screening 1 Status","Pre-screening 1 Completed by","Pre-screening Date","Referral Completed by","Referral Source","Last Added Notes","Outreach Email"]; 
      let queryFields = ["Name", "MRNID", "PatientID","Referreddate", "StudyCodeName", "StudySiteName","InvestigatorName","ParticipantStatus","StatusChangeReason","ParticipantStatusLastChangedDt","LastStatusChangedNotes","PreScreeningStatus","PreScreeningCompletedby","PreScreeningdate","ReferralCompletedby","ReferralSource"]; 
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