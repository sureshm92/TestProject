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
import formFactor from '@salesforce/client/formFactor';

export default class PpCreateTask extends LightningElement {
    task_icon = pp_icons + '/' + 'createTask_illustration.svg';
    taskNameLeng = 0;
    currentBrowserTime;
    diffInMinutes;
    todaydate;
    past = false;
    @track task;
    calculatedDate;
    notReminder = false;
    todaytime;
    taskDateTime;
    taskDueTime;
    taskDueDate;
    @track initData;
    subject;
    jsonState;
    isReminderSelected = false;
    spinner;
    taskReminderDate;
    taskTypeNotSelected = 'Not Selected';
    taskStatusOpen = 'Open';
    isMobile = false;

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
        if (formFactor === 'Small') {
            this.isMobile = true;
        } else {
            this.isMobile = false;
        }
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
                    task.Status = this.taskStatusOpen;
                    task.Task_Type__c = this.taskTypeNotSelected;
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
    handletaskNameChange(event) {
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
        this.taskDueTime = event.detail.comptime;
    }
    get taskTime() {
        if (this.taskDueTime) {
            return this.taskDueTime;
        } else {
            return null;
        }
    }

    get taskDate() {
        if (this.taskDueDate) {
            return this.taskDueDate;
        } else {
            return null;
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
    handleTime(event) {
        this.taskDateTime = event.detail.compdatetime;
        this.taskDueTime = event.detail.comptime;
        this.taskDueDate = event.detail.compdate;
        this.initData.activityDate = this.taskDateTime;
        /**Reset Reminder Values */
        console.log('date change', this.taskDateTime, this.taskDueTime, this.taskDueDate);
        this.template.querySelector('c-pp-create-task-reminder').handleDueDateChange();
        this.enableSave = true;
    }

    get saveLogic() {
        return this.enableSave;
    }
    handleDate(event) {
        this.taskDateTime = event.detail.compdatetime;
        this.taskDueDate = event.detail.compdate;
        this.taskDueTime = event.detail.comptime;
        this.initData.activityDate = this.taskDateTime;
        this.isReminderSelected = false;
        this.taskReminderDate = null;
        /**Reset Reminder Values */
        console.log('date change', this.taskDateTime, this.taskDueTime, this.taskDueDate);
        this.template.querySelector('c-pp-create-task-reminder').handleDueDateChange();
    }
    handleNullDateTime(event) {
        this.enableSave = false;
        this.taskDateTime = '';
        this.taskDueDate = '';
        this.taskDueTime = '';
        this.isReminderSelected = false;
        this.taskReminderDate = null;
        this.template.querySelector('c-pp-create-task-reminder').handleDueDateChange();
    }
    handleOnlyDate(event) {
        this.taskDateTime = event.detail.compdatetime;
        this.taskDueDate = event.detail.compdate;
        this.template.querySelector('c-pp-create-task-reminder').handleDueDateChange();
    }
    handleOnlyTime(event) {
        this.taskDateTime = event.detail.compdatetime;
        this.taskDueTime = event.detail.comptime;
        this.template.querySelector('c-pp-create-task-reminder').handleDueDateChange();
    }
    doCreateTask() {
        this.spinner.show();
        this.task.Subject = this.subject;
        if (!this.isReminderSelected) {
            this.task.Subject = this.subject;
            upsertTask({
                wrapper: JSON.stringify(this.initData),
                paramTask: JSON.stringify(this.task)
            })
                .then((result) => {
                    this.spinner.hide();
                    this.enableSave = false;
                    communityService.showToast('', 'success', taskCreationSuccess, 100);
                    const taskCloseEvent = new CustomEvent('taskclose', {
                        detail: {
                            isClose: false
                        }
                    });
                    this.dispatchEvent(taskCloseEvent);
                })
                .catch((error) => {
                    console.log(' error during task creation without reminder ', error);
                });
        } else if (
            this.isReminderSelected &&
            (this.task.Remind_Using_Email__c || this.task.Remind_Using_SMS__c)
        ) {
            this.task.Subject = this.subject;
            upsertTask({
                wrapper: JSON.stringify(this.initData),
                paramTask: JSON.stringify(this.task)
            })
                .then((result) => {
                    this.spinner.hide();
                    this.enableSave = false;
                    communityService.showToast('', 'success', taskCreationSuccess, 100);
                    const taskCloseEvent = new CustomEvent('taskclose', {
                        detail: {
                            isClose: false
                        }
                    });
                    this.dispatchEvent(taskCloseEvent);
                })
                .catch((error) => {
                    console.log('  error during task creation with reminder ', error);
                });
        } else {
            communityService.showToast('', 'error', this.labels.REMIND_USING_REQUIRED, 100);
            this.spinner.hide();
        }
    }
    handleCancelTask() {
        const taskCloseEvent = new CustomEvent('taskclose', {
            detail: {
                isClose: false
            }
        });
        this.dispatchEvent(taskCloseEvent);
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
        return this.taskDueDate == this.todaydate ? currentTime : null;
    }

    get isDueDateTimeSelected() {
        return this.taskDateTime && this.taskDueTime && this.taskDueDate ? true : false;
    }

    handleCustomReminder(event) {
        this.task.Remind_Using_Email__c = event.detail.emailReminderOptIn;
        this.task.Remind_Using_SMS__c = event.detail.smsReminderOptIn;
        this.task.Remind_Me__c =
            event.detail.reminderType == 'No reminder' ? '' : event.detail.reminderType;
        this.initData.reminderDate =
            event.detail.reminderType == 'No reminder' ? '' : event.detail.reminderDateTime;
        this.taskReminderDate = event.detail.reminderDateTime;
        this.isReminderSelected = event.detail.reminderType == 'No reminder' ? false : true;
    }

    handleReminder(event) {
        this.task.Remind_Using_Email__c = event.detail.emailReminderOptIn;
        this.task.Remind_Using_SMS__c = event.detail.smsReminderOptIn;
        this.task.Remind_Me__c =
            event.detail.reminderType == 'No reminder' ? '' : event.detail.reminderType;
        this.isReminderSelected = event.detail.reminderType == 'No reminder' ? false : true;
    }

    get saveButtonClass() {
        this.enableSave = false;
        if (this.subject && this.taskDueTime && this.taskDueDate) {
            if (!this.isReminderSelected) {
                this.enableSave = true;
            } else if (this.isReminderSelected) {
                if (this.task.Remind_Me__c) {
                    if (
                        this.task.Remind_Me__c != 'Custom' &&
                        (this.task.Remind_Using_Email__c || this.task.Remind_Using_SMS__c)
                    ) {
                        this.enableSave = true;
                    } else if (
                        this.task.Remind_Me__c == 'Custom' &&
                        (this.task.Remind_Using_Email__c || this.task.Remind_Using_SMS__c) &&
                        this.taskReminderDate
                    ) {
                        this.enableSave = true;
                    } else {
                        this.enableSave = false;
                    }
                }
            } else {
                this.enableSave = false;
            }
        } else {
            this.enableSave = false;
        }
        return this.enableSave ? 'task-save-btn' : 'task-save-btn-opacity';
    }
}
