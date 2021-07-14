import { LightningElement, wire,api,track } from 'lwc';
import getRecordsDetails from '@salesforce/apex/RPRecordReviewLogController.getRecordsDetails';
import community_icon from '@salesforce/resourceUrl/rr_community_icons';
import getpatient from '@salesforce/apex/NonReferredPatientController.getpatientdetails'; 
import RPR_Actions from '@salesforce/label/c.RPR_Actions';
import RPR_Patient_Id from '@salesforce/label/c.RPR_Patient_Id';
import RPR_First_Name from '@salesforce/label/c.RPR_First_Name';
import RPR_Last_Name from '@salesforce/label/c.RPR_Last_Name';
import RPR_Excluded from '@salesforce/label/c.RPR_Excluded';
import RPR_Outreach_Status from '@salesforce/label/c.RPR_Outreach_Status';
import RPR_Consent from '@salesforce/label/c.RPR_Consent';
import RPR_Attestation from '@salesforce/label/c.RPR_Attestation';
import RPR_Medical_Review from '@salesforce/label/c.RPR_Medical_Review';
import RPR_Email from '@salesforce/label/c.RPR_Email';
import RPR_Study_Code_Name from '@salesforce/label/c.RPR_Study_Code_Name';
import RPR_YOB from '@salesforce/label/c.RPR_YOB';
import RPR_Site_Name from '@salesforce/label/c.RPR_Site_Name';
import RPR_Country from '@salesforce/label/c.RPR_Country';
import RPR_State from '@salesforce/label/c.RPR_State';
import Summary_View from '@salesforce/label/c.Summary_View';
import Primary from '@salesforce/label/c.Primary';
import Study_Info from '@salesforce/label/c.Study_Info';
import Email_Id from '@salesforce/label/c.Email_Id';
import CC_Phone_Number from '@salesforce/label/c.CC_Phone_Number';
import State_Country from '@salesforce/label/c.State_Country';
import Study_Name from '@salesforce/label/c.Study_Name';

//REF-4289
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';

export default class NonReferredParticipantList extends LightningElement {

    @track cloneCurrentPageList = [];
    @track originalCurrentPageList = [];
    @api studyFilterEnabled; @track isModalOpen = false;  @api patdetails={}; @api day;@api month;@api year;@api isLoading = false;
    @track showModal = false;
    @track showNegativeButton;
    @track showPositiveButton = true;
    @track positiveButtonLabel = 'Close';
    @track editMode = false;
    @track name; 
    @track accounts;
    @track error;
    @track peRecords;


    @api
    get currentPageList() {
        this.originalCurrentPageList = this.cloneCurrentPageList;
        return this.cloneCurrentPageList;
    }

    set currentPageList(value) {
        this.originalCurrentPageList = JSON.parse(JSON.stringify(value));
      //shallow copy the array
        this.cloneCurrentPageList = JSON.parse(JSON.stringify(value));
    }

    close_icon = community_icon + '/close.svg';
    check_icon = community_icon + '/checkGreen.svg';
    lock_icon = community_icon + '/lock.svg';
    comment_icon = community_icon + '/comments.svg';
    sendtostudy_icon = community_icon + '/sendToStudy.svg';

    label = {
        RPR_Actions,
        RPR_Patient_Id,
        RPR_First_Name,
        RPR_Last_Name,
        RPR_Excluded,
        RPR_Outreach_Status,
        RPR_Consent,
        RPR_Attestation,
        RPR_Medical_Review,
        RPR_Email,
        RPR_YOB,
        RPR_Study_Code_Name,
        RPR_Site_Name,
        RPR_Country,
        RPR_State,
        Summary_View,
        Primary,
        Study_Info,
        Email_Id,
        CC_Phone_Number,
        State_Country,
        Study_Name

    };
   /**showModalPopup() {
        this.showModal = true;
   }
   closeModal() {
        this.showModal = false;
    }**/
    openModal(event) {
        this.isLoading = true;
        getpatient({ patid: event.currentTarget.dataset.value })
        .then((result) => {
            this.patdetails = result.pe;
            this.day=result.day;
            this.month=result.month;
            this.year=result.year;
            console.log('Record-->'+ this.patdetails.Id);
            this.showModal = true;
        })
        .catch((error) => {
            console.log(error);
        });
    }
    closeModal() {
        this.showModal = false;
    }
    get title() {
        return '<b>'+this.patdetails.Patient_ID__c+'</b>'+'&nbsp;'+'<b>'+this.patdetails.Participant_Name__c+'</b>'+'&nbsp;'+'<b>'+this.patdetails.Participant_Surname__c+'</b>'
        +'&nbsp;'+'&nbsp;'+'<b>'+'Added on'+'</b>'+'&nbsp;'+this.month+'&nbsp;'+this.day+','+'&nbsp;'+this.year;
        
    }  
     
    handleLockClick(event) {
        this.editMode = true;             
        for(let per in this.cloneCurrentPageList) {
            if(this.cloneCurrentPageList[per].pe.Id == event.target.dataset.id) {
                this.cloneCurrentPageList[per].editMode = true;
            }
        }
        alert(JSON.stringify(this.peRecords.participantStatus));

    }
    @track peRecords = [];
    @track error;


    @wire(getRecordsDetails)
    recordsDetails({ error, data }) {
        if (data) {
            this.peRecords = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            alert(JSON.stringify(this.error));
            this.peRecords = undefined;
        }
    }



    handleSave(event){
        this.editMode = false;
        for(let per in this.cloneCurrentPageList) {
            alert(JSON.stringify(this.cloneCurrentPageList[per].pe.Participant_Name__c));
            alert(JSON.stringify(this.cloneCurrentPageList[per].pe.Participant_Surname__c));
            alert(JSON.stringify(this.cloneCurrentPageList[per].pe.Participant_Status__c));

         } 
    }
    
    changeInputValue(event) {
        let record = this.cloneCurrentPageList.find(ele  => ele.pe.Id === event.target.dataset.id);
        if(event.target.dataset.value === 'pName') {
            record.pe.Participant_Name__c = event.target.value;
        }
        else if(event.target.dataset.value === 'pSurName') {
            record.pe.Participant_Surname__c = event.target.value;
        }
        this.cloneCurrentPageList = [...this.cloneCurrentPageList];
    }

    handleCancel(event){
        this.editMode = false;       
        for(let per in this.originalCurrentPageList) {
            this.cloneCurrentPageList[per].editMode = false;
            this.cloneCurrentPageList[per] = this.originalCurrentPageList[per];
        }
    }
    //REF-4289 Start
    @track showCommentsModal = false;
    @track charNum = 0;
    @api peId = '';
    maxChar = 1000;
    @wire(getRecord, { recordId: '$peId', fields: ['Participant_Enrollment__c.Notes__c'] })
    wiredRecord({ error, data }) {
        if (data) {
            this.charNum=data.fields.Notes__c.value.length; 
            this.template.querySelector(".comments").value =data.fields.Notes__c.value;
        }
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            console.log(message);
            
        }
    }

    addCommens (event){
        this.showCommentsModal = true;      
        this.peId = event.currentTarget.dataset.value;
    }

    countChar(event) {
        var len = event.target.value.length;
        this.charNum=len;    
        
    }

    saveNotes(){
        this.template.querySelector(".cmtBtnC").disabled = true;
        this.template.querySelector(".cmtBtnS").disabled = true;
        const fields = {};
        fields["Id"] = this.peId;
        fields["Notes__c"] = this.template.querySelector(".comments").value;
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.closeComments();
            })
            .catch(error => {
                console.log("na hua update :|");
            });    
    }
    closeComments(){
        this.template.querySelector(".comments").value ='';
        this.showCommentsModal = false; 
        this.peId = '';  
        this.charNum =0 ;
    }
    //REF-4289 End
}