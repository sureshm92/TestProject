import { LightningElement, api, track } from 'lwc';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import moment from '@salesforce/resourceUrl/moment_js';
import momentTZ from '@salesforce/resourceUrl/momenttz';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import { loadScript } from 'lightning/platformResourceLoader';
import upsertTask from '@salesforce/apex/TaskEditRemote.upsertTask';
import getTaskEditData from '@salesforce/apex/TaskEditRemote.getTaskEditData';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import taskCreationSuccess from '@salesforce/label/c.PP_TaskCreationSuccess';
import REMIND_USING_REQUIRED from '@salesforce/label/c.PP_Remind_Using_Required';
import taskName from '@salesforce/label/c.Task_Name';
import enterTaskName from '@salesforce/label/c.Enter_Task_Name';
import cancel from '@salesforce/label/c.BTN_Cancel';
import save from '@salesforce/label/c.BTN_Save';

export default class PpCreateTask extends LightningElement {
    task_icon = pp_icons + '/' + 'createTask_illustration.svg';
    taskNameLeng = 0;
    currentBrowserTime;
    diffInMinutes;
    todaydate;
    past = false;
    task;
    calculatedDate;
    notReminder = false;
    todaytime;
    taskDateTime;
    taskTime;
    taskDueDate;
    @track initData;
    subject;
    jsonState;
    isReminderSelected = false;
    spinner;

    labels = { REMIND_USING_REQUIRED };
    label = {
        taskCreationSuccess,
        taskName,
        enterTaskName,
        cancel,
        save
    };
    enableSave = false;
    createTask = true;
    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                console.log('RR_COMMUNITY_JS loaded');
                this.spinner = this.template.querySelector('c-web-spinner');
            })
            .catch((error) => {
                console.error('Error in loading RR Community JS: ' + JSON.stringify(error));
            });
        loadScript(this, moment).then(() => {
            loadScript(this, momentTZ).then(() => {
                this.currentBrowserTime = window.moment();
                var localOffset = this.currentBrowserTime.utcOffset();
                var userTime = this.currentBrowserTime.tz(TIME_ZONE);
                var centralOffset = userTime.utcOffset();
                this.diffInMinutes = localOffset - centralOffset;
                this.initializeData();
            });
        });
    }
    initializeData() {
        this.spinner.show();
        if (!communityService.isDummy()) {
            this.isRTL = rtlLanguages.includes(communityService.getLanguage()) ? true : false;
            getTaskEditData({ taskId: this.taskId })
                .then((wrapper) => {
                    this.initData = wrapper;
                    this.spinner.hide();
                    var task = wrapper.task;
                    task.Status = 'Open';
                    task.Task_Type__c = 'Not Selected';
                    this.task = task;
                    this.jsonState = JSON.stringify(wrapper) + '' + JSON.stringify(task);
                })
                .catch((error) => {
                    console.log('error', error);
                });
        } else {
            this.spinner.hide();
        }
    }
    get taskNameLength() {
        return this.taskNameLeng > 0 ? this.taskNameLeng : '00';
    }
    get taskNameLength() {
        return this.taskNameLeng > 0 ? this.taskNameLeng : '00';
    }
    handleuserNameChange(event) {
        var val = event.target.value;
        this.taskNameLeng = val.length;
        this.subject = event.target.value;
        if (event.target.value !== '') {
            this.template.querySelector('[data-id="taskName"]').value = event.target.value;
        }
    }
    handleInitialDateLoad(event) {
        this.taskDueDate = event.detail.compdate;
    }

    handleInitialTimeLoad(event) {
        this.taskTime = event.detail.comptime;
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
    handleTime(event) {
        this.taskDateTime = event.detail.compdatetime;
        this.taskTime = event.detail.comptime;
        this.taskDueDate = event.detail.compdate;
        this.initData.activityDate = this.taskDateTime;
        /**Reset Reminder Values */
        console.log('date change', this.taskDateTime, this.taskTime, this.taskDate);
        if (this.isDueDateTimeSelected) {
            this.template.querySelector('c-pp-create-task-reminder').handleDueDateChange();
        }
        this.enableSave = true;
    }

    get saveLogic() {
        return this.enableSave;
    }
    handleDate(event) {
        this.taskDateTime = event.detail.compdatetime;
        this.taskDueDate = event.detail.compdate;
        this.taskTime = event.detail.comptime;
        this.initData.activityDate = this.taskDateTime;
        /**Reset Reminder Values */
        console.log('date change', this.taskDateTime, this.taskTime, this.taskDate);
        if (this.isDueDateTimeSelected) {
            this.template.querySelector('c-pp-create-task-reminder').handleDueDateChange();
        }
    }
    doCreateTask() {
        if (
            this.isReminderSelected &&
            (this.task.Remind_Using_Email__c || this.task.Remind_Using_SMS__c)
        ) {
            this.task.Subject = this.subject;
            upsertTask({
                wrapper: JSON.stringify(this.initData),
                paramTask: JSON.stringify(this.task)
            })
                .then((result) => {
                    this.enableSave = false;
                    communityService.showToast('', 'success', taskCreationSuccess, 100);
                })
                .catch((error) => {
                    console.log(' error ', error);
                });
        } else {
            communityService.showToast('', 'error', this.labels.REMIND_USING_REQUIRED, 100);
        }
    }
    handleCancelTask() {
        const dateEvent = new CustomEvent('taskcancel', {
            detail: {
                isCreate: false
            }
        });
        this.dispatchEvent(dateEvent);
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
        return currentTime;
    }

    get isDueDateTimeSelected() {
        return this.taskDateTime && this.taskTime && this.taskDate ? true : false;
    }

    handleCustomReminder(event) {
        this.task.Remind_Using_Email__c = event.detail.emailReminderOptIn;
        this.task.Remind_Using_SMS__c = event.detail.smsReminderOptIn;
        this.task.Remind_Me__c =
            event.detail.reminderType == 'No reminder' ? '' : event.detail.reminderType;
        this.initData.reminderDate =
            event.detail.reminderType == 'No reminder' ? '' : event.detail.reminderDateTime;
        this.isReminderSelected = event.detail.reminderType == 'No reminder' ? false : true;
    }

    handleReminder(event) {
        this.task.Remind_Using_Email__c = event.detail.emailReminderOptIn;
        this.task.Remind_Using_SMS__c = event.detail.smsReminderOptIn;
        this.task.Remind_Me__c = event.detail.reminderType;
        this.isReminderSelected = true;
    }
}
