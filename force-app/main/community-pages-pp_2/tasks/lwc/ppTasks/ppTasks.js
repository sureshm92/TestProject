import { LightningElement, track } from 'lwc';
import tasksHeader from '@salesforce/label/c.PG_SW_Tab_Tasks';
import createNewTask from '@salesforce/label/c.BTN_Create_New_Task';
import taskCompleted from '@salesforce/label/c.Task_Completed';
import taskCreateReminder from '@salesforce/label/c.Task_create_reminder';
import taskEdit from '@salesforce/label/c.Task_Edit';
import taskIgnore from '@salesforce/label/c.Task_Ignore';
import taskMarkComplete from '@salesforce/label/c.Task_Mark_Complete_Msg';
import taskDue from '@salesforce/label/c.Task_Due';
import taskCancel from '@salesforce/label/c.RH_RP_Cancel';
import taskConfirm from '@salesforce/label/c.RH_TV_Confirm';
import taskPriorityCritical from '@salesforce/label/c.Task_priority_critical';
import notAvailable from '@salesforce/label/c.Not_Available';
import taskMarkCompleteHeader from '@salesforce/label/c.Task_Mark_Complete';
import taskReminder from '@salesforce/label/c.Task_Reminder';
import noOpenTasks from '@salesforce/label/c.No_Open_Tasks';
import noCompletedTasks from '@salesforce/label/c.Task_No_Completed';

import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import getPPParticipantTasks from '@salesforce/apex/TasksRemote.getPPParticipantTasks';
import { NavigationMixin } from 'lightning/navigation';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import TIME_ZONE from '@salesforce/i18n/timeZone';

export default class PpTasks extends NavigationMixin(LightningElement) {
    initData;
    isNewTask = true;
    isRTL;
    taskId;
    task;
    taskExisting;
    userTimeZone = TIME_ZONE;
    label = {
        createNewTask,
        tasksHeader,
        taskCompleted,
        taskCreateReminder,
        taskEdit,
        taskIgnore,
        taskMarkComplete,
        taskDue,
        taskCancel,
        taskConfirm,
        taskPriorityCritical,
        notAvailable,
        taskMarkCompleteHeader,
        taskReminder,
        noOpenTasks,
        noCompletedTasks
    };
    taskSelectionMode = 'Open';
    taskBtnOpenClass = 'open-task active-btn';
    taskBtnCompleteClass = 'completed-task inactive-btn';
    taskOpenTab = true;
    isEnrolled;
    emailOptIn;
    smsOptIn;
    jsonState;
    showCreateTaskButton;
    @track openTasks;
    @track completedTasks;
    spinner;
    taskCodeList = [
        'Complete_Survey',
        'Complete_Your_Profile',
        'Activate_Ecoa_Ediaries',
        'Update_Your_Phone_Number',
        'Select_COI'
    ];

    isCreateTask = false;
    isShowModal = false;
    selectedTaskId;
    cssClass;
    popUpTaskId;
    @track popupTaskMenuItems;
    systemTaskImg = pp_icons + '/' + 'Task_Illustration.svg';
    emptyOpenTasks = false;
    emptyCompletedTasks = false;
    emptyIgnoreTasks = false;
    emptyExpiredTasks = false;
    completedTasksList = [];
    expiredTasksList = [];
    ignoredTasksList = [];

    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                console.log('NEW RR_COMMUNITY_JS loaded');
                this.spinner = this.template.querySelector('c-web-spinner');
                this.initializeData();
            })
            .catch((error) => {
                console.error('Error in loading RR Community JS: ' + JSON.stringify(error));
            });
    }
    initializeData() {
        try {
            this.spinner.show();
            this.openTasks = [];
            this.completedTasks = [];
            getPPParticipantTasks()
                .then((participantTasks) => {
                    console.log('participantTasks', participantTasks);
                    this.emptyIgnoreTasks = true;
                    this.emptyExpiredTasks = true;
                    this.showCreateTaskButton = participantTasks.showCreateTaskButton;
                    this.openTasks = participantTasks.openTasksWrapper;
                    if (this.openTasks) {
                        this.emptyOpenTasks = this.openTasks.length == 0;
                    }
                    console.log('this.taskSelectionMode ', this.taskSelectionMode);

                    this.completedTasks = participantTasks.completedTasks;
                    if (this.completedTasks) {
                        this.emptyCompletedTasks = this.completedTasks.length == 0;
                    }
                    if (this.taskSelectionMode == 'Complete') {
                        console.log('i am here');
                        this.populateSystemTasksforCompleted(this.completedTasks);
                    } else {
                        this.populateSystemTasks(this.openTasks);
                    }
                    this.spinner.hide();
                })
                .catch((error) => {
                    this.spinner.hide();
                });
        } catch (e) {
            alert(e);
        }
    }
    get cardRTL() {
        return this.isRTL ? 'cardRTL' : '';
    }
    doCreateTask() {
        this.isCreateTask = !this.isCreateTask;
    }
    get taskButtonClass() {
        return this.isCreateTask
            ? 'create-task after-create-task'
            : 'create-task before-create-task';
    }
    handleTaskClose(event) {
        this.isCreateTask = event.detail.isClose;
        this.initializeData();
    }
    handleTaskCreated(event) {
        if (event.detail.taskStatus == 'Open') {
            this.openTasks = event.detail.tasksList;
        }
        // this.initializeData();
    }

    populateSystemTasks(tasks) {
        try {
            console.log('tasks in populateSystemTasks', tasks);
            for (let i = 0; i < tasks.length; i++) {
                tasks[i].task = tasks[i].openTask;
                tasks[i].isClosed = false;
                tasks[i].systemTask =
                    tasks[i].openTask.Task_Code__c === undefined
                        ? false
                        : this.taskCodeList.includes(tasks[i].openTask.Task_Code__c);
                tasks[i].dueDate = tasks[i].openTask.Activity_Datetime__c ? true : false;
                tasks[i].startDate =
                    tasks[i].openTask.Start_Date__c &&
                    tasks[i].openTask.Activity_Datetime__c === undefined
                        ? true
                        : false;
                tasks[i].createdDate =
                    tasks[i].openTask.Start_Date__c === undefined &&
                    tasks[i].openTask.Activity_Datetime__c === undefined
                        ? true
                        : false;
                if (this.taskCodeList.includes(tasks[i].openTask.Task_Code__c)) {
                    tasks[i].criticalTask = false;
                } else {
                    tasks[i].criticalTask = tasks[i].openTask.Priority == 'Critical' ? true : false;
                }
                tasks[i].subjectClass = tasks[i].systemTask
                    ? 'set-up-your-account curpointer'
                    : 'set-up-your-account';
                tasks[i].subjectEllipsisClass = tasks[i].criticalTask
                    ? 'crit-subject-ellipsis crit-mob-subject-ellipsis'
                    : 'subject-ellipsis mob-subject-ellipsis';
                tasks[i].businessTask = tasks[i].systemTask
                    ? tasks[i].openTask.Task_Code__c == 'Complete_Survey'
                    : true;
            }
            this.openTasks = JSON.parse(JSON.stringify(this.openTasks));
        } catch (e) {
            alert(e);
        }
    }

    populateSystemTasksforCompleted(tasks) {
        this.expiredTasksList = [];
        this.ignoredTasksList = [];
        this.completedTasksList = [];
        for (let i = 0; i < tasks.length; i++) {
            tasks[i].isClosed = false;
            tasks[i].systemTask =
                tasks[i].task.Task_Code__c === undefined
                    ? false
                    : this.taskCodeList.includes(tasks[i].task.Task_Code__c);
                tasks[i].completed = tasks[i].task.Status == 'Completed' ? true : false;
                tasks[i].dueDate = false;
                if (!tasks[i].completed) {
            tasks[i].dueDate = tasks[i].task.Activity_Datetime__c ? true : false;
                }
            tasks[i].startDate =
                tasks[i].task.Start_Date__c && tasks[i].task.Activity_Datetime__c === undefined
                    ? true
                    : false;
            tasks[i].createdDate =
                tasks[i].task.Start_Date__c === undefined &&
                tasks[i].task.Activity_Datetime__c === undefined
                    ? true
                    : false;
            if (this.taskCodeList.includes(tasks[i].task.Task_Code__c)) {
                tasks[i].criticalTask = false;
            } else {
                tasks[i].criticalTask = tasks[i].task.Priority == 'Critical' ? true : false;
            }

            tasks[i].businessTask = tasks[i].systemTask
                ? tasks[i].task.Task_Code__c == 'Complete_Survey'
                : true;
            if (tasks[i].task.Status == 'Completed') {
                tasks[i].subjectClass = tasks[i].systemTask
                    ? 'set-up-your-account complete-header curpointer'
                    : 'set-up-your-account complete-header';
                this.completedTasksList.push(tasks[i]);
                tasks[i].isClosed = true;
            }
            if (tasks[i].task.Status == 'Ignored') {
                tasks[i].subjectClass = tasks[i].systemTask
                    ? 'set-up-your-account ignore-header curpointer'
                    : 'set-up-your-account ignore-header';
                this.ignoredTasksList.push(tasks[i]);
            }
            if (tasks[i].task.Status == 'Expired') {
                tasks[i].subjectClass = tasks[i].systemTask
                    ? 'set-up-your-account expire-header curpointer'
                    : 'set-up-your-account expire-header';
                this.expiredTasksList.push(tasks[i]);
            }
            tasks[i].subjectEllipsisClass = tasks[i].criticalTask
                ? 'crit-subject-ellipsis crit-mob-subject-ellipsis'
                : 'subject-ellipsis mob-subject-ellipsis';
        }
        this.emptyIgnoreTasks = this.ignoredTasksList.length == 0;
        this.emptyExpiredTasks = this.expiredTasksList.length == 0;
    }
    navigateToCompleted() {
        this.taskSelectionMode = 'Complete';
        this.taskBtnOpenClass = 'open-task inactive-btn';
        this.taskBtnCompleteClass = 'completed-task active-btn';
        this.taskOpenTab = this.taskSelectionMode == 'Open';
        this.initializeData();
    }
    navigateToOpen() {
        this.taskSelectionMode = 'Open';
        this.taskOpenTab = this.taskSelectionMode == 'Open';
        this.taskBtnOpenClass = 'open-task active-btn';
        this.taskBtnCompleteClass = 'completed-task inactive-btn';
        this.initializeData();
    }
}
