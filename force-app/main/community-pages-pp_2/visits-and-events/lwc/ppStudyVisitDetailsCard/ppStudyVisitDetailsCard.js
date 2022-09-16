import { LightningElement, api, track, wire } from 'lwc';
import moment from '@salesforce/resourceUrl/moment_js';
import momentTZ from '@salesforce/resourceUrl/momenttz';
import { loadScript } from 'lightning/platformResourceLoader';
import checkSmsOptIn from '@salesforce/apex/TaskEditRemote.checkSmsOptIn';
import updatePatientVisits from '@salesforce/apex/TaskEditRemote.updatePatientVisits';
import upsertTaskData from '@salesforce/apex/TaskEditRemote.upsertTaskData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import date from '@salesforce/label/c.TV_TH_Date';
import location from '@salesforce/label/c.SS_Location';
import reminder from '@salesforce/label/c.Home_Page_StudyVisit_Reminder';
import notificationSettings from '@salesforce/label/c.Update_Notification_Settings';
import saveChanges from '@salesforce/label/c.PG_AS_BTN_Save_Changes';
import discard from '@salesforce/label/c.RH_TV_Discard';
import selectreminder from '@salesforce/label/c.Select_reminder';
import email from '@salesforce/label/c.Email';
import sms from '@salesforce/label/c.SMS_Text';
import onehour from '@salesforce/label/c.PP_One_Hour_Before';
import fourhour from '@salesforce/label/c.PP_Four_Hours_Before';
import oneday from '@salesforce/label/c.One_day_before';
import oneweek from '@salesforce/label/c.PP_One_Week_Before';
import custom from '@salesforce/label/c.PP_Custom';
import visitdetailsupdated from '@salesforce/label/c.Visit_details_updated_successfully';
export default class PpStudyVisitDetailsCard extends LightningElement {
    label = {
        date,
        location,
        reminder,
        notificationSettings,
        saveChanges,
        discard,
        selectreminder,
        email,
        sms,
        onehour,
        fourhour,
        oneday,
        oneweek,
        custom,
        visitdetailsupdated
    };

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
    @track showreminderdatepicker = false;
    @track diffInMinutes;
    @track currentBrowserTime;
    booleanFalse = false;
    booleanTrue = true;

    connectedCallback() {
        loadScript(this, moment).then(() => {
            loadScript(this, momentTZ).then(() => {
                this.currentBrowserTime = window.moment();
                var localOffset = this.currentBrowserTime.utcOffset();
                var userTime = this.currentBrowserTime.tz(TIME_ZONE);
                var centralOffset = userTime.utcOffset();
                this.diffInMinutes = localOffset - centralOffset;
            });
        });
    }

    @wire(checkSmsOptIn)
    returneddata({ error, data }) {
        if (data) {
            this.smsOptIn = data[0].Permit_SMS_Text_for_this_study__c;
            this.emailOptIn = data[0].Permit_Mail_Email_contact_for_this_study__c;
        } else if (error) {
            this.showErrorToast('Error occured', error.message, 'error');
        }
    }

    @api
    callFromParent() {
        this.visitDate = '';
        this.visitTime = '';
        this.visitDateTime = '';
        this.remindmepub = '';
        this.showreminderdatepicker = false;
        this.visitDateChanged = false;
        this.template.querySelector('[data-id="visitDateTime"]').callFromParent();
        this.template.querySelector('[data-id="reminderDateTime"]').callFromParent();
    }

    get dbreminderdate() {
        if (
            this.visitdata.task.Reminder_Date__c &&
            !this.visitDateChanged &&
            !this.reminderDateChanged
        ) {
            this.selectedReminderDateTime = this.visitdata.task.Reminder_Date__c;
            var reminderDate = this.visitdata.task.Reminder_Date__c;
            return reminderDate;
        } else if (this.selectedReminderDateTime) {
            return this.selectedReminderDateTime;
        } else {
            return null;
        }
    }

    get dbremindertime() {
        if (
            this.visitdata.task.Reminder_Date__c &&
            !this.visitDateChanged &&
            !this.reminderDateChanged
        ) {
            var reminderTime = this.visitdata.task.Reminder_Date__c;
            return reminderTime;
        } else if (this.selectedReminderDateTime) {
            return this.selectedReminderDateTime;
        } else {
            return null;
        }
    }

    get compDate() {
        if (this.visitdata.visitDate && !this.visitDateChanged) {
            this.visitDateTime = this.visitdata.visitDate;
            var visitDate = this.visitdata.visitDate;
            return visitDate;
        } else if (this.visitDateTime) {
            return this.visitDateTime;
        } else {
            return null;
        }
    }

    get compTime() {
        if (this.visitdata.visitDate) {
            var visitTime = this.visitdata.visitDate;
            return visitTime;
        } else {
            return null;
        }
    }

    handleInitialDateLoad(event) {
        this.visitDate = event.detail.compdate;
    }

    handleInitialTimeLoad(event) {
        this.visitTime = event.detail.comptime;
    }

    handleInitialReminderDateLoad(event) {
        this.selectedReminderDate = event.detail.compdate;
    }

    handleInitialReminderTimeLoad(event) {
        this.selectedReminderTime = event.detail.comptime;
    }

    get dbCompletedDate() {
        if (this.visitdata.visitStatus == 'Missed') {
            return null;
        } else if (this.visitdata.visit.Completed_Date__c) {
            var completedDate, completedTime;
            var dbvisitDate = new Date(this.visitdata.visit.Completed_Date__c);
            var localtimezonedate = dbvisitDate.toLocaleString('en-US', { timeZone: TIME_ZONE });
            var processlocaltimezonedate = new Date(localtimezonedate);
            var hh = String(
                (processlocaltimezonedate.getHours() < 10 ? '0' : '') +
                    processlocaltimezonedate.getHours()
            );
            var mm = String(
                (processlocaltimezonedate.getMinutes() < 10 ? '0' : '') +
                    processlocaltimezonedate.getMinutes()
            );
            var ss = String(
                (processlocaltimezonedate.getSeconds() < 10 ? '0' : '') +
                    processlocaltimezonedate.getSeconds()
            );
            completedTime = hh + ':' + mm + ':' + ss;
            var dd = String(processlocaltimezonedate.getDate()).padStart(2, '0');
            var mm = String(processlocaltimezonedate.getMonth() + 1).padStart(2, '0');
            var yyyy = processlocaltimezonedate.getFullYear();
            completedDate = yyyy + '-' + mm + '-' + dd;
            return completedDate;
        } else {
            return null;
        }
    }

    get showReminders() {
        if (this.visitdata.visitDate || this.visitDateTime) {
            return false;
        } else {
            return true;
        }
    }

    get maxReminderTime() {
        if (this.selectedReminderDate == this.visitDate) {
            if (this.visitTime) {
                return this.visitTime;
            } else {
                return null;
            }
        } else {
            return null;
        }
    }

    get minReminderTime() {
        if (this.todaydate == this.selectedReminderDate) {
            return this.todaytime;
        } else {
            return null;
        }
    }

    get showEmailSms() {
        if (this.remindmepub) {
            return true;
        } else {
            return false;
        }
    }

    get dbReminderOption() {
        if (this.remindmepub) {
            if (this.remindmepub == this.label.custom) {
                this.showreminderdatepicker = true;
            }
            return this.remindmepub;
        } else if (this.visitdata.task.Remind_Me__c) {
            this.remindmepub = this.visitdata.task.Remind_Me__c;
            if (this.remindmepub == this.label.custom) {
                this.showreminderdatepicker = true;
            }
            return this.remindmepub;
        }
    }

    get reminderFrequencyList() {
        this.reminderOptions = [];
        if (this.visitDateTime) {
            var dateTime = new Date(this.visitDateTime);
            var currentDateTime = new Date();
            var differenceTimeHours = (dateTime - currentDateTime) / 3600000;
            if (differenceTimeHours > 1) {
                const option = {
                    label: this.label.onehour,
                    value: this.label.onehour
                };
                this.reminderOptions = [...this.reminderOptions, option];
            }
            if (differenceTimeHours > 4) {
                const option = {
                    label: this.label.fourhour,
                    value: this.label.fourhour
                };
                this.reminderOptions = [...this.reminderOptions, option];
            }
            if (differenceTimeHours > 24) {
                const option = {
                    label: this.label.oneday,
                    value: this.label.oneday
                };
                this.reminderOptions = [...this.reminderOptions, option];
            }
            if (differenceTimeHours > 168) {
                const option = {
                    label: this.label.oneweek,
                    value: this.label.oneweek
                };
                this.reminderOptions = [...this.reminderOptions, option];
            }
            const option = {
                label: this.label.custom,
                value: this.label.custom
            };
            this.reminderOptions = [...this.reminderOptions, option];
        }
        return this.reminderOptions;
    }

    get disablereminder() {
        if (this.visitDate) {
            return false;
        } else {
            return true;
        }
    }

    get currentDate() {
        var currentDate;
        if (this.diffInMinutes < 0) {
            var currentDateTime = this.currentBrowserTime - this.diffInMinutes * 60 * 1000;
            currentDate = new Date(currentDateTime);
        } else {
            var currentDateTime = this.currentBrowserTime + this.diffInMinutes * 60 * 1000;
            currentDate = new Date(currentDateTime);
        }
        var dd = String(currentDate.getDate()).padStart(2, '0');
        var mm = String(currentDate.getMonth() + 1).padStart(2, '0');
        var yyyy = currentDate.getFullYear();
        var today = yyyy + '-' + mm + '-' + dd;
        this.todaydate = today;
        this.calculatedDate = today;
        return today;
    }

    get currentTime() {
        var currentDate;
        if (this.diffInMinutes < 0) {
            var currentDateTime = this.currentBrowserTime - this.diffInMinutes * 60 * 1000;
            currentDate = new Date(currentDateTime);
        } else {
            var currentDateTime = this.currentBrowserTime + this.diffInMinutes * 60 * 1000;
            currentDate = new Date(currentDateTime);
        }
        var hh = String((currentDate.getHours() < 10 ? '0' : '') + currentDate.getHours());
        var mm = String((currentDate.getMinutes() < 10 ? '0' : '') + currentDate.getMinutes());
        var ss = String((currentDate.getSeconds() < 10 ? '0' : '') + currentDate.getSeconds());
        var currentTime = hh + ':' + mm + ':' + ss;
        this.todaytime = currentTime;
        if (this.calculatedDate == this.visitDate) {
            return currentTime;
        } else {
            return null;
        }
    }

    setAttributeValueEmail(event) {
        this.reminderChanged = true;
        this.disableButtonSaveCancel = false;
        this.email = event.target.checked;
    }

    setAttributeValueSms(event) {
        this.reminderChanged = true;
        this.disableButtonSaveCancel = false;
        this.sms = event.target.checked;
    }

    doValidateFields(event) {
        this.reminderChanged = true;
        this.disableButtonSaveCancel = false;
        this.remindmepub = event.target.value;
        var remindMe = event.target.value;
        var today = new Date(new Date() + 60 * 1000);
        var dueDateOrplanDate = this.visitDateTime;
        if (remindMe !== this.label.custom) {
            this.showreminderdatepicker = false;
            if (remindMe === this.label.oneweek) {
                isGreaterThanToday = moment(dueDateOrplanDate).subtract(7, 'days').isBefore(today);
                this.selectedReminderDateTime = moment(dueDateOrplanDate).subtract(7, 'days');
            } else if (remindMe === this.label.oneday) {
                isGreaterThanToday = moment(dueDateOrplanDate).subtract(1, 'days').isBefore(today);
                this.selectedReminderDateTime = moment(dueDateOrplanDate).subtract(1, 'days');
            } else if (remindMe === this.label.onehour) {
                this.selectedReminderDateTime = new Date(dueDateOrplanDate) - 3600 * 1000;
                isGreaterThanToday = new Date() > new Date(reminderdate);
            } else if (remindMe === this.label.fourhour) {
                this.selectedReminderDateTime = new Date(dueDateOrplanDate) - 4 * 3600 * 1000;
                isGreaterThanToday = new Date() > new Date(reminderdate);
            }
            var date = new Date(this.selectedReminderDateTime);
            this.selectedReminderDateTime = date.toISOString();
        } else {
            this.showreminderdatepicker = true;
        }
    }

    handleOnlyDate(event) {
        this.reminderDateChanged = true;
        this.reminderChanged = true;
        this.disableButtonSaveCancel = false;
        this.selectedReminderDate = event.detail.compdate;
        this.minReminderTime();
    }

    handleOnlyTime(event) {
        this.reminderDateChanged = true;
        this.reminderChanged = true;
        this.disableButtonSaveCancel = false;
        this.selectedReminderDate = event.detail.comptime;
    }

    handleReminderDate(event) {
        this.reminderDateChanged = true;
        this.reminderChanged = true;
        this.disableButtonSaveCancel = false;
        this.selectedReminderDate = event.detail.compdate;
        this.selectedReminderDateTime = event.detail.compdatetime;
        this.minReminderTime();
    }

    handleReminderTime(event) {
        this.reminderDateChanged = true;
        this.reminderChanged = true;
        this.disableButtonSaveCancel = false;
        this.selectedReminderTime = event.detail.comptime;
        this.selectedReminderDateTime = event.detail.compdatetime;
    }

    handleTime(event) {
        this.disableButtonSaveCancel = false;
        this.visitDateChanged = true;
        this.reminderDateChanged = true;
        this.selectedReminderDate = '';
        this.selectedReminderTime = '';
        this.selectedReminderDateTime = '';
        this.visitDateTime = event.detail.compdatetime;
        this.visitTime = event.detail.comptime;
        this.visitDate = event.detail.compdate;
        this.reminderFrequencyList();
    }

    handleDate(event) {
        this.disableButtonSaveCancel = false;
        this.visitDateChanged = true;
        this.reminderDateChanged = true;
        this.selectedReminderDate = '';
        this.selectedReminderTime = '';
        this.selectedReminderDateTime = '';
        this.visitDateTime = event.detail.compdatetime;
        this.visitDate = event.detail.compdate;
        this.visitTime = event.detail.comptime;
        this.reminderFrequencyList();
    }

    doSave() {
        this.disableButtonSaveCancel = true;
        var errorInDml = false;
        var reminderDate;
        if (!this.reminderDateChanged) {
            reminderDate = this.visitdata.task.Reminder_Date__c;
        } else {
            reminderDate = this.selectedReminderDateTime;
        }
        var patientVisit = {
            sobjectType: 'Patient_Visit__c',
            Id: this.visitid,
            Planned_Date__c: this.visitDateTime,
            Status__c: 'Scheduled'
        };
        var visitTask;
        if (this.taskid) {
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
        } else {
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

        if (this.visitDateChanged) {
            updatePatientVisits({
                visit: JSON.stringify(patientVisit)
            })
                .then((result) => {
                    if (this.reminderChanged || this.reminderDateChanged) {
                        upsertTaskData({
                            task: JSON.stringify(visitTask)
                        })
                            .then((result) => {
                                const event = new ShowToastEvent({
                                    message: this.label.visitdetailsupdated,
                                    variant: 'success',
                                    mode: 'dismissable'
                                });
                                this.dispatchEvent(event);
                                const selectEvent = new CustomEvent('dataupdated');
                                this.dispatchEvent(selectEvent);
                            })
                            .catch((error) => {
                                this.showErrorToast('Error occured', error.message, 'error');
                            });
                    } else {
                        const event = new ShowToastEvent({
                            message: this.label.visitdetailsupdated,
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                        const selectEvent = new CustomEvent('dataupdated');
                        this.dispatchEvent(selectEvent);
                    }
                })
                .catch((error) => {
                    this.showErrorToast('Error occured', error.message, 'error');
                });
        } else if (this.reminderChanged) {
            upsertTaskData({
                task: JSON.stringify(visitTask)
            })
                .then((result) => {
                    const event = new ShowToastEvent({
                        message: this.label.visitdetailsupdated,
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    const selectEvent = new CustomEvent('dataupdated');
                    this.dispatchEvent(selectEvent);
                })
                .catch((error) => {
                    this.showErrorToast('Error occured', error.message, 'error');
                });
        }
    }

    doCancel() {
        this.remindmepub = this.visitdata.task.Remind_Me__c;
        this.visitDate = '';
        this.visitTime = '';
        this.selectedReminderDate = '';
        this.selectedReminderTime = '';
        this.email = this.visitdata.task.Remind_Using_Email__c;
        this.sms = this.visitdata.task.Remind_Using_SMS__c;
        this.disableButtonSaveCancel = true;
    }

    showErrorToast(titleText, messageText, variantType) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: titleText,
                message: messageText,
                variant: variantType
            })
        );
    }
}
