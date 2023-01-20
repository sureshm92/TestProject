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

import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import getPPParticipantTasks from '@salesforce/apex/TasksRemote.getPPParticipantTasks';
import markAsCompleted from '@salesforce/apex/TaskEditRemote.markAsCompleted';
import { NavigationMixin } from 'lightning/navigation';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import basePathName from '@salesforce/community/basePath';
import viewAllTasks from '@salesforce/label/c.View_All_Tasks';

export default class PpHomePageTasks extends NavigationMixin(LightningElement) {
    initData;
    isNewTask = true;
    isRTL;
    @track taskId;
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
        viewAllTasks
    };
    isEnrolled;
    emailOptIn;
    smsOptIn;
    jsonState;
    showCreateTaskButton;
    @track openTasks;
    @track sfdcBaseURL;
    completedTasks;
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
    threedots_imgUrl = pp_icons + '/' + 'three_dots.png';
    systemTaskImg = pp_icons + '/' + 'Task_Illustration.svg';
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
    emptyOpenTasks;

    connectedCallback() {
        this.sfdcBaseURL = window.location.origin + basePathName + '/tasks';
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                console.log('NEW RR_COMMUNITY_JS loaded');
                this.spinner = this.template.querySelector('c-web-spinner');
                this.initializeData();
            })
            .catch((error) => {
                console.error('Error in loading RR Community JS: ' + JSON.stringify(error));
            });
            console.log('openTasks:',this.openTasks);
    }
    initializeData() {
        this.spinner.show();
        getPPParticipantTasks()
            .then((participantTasks) => {
                this.showCreateTaskButton = participantTasks.showCreateTaskButton;
                this.openTasks = participantTasks.openTasksWrapper;
                this.emptyOpenTasks = this.openTasks.length == 0;
                this.populateSystemTasks(this.openTasks);
                this.completedTasks = participantTasks.completedTasks;
                this.spinner.hide();
            })
            .catch((error) => {
                this.spinner.hide();
            });
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

    populateSystemTasks(tasks) {
        for (let i = 0; i < tasks.length; i++) {
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
            tasks[i].businessTask = tasks[i].systemTask
                ? tasks[i].openTask.Task_Code__c == 'Complete_Survey'
                : true;
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
    handleonclick(event) {
        var taskId = event.currentTarget.dataset.index;
        console.log('taskId:',taskId);
        this.redirectPage(taskId);
    }
    redirectPage(taskId) {
        console.log('redirectPage:',window.location.origin);
        console.log('basePathName:',basePathName);

        this.taskurl = window.location.origin + basePathName + '/tasks'+ '?taskId=' + taskId;
        console.log('taskurl:', this.taskurl);

        const config = {
            type: 'standard__webPage',

            attributes: {
                url: this.taskurl
            }
        };
        this[NavigationMixin.GenerateUrl](config).then((url) => {
            window.open(url, '_self');
        });
    }
}
