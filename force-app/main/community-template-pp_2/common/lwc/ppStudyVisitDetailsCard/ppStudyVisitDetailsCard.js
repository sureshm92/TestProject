import { LightningElement,api,track,wire } from 'lwc';
import moment from '@salesforce/resourceUrl/moment_js'; 
import { loadScript } from 'lightning/platformResourceLoader';
import checkSmsOptIn from '@salesforce/apex/TaskEditRemote.checkSmsOptIn';
import updatePatientVisits from '@salesforce/apex/TaskEditRemote.updatePatientVisits'; 
import upsertTaskData from '@salesforce/apex/TaskEditRemote.upsertTaskData'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';

export default class PpStudyVisitDetailsCard extends LightningElement {
    @api visitid;
    @api taskid;
    @api visitdata;
    @api tasksubject;
    @api remindmepub;
    @api url;
    @api siteaddress;
    @api sitename;
    @api sitephone;
    @api past;
    @track todaydate;
    @track todaytime;
    @track calculatedDate;
    @track visitDate;
    @track visitTime;
    @track selectedReminderDate;
    @track selectedReminderTime;
    @track selectedReminderDateTime;
    @track emailOptIn = false;
    @track smsOptIn = false;
    @track email;
    @track sms;    
    @track date;
    @track reminderDateChanged = false;
    @track visitDateChanged = false;
    @track reminderChanged = false;
    @track reminderOptions = [];
    @track visitDateTime;
    @track disableButtonSaveCancel = true;
    @track showreminderdatepicker =false;
    
    async connectedCallback() {
        await loadScript(this, moment);
    }

    @wire(checkSmsOptIn)
    returneddata({error,data}){
        if(data){
            this.smsOptIn = data[0].Permit_SMS_Text_for_this_study__c;
            this.emailOptIn = data[0].Permit_Mail_Email_contact_for_this_study__c;
        }else if (error) {
            this.error = error;
        }
    }

    @api
    callFromParent(){
        this.visitDate='';
        this.visitTime='';
        this.visitDateTime='';
        this.showreminderdatepicker = false;
        this.remindmepub='';
    }

    get dbreminderdate(){
        if(this.visitdata.task.Reminder_Date__c && !this.visitDateChanged && !this.reminderDateChanged){
            this.selectedReminderDateTime = this.visitdata.task.Reminder_Date__c;
            var reminderDate = this.visitdata.task.Reminder_Date__c;
            console.log('this.reminderDate'+this.reminderDate);
            return reminderDate;
        }else if(this.selectedReminderDateTime){
            return this.selectedReminderDateTime;
        }else{
            return null;
        }
    }

    get dbremindertime(){
        if(this.visitdata.task.Reminder_Date__c && !this.visitDateChanged && !this.reminderChanged){
            var reminderTime = this.visitdata.task.Reminder_Date__c;
            console.log('this.reminderTIme'+this.reminderTime);
            return reminderTime;
        }else if(this.selectedReminderDateTime){
            return this.selectedReminderTime;
        }else{
            return null;
        }
    }

    get compDate(){
        if(this.visitdata.visitDate && !this.visitDateChanged){
            this.visitDateTime = this.visitdata.visitDate;
            var visitDate = this.visitdata.visitDate;
            return visitDate;
        }else if(this.visitDateTime){
            return this.visitDateTime;
        }else{
            return null;
        }
    }

    get compTime(){
        if(this.visitdata.visitDate){
            var visitTime = this.visitdata.visitDate;
            return visitTime;
        }else{
            return null;
        }
    }

    handleInitialDateLoad(event){
        console.log('Initial date load');
        this.visitDate = event.detail.compdate;
    }

    handleInitialTimeLoad(event){
        console.log('Initial time load');
        this.visitTime = event.detail.comptime;
    }

    handleInitialReminderDateLoad(event){
        this.selectedReminderDate = event.detail.compdate;
    }

    handleInitialReminderTimeLoad(event){
        this.selectedReminderTime = event.detail.comptime;
    }

    get dbCompletedDate(){
        if(this.visitdata.visitStatus == 'Missed'){
            return null;
        }else if(this.visitdata.visit.Completed_Date__c){
            var completedDate, completedTime;
            var dbvisitDate = new Date(this.visitdata.visit.Completed_Date__c);
            var localtimezonedate = dbvisitDate.toLocaleString('en-US', {timeZone: TIME_ZONE});
            var processlocaltimezonedate = new Date(localtimezonedate);
            var hh = String((processlocaltimezonedate.getHours()<10?'0':'') + processlocaltimezonedate.getHours());
            var mm = String((processlocaltimezonedate.getMinutes()<10?'0':'') + processlocaltimezonedate.getMinutes());
            var ss = String((processlocaltimezonedate.getSeconds()<10?'0':'') + processlocaltimezonedate.getSeconds());
            completedTime = hh + ':' + mm + ':' + ss;
            var dd = String(processlocaltimezonedate.getDate()).padStart(2, '0');
            var mm = String(processlocaltimezonedate.getMonth() + 1).padStart(2, '0');
            var yyyy = processlocaltimezonedate.getFullYear();
            completedDate = yyyy + '-' + mm + '-' + dd ;
            return completedDate;
        }else{
            return null;
        }
    }

    get showReminders(){
        if(this.visitdata.visitDate || this.visitDateTime){
            return false;
        }else{
            return true;
        }
    }

    get maxReminderTime(){
        if(this.selectedReminderDate == this.visitDate){
            console.log('maxRemindertime');
            if(this.visitTime){
                console.log('--1--');
                return this.visitTime;
            }else{
                return null;
            }
        }else{
            return null;
        }
    }

    get minReminderTime(){
        console.log('minremindertime');
        if(this.todaydate == this.selectedReminderDate){
            console.log('minremindertime-1'+this.todaytime);
            return this.todaytime;
        }else{
            return null;
        }
    }

    get showEmailSms(){
        if(this.remindmepub){
            return true;
        }else{
            return false;
        }
    }

    get dbReminderOption(){
        if(this.remindmepub){
            if(this.remindmepub == 'Custom'){
                this.showreminderdatepicker = true;
            }
            return this.remindmepub;
        }else if(this.visitdata.task.Remind_Me__c){
            this.remindmepub = this.visitdata.task.Remind_Me__c;
            if(this.remindmepub == 'Custom'){
                this.showreminderdatepicker = true;
            }
            return this.remindmepub;
        }
    }

    get reminderFrequencyList() {
        console.log('reminderFrequencyList');
        this.reminderOptions = [];
        if(this.visitDateTime){
            var dateTime = new Date(this.visitDateTime)
            var currentDateTime = new Date();    
            var differenceTimeHours = (dateTime - currentDateTime)/3600000;
            console.log('dateTime'+dateTime);
            if(differenceTimeHours > 1){
                const option = {
                    label: '1 hour before',
                    value: '1 hour before'
                };
                this.reminderOptions = [ ...this.reminderOptions, option ];
            }
            if(differenceTimeHours > 4){
                const option = {
                    label: '4 hours before',
                    value: '4 hours before'
                };
                this.reminderOptions = [ ...this.reminderOptions, option ];
            }
            if(differenceTimeHours > 24){
                const option = {
                    label: '1 day before',
                    value: '1 day before'
                };
                this.reminderOptions = [ ...this.reminderOptions, option ];
            }
            if(differenceTimeHours > 168){
                const option = {
                    label: '1 week before',
                    value: '1 week before'
                };
                this.reminderOptions = [ ...this.reminderOptions, option ];
            }
            const option = {
                label: 'Custom',
                value: 'Custom'
            };
            this.reminderOptions = [ ...this.reminderOptions, option ];
        }
        return this.reminderOptions;
    }

    get disablereminder(){
        if(this.visitDate){
            return false;
        }else{
            return true;
        }
    }

    get currentDate() {
        var currentDate = new Date();
        var dd = String(currentDate.getDate()).padStart(2, '0');
        var mm = String(currentDate.getMonth() + 1).padStart(2, '0');
        var yyyy = currentDate.getFullYear();
        var today = yyyy + '-' + mm + '-' + dd ;
        this.todaydate = today;
        console.log('Today date'+this.todaydate);
        this.calculatedDate = today;
        return today;
    }

    get currentTime(){
        var currentDateTime = new Date();
        var hh = String((currentDateTime.getHours()<10?'0':'') + currentDateTime.getHours());
        var mm = String((currentDateTime.getMinutes()<10?'0':'') + currentDateTime.getMinutes());
        var ss = String((currentDateTime.getSeconds()<10?'0':'') + currentDateTime.getSeconds());
        var currentTime = hh + ':' + mm + ':' + ss;
        this.todaytime = currentTime;
        console.log('Today'+this.todaytime);
        if(this.calculatedDate == this.visitDate){
            return currentTime;
        }else{
            return null;
        }
    }

    setAttributeValueEmail(event){
        this.reminderChanged = true;
        this.disableButtonSaveCancel = false;
        this.email = event.target.checked; 
    }

    setAttributeValueSms(event){
        this.reminderChanged = true;
        this.disableButtonSaveCancel = false;
        this.sms = event.target.checked; 
    }

    doValidateFields(event){
        this.reminderChanged = true;
        this.disableButtonSaveCancel = false;
        this.remindmepub = event.target.value;
        var remindMe = event.target.value;
        var today =  new Date(new Date() + 60 * 1000);
        var dueDateOrplanDate = this.visitDateTime;
        if (remindMe !== 'Custom') {
            this.showreminderdatepicker = false;
            if (remindMe === '1 Week before') {
                isGreaterThanToday = moment(dueDateOrplanDate).subtract(7, 'days').isBefore(today);
                this.selectedReminderDateTime = moment(dueDateOrplanDate).subtract(7, 'days');
            } else if (remindMe === '1 day before') {
                isGreaterThanToday = moment(dueDateOrplanDate).subtract(1, 'days').isBefore(today);
                this.selectedReminderDateTime = moment(dueDateOrplanDate).subtract(1, 'days')
            } else if (remindMe === '1 hour before') {
                this.selectedReminderDateTime = new Date(dueDateOrplanDate) - 3600 * 1000;
                isGreaterThanToday = new Date() > new Date(reminderdate);
            } else if (remindMe === '4 hours before') {
                this.selectedReminderDateTime = new Date(dueDateOrplanDate) - 4 * 3600 * 1000;
                isGreaterThanToday = new Date() > new Date(reminderdate);
            }
            var date = new Date(this.selectedReminderDateTime);
            this.selectedReminderDateTime = date.toISOString();
        }else{
            this.showreminderdatepicker = true;
        } 
    }

    handleOnlyDate(event){
        this.reminderDateChanged = true;
        this.reminderChanged = true;
        this.disableButtonSaveCancel = false;
        this.selectedReminderDate = event.detail.compdate;
        this.minReminderTime();        
    }

    handleOnlyTime(event){
        this.reminderDateChanged = true;
        this.reminderChanged = true;
        this.disableButtonSaveCancel = false;
        this.selectedReminderDate = event.detail.comptime;
    }

    handleReminderDate(event){
        console.log('dt change');
        this.reminderDateChanged = true;
        this.reminderChanged = true;
        this.disableButtonSaveCancel = false;
        this.selectedReminderDate = event.detail.compdate;
        this.selectedReminderDateTime = event.detail.compdatetime;
        console.log('this.selected'+this.selectedReminderDate+'=='+this.selectedReminderDateTime);
        this.minReminderTime();
    }

    handleReminderTime(event){
        this.reminderDateChanged = true;
        this.reminderChanged = true;
        this.disableButtonSaveCancel = false;
        this.selectedReminderTime = event.detail.comptime;
        this.selectedReminderDateTime = event.detail.compdatetime;
        console.log('this.selected'+this.selectedReminderDate+this.selectedReminderDateTime);
    }

    handleTime(event){
        this.disableButtonSaveCancel = false;
        this.visitDateChanged = true;
        this.reminderDateChanged = true;
        this.selectedReminderDate = '';
        this.selectedReminderTime = '';
        this.selectedReminderDateTime = '';
        this.visitDateTime = event.detail.compdatetime;
        this.visitTime = event.detail.comptime;
        this.visitDate = event.detail.compdate;
        console.log('this.visitDate'+this.visitDate);
        console.log('handle time:'+this.visitDateTime);
        this.reminderFrequencyList();
    }

    handleDate(event){
        console.log('handle date:');
        this.disableButtonSaveCancel = false;
        this.visitDateChanged = true;
        this.reminderDateChanged = true;
        this.selectedReminderDate = '';
        this.selectedReminderTime = '';
        this.selectedReminderDateTime = '';
        this.visitDateTime = event.detail.compdatetime;
        this.visitDate = event.detail.compdate;
        this.visitTime = event.detail.comptime;
        console.log('this.visitDate'+this.visitDate);
        console.log('handle date:'+this.visitDateTime);
        this.reminderFrequencyList();
    }

    doSave(){
        this.disableButtonSaveCancel = true;
        var errorInDml = false;
        var reminderDate;
        console.log('reminder date changed'+this.reminderChanged);
        if(!this.reminderDateChanged){
            console.log('reminder date changed'+this.reminderChanged);
            reminderDate =  this.visitdata.task.Reminder_Date__c;
        }else{
            console.log('reminder date changed'+this.reminderChanged);
            reminderDate = this.selectedReminderDateTime;
        }
        console.log('Visit Id:'+this.visitid + this.visitDateTime);
        var patientVisit = {
            sobjectType: 'Patient_Visit__c',
            Id: this.visitid,
            Planned_Date__c: this.visitDateTime,
            Status__c: 'Scheduled'
        };
        var visitTask;
        if(this.taskid){
            visitTask = {
                Id: this.taskid,
                Subject: this.tasksubject,
                Patient_Visit__c: this.visitid,
                Remind_Me__c: this.remindmepub,
                Reminder_Date__c: this.selectedReminderDateTime,
                Remind_Using_Email__c: this.email,
                Remind_Using_SMS__c: this.sms,
                Is_Reminder_Sent__c: false,
                Task_Type__c: 'Visit'
            };
        }else{
            visitTask = {
                Subject: this.tasksubject,
                Patient_Visit__c: this.visitid,
                Remind_Me__c: this.remindmepub,
                Reminder_Date__c: this.selectedReminderDateTime,
                Remind_Using_Email__c: this.email,
                Remind_Using_SMS__c: this.sms,
                Is_Reminder_Sent__c: false,
                Task_Type__c: 'Visit'
            };
        }
        
        console.log('JSON:'+JSON.stringify(visitTask));
        if(this.visitDateChanged){
            updatePatientVisits({
                visit: JSON.stringify(patientVisit)
            })
            .then(result=>{
                if(this.reminderChanged || this.reminderDateChanged){
                    upsertTaskData({
                        task : JSON.stringify(visitTask)
                     })
                     .then(result=>{ 
                        const event = new ShowToastEvent({
                            message:'Visit details updated successfully!',
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);   
                        const selectEvent = new CustomEvent('dataupdated');
                        this.dispatchEvent(selectEvent);
                     })
                     .catch(error=>{
                         errorInDml = true;
                         console.log('Error - task 0:'+JSON.stringify(error));
                     })       
                }else{
                    const event = new ShowToastEvent({
                        message:'Visit details updated successfully!',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);   
                    const selectEvent = new CustomEvent('dataupdated');
                    this.dispatchEvent(selectEvent);
                }
            })
            .catch(error=>{
                errorInDml = true;
                console.log('Error - task:'+JSON.stringify(error));
            })    
        }else if(this.reminderChanged){
            upsertTaskData({
                task : JSON.stringify(visitTask)
             })
             .then(result=>{ 
                const event = new ShowToastEvent({
                    message:'Visit details updated successfully!',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);   
                const selectEvent = new CustomEvent('dataupdated');
                this.dispatchEvent(selectEvent);
             })
             .catch(error=>{
                 errorInDml = true;
                 console.log('Error - task 1:'+error);
             })  
        }       
    }

    doCancel(){
        this.remindmepub = this.visitdata.task.Remind_Me__c;
        this.visitDate = '';
        this.visitTime = ''; 
        this.selectedReminderDate = '';
        this.selectedReminderTime = '';
        this.email = this.visitdata.task.Remind_Using_Email__c;
        this.sms = this.visitdata.task.Remind_Using_SMS__c;
        this.disableButtonSaveCancel = true;
    }
}