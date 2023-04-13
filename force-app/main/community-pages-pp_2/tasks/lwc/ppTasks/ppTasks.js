import { LightningElement, track, api } from 'lwc';
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
import taskPPCompleted from '@salesforce/label/c.Task_PP_Completed';
import taskPPIgnored from '@salesforce/label/c.Task_PP_Ignored';
import taskPPExpired from '@salesforce/label/c.Task_PP_Expired';
import getPPParticipantTasks from '@salesforce/apex/TasksRemote.getPPParticipantTasks';
import { NavigationMixin } from 'lightning/navigation';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import formFactor from '@salesforce/client/formFactor';
import markAsCompleted from '@salesforce/apex/TaskEditRemote.markAsCompleted';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import basePathName from '@salesforce/community/basePath';
import viewAllTasks from '@salesforce/label/c.View_All_Tasks';

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
        noCompletedTasks,
        taskPPCompleted,
        taskPPIgnored,
        taskPPExpired,
        viewAllTasks
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
    @track sfdcBaseURL;
    spinner;
    taskCodeList = [
        'Complete_Survey',
        'Complete_Your_Profile',
        'Activate_Ecoa_Ediaries',
        'Update_Your_Phone_Number',
        'Select_COI'
    ];

    ishomepage = false;
    isMobile = false;
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
    openTaskImg = pp_icons + '/' + 'Oval.svg';
    closeTaskImg = pp_icons + '/' + 'Oval_Completed.svg';
    reminderObj = {
        name: this.label.taskCreateReminder,
        iconUrl: 'reminderbell_icon',
        reminder: true
    };
    editObj = { name: this.label.taskEdit, iconUrl: 'Pencil_Icon', edit: true };
    ignoreObj = { name: this.label.taskIgnore, iconUrl: 'icon-close', ignore: true };
    editImg = pp_icons + '/' + 'Pencil_Icon.svg';
    @api desktop;
    editMode = false;
    taskParamId;
    showSpinner = true;
    rightPanelComponents = [];
    
    connectedCallback() {
        if (formFactor === 'Small') {
            this.isMobile = true;
        } else {
            this.isMobile = false;
        }
        var pageurl = communityService.getFullPageName();
        var pageParam = communityService.getUrlParameter('id');
        this.taskParamId = pageParam;
        this.selectedTaskId = pageParam;
        if (pageurl.includes('tasks') || pageParam) {
            this.ishomepage = false;
        } else {
            this.ishomepage = true;
        }
        this.spinner = this.template.querySelector('c-web-spinner');
        this.initializeData();
    }

    initializeData() {
        try {
            this.showSpinner = true;
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
                        if (this.ishomepage) {
                            this.openTasks.splice(
                                this.openTasks.length > 4 ? 4 : this.openTasks.length
                            );
                        }
                    }
                    this.showSpinner = false;
                })
                .catch((error) => {
                    this.showSpinner = false;
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
        this.taskParamId = '';
        this.initializeData();
    }
    handleTaskEdit(event) {
        this.isCreateTask = event.detail.isClose;
        this.editMode = event.detail.editMode;
    }
    handleTaskCreated(event) {
        this.taskParamId = '';
        this.initializeData();
    }
    handleTaskCompleted(event) {
        if (event.detail.taskStatus == 'Open') {
            this.openTasks = event.detail.tasksList;
        }
    }

    populateSystemTasks(tasks) {
        try {
            for (let i = 0; i < tasks.length; i++) {
                tasks[i].task = tasks[i].openTask;

                tasks[i].isClosed = false;
                tasks[i].systemTask =
                    tasks[i].openTask.Task_Code__c === undefined
                        ? false
                        : this.taskCodeList.includes(tasks[i].openTask.Task_Code__c);
                if (tasks[i].task.Id == this.taskParamId) {
                    tasks[i].expandCard = true;
                }
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
                tasks[i].homeSubjectEllipsisClass = tasks[i].criticalTask
                    ? 'home-crit-subject-ellipsis home-crit-mob-subject-ellipsis curpointer'
                    : 'home-subject-ellipsis mob-subject-ellipsis curpointer';
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
                tasks[i].subjectClass = 'set-up-your-account complete-header cursor-default';
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
                tasks[i].subjectClass = 'set-up-your-account expire-header cursor-default';
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
    closeTheTask() {
        this.hideModalBox();
        this.spinner.show();
        let radioTask = this.template.querySelector('[data-index="' + this.selectedTaskId + '"]');
        markAsCompleted({ taskId: this.selectedTaskId })
            .then(() => {
                for (let i = 0; i < this.openTasks.length; i++) {
                    if (this.openTasks[i].openTask.Id == this.selectedTaskId) {
                        this.openTasks[i].isClosed = true;
                        break;
                    }
                }
                this.spinner.hide();

                this.showToast(this.label.taskCompleted, this.label.taskCompleted, 'success');
            })
            .catch((error) => {
                console.log(error);
                this.spinner.hide();
            });
    }
    expandtheCard(event) {
        try {
            this.popupTaskMenuItems = [];
            var taskId = event.currentTarget.dataset.popup;
            this.popUpTaskId = taskId;
            let radioTask = this.template.querySelector('[data-popup="' + taskId + '"]');
            let cl = radioTask.classList.value;
            let selectedTask;
            for (let i = 0; i < this.openTasks.length; i++) {
                if (this.openTasks[i].openTask.Id == this.popUpTaskId) {
                    selectedTask = this.openTasks[i];
                    break;
                }
            }

            if (
                this.taskCodeList.includes(selectedTask.openTask.Task_Code__c) &&
                selectedTask.openTask.Task_Code__c != 'Complete_Survey'
            ) {
                this.popupTaskMenuItems.push(this.reminderObj);
            } else {
                if (selectedTask.openTask.Task_Code__c == 'Complete_Survey') {
                    this.popupTaskMenuItems.push(this.reminderObj, this.ignoreObj);
                } else {
                    if (selectedTask.openTask.Originator__c == 'IQVIA Admin') {
                        this.popupTaskMenuItems.push(this.reminderObj, this.ignoreObj);
                    } else {
                        this.popupTaskMenuItems.push(this.editObj, this.ignoreObj);
                    }
                }
            }
            if (!cl.includes('slds-is-open')) radioTask.classList.add('slds-is-open');
            if (cl.includes('slds-is-open')) radioTask.classList.remove('slds-is-open');
        } catch (e) {
            alert(e);
        }
    }

    closeMenu() {
        try {
            let radioTask = this.template.querySelector('[data-popup="' + this.popUpTaskId + '"]');
            radioTask.classList.remove('slds-is-open');
        } catch (e) {
            alert(e);
        }
    }
    closeModel() {
        let radioTask = this.template.querySelector('[data-modalpopup="' + this.popUpTaskId + '"]');
        this.isShowModal = false;
        let radioTask2 = this.template.querySelector(
            '[data-parentdiv="' + this.selectedTaskId + '"]'
        );
        radioTask2.classList.remove('active-custom-box');
    }
    showToast(titleText, messageText, variantType) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: titleText,
                message: '',
                variant: variantType
            })
        );
    }
    fillTheOpenIcon(event) {
        var taskId = event.currentTarget.dataset.index;
        let radioTask2 = this.template.querySelector('[data-index="' + taskId + '"]');
        if (radioTask2.classList.value.includes('fill-oval')) {
            radioTask2.classList.remove('fill-oval');
            radioTask2.classList.add('empty-oval');
        } else {
            radioTask2.classList.add('fill-oval');
            radioTask2.classList.remove('empty-oval');
        }
    }
    taskOpen(event) {
        let selectedTask;
        var taskId = event.currentTarget.dataset.index;
        if (event.currentTarget.dataset.actionurl != undefined) {
            communityService.navigateToPage(event.currentTarget.dataset.actionurl);
        }
    }
    showTaskCompleteModal(event) {
        let selectedTask;

        var taskId = event.currentTarget.dataset.index;
        for (let i = 0; i < this.openTasks.length; i++) {
            if (this.openTasks[i].openTask.Id == taskId) {
                selectedTask = this.openTasks[i];
                break;
            }
        }
        if (selectedTask.isClosed) return;
        this.isShowModal = true;
        this.popUpTaskId = taskId;
        this.selectedTaskId = taskId;
        let radioTask = this.template.querySelector(
            '[data-parentdiv="' + this.selectedTaskId + '"]'
        );
        radioTask.classList.add('active-custom-box');
    }
    hideModalBox() {
        this.isShowModal = false;
        let radioTask = this.template.querySelector(
            '[data-parentdiv="' + this.selectedTaskId + '"]'
        );
        radioTask.classList.remove('active-custom-box');
    }
    navigateToTasks() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'tasks'
            }
        });
    }

    handleLoad(event){
        let rightElement = this.template.querySelector('.task-panel_right');
        let leftElement = this.template.querySelector('.task-panel_left');
        this.rightPanelComponents.push(event.detail);
        if(rightElement && !(rightElement.classList.contains('divider'))){
            rightElement.classList.add('divider');
        }
        if(leftElement && !leftElement.classList.contains('slds-large-size--2-of-3')){
            leftElement.classList.add('slds-large-size--2-of-3');
        }
    }

    handleCardRemove(event){
        let cmpName = event.detail;
        let leftElement = this.template.querySelector('.task-panel_left');
        if(this.rightPanelComponents.includes(cmpName)){
            this.rightPanelComponents.splice(this.rightPanelComponents.indexOf(cmpName),1);
            if(this.rightPanelComponents.length == 0){
                this.template.querySelector('.task-panel_right').classList.remove('divider'); 
                if(leftElement  && leftElement.classList.contains('slds-large-size--2-of-3')){
                    leftElement.classList.remove('slds-large-size--2-of-3');
                } 
            }
        }
        
    }
}
