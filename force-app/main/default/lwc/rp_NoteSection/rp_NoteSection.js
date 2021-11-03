import { LightningElement, api } from 'lwc';
import getnotesdetails from '@salesforce/apex/GetNotes.getNotesdatarp';
import CreateNotes from '@salesforce/apex/GetNotes.CreateNotes';
import UpdateNotes from '@salesforce/apex/GetNotes.UpdNotesSection';
import delNotes from '@salesforce/apex/GetNotes.deleteNotes';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RecordIdInLWC extends LightningElement {
    @api recordId;
    @api notedata =[];
    @api isModalOpen = false;
    @api isModalOpenEdit = false;
    @api isModalOpenDelete = false;
    @api newnote='';
    @api editNote='';
    @api editNoteId='';
    @api deleteNoteId ='';
    nodata = false;
    connectedCallback() {
        getnotesdetails({ RecordId: this.recordId })
        .then(result => {
            this.notedata = result;
            console.log('len'+this.notedata.length);
            if(this.notedata.length == 0){
                this.nodata = true;
            }else{
                this.nodata = false;
            }
        }) .catch((error => {
            console.log('Err:'+this.error);
            console.log('Err:'+JSON.stringify(error));
        })); 
       
    }
    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
        this.isModalOpenEdit = false;
    }
    handleDataChange(event){
        this.newnote = event.target.value;
    }
   
    submitDetails() {
        CreateNotes({ RecordId: this.recordId,notes: this.newnote })
        .then(result => {
           // location.reload();
           this.connectedCallback();
        }) .catch((error => {
            console.log('Err:'+JSON.stringify(error));
        })); 
        this.isModalOpen = false;
    }
    handleClickEdit(event){
        this.editNoteId = event.target.dataset.id;
        this.editNote = event.target.name;
        this.isModalOpenEdit = true;
    }
    handleDataChangeUpd(event){
        this.editNote= event.target.value;
    }
    UpdateDetails() {
        UpdateNotes({ RecordId:  this.editNoteId ,notes:this.editNote })
        .then(result => {
            //location.reload();
            this.connectedCallback();
        }) .catch((error => {
            const evt = new ShowToastEvent({
                title: '',
                message: 'You dont have permission to perform the operation.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            console.log('Err:'+JSON.stringify(error));
        })); 
        this.isModalOpenEdit = false;
    }
    handleClickDelete(event){
        this.deleteNoteId = event.target.dataset.id;
        this.isModalOpenDelete = true;
    }
    DeleteDetails(){
        delNotes({ RecordId:this.deleteNoteId})
        .then(result => {
            //location.reload();
            this.connectedCallback();
        }) .catch((error => {
            const evt = new ShowToastEvent({
                title: '',
                message: 'You dont have permission to perform the operation.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            console.log('Err:'+JSON.stringify(error));
        })); 
        this.isModalOpenDelete = false;
    }
    
}