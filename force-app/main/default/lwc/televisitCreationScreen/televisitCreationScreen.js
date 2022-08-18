import { LightningElement,track,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendRecord from "@salesforce/apex/TelevisitCreationScreenController.insertTelevisitRecord";
import fetchRecord from "@salesforce/apex/TelevisitCreationScreenController.fetchTelevisitRecord";
import fetchAttendees from "@salesforce/apex/TelevisitCreationScreenController.fetchAttendees";
import fetchSelectedAttendees from "@salesforce/apex/TelevisitCreationScreenController.fetchSelectedAttendees";
import updateAttendees from "@salesforce/apex/TelevisitCreationScreenController.updateAttendees";
import cancelTelevisit from "@salesforce/apex/TelevisitCreationScreenController.cancelTelevisit";
import fetchParticipantDetails from "@salesforce/apex/TelevisitCreationScreenController.fetchParticipantDetails";
import { NavigationMixin } from "lightning/navigation";
import TIME_ZONE from '@salesforce/i18n/timeZone';
import pirResources from '@salesforce/resourceUrl/pirResources';
import RH_TV_View from '@salesforce/label/c.RH_TV_View';
import RH_TV_CreateTelevisit from '@salesforce/label/c.RH_TV_CreateTelevisit';
import RH_TV_EditTelevisit from '@salesforce/label/c.RH_TV_EditTelevisit';
import RH_TV_CancelTelevisit from '@salesforce/label/c.RH_TV_CancelTelevisit';
import RH_TV_CancelMessage from '@salesforce/label/c.RH_TV_CancelMessage';
import RH_TV_NoRecordsFoundMessage from '@salesforce/label/c.RH_TV_NoRecordsFoundMessage';
import RH_TV_SiteStaffRequiredErrorMessage from '@salesforce/label/c.RH_TV_SiteStaffRequiredErrorMessage';
import RH_UserEmailPermissionAlert from '@salesforce/label/c.RH_UserEmailPermissionAlert';
import RH_UserRegistration_Warning from '@salesforce/label/c.RH_UserRegistration_Warning';
import FORM_FACTOR from '@salesforce/client/formFactor';
import RH_TV_Discard from '@salesforce/label/c.RH_TV_Discard';
import RH_TV_Confirm from '@salesforce/label/c.RH_TV_Confirm';
import RH_TV_Close from '@salesforce/label/c.RH_TV_Close';
import RH_TV_Remove from '@salesforce/label/c.RH_TV_Remove';
import RH_TV_Save from '@salesforce/label/c.RH_TV_Save';

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
        this.fetchTelevisitRecord();
    }
    backArrow = pirResources + "/pirResources/icons/triangle-left.svg";
    notification = pirResources+'/pirResources/icons/bell.svg';
    alert = pirResources+'/pirResources/icons/status-alert.svg';
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
    @track today;
    fieldValidationStatus;
    isCancelModalOpen = false;
    cancelTelevisitRecordId;
    televisitEditView = false;
    televisitRecordId='';
    siteStaffAdded = true;
    isLoading = true;
    isMainSpinnerLoading = false;
    isCancelSpinnerLoading = false;
    currentTime;
    startTimeChanged = false;
    @track defaultTime;
    @track isModalOpen = false;
    @track userTimeZone;
    selectedAttendees = [];
    attendeeObj = {name:'',id:'',index:'',attendeeId:'',attendeeType:'',isMandatorySelection:false};
    @track selectedAttendeesList = [];
    @track itemToRemove = {name:'',id:''};
    @track selectedItems;
    @track isMobileDevice = false;
    isPPUserActivated = true;
    isEmailPermitted = true;
    label = {
        RH_TV_View,
        RH_TV_CreateTelevisit,
        RH_TV_EditTelevisit,
        RH_TV_CancelTelevisit,
        RH_TV_CancelMessage,
        RH_TV_NoRecordsFoundMessage,
        RH_TV_SiteStaffRequiredErrorMessage,
        RH_TV_Discard,
        RH_TV_Confirm,
        RH_TV_Close,
        RH_TV_Remove,
        RH_TV_Save,
        RH_UserEmailPermissionAlert,
        RH_UserRegistration_Warning

    }

    //bishwa starts
    renderedCallback() {
        const style = document.createElement('style'); 
        style.innerText = "lightning-combobox[data-id=Duration] .slds-combobox__input{  padding: 4px;}"; 
        if (window.innerWidth == 768) {           
            this.template.querySelector('lightning-combobox[data-id=Duration]').appendChild(style);
        }
    }
    goBackHandler(){
        window.history.back();
    }
    //bishwa ends
    openModal(event) {
        this.isModalOpen = true;
        if(event.target.dataset.id !== null && event.target.dataset.id !== '' && event.target.dataset.id !== undefined){
            this.televisitEditView = true;
            this.title = event.target.dataset.title;
            this.visitDate = event.target.dataset.visitdate;
            
            var visitDateTime = new Date(event.target.dataset.visitdatetime).toLocaleTimeString('en-US', { timeZone: TIME_ZONE });
            visitDateTime = this.getTwentyFourHourTime(visitDateTime);
            //this.startTime = visitDateTime;

            if(FORM_FACTOR == 'Small'){
                this.isMobileDevice = true;
                this.startTime = visitDateTime.substring(0, 5);
                
            }else{
                this.isMobileDevice = false;
            this.startTime = visitDateTime;
            }
  


            //this.startTime = this.msToTime(event.target.dataset.starttime);
            


            this.duration = event.target.dataset.duration;
            this.televisitRecordId = event.target.dataset.id;
            //console.log('SelectedAttendeesList :',event.target.dataset.id);
            //this.fetchSelectedAttendees(event.target.dataset.id);
            this.isLoading = true;
            this.startTimeChanged = false;
            
            this.fetchAttendees();

            var today = new Date();
            var newdatetimezone = today.toLocaleTimeString('en-US', { timeZone: TIME_ZONE });
            newdatetimezone = this.getTwentyFourHourTime(newdatetimezone);
            if(this.visitDate > this.today){
                this.defaultTime = '00:00:00.000Z';
            }else{
                this.defaultTime = newdatetimezone;
            
            }
            this.currentTime = newdatetimezone;
            
            //Added for android issue
            if(FORM_FACTOR == 'Small'){
                this.isMobileDevice = true;
                this.defaultTime = this.defaultTime.substring(0, 5);
                this.currentTime = this.currentTime.substring(0, 5);
            }else{
                this.isMobileDevice = false;
                this.defaultTime = this.defaultTime;
                this.currentTime = this.currentTime;
            }

        }else{
            this.televisitEditView = false;
            this.televisitRecordId = '';
            this.title = '';
            this.visitDate = '';
            this.startTime = '';
            this.duration = '';
            
            var today = new Date();
            let h = today.getHours();
            let m = today.getMinutes();
            h = h < 10 ? '0' + h : h;
            m = m < 10 ? '0' + m : m;
            //this.currentTime = h+':' + m + ':00.000Z';
            //this.defaultTime = this.currentTime;
            //this.startTime = this.msToTime(event.target.dataset.starttime);
            
            
            
            this.startTimeChanged = false;
            var newdatetimezone = today.toLocaleTimeString('en-US', { timeZone: TIME_ZONE })
            newdatetimezone = this.getTwentyFourHourTime(newdatetimezone);
            this.defaultTime = newdatetimezone;
            this.currentTime = newdatetimezone;

            //Added for android issue
            if(FORM_FACTOR == 'Small'){
                this.isMobileDevice = true;
                this.defaultTime = this.defaultTime.substring(0, 5);
                this.currentTime = this.currentTime.substring(0, 5);
            }else{
                this.isMobileDevice = false;
                this.defaultTime = this.defaultTime;
                this.currentTime = this.currentTime;
            }

            //this.fetchRequiredAttendees();
            this.isLoading = true;
            this.fetchAttendees();

            
            
        }
    }

    getTwentyFourHourTime(amPmString) { 
        var d = new Date("1/1/2013 " + amPmString); 
        let h = d.getHours();
        let m = d.getMinutes();
        h = h < 10 ? '0' + h : h;
        m = m < 10 ? '0' + m : m;
        return h + ':' + m + ':00.000Z'; 
    }

    checkSiteStaffAdded(localSelectedAttendeesList){
        for(let i=0; i<localSelectedAttendeesList.length; i++){
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

    compareArrayOfObjects(a,b){
        a = a.filter(function(obj) {
            return !this.has(obj.id);
        }, new Set(b.map(obj => obj.id)));
        
        return a;
    }

    updateAttendees(recordId,deletedAttendeesRecord,newlyAddedAttendeesRecord){
        updateAttendees({TelevisitId :recordId,
                        deletedAttendeesRecord:deletedAttendeesRecord,
                        newlyAddedAttendeesRecord:newlyAddedAttendeesRecord})
            .then((result) => {
                this.fetchTelevisitRecord();
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
            deletedAttendeesRecord = this.compareArrayOfObjects(this.duplicateSelectedTelevisitAttendeesList,this.selectedTelevisitAttendeesList);
            newlyAddedAttendeesRecord = this.compareArrayOfObjects(this.selectedTelevisitAttendeesList,this.duplicateSelectedTelevisitAttendeesList);
            this.updateAttendees(this.televisitRecordId, JSON.stringify(deletedAttendeesRecord), JSON.stringify(newlyAddedAttendeesRecord));
        }
        //this.resetTelevisitAttendeesList();
    }
    get options() {
        return [
            { label: 'Scheduled', value: 'Scheduled' },
            { label: 'Canceled/Completed', value: 'Cancelled/Completed' },
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
        
        let dom = this.template.querySelector('[data-id="' + fieldName + '"]');
            let val = dom.value;
            if(fieldName === 'Title'){
                this.title = val;
            }
            if(fieldName === 'Visit Date'){
                this.visitDate = val;
                if(this.visitDate > this.today){
                    this.defaultTime = '00:00:00.000Z';
                }else if(this.visitDate === this.today){
                    this.defaultTime = this.currentTime;
                    if(this.startTime < this.currentTime && this.startTimeChanged){
                        this.startTime = null;
                        this.template.querySelector('[data-id="Start Time"]').setCustomValidity('Please Enter the Start Time');
                        this.template.querySelector('[data-id="Start Time"]').reportValidity();
                    }
                }else if(this.visitDate < this.today){
                    this.defaultTime = this.currentTime;
                }
            }
            if(fieldName === 'Start Time'){
                this.startTimeChanged = true;
                this.startTime = val;         
                this.errorTime = false;

                if(val < this.defaultTime){
                    this.errorTime = true;
                    dom.setCustomValidity('Enter Current or Future Time');
                }
                else {
                    this.errorTime = false;
                }
            }
            if(fieldName === 'Duration'){
                this.duration = val;
            }   
            if(val == null){
                dom.setCustomValidity('Please Enter the ' +fieldName);
            }
            else if(!val.replace(/\s/g, '')){
                dom.setCustomValidity('Please Enter the ' +fieldName);
            }
            else if(!this.errorTime ){
                dom.setCustomValidity('');
            }
            dom.reportValidity();
            //this.fieldValidationStatus = dom.reportValidity();
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

    errorTime = false;

    checkAllFieldsArePopulated(){
        var title = this.template.querySelector('[data-id="Title"]').value.replace(/\s/g, '');
        var visitDate = this.template.querySelector('[data-id="Visit Date"]').value;
        var startTime = this.template.querySelector('[data-id="Start Time"]').value;
        var duration = this.template.querySelector('[data-id="Duration"]').value;
        if(title !== null && title !== undefined && title !== '' && 
        visitDate !== null && visitDate !== undefined && visitDate !== '' && 
        this.startTime !== null && this.startTime !== undefined && this.startTime !== '' && 
        duration !== null && duration !== undefined && duration !== '' && visitDate >= this.today && 
        this.siteStaffAdded && !this.errorTime){
            this.disableSaveButton = false;
            //Added for android issue
            if(this.visitDate === this.today){
                if(this.startTime < this.currentTime && this.startTimeChanged){
                    this.disableSaveButton = true;
                }
            }
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
        this.televisitRecord.duration = this.duration;
        this.televisitRecord.peid = this.peid.id;
        this.televisitRecord.attendeesList = this.selectedTelevisitAttendeesList;
        this.isMainSpinnerLoading = true;
        
        //this.televisitRecord.attendeesList = this.selectedAttendees;
        sendRecord({wrapperText:JSON.stringify(this.televisitRecord)})
            .then((result) => {
                if(result !== null){
                    this.showToastSuccess();
                    this.isMainSpinnerLoading = false;
                    this.isModalOpen = false;
                    this.fetchTelevisitRecord();
                    if(!this.televisitEditView){
                        this.resetTelevisitAttendeesList();
                    }
                }
                
            })
            .catch((error) => {
                console.log(error);
            });
    }

    connectedCallback(){
        this.displayTelevisitRecords = true;        
        this.checkForPPUser();      
        this.fetchTelevisitRecord();

        var rightNow = new Date();
        var newdatetimezone = rightNow.toLocaleString('sv-SE', { timeZone: TIME_ZONE }).slice(0,10);
        this.today = newdatetimezone;
        this.userTimeZone = TIME_ZONE;
    }

    

    fetchTelevisitRecord(){
        fetchRecord({status : this.value, participantEnrollmentId : this.peid.id})
            .then((result) => {
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
                                        participantHasEmail:result[i].participantHasEmail,
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
                this.televisitAttendeesObj.participantHasEmail = result[i].participantHasEmail;
                if(this.televisitAttendeesObj.attendeeType === 'Participant'){
                    this.televisitAttendeesObj.isMandatorySelection = true;
                }else if(this.televisitAttendeesObj.attendeeType === 'Participant Delegate' && 
                        (this.televisitAttendeesObj.participantAdult === false || (this.televisitAttendeesObj.participantAdult === true && this.televisitAttendeesObj.participantHasEmail === false)) && 
                        this.televisitAttendeesObj.participantPrimaryDelegate ){
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
        this.checkForPPUser();
        this.fetchTelevisitRecord();
    }

    openTelevisitWindow(event){
        var url = event.target.value;
        //var url = '/apex/televisit?sessionId=2_MX40NzQ2MjA4MX5-MTY0ODczNjAyNjA3OX5CT01pQ0orZytUZ2dpQVpZMHhNNlFMR1l-fg';
        window.open(url);
    }
    
    cancelTelevisit(event){
        this.isCancelSpinnerLoading = true;
        cancelTelevisit({TelevisitId : event.target.dataset.id})
            .then((result) => {
                if(result === 'Televisit Cancelled Successfully'){
                    this.fetchTelevisitRecord();
                    const event = new ShowToastEvent({
                        title: 'Televisit record canceled successfully',
                        message: 'Televisit record canceled successfully',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    this.isCancelSpinnerLoading = false;
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
        if(event.target.dataset.participantPrimaryDelegate === 'true'){
            this.televisitAttendeesObj.participantPrimaryDelegate = true;
        }else{
            this.televisitAttendeesObj.participantPrimaryDelegate = false;
        }

        if(event.target.dataset.participantHasEmail === 'true'){
            this.televisitAttendeesObj.participantHasEmail = true;
        }else{
            this.televisitAttendeesObj.participantHasEmail = false;
        }
        
        if(event.target.dataset.isMandatorySelection === 'true'){
            this.televisitAttendeesObj.isMandatorySelection = true;
        }else{
            this.televisitAttendeesObj.isMandatorySelection = false;
        }
        this.selectedTelevisitAttendeesList.push(this.televisitAttendeesObj);
        //this.televisitAttendeesList.splice(this.televisitAttendeesList.findIndex(a => a.id === event.target.dataset.id) , 1);
       
        if(this.isSearchMode){
            this.televisitAttendeesListTemp.splice(this.televisitAttendeesListTemp.findIndex(a => a.id === event.target.dataset.id) , 1);
            this.template.querySelector('[data-id="searchbox"]').value = '';
            this.televisitAttendeesList = this.televisitAttendeesListTemp;
        }else{
            this.televisitAttendeesList.splice(this.televisitAttendeesList.findIndex(a => a.id === event.target.dataset.id) , 1);
        }  
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
        if(event.target.dataset.participantPrimaryDelegate === 'true'){
            this.televisitAttendeesObj.participantPrimaryDelegate = true;
        }else{
            this.televisitAttendeesObj.participantPrimaryDelegate = false;
        }

        if(event.target.dataset.participantHasEmail === 'true'){
            this.televisitAttendeesObj.participantHasEmail = true;
        }else{
            this.televisitAttendeesObj.participantHasEmail = false;
        }

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
            if(this.televisitAttendeesList[i].attendeeType === 'Participant' || (this.televisitAttendeesList[i].attendeeType === 'Participant Delegate'
                && this.televisitAttendeesList[i].participantPrimaryDelegate === true)){
                this.televisitAttendeesObj = {};
                this.televisitAttendeesObj.id =this.televisitAttendeesList[i].id;
                this.televisitAttendeesObj.firstName = this.televisitAttendeesList[i].firstName;
                this.televisitAttendeesObj.lastName = this.televisitAttendeesList[i].lastName;
                this.televisitAttendeesObj.attendeeType = this.televisitAttendeesList[i].attendeeType;
                this.televisitAttendeesObj.isMandatorySelection = this.televisitAttendeesList[i].isMandatorySelection;
                this.televisitAttendeesObj.participantPrimaryDelegate = this.televisitAttendeesList[i].participantPrimaryDelegate;
                this.televisitAttendeesObj.participantHasEmail = this.televisitAttendeesList[i].participantHasEmail;
                
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
                    if(this.televisitAttendeesList.find(a => a.id === result[i].id) !== undefined){
                        this.televisitAttendeesObj.isMandatorySelection = this.televisitAttendeesList.find(a => a.id === result[i].id).isMandatorySelection;
                    }else{
                        if(this.televisitAttendeesObj.attendeeType === 'Participant'){
                            this.televisitAttendeesObj.isMandatorySelection = true;
                        }else{
                            this.televisitAttendeesObj.isMandatorySelection = false;
                        }
                    }
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

    checkForPPUser(){
        fetchParticipantDetails({perId : this.peid.id })
        .then((result) => {
            this.isPPUserActivated = result.isPPUserActivated;
            this.isEmailPermitted = result.isEmailPermitted;
        })
        .catch((error) => {
            console.log('error on PP check'+JSON.stringify(error));
        });
    }
}