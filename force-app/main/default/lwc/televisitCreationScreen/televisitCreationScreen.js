import { LightningElement,track,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendRecord from "@salesforce/apex/TelevisitCreationScreenController.insertTelevisitRecord";
import fetchRecord from "@salesforce/apex/TelevisitCreationScreenController.fetchTelevisitRecord";
import fetchAttendees from "@salesforce/apex/TelevisitCreationScreenController.fetchAttendees";
import cancelTelevisit from "@salesforce/apex/TelevisitCreationScreenController.cancelTelevisit";
import { NavigationMixin } from "lightning/navigation";


export default class ModalPopupLWC extends NavigationMixin(LightningElement) {
    @api peid;
    @api get peidnew(){
        return this.peid;
    };
    set peidnew(value){
        this.peid = value;
        this.doSelectedPI();
    }
    
    value = 'Scheduled';
    duration;
    startTime;
    title;
    visitDate;
    televisitRecord = {};
    @track televisitRecordsList = [];
    displayTelevisitRecords;
    attendeesList = [];
    attendeesListObject = {
        attendeesList:[]
    };
    disableSaveButton = true;
    today;
    fieldValidationStatus;
    isCancelModalOpen = false;
    cancelTelevisitRecordId;
    televisitEditView = false;
    televisitRecordId='';
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    openModal(event) {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
        if(event.target.dataset.id !== null && event.target.dataset.id !== '' && event.target.dataset.id !== undefined){
            this.televisitEditView = true;
            this.title = event.target.dataset.title;
            this.visitDate = event.target.dataset.visitdate;
            this.startTime = this.msToTime(event.target.dataset.starttime);
            this.duration = event.target.dataset.duration;
            this.televisitRecordId = event.target.dataset.id;
        }else{
            this.televisitEditView = false;
            this.televisitRecordId = '';
            this.title = '';
            this.visitDate = '';
            this.startTime = '';
            this.duration = '';
            
        }
    }

    msToTime(s){
        let ms = s % 1000;
        s = (s - ms) / 1000;
        let secs = s % 60;
        s = (s - secs) / 60;
        let mins = s % 60;
        let hrs = (s - mins) / 60;
        hrs = hrs < 10 ? '0' + hrs : hrs;
        mins = mins < 10 ? '0' + mins : mins;
        console.log(hrs + '  ' + mins);
        return hrs+':' + mins + ':00.000Z';
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this.clearFieldValues();
    }
    submitDetails() {
        if(this.title === undefined || this.startTime === undefined || this.visitDate === undefined || this.duration === undefined ){
            this.showToast();
        }else{
            this.sendRecord();
            
        }
        
    }
    get options() {
        return [
            { label: 'Scheduled', value: 'Scheduled' },
            { label: 'Cancelled/Completed', value: 'Cancelled/Completed' },
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
        this.fetchTelevisitRecord();
    }

    get durations() {
        return [
            { label: '15 minutes', value: '15 minutes' },
            { label: '30 minutes', value: '30 minutes' },
            { label: '45 minutes', value: '45 minutes' },
            { label: '60 minutes', value: '60 minutes' },
        ];
    }

    handleDurationChange(event) {
        this.duration = event.detail.value;
    }

    get startTimes() {
        return [
            { label: '9:30AM', value: '9:30AM' },
            { label: '10:00AM', value: '10:00AM' },
            { label: '10:30AM', value: '10:30AM' },
            { label: '11:00AM', value: '11:00AM' },
        ];
    }

    handleStartTimeChange(event) {
        this.startTime = event.detail.value;
    }

    
    handleChangeValidation(event){
        let fieldName = event.target.name;
        console.log('fieldName',fieldName);
        let dom = this.template.querySelector('[data-id="' + fieldName + '"]');
            let Val = dom.value;
            console.log('titleVal ',Val);
            if(fieldName === 'Title'){
                this.title = Val;
            }
            if(fieldName === 'Visit Date'){
                this.visitDate = Val;
                
            }
            if(fieldName === 'Start Time'){
                this.startTime = Val;
            }
            if(fieldName === 'Duration'){
                this.duration = Val;
            }   
            if(!Val){
                console.log('success');
                dom.setCustomValidity('Please Enter the ' +fieldName);
            }else{
                dom.setCustomValidity('');
            }
            dom.reportValidity();
            //this.fieldValidationStatus = dom.reportValidity();
            console.log('Validation status :',dom.reportValidity());
            this.checkAllFieldsArePopulated();
    }

    clearFieldValues(){

        this.title=null;
        this.visitDate=null;
        this.startTime=null;
        this.duration=null;
    }

    checkAllFieldsArePopulated(){
        var title = this.template.querySelector('[data-id="Title"]').value;
        var visitDate = this.template.querySelector('[data-id="Visit Date"]').value;
        var startTime = this.template.querySelector('[data-id="Start Time"]').value;
        var duration = this.template.querySelector('[data-id="Duration"]').value;
        
        console.log(title);
        console.log(visitDate);
        console.log(startTime);
        console.log(duration);

        if(title !== null && title !== undefined && title !== '' && 
        visitDate !== null && visitDate !== undefined && visitDate !== '' && 
        startTime !== null && startTime !== undefined && startTime !== '' && 
        duration !== null && duration !== undefined && duration !== '' && visitDate >= this.today){
            this.disableSaveButton = false;
        }else{
            this.disableSaveButton = true;
        }



        /*
        if(title !== undefined && startTime !== undefined && visitDate !== undefined && duration !== undefined ){
            this.showToast();
        }else{
            this.sendRecord();
            
        }*/

    }

    titleChange(event){
        this.title= event.target.value;
    }

    visitDateChange(event){
        console.log('In');
        this.visitDate= event.target.value;
    }
    
    showToast() {
        const event = new ShowToastEvent({
            title: 'Please fill the required fields',
            message: 'Please fill the required fields',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showToastSuccess() {
        var message;
        if(this.televisitEditView){
            message='Televisit record updated successfully'
        }else{
            message='Televisit record created successfully';
        }
        const event = new ShowToastEvent({
            title: message,
            message: message,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    sendRecord() {
        if(this.televisitRecordId !== ''){
            this.televisitRecord.id = this.televisitRecordId;
        }else{
            this.televisitRecord.id = '';
        }
        this.televisitRecord.title = this.title;
        this.televisitRecord.visitDate = this.visitDate;
        this.televisitRecord.startTime = this.startTime;
        console.log('Start Time:',this.startTime);
        this.televisitRecord.duration = this.duration;
        this.televisitRecord.peid = this.peid.id;
        
        //console.log('AttendeesList', this.attendeesList);
        //this.attendeesListObject.attendeesList.push(this.attendeesList);
        //console.log(this.attendeesListObject.attendeesList);
        //this.televisitRecord.attendeesList = JSON.stringify(this.attendeesListObject);
        this.televisitRecord.attendeesList = this.selectedAttendees;
        
        console.log('Televisit Record :',this.televisitRecord);
        sendRecord({wrapperText:JSON.stringify(this.televisitRecord)})
            .then((result) => {
                console.log(result);
                if(result !== null){
                    this.showToastSuccess();
                    this.isModalOpen = false;
                    this.fetchTelevisitRecord();
                }
            })
            .catch((error) => {
                console.log(error);
            });
    }

    connectedCallback(){
        
        this.displayTelevisitRecords = true;        
                
        this.fetchTelevisitRecord();

        /*
        fetchAttendees({ParticipantEnrollmentId : this.peid.id})
            .then((result) => {
                console.log(result.length);
                this.attendeesList = [];
                for(let i=0; i<result.length; i++){
                    this.attendeesList.push({label: result[i].contactId, value: result[i].firstName +' '+ result[i].lastName + ' ('+result[i].attendeeType+')'});
                }
            })
            .catch((error) => {
                console.log(error);
            });*/
            
        // Get the current date/time in UTC
        let rightNow = new Date();

        // Adjust for the user's time zone
        rightNow.setMinutes(
            new Date().getMinutes() - new Date().getTimezoneOffset()
        );

        // Return the date in "YYYY-MM-DD" format
        this.today = rightNow.toISOString().slice(0,10);
        console.log(this.today); // Displays the user's current date, e.g. "2020-05-15"
    }

    fetchTelevisitRecord(){
        fetchRecord({status : this.value, participantEnrollmentId : this.peid.id})
            .then((result) => {
                console.log(result);
                this.televisitRecordsList = result;
            })
            .catch((error) => {
                console.log(error);
            });
    }
    

    @api
    doSelectedPI(){
        this.value = 'Scheduled';
        this.attendeesList = [];
        fetchAttendees({ParticipantEnrollmentId : this.peid.id})
        .then((result) => {
            for(let i=0; i<result.length; i++){
                this.attendeesList.push({label: result[i].contactId, value: result[i].firstName +' '+ result[i].lastName + ' ('+result[i].attendeeType+')'});
            }
        })
        .catch((error) => {
            console.log(error);
        });
        this.fetchTelevisitRecord();
        //let obj = {label: this.peid.id, value: this.peid.firstName +' '+ this.peid.lastName +' (Participant)'};
        //this.attendeesList.push(obj);
    }

    openTelevisitWindow(event){
        var url = event.target.value;
        //var url = '/apex/televisit?sessionId=2_MX40NzQ2MjA4MX5-MTY0ODczNjAyNjA3OX5CT01pQ0orZytUZ2dpQVpZMHhNNlFMR1l-fg';
        window.open(url);
    }

    
    selectedAttendees = [];

    handleAttendeeChange(event){
        let opps = event.detail;
        this.selectedAttendees = [];
            
        opps.forEach(opp => {
            this.selectedAttendees.push(opp.label+':'+opp.value);
            //this.selectedAttendees.push(opp.label);
        });
        console.log('selectedAttendees :',this.selectedAttendees);
    }

    cancelTelevisit(event){
        console.log('Cancel Id :', event.target.dataset.id);
        cancelTelevisit({TelevisitId : event.target.dataset.id})
            .then((result) => {
                console.log(result);
                if(result === 'Televisit Cancelled Successfully'){
                    this.fetchTelevisitRecord();
                    const event = new ShowToastEvent({
                        title: 'Televisit record cancelled successfully',
                        message: 'Televisit record cancelled successfully',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    this.isCancelModalOpen = false;
                }
            })
            .catch((error) => {
                console.log(error);
            });
    }


    handleCloseModal(){
        this.isCancelModalOpen = false;
    }

    openCancelModal(event){
        this.isCancelModalOpen = true;
        this.cancelTelevisitRecordId = event.target.dataset.id;
    }
}