import { LightningElement, api, track } from 'lwc';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import moment from '@salesforce/resourceUrl/moment_js';
import momentTZ from '@salesforce/resourceUrl/momenttz';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import { loadScript } from 'lightning/platformResourceLoader';
import upsertTask from '@salesforce/apex/TaskEditRemote.upsertTask';
import getTaskEditData from '@salesforce/apex/TaskEditRemote.getTaskEditData';
import getisRTL from '@salesforce/apex/HomePageParticipantRemote.getIsRTL';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import taskCreationSuccess from '@salesforce/label/c.PP_TaskCreationSuccess';
import taskEditSuccess from '@salesforce/label/c.Task_Edit_Success_Message';
import REMIND_USING_REQUIRED from '@salesforce/label/c.PP_Remind_Using_Required';
import taskName from '@salesforce/label/c.Task_Name';
import enterTaskName from '@salesforce/label/c.Enter_Task_Name';
import cancel from '@salesforce/label/c.BTN_Cancel';
import save from '@salesforce/label/c.BTN_Save';
import PP_required from '@salesforce/label/c.PP_required';
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
    participantDateTime = null;
    participantDueDate = null;
    participantDueTime = null;
    maxremdate;
    maxremtime;
    displayDateInUi = true;
    @track initData;
    subject;
    jsonState;
    isReminderSelected = false;
    spinner;
    taskReminderDate;
    taskTypeNotSelected = 'Not Selected';
    taskStatusOpen = 'Open';
    isMobile = false;
    @api taskId;
    @api editMode = false;
    disbaleDateTime = false;
    isSystemOrBusinessTask = false;
    initialRecord;
    updatedRecord;
    @api isRTL;
    customLayoutSizeFields = parseInt(12);
    customLayoutSizeImg = "";

    labels = { REMIND_USING_REQUIRED };
    label = {
        taskCreationSuccess,
        taskName,
        enterTaskName,
        cancel,
        save,
        PP_required
    };
    enableSave = false;
    createTask = true;
    @api
    readOnlyMode = false;
    taskCodeList = ['Complete_Your_Profile', 'Update_Your_Phone_Number', 'Select_COI'];

    get buttonPaddingStyle() {
        return this.isRTL ? 'pad-left' : 'pad-right';
    }

    connectedCallback() {
        if (formFactor === 'Large') {
            this.isMobile = false;
        } else {
            this.isMobile = true;
        }
        getisRTL()
            .then((data) => {
                this.isRTL = data;
                console.log('rtl--->'+this.isRTL);
            })
            .catch(function (error) {
                console.error('Error RTL: ' + JSON.stringify(error));
            });

        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                console.log('RR_COMMUNITY_JS loaded');
                this.spinner = this.template.querySelector('c-web-spinner');
            })
            .catch((error) => {
                console.error('Error in loading RR Community JS: ' + JSON.stringify(error));
            });
        loadScript(this, moment)
            .then(() => {
                loadScript(this, momentTZ).then(() => {
                    this.currentBrowserTime = window.moment();
                    if (this.currentBrowserTime) {
                        var localOffset = this.currentBrowserTime.utcOffset();
                        var userTime = this.currentBrowserTime.tz(TIME_ZONE);
                        var centralOffset = userTime.utcOffset();
                        this.diffInMinutes = localOffset - centralOffset;
                        this.initializeData();
                    }
                });
            })
            .catch((error) => {
                console.error('Error in loading moment: ' + JSON.stringify(error));
            });
            window.addEventListener('orientationchange',this.onOrientationChange);
    }

    onOrientationChange () {
        if(screen.orientation.type == 'landscape-primary'){
            this.customLayoutSizeFields = parseInt(9);
            this.customLayoutSizeImg = parseInt(3);
        }else if(screen.orientation.type == 'portrait-primary'){
            this.customLayoutSizeFields = parseInt(12);
            this.customLayoutSizeImg = "";
        }
    }

    initializeData() {
        this.spinner.show();
        if (!communityService.isDummy()) {
            this.isRTL = rtlLanguages.includes(communityService.getLanguage()) ? true : false;
            getTaskEditData({ taskId: this.taskId })
                .then((wrapper) => {
                    if (this.taskId) {
                        this.template.querySelector('[data-id="taskName"]').value =
                            wrapper.task.Subject;
                        if (this.taskCodeList.includes(wrapper.task.Task_Code__c)) {
                            this.isSystemOrBusinessTask = true;
                            this.disbaleDateTime = true;
                            this.readOnlyMode = true;
                        } else {
                            if (
                                wrapper.task.Originator__c != 'Participant' &&
                                wrapper.task.Originator__c != 'Delegate'
                            ) {
                                if (
                                    !wrapper.task.Activity_Datetime__c ||
                                    (wrapper.task.Survey_Invitation__c &&
                                        wrapper.task.Survey_Invitation__r.IsTrialSurvey__c &&
                                        !wrapper.task.Survey_Invitation__r.Is_End_Date_Visible__c)
                                ) {
                                    this.disbaleDateTime = true;
                                    if (
                                        !wrapper?.task?.Survey_Invitation__r?.Trial_Survey__r
                                            ?.Display_in_UI__c &&
                                        wrapper.task.Survey_Invitation__r?.IsTrialSurvey__c
                                    ) {
                                        this.displayDateInUi = false;
                                        if (
                                            wrapper.task.Survey_Invitation__r
                                                ?.Participant_Due_Date__c == undefined
                                        ) {
                                            wrapper.reminderDate = '';
                                        }
                                    }
                                }
                                if (wrapper.task.Task_Type__c == 'Ecoa') this.isSystemOrBusinessTask = false;
                                else this.isSystemOrBusinessTask = true;
                                this.readOnlyMode = true;
                            }
                        }
                        this.task = wrapper.task;
                        this.subject = wrapper.task.Subject;
                        this.taskNameLeng = wrapper.task.Subject.length;
                        this.taskDateTime = wrapper.task.Activity_Datetime__c;
                        this.taskDueDate = wrapper.task.Activity_Datetime__c;
                        this.participantDueDate =
                            wrapper.task.Survey_Invitation__r?.Participant_Due_Date__c != undefined
                                ? wrapper.task.Survey_Invitation__r.Participant_Due_Date__c
                                : null;
                        this.participantDateTime =
                            wrapper.task.Survey_Invitation__r?.Participant_Due_Date__c != undefined
                                ? wrapper.task.Survey_Invitation__r.Participant_Due_Date__c
                                : null;
                        this.participantDueTime =
                            wrapper.task.Survey_Invitation__r?.Participant_Due_Date__c != undefined
                                ? wrapper.task.Survey_Invitation__r.Participant_Due_Date__c
                                : null;
                        this.taskDueTime =
                            wrapper.task.Activity_Datetime__c != undefined
                                ? wrapper.task.Activity_Datetime__c
                                : false;
                        this.maxremdate =
                            this.participantDueDate != undefined
                                ? this.participantDueDate
                                : this.taskDueDate;
                        this.maxremtime =
                            this.participantDueTime != undefined
                                ? this.participantDueTime
                                : this.taskDueTime;
                        const date = new Date(this.taskDueTime);
                        this.initialRecord = {
                            subject: this.subject,
                            dueDatetime: this.taskDateTime ? this.taskDateTime : '',
                            remindme: this.task.Remind_Me__c ? this.task.Remind_Me__c : '',
                            remindEmail: this.task.Remind_Using_Email__c
                                ? this.task.Remind_Using_Email__c
                                : '',
                            remindSMS: this.task.Remind_Using_SMS__c
                                ? this.task.Remind_Using_SMS__c
                                : '',
                            reminderDateTime: wrapper.reminderDate ? wrapper.reminderDate : '',
                            partDueDate:
                                wrapper.task.Survey_Invitation__r?.Participant_Due_Date__c !=
                                undefined
                                    ? wrapper.task.Survey_Invitation__r.Participant_Due_Date__c
                                    : ''
                        };
                    }
                    this.initData = wrapper;
                    this.spinner.hide();
                    var task = wrapper.task;
                    task.Status = this.taskStatusOpen;
                    task.Task_Type__c = this.task
                        ? this.task.Task_Type__c
                            ? this.task.Task_Type__c
                            : this.taskTypeNotSelected
                        : this.taskTypeNotSelected;
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

    get taskInitData() {
        return this.initData && JSON.stringify(this.initData) != '{}' ? true : false;
    }

    get disabledFieldCSS() {
        return this.readOnlyMode ? 'read-only-field' : '';
    }

    handletaskNameChange(event) {
        this.initialLoad = false;
        let inputvalue = event.target.value;
        if (inputvalue) {
            let tasksubject = inputvalue.trimStart();
            if (tasksubject.length > 0) {
                this.taskNameLeng = tasksubject.length;
                this.subject = tasksubject;
                if (event.target.value !== '') {
                    this.template.querySelector('lightning-input[data-id="taskName"]').value = tasksubject;
                }
            } else {
                this.subject = '';
                this.taskNameLeng = 0;
            }
        } else {
            this.taskNameLeng = 0;
            this.subject = '';
        }
    }
    handleInitialDateLoad(event) {
        if (!this.displayDateInUi && this.task.Survey_Invitation__r.IsTrialSurvey__c) {
            this.taskDueDate = this.taskDateTime;
        } else {
            this.taskDueDate = event.detail.compdate;
        }
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
        let currentDateTime = new Date().toLocaleString('en-US', {
            timeZone: TIME_ZONE
        });
        let currentDateTimeObject = new Date(currentDateTime);

        let dd = String(currentDateTimeObject.getDate()).padStart(2, '0');
        let mm = String(currentDateTimeObject.getMonth() + 1).padStart(2, '0');
        let yyyy = currentDateTimeObject.getFullYear();
        let today = yyyy + '-' + mm + '-' + dd;
        this.todaydate = today;
        this.calculatedDate = today;
        return today;
    }
    handleTime(event) {
        this.initialLoad = false;
        if (!this.displayDateInUi && this.task.Survey_Invitation__r.IsTrialSurvey__c) {
            //this.initData.Survey_Invitation__r.Participant_Due_Date__c = this.participantDateTime;
            this.initData.participantDateTime = event.detail.compdatetime;
            this.participantDueTime = event.detail.comptime;
            this.participantDueDate = event.detail.compdate;
        } else {
            this.taskDateTime = event.detail.compdatetime;
            this.taskDueTime = event.detail.comptime;
            this.taskDueDate = event.detail.compdate;
            this.initData.activityDate = this.taskDateTime;
        }
        this.maxremdate =
            this.participantDueDate != undefined ? this.participantDueDate : this.taskDueDate;
        this.maxremtime =
            this.participantDueTime != undefined ? this.participantDueTime : this.taskDueTime;
        /**Reset Reminder Values */
        this.template.querySelector('c-pp-create-task-reminder').handleDueDateChange();
        this.enableSave = true;
    }

    get saveLogic() {
        return this.enableSave;
    }
    handleDate(event) {
        this.initialLoad = false;
        if (!this.displayDateInUi && this.task.Survey_Invitation__r.IsTrialSurvey__c) {
            this.initData.participantDateTime = event.detail.compdatetime;
            this.participantDueDate = event.detail.compdate;
            this.participantDueTime = event.detail.comptime;
        } else {
            this.taskDateTime = event.detail.compdatetime;
            this.taskDueDate = event.detail.compdate;
            this.taskDueTime = event.detail.comptime;
            this.initData.activityDate = this.taskDateTime;
        }
        this.maxremdate =
            this.participantDueDate != undefined ? this.participantDueDate : this.taskDueDate;
        this.maxremtime =
            this.participantDueTime != undefined ? this.participantDueTime : this.taskDueTime;
        this.isReminderSelected = false;
        this.taskReminderDate = null;
        /**Reset Reminder Values */
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
        this.initialLoad = false;
        if (!this.displayDateInUi && this.task.Survey_Invitation__r.IsTrialSurvey__c) {
            this.initData.participantDateTime = event.detail.compdatetime;
            this.participantDueDate = event.detail.compdate;
            this.participantDueTime = '';
        } else {
            this.taskDateTime = event.detail.compdatetime;
            this.taskDueDate = event.detail.compdate;
            this.taskDueTime = '';
        }
        this.template.querySelector('c-pp-create-task-reminder').handleDueDateChange();
    }
    handleOnlyTime(event) {
        this.initialLoad = false;
        if (!this.displayDateInUi && this.task.Survey_Invitation__r.IsTrialSurvey__c) {
            this.initData.participantDateTime = event.detail.compdatetime;
            this.participantDueTime = event.detail.comptime;
            this.participantDateTime = event.detail.compdatetime;
        } else {
            this.taskDateTime = event.detail.compdatetime;
            this.taskDueTime = event.detail.comptime;
        }
        this.template.querySelector('c-pp-create-task-reminder').handleDueDateChange();
    }
    doCreateTask() {
        this.spinner.show();
        this.task.Subject = this.subject;
        if (!this.isReminderSelected) {
            this.task.Subject = this.subject;
            upsertTask({
                wrapper: JSON.stringify(this.initData),
                paramTask: JSON.stringify(this.task),
                isNewTaskFromTaskTab: !this.editMode
            })
                .then((result) => {
                    this.spinner.hide();
                    this.enableSave = false;
                    communityService.showToast(
                        '',
                        'success',
                        this.editMode ? taskEditSuccess : taskCreationSuccess,
                        100
                    );
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
                paramTask: JSON.stringify(this.task),
                isNewTaskFromTaskTab: !this.editMode
            })
                .then((result) => {
                    this.spinner.hide();
                    this.enableSave = false;
                    communityService.showToast(
                        '',
                        'success',
                        this.editMode ? taskEditSuccess : taskCreationSuccess,
                        100
                    );
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
        this.initialLoad = true;
        communityService.replaceUrlParameter('id', '');
        const taskCloseEvent = new CustomEvent('taskclose', {
            detail: {
                isClose: false,
                taskId: this.taskId
            }
        });
        this.dispatchEvent(taskCloseEvent);
    }

    get currentTime() {
        let currentDateTime = new Date().toLocaleString('en-US', {
            timeZone: TIME_ZONE
        });
        let currentDateTimeObject = new Date(currentDateTime);
        let hh = String(
            (currentDateTimeObject.getHours() < 10 ? '0' : '') + currentDateTimeObject.getHours()
        );
        let mm = String(
            (currentDateTimeObject.getMinutes() < 10 ? '0' : '') +
                currentDateTimeObject.getMinutes()
        );
        let ss = String(
            (currentDateTimeObject.getSeconds() < 10 ? '0' : '') +
                currentDateTimeObject.getSeconds()
        );
        this.todayTime = hh + ':' + mm + ':' + ss;
        return this.taskDueDate == this.todaydate ? this.todayTime : null;
    }

    get currentTimeParticipant() {
        let currentDateTime = new Date().toLocaleString('en-US', {
            timeZone: TIME_ZONE
        });
        let currentDateTimeObject = new Date(currentDateTime);
        let hh = String(
            (currentDateTimeObject.getHours() < 10 ? '0' : '') + currentDateTimeObject.getHours()
        );
        let mm = String(
            (currentDateTimeObject.getMinutes() < 10 ? '0' : '') +
                currentDateTimeObject.getMinutes()
        );
        let ss = String(
            (currentDateTimeObject.getSeconds() < 10 ? '0' : '') +
                currentDateTimeObject.getSeconds()
        );
        this.todayTime = hh + ':' + mm + ':' + ss;
        return this.participantDueDate == this.todaydate ? this.todayTime : null;
    }

    get isDueDateTimeSelected() {
        let currentDateTime = new Date().toLocaleString('en-US', {
            timeZone: TIME_ZONE
        });
        return this.taskDateTime &&
            this.taskDueTime &&
            this.taskDueDate &&
            new Date(this.taskDateTime) >= new Date(currentDateTime)
            ? true
            : false;
    }

    handleCustomReminder(event) {
        this.initialLoad = false;
        this.task.Remind_Using_Email__c = event.detail.emailReminderOptIn;
        this.task.Remind_Using_SMS__c = event.detail.smsReminderOptIn;
        this.task.Remind_Me__c =
            event.detail.reminderType == 'No reminder' ? '' : event.detail.reminderType;
        this.initData.reminderDate =
            event.detail.reminderType == 'No reminder' ? null : event.detail.reminderDateTime;
        this.taskReminderDate = event.detail.reminderDateTime;
        this.isReminderSelected =
            !event.detail.reminderType || event.detail.reminderType == 'No reminder' ? false : true;
    }

    handleReminder(event) {
        this.initialLoad = false;
        this.task.Remind_Using_Email__c = event.detail.emailReminderOptIn;
        this.task.Remind_Using_SMS__c = event.detail.smsReminderOptIn;
        this.task.Remind_Me__c =
            event.detail.reminderType == 'No reminder' ? '' : event.detail.reminderType;
        if (event.detail.reminderType == 'No reminder') {
            this.initData.reminderDate = null;
            this.taskReminderDate = null;
        }
        this.isReminderSelected =
            !event.detail.reminderType || event.detail.reminderType == 'No reminder' ? false : true;
    }

    get saveButtonClass() {
        if (this.task) {
            this.updatedRecord = {
                subject: this.subject,
                dueDatetime: this.taskDateTime ? this.taskDateTime : '',
                remindme: this.task.Remind_Me__c ? this.task.Remind_Me__c : '',
                remindEmail: this.task.Remind_Using_Email__c ? this.task.Remind_Using_Email__c : '',
                remindSMS: this.task.Remind_Using_SMS__c ? this.task.Remind_Using_SMS__c : '',
                reminderDateTime: this.taskReminderDate ? this.taskReminderDate : '',
                partDueDate: this.initData.participantDateTime
                    ? this.initData.participantDateTime
                    : ''
            };
        }
        if (this.initialRecord) {
            if (this.initialRecord.remindme != 'Custom') {
                this.initialRecord.reminderDateTime = '';
            }
        }
        var upDateRequired =
            JSON.stringify(this.initialRecord) == JSON.stringify(this.updatedRecord);

        this.enableSave = false;
        let currentDateTime = new Date().toLocaleString('en-US', {
            timeZone: TIME_ZONE
        });
        let selectedTaskDueDateTimeString = new Date(this.taskDateTime).toLocaleString('en-US', {
            timeZone: TIME_ZONE
        });
        let selectedTaskReminderDateTimeString = new Date(this.taskReminderDate).toLocaleString(
            'en-US',
            {
                timeZone: TIME_ZONE
            }
        );
        let selectedTaskReminderDateTime = new Date(selectedTaskReminderDateTimeString);
        let selectedTaskDueDateTime = new Date(selectedTaskDueDateTimeString);
        let currentDateTimeObject = new Date(currentDateTime);
        if ((!upDateRequired && this.editMode) || !this.editMode) {
            if (this.subject && ((this.taskDueTime && this.taskDueDate) || this.disbaleDateTime)) {
                if (!this.isReminderSelected && selectedTaskDueDateTime >= currentDateTimeObject) {
                    this.enableSave = true;
                    if (
                        !this.displayDateInUi &&
                        this.initData.participantDateTime == undefined &&
                        this.updatedRecord.reminderDateTime == this.initialRecord.reminderDateTime
                    ) {
                        this.enableSave = false;
                    }
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
                            this.taskReminderDate &&
                            ((selectedTaskReminderDateTime <= selectedTaskDueDateTime &&
                                selectedTaskReminderDateTime >= currentDateTimeObject) ||
                                (selectedTaskReminderDateTime >= currentDateTimeObject &&
                                    this.disbaleDateTime))
                        ) {
                            this.enableSave = true;
                        } else {
                            this.enableSave = false;
                        }
                    }
                    if (
                        this.updatedRecord?.reminderDateTime ==
                            this.initialRecord?.reminderDateTime &&
                        this.updatedRecord?.remindSMS == this.initialRecord?.remindSMS &&
                        this.updatedRecord?.remindEmail == this.initialRecord?.remindEmail &&
                        this.initialRecord.remindme ==this.updatedRecord.remindme
                    ) {
                        this.enableSave = false;
                    }
                    if (
                        !this.displayDateInUi &&
                        this.initData?.participantDateTime == undefined &&
                        this.task?.Survey_Invitation__r?.Participant_Due_Date__c == null
                    ) {
                        this.enableSave = false;
                    }
                } else {
                    if (
                        !this.isReminderSelected &&
                        this.editMode &&
                        selectedTaskDueDateTime != 'Invalid Date' &&
                        selectedTaskDueDateTime >= currentDateTimeObject
                    ) {
                        this.enableSave = true;
                    } else if (
                        !this.isReminderSelected &&
                        this.editMode &&
                        selectedTaskDueDateTime == 'Invalid Date'
                    ) {
                        this.enableSave = true;
                    } else {
                        this.enableSave = false;
                    }
                }
            } else {
                this.enableSave = false;
            }
        }
        return this.enableSave ? 'task-save-btn' : 'task-save-btn-opacity';
    }
}