import { LightningElement,track,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendRecord from "@salesforce/apex/TelevisitCreationScreenController.insertTelevisitRecord";
import fetchRecord from "@salesforce/apex/TelevisitCreationScreenController.fetchTelevisitRecord";
import fetchAttendees from "@salesforce/apex/TelevisitCreationScreenController.fetchAttendees";
import fetchSelectedAttendees from "@salesforce/apex/TelevisitCreationScreenController.fetchSelectedAttendees";
import updateAttendees from "@salesforce/apex/TelevisitCreationScreenController.updateAttendees";
import cancelTelevisit from "@salesforce/apex/TelevisitCreationScreenController.cancelTelevisit";
import { NavigationMixin } from "lightning/navigation";
const cbClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
const isMenuOpen = ' slds-is-open';

export default class ModalPopupLWC extends NavigationMixin(LightningElement) {
    @api peid;
    @api get peidnew(){
        return this.peid;
    };
    set peidnew(value){
        this.peid = value;
        this.doSelectedPI();
    }

    @api callTV;
    @api get calltelevisit(){
        return this.callTV;
    };
    set calltelevisit(value){
        this.fetchTelevisitRecord3();
    }

    @api fetchTelevisitRecord3(){
        console.log('fetchTelevisitRecord3');
        this.fetchTelevisitRecord();
    }
    
    value = 'Scheduled';
    duration;
    @track startTime;
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
    siteStaffAdded = true;
    isLoading = true;
    currentTime;
    startTimeChanged = false;
    @track defaultTime;
    @track isModalOpen = false;
    selectedAttendees = [];
    attendeeObj = {name:'',id:'',index:'',attendeeId:'',attendeeType:'',isMandatorySelection:false};
    @track selectedAttendeesList = [];
    @track itemToRemove = {name:'',id:''};
    @track selectedItems;
    openModal(event) {
        this.isModalOpen = true;
        if(event.target.dataset.id !== null && event.target.dataset.id !== '' && event.target.dataset.id !== undefined){
            this.televisitEditView = true;
            this.title = event.target.dataset.title;
            this.visitDate = event.target.dataset.visitdate;
            this.startTime = this.msToTime(event.target.dataset.starttime);
            this.duration = event.target.dataset.duration;
            this.televisitRecordId = event.target.dataset.id;
            //console.log('SelectedAttendeesList :',event.target.dataset.id);
            //this.fetchSelectedAttendees(event.target.dataset.id);
            this.isLoading = true;
            this.startTimeChanged = false;
            this.fetchAttendees();
        }else{
            this.televisitEditView = false;
            this.televisitRecordId = '';
            this.title = '';
            this.visitDate = '';
            this.startTime = '';
            this.duration = '';
            const today = new Date();
            let h = today.getHours();
            let m = today.getMinutes();
            h = h < 10 ? '0' + h : h;
            m = m < 10 ? '0' + m : m;
            this.currentTime = h+':' + m + ':00.000Z';
            this.defaultTime = this.currentTime;
            this.startTimeChanged = false;
            //this.startTime = this.msToTime(event.target.dataset.starttime);
            
            //this.fetchRequiredAttendees();
            this.isLoading = true;
            this.fetchAttendees();
            
        }
    }

    checkSiteStaffAdded(localSelectedAttendeesList){
        console.log('this.siteStaffAdded',this.siteStaffAdded);
        for(let i=0; i<localSelectedAttendeesList.length; i++){
            console.log('localSelectedAttendeesList.attendeeType',localSelectedAttendeesList[i].attendeeType);
            if(localSelectedAttendeesList[i].attendeeType === 'Site Staff' || 
                localSelectedAttendeesList[i].attendeeType === 'PI'
            ){
                this.siteStaffAdded = true;
                break;
            }else{
                this.siteStaffAdded = false;
            }
        }  
        this.checkAllFieldsArePopulated();  
    }

    /*
    fetchSelectedAttendees(recordId){
        fetchSelectedAttendees({TelevisitId :recordId })
            .then((result) => {
                console.log(result);
                this.selectedAttendeesList = [];
                
                for(let i=0; i<result.length; i++){
                    for(let j=0; j<this.attendeesList.length; j++){
                        if(result[i].contactId === this.attendeesList[j].label){
                            this.attendeeObj = {};
                            //this.attendeeObj.name = result[i].firstName + ' ' + result[i].lastName + ' ('+result[i].attendeeType+ ')';
                            this.attendeeObj.id = result[i].contactId;
                            this.attendeeObj.firstName = result[i].firstName;
                            this.attendeeObj.lastName = result[i].lastName;
                            this.attendeeObj.attendeeType = result[i].attendeeType;
                            this.attendeeObj.contactId = result[i].contactId;
                            this.attendeeObj.attendeeId = result[i].attendeeId;
                            this.attendeeObj.index = j;
                            this.selectedAttendeesList.push(this.attendeeObj);
                        }
                        
                    }
                }
                this.selectedItems = this.selectedAttendeesList;
                this.isLoading = false;
                
            })
            .catch((error) => {
                console.log(error);
            });
    }*/

    compareArrayOfObjects(a,b){
        console.log('Inside',a);
        console.log('Inside',b);
        a = a.filter(function(obj) {
            return !this.has(obj.id);
        }, new Set(b.map(obj => obj.id)));
        
        console.log(a);
        return a;
    }

    updateAttendees(recordId,deletedAttendeesRecord,newlyAddedAttendeesRecord){
        updateAttendees({TelevisitId :recordId,
                        deletedAttendeesRecord:deletedAttendeesRecord,
                        newlyAddedAttendeesRecord:newlyAddedAttendeesRecord})
            .then((result) => {
                //console.log(result);
                this.fetchTelevisitRecord();
                //this.selectedAttendees = [];
                //this.selectedAttendeesList = [];
                //this.selectedItems = [];
                this.resetTelevisitAttendeesList();
            })
            .catch((error) => {
                console.log(error);
            });
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
        this.isModalOpen = false;
        this.clearFieldValues();
    }
    submitDetails(event) {
        this.sendRecord();
        var deletedAttendeesRecord = [];
        var newlyAddedAttendeesRecord = [];
        if(event.target.dataset.id ==='Update'){
            /*
            deletedAttendeesRecord = this.compareArrayOfObjects(this.selectedItems,this.selectedAttendeesList);
            newlyAddedAttendeesRecord = this.compareArrayOfObjects(this.selectedAttendeesList,this.selectedItems);
            this.updateAttendees(this.televisitRecordId, JSON.stringify(deletedAttendeesRecord), JSON.stringify(newlyAddedAttendeesRecord));
            */
            deletedAttendeesRecord = this.compareArrayOfObjects(this.duplicateSelectedTelevisitAttendeesList,this.selectedTelevisitAttendeesList);
            newlyAddedAttendeesRecord = this.compareArrayOfObjects(this.selectedTelevisitAttendeesList,this.duplicateSelectedTelevisitAttendeesList);
            this.updateAttendees(this.televisitRecordId, JSON.stringify(deletedAttendeesRecord), JSON.stringify(newlyAddedAttendeesRecord));
        }
        
        //this.resetTelevisitAttendeesList();
     
                
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
            let val = dom.value;
            if(fieldName === 'Title'){
                this.title = val;
            }
            if(fieldName === 'Visit Date'){
                this.visitDate = val;
                if(this.visitDate > this.today){
                    this.defaultTime = '05:00:00.000Z';
                }else if(this.visitDate === this.today){
                    this.defaultTime = this.currentTime;
                    console.log('current Time :',this.currentTime);
                    console.log('start Time :',this.startTime);
                    if(this.startTime < this.currentTime && this.startTimeChanged){
                        this.startTime = null;
                        this.template.querySelector('[data-id="Start Time"]').setCustomValidity('Please Enter the Start Time');
                        this.template.querySelector('[data-id="Start Time"]').reportValidity();
                    }
                }
            }
            if(fieldName === 'Start Time'){
                this.startTime = val;
                this.startTimeChanged = true;
            }
            if(fieldName === 'Duration'){
                this.duration = val;
            }   
            if(!val){
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
        this.selectedAttendees = [];
        this.selectedAttendeesList = [];
        this.selectedItems = [];
        this.siteStaffAdded = true;
        this.selectedTelevisitAttendeesList = [];
        this.duplicateSelectedTelevisitAttendeesList = [];
    }

    checkAllFieldsArePopulated(){
        var title = this.template.querySelector('[data-id="Title"]').value;
        var visitDate = this.template.querySelector('[data-id="Visit Date"]').value;
        var startTime = this.template.querySelector('[data-id="Start Time"]').value;
        var duration = this.template.querySelector('[data-id="Duration"]').value;
        console.log('startTime ',startTime);
        console.log('this.startTime ',this.startTime);
        if(title !== null && title !== undefined && title !== '' && 
        visitDate !== null && visitDate !== undefined && visitDate !== '' && 
        this.startTime !== null && this.startTime !== undefined && this.startTime !== '' && 
        duration !== null && duration !== undefined && duration !== '' && visitDate >= this.today && 
        this.siteStaffAdded){
            this.disableSaveButton = false;
        }else{
            this.disableSaveButton = true;
        }
    }

    titleChange(event){
        this.title= event.target.value;
    }

    visitDateChange(event){
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
        this.televisitRecord.attendeesList = this.selectedTelevisitAttendeesList;
        //this.televisitRecord.attendeesList = this.selectedAttendees;
        sendRecord({wrapperText:JSON.stringify(this.televisitRecord)})
            .then((result) => {
                if(result !== null){
                    this.showToastSuccess();
                    this.isModalOpen = false;
                    this.fetchTelevisitRecord();
                    this.resetTelevisitAttendeesList();
                }
                
            })
            .catch((error) => {
                console.log(error);
            });
    }

    connectedCallback(){
        this.displayTelevisitRecords = true;        
        this.fetchTelevisitRecord();
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
                if(result.length > 0){
                    this.displayTelevisitRecords = true;   
                }else{
                    this.displayTelevisitRecords = false;
                }
            })
            .catch((error) => {
                console.log(error);
            });
    }


    /*
    fetchRequiredAttendees(){
        this.itemToRemove = {};
                
        this.selectedAttendees = [];
        this.selectedAttendeesList = [];
        this.selectedItems = [];
        
        for(var i=0;i<this.attendeesList.length;i++){
            console.log('this.attendeesList :',this.attendeesList);
            if(this.attendeesList[i].attendeeType === 'Participant'){
                this.selectedAttendees.push(this.attendeesList[i].label+':'+this.attendeesList[i].value);
                this.attendeeObj = {};
                this.attendeeObj.name = this.attendeesList[i].value;
                this.attendeeObj.id = this.attendeesList[i].label;
                this.attendeeObj.index = i;
                this.attendeeObj.attendeeType = this.attendeesList[i].attendeeType;
                this.attendeeObj.isMandatorySelection = true;
                this.selectedAttendeesList.push(this.attendeeObj);
                
            }
            if(this.attendeesList[i].attendeeType === 'Participant Delegate'){
                this.selectedAttendees.push(this.attendeesList[i].label+':'+this.attendeesList[i].value);
                this.attendeeObj = {};
                this.attendeeObj.name = this.attendeesList[i].value;
                this.attendeeObj.id = this.attendeesList[i].label;
                this.attendeeObj.index = i;
                this.attendeeObj.attendeeType = this.attendeesList[i].attendeeType;
                this.attendeeObj.isMandatorySelection = false;
                this.selectedAttendeesList.push(this.attendeeObj);
                
            }
        }
        console.log('fetchRequiredAttendees :',this.selectedAttendeesList);
        this.selectedItems = this.selectedAttendeesList;
    }*/

    fetchAttendees(){
        this.attendeesList = [];
        this.televisitAttendeesList = [];
        this.selectedTelevisitAttendeesList = [];
        fetchAttendees({ParticipantEnrollmentId : this.peid.id})
        .then((result) => {
            for(let i=0; i<result.length; i++){
                this.attendeesList.push({participantPrimaryDelegate:result[i].participantPrimaryDelegate,
                                        participantAdult:result[i].participantAdult,
                                        attendeeType:result[i].attendeeType,
                                        label: result[i].contactId, 
                                        value: result[i].firstName +' '+ result[i].lastName + ' ('+result[i].attendeeType+')'});
                
                this.televisitAttendeesObj = {};
                this.televisitAttendeesObj.id = result[i].contactId;
                this.televisitAttendeesObj.firstName = result[i].firstName;
                this.televisitAttendeesObj.lastName = result[i].lastName;
                this.televisitAttendeesObj.attendeeType = result[i].attendeeType;
                this.televisitAttendeesObj.participantAdult = result[i].participantAdult;
                this.televisitAttendeesObj.participantPrimaryDelegate = result[i].participantPrimaryDelegate;
                if(this.televisitAttendeesObj.attendeeType === 'Participant'){
                    this.televisitAttendeesObj.isMandatorySelection = true;
                }else if(this.televisitAttendeesObj.attendeeType === 'Participant Delegate' && this.televisitAttendeesObj.participantAdult === false && this.televisitAttendeesObj.participantPrimaryDelegate){
                    this.televisitAttendeesObj.isMandatorySelection = true;
                }else{
                    this.televisitAttendeesObj.isMandatorySelection = false;
                }
                this.televisitAttendeesList.push(this.televisitAttendeesObj);
                this.televisitAttendeesListTemp =  this.televisitAttendeesList;
            }

            if(this.televisitEditView){
                this.fetchTelevisitSelectedAttendees(this.televisitRecordId);
            }else{
                this.handleMandatoryAttendeesSelection();
            }
        })
        .catch((error) => {
            console.log(error);
        });
    }

    @api
    doSelectedPI(){
        this.value = 'Scheduled';
        this.attendeesList = [];
        this.televisitAttendeesList = [];
        //this.fetchAttendees();
        this.fetchTelevisitRecord();
    }

    openTelevisitWindow(event){
        var url = event.target.value;
        //var url = '/apex/televisit?sessionId=2_MX40NzQ2MjA4MX5-MTY0ODczNjAyNjA3OX5CT01pQ0orZytUZ2dpQVpZMHhNNlFMR1l-fg';
        window.open(url);
    }
    
    /*
    handleAttendeeChange(event){
        let opps = event.detail;
        console.log('opps :',opps);
        console.log('this.selectedAttendeesList :',this.selectedAttendeesList);
        this.selectedAttendees = [];
        this.selectedAttendeesList = [];
        
        opps.forEach(opp => {
            this.selectedAttendees.push(opp.label+':'+opp.value);
            this.attendeeObj = {};
            this.attendeeObj.name = opp.value;
            this.attendeeObj.id = opp.label;
            this.attendeeObj.index = opp.index;
            this.attendeeObj.attendeeType = opp.attendeeType;
            if(opp.attendeeType === 'Participant'){
                this.attendeeObj.isMandatorySelection = true;
            }else if(opp.attendeeType === 'Participant Delegate' && opp.participantAdult === false && opp.participantPrimaryDelegate){
                this.attendeeObj.isMandatorySelection = true;
            }else{
                this.attendeeObj.isMandatorySelection = false;
            }
            
            this.selectedAttendeesList.push(this.attendeeObj);

            
            //this.selectedAttendees.push(opp.label);
        });
        console.log('selectedAttendees :',this.selectedAttendees);
        console.log('selectedAttendeesList :',this.selectedAttendeesList);
        //this.checkSiteStaffAdded(this.selectedAttendeesList);

    }
    */

    /*
    removeSelectedItem(event){
        console.log('Inside');
        console.log('Selected Id :', event.target.dataset.id);
        this.itemToRemove = {name:'',id:'',index:''};
        this.itemToRemove.name = event.target.dataset.name;
        this.itemToRemove.id = event.target.dataset.id;
        this.itemToRemove.index = event.target.dataset.index;
        console.log('itemToRemove',this.itemToRemove);
        this.selectedAttendeesList.splice(this.selectedAttendeesList.findIndex(a => a.id === this.itemToRemove.id) , 1)
        console.log('selectedAttendeesList :',this.selectedAttendeesList);
    }
    */
    cancelTelevisit(event){
        cancelTelevisit({TelevisitId : event.target.dataset.id})
            .then((result) => {
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

    @track cbComputedClass = cbClass;
    @track isComboExpanded = false;
    @api placeHolder = 'Search to add';
    televisitAttendeesList = [];
    televisitAttendeesObj = {};
    @track selectedTelevisitAttendeesList = [];
    @track duplicateSelectedTelevisitAttendeesList = [];
    @track mapData= [];
    @track noResultsFound = false;
    @track televisitAttendeesListTemp = [];
    isSearchMode = false;
    closeOptionsMenu(){
        this.isComboExpanded = false;
        this.cbComputedClass = cbClass;        
    }
    openOptionsMenu(){
        if(this.televisitAttendeesList.length>0){
            this.isComboExpanded = true;
            this.cbComputedClass = cbClass+isMenuOpen;
        }else{
            this.closeOptionsMenu();
        }
        
    }

    handleSelection(event){
        this.televisitAttendeesObj = {};
        this.televisitAttendeesObj.id =event.target.dataset.id;
        this.televisitAttendeesObj.firstName = event.target.dataset.firstName;
        this.televisitAttendeesObj.lastName = event.target.dataset.lastName;
        this.televisitAttendeesObj.attendeeType = event.target.dataset.attendeeType;
        this.televisitAttendeesObj.attendeeId = event.target.dataset.attendeeId;
        if(event.target.dataset.isMandatorySelection === 'true'){
            this.televisitAttendeesObj.isMandatorySelection = true;
        }else{
            this.televisitAttendeesObj.isMandatorySelection = false;
        }
        this.selectedTelevisitAttendeesList.push(this.televisitAttendeesObj);
        this.televisitAttendeesList.splice(this.televisitAttendeesList.findIndex(a => a.id === event.target.dataset.id) , 1);
        if(this.isSearchMode)
            this.televisitAttendeesListTemp.splice(this.televisitAttendeesListTemp.findIndex(a => a.id === event.target.dataset.id) , 1);
        this.closeOptionsMenu();
        this.checkSiteStaffAdded(this.selectedTelevisitAttendeesList);
    }
    handleRemoveItems(event){
        this.televisitAttendeesObj = {};
        this.televisitAttendeesObj.id =event.target.dataset.id;
        this.televisitAttendeesObj.firstName = event.target.dataset.firstName;
        this.televisitAttendeesObj.lastName = event.target.dataset.lastName;
        this.televisitAttendeesObj.attendeeType = event.target.dataset.attendeeType;
        this.televisitAttendeesObj.attendeeId = event.target.dataset.attendeeId;
        if(event.target.dataset.isMandatorySelection === 'true'){
            this.televisitAttendeesObj.isMandatorySelection = true;
        }else{
            this.televisitAttendeesObj.isMandatorySelection = false;
        }
        this.televisitAttendeesList.push(this.televisitAttendeesObj);
        this.televisitAttendeesListTemp =  this.televisitAttendeesList;
        this.selectedTelevisitAttendeesList.splice(this.selectedTelevisitAttendeesList.findIndex(a => a.id === event.target.dataset.id) , 1);
        this.checkSiteStaffAdded(this.selectedTelevisitAttendeesList);
    }

    handleMandatoryAttendeesSelection(){
        for(var i=0;i<this.televisitAttendeesList.length;i++){
            if(this.televisitAttendeesList[i].attendeeType === 'Participant' || this.televisitAttendeesList[i].attendeeType === 'Participant Delegate'){
                this.televisitAttendeesObj = {};
                this.televisitAttendeesObj.id =this.televisitAttendeesList[i].id;
                this.televisitAttendeesObj.firstName = this.televisitAttendeesList[i].firstName;
                this.televisitAttendeesObj.lastName = this.televisitAttendeesList[i].lastName;
                this.televisitAttendeesObj.attendeeType = this.televisitAttendeesList[i].attendeeType;
                this.televisitAttendeesObj.isMandatorySelection = this.televisitAttendeesList[i].isMandatorySelection;
                this.selectedTelevisitAttendeesList.push(this.televisitAttendeesObj);
                this.televisitAttendeesList.splice(this.televisitAttendeesList.findIndex(a => a.id === this.televisitAttendeesList[i].id) , 1);
                //Added for Search functionality
                this.televisitAttendeesListTemp =  this.televisitAttendeesList;
            }
        }
        this.checkSiteStaffAdded(this.selectedTelevisitAttendeesList);
        this.isLoading = false;
    }

    resetTelevisitAttendeesList(){
        this.televisitAttendeesList = [];
        this.selectedTelevisitAttendeesList = [];
        this.duplicateSelectedTelevisitAttendeesList = [];
    }

    fetchTelevisitSelectedAttendees(recordId){
        fetchSelectedAttendees({TelevisitId :recordId })
            .then((result) => {
                this.selectedTelevisitAttendeesList = [];
                for(var i=0;i<result.length;i++){
                    this.televisitAttendeesObj = {};
                    this.televisitAttendeesObj.id =result[i].id;
                    this.televisitAttendeesObj.firstName = result[i].firstName;
                    this.televisitAttendeesObj.lastName = result[i].lastName;
                    this.televisitAttendeesObj.attendeeType = result[i].attendeeType;
                    this.televisitAttendeesObj.attendeeId = result[i].attendeeId;
                    this.televisitAttendeesObj.isMandatorySelection = this.televisitAttendeesList.find(a => a.id === result[i].id).isMandatorySelection;
                    this.selectedTelevisitAttendeesList.push(this.televisitAttendeesObj);
                    this.duplicateSelectedTelevisitAttendeesList.push(this.televisitAttendeesObj);
                    this.televisitAttendeesList.splice(this.televisitAttendeesList.findIndex(a => a.id === result[i].id) , 1);
                    //Added for Search functionality
                    this.televisitAttendeesListTemp =  this.televisitAttendeesList;
                }
                this.checkSiteStaffAdded(this.selectedTelevisitAttendeesList);
                this.isLoading = false;
                
            })
            .catch((error) => {
                console.log(error);
            });
    }

    handleSearch(event) {
        const searchKey = event.target.value;
        this.noResultsFound = false;
        if(searchKey){   
            this.isSearchMode = true;       
            this.televisitAttendeesList = this.televisitAttendeesListTemp.filter(obj => obj.firstName.toLowerCase().includes(searchKey.toLowerCase()) ||
                                                                                        obj.lastName.toLowerCase().includes(searchKey.toLowerCase()) || 
                                                                                        obj.attendeeType.toLowerCase().includes(searchKey.toLowerCase()));
            if(this.televisitAttendeesList.length === 0) this.noResultsFound = true;
            this.openOptionsMenu();
        }
        
        else{
            this.isSearchMode = false; 
            this.closeOptionsMenu();
            this.televisitAttendeesList = this.televisitAttendeesListTemp;
        }  
        
    }
}