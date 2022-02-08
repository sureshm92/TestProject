import { LightningElement,api,wire } from 'lwc';
import getNotesDetails from '@salesforce/apex/RPRecordReviewLogController.getNotesDetails';
import createNotes from '@salesforce/apex/RPRecordReviewLogController.createNotes';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RH_RP_No_Item_To_Display from '@salesforce/label/c.RH_RP_No_Item_To_Display';
import icon_chevron_up_white from '@salesforce/resourceUrl/icon_chevron_up_white'
import RH_RP_Comments from '@salesforce/label/c.RH_RP_Comments';
import RH_RP_Add_Comments from '@salesforce/label/c.RH_RP_Add_Comments';
import RH_RP_Clear from '@salesforce/label/c.RH_RP_Clear';
import RH_RP_Save_Note from '@salesforce/label/c.RH_RP_Save_Note';
import CC_Btn_Search from '@salesforce/label/c.CC_Btn_Search';

export default class Rp_NotesTab extends LightningElement {
    
    //get custom label
    label = {
        RH_RP_No_Item_To_Display,
        RH_RP_Comments,
        RH_RP_Add_Comments,
        RH_RP_Clear,
        RH_RP_Save_Note,
        CC_Btn_Search
    };

    //Variable declaration
    noteList =[];
    masterList =[];
    commentValue;
    @api delegateid;
    @api patientrecord;
    noteRefreshList = [];
    pId;
    charCount = 0;
    totalCount = 250;
    disabledOkButton = false;
    isLoading = false;
    noRecords = false;
    openSaveModel = false;
    searchValue = '';
    disabledSaveButton = true;
    topIcon = icon_chevron_up_white;

    //get participant enrolment Id during onload
    connectedCallback(){
        this.pId =this.patientrecord[0].peRecord.Id;
    }

    goTop(){
        window.scrollTo({
            top: 100,
            behavior: 'smooth'
          });
    }

    //on text area value change
    handleTextAreaChange(event) {
        this.commentValue = event.target.value;
        this.charCount = this.commentValue.length;
        let charCountLength = this.commentValue.replace(/\s+/g, '');
       
        if(charCountLength.length == 0){
            this.disabledSaveButton = true;
        }
        else {
            this.disabledSaveButton = false;
        }
    }

    //clear text area value
    clearComments(){
        this.commentValue = '';
        this.charCount = 0;
        this.disabledSaveButton = true;
    }

    //search records if char more than 2 length
    handleSearch(event){
        this.noteList = this.masterList;  
        this.searchValue = event.target.value;
        this.noRecords = false;   
        if(this.searchValue.length == 0){
            this.noteList = this.masterList;      
        }
        else if(this.searchValue.length > 2) {
            let searchRecordList = this.noteList;
             searchRecordList = searchRecordList.filter((rec) =>
                JSON.stringify(rec).toLowerCase().includes(this.searchValue.toLowerCase())
            );    
            this.noteList = searchRecordList;      
        }
        if(this.noteList.length == 0){
            this.noRecords = true;   
        }
    }

    //get note value to display
    @wire(getNotesDetails, {peId: '$pId'}) 
        noteRecordsList(result) {
            this.noteRefreshList = result;
            this.isLoading = true;
            if (result.data) {
                this.noteList = result.data;
                this.masterList = result.data;
                console.log(this.noteList.length);
                this.searchValue = '';
                this.error = undefined;
                this.isLoading = false;
            } 
            else if (result.error) {
                console.log(JSON.stringify(result.error));
                this.error = result.error;
                this.noteList = [];
                this.isLoading = false;
            }
    }

    //create note 
    createNoteRecords() {
        this.disabledOkButton = true;
        this.openSaveModel = false
        this.isLoading = true;

        createNotes({notes: this.commentValue, peId: this.patientrecord[0].peRecord.Id,delegateId: this.delegateid})
        .then((result) => { 
            this.commentValue = '';
            this.charCount = 0;
            refreshApex(this.noteRefreshList);
            this.isLoading = false;
            this.disabledSaveButton = true;
            this.showSuccessToastSave('Notes has been successfully saved.');
        })
        .catch((error) => {
            console.log(JSON.stringify(error));
            this.disabledOkButton = false;
            this.isLoading = false;
            this.disabledSaveButton = false;
        })
    }
    
    //open model while click on save
    openCommentModel(){
        this.disabledOkButton = false;
       
        if(this.charCount == 0){
           this.disabledSaveButton = true;
        }
        else{
            this.openSaveModel = true;
        }
    }

    //close model
    closeSaveModel(){
        this.openSaveModel = false;
        this.disabledOkButton = false;
        this.disabledSaveButton = false;
    }

    //for error tost
    showErrorToast(errorRec) {
        const evt = new ShowToastEvent({
            title: errorRec,
            message: errorRec,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showSuccessToastSave(MessageRec) {
        const evt = new ShowToastEvent({
            title: MessageRec,
            message: MessageRec,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}