import { LightningElement, track, api } from 'lwc';
import taskCompleted from '@salesforce/label/c.Task_Completed';
import taskCreateReminder from '@salesforce/label/c.Task_create_reminder';
import taskEdit from '@salesforce/label/c.Task_Edit';
import taskIgnore from '@salesforce/label/c.Task_Ignore';
import taskDue from '@salesforce/label/c.Task_Due';
import taskCancel from '@salesforce/label/c.RH_RP_Cancel';
import taskConfirm from '@salesforce/label/c.RH_TV_Confirm';
import taskPriorityCritical from '@salesforce/label/c.Task_priority_critical';
import notAvailable from '@salesforce/label/c.Not_Available';
import taskReminder from '@salesforce/label/c.Task_Reminder';
import noOpenTasks from '@salesforce/label/c.No_Open_Tasks';
import taskPPCompletedLabel from '@salesforce/label/c.Task_PP_Completed';
import taskIgnoreContinue from '@salesforce/label/c.Continue';
import taskIgnoredMessage from '@salesforce/label/c.Task_Ignored_Message';

import markAsCompleted from '@salesforce/apex/TaskEditRemote.markAsCompleted';
import markAsIgnore from '@salesforce/apex/TaskEditRemote.ignoreTask';
import { NavigationMixin } from 'lightning/navigation';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import formFactor from '@salesforce/client/formFactor';

export default class PpTasksList extends NavigationMixin(LightningElement) {
    isTaskIgnoreModal = false;
    popUpTaskId;
    userTimeZone = TIME_ZONE;
    @track tasksList;
    @api expireTaskAvailable = false;
    @api containerClass;
    @api dueTimeClass;
    @api isActive;

    @api contact;
    @api selectedparent;
    @api usermode;

    @api
    get selectedTasks() {
        return this.uppercaseItemName;
    }
    set selectedTasks(value) {
        if (value !== undefined) {
            this.tasksList = JSON.parse(JSON.stringify(value));
        }
    }
    @api completedTasks;
    spinner;
    @api webIconClass;
    @api systemIconClass;
    taskCodeList = [
        'Complete_Survey',
        'Complete_Your_Profile',
        'Activate_Ecoa_Ediaries',
        'Update_Your_Phone_Number',
        'Select_COI'
    ];
    taskSelectionMode = 'Open';
    taskBtnOpenClass = 'open-task active-btn';
    taskBtnCompleteClass = 'completed-task inactive-btn';
    taskOpenTab = true;
    label = {
        taskCancel,
        taskConfirm,
        taskPriorityCritical,
        taskDue,
        notAvailable,
        taskReminder,
        notAvailable,
        noOpenTasks,
        taskEdit,
        taskIgnore,
        taskCreateReminder,
        taskCompleted,
        taskPPCompletedLabel,
        taskIgnoreContinue,
        taskIgnoredMessage
    };
    isCreateTask = false;
    isShowModal = false;
    selectedTaskId;
    cssClass;
    @track popupTaskMenuItems;
    threedots_imgUrl = pp_icons + '/' + 'three_dots.png';
    systemTaskImg = pp_icons + '/' + 'Task_Illustration.svg';
    openTaskImg = pp_icons + '/' + 'Oval.svg';
    closeTaskImg = pp_icons + '/' + 'Oval_Completed.svg';
    reminderObj = {
        name: this.label.taskCreateReminder,
        iconUrl: 'reminderbell_icom',
        reminder: true
    };
    editObj = {
        name: this.label.taskEdit,
        iconUrl: 'Pencil_Icon',
        edit: true
    };
    ignoreObj = {
        name: this.label.taskIgnore,
        iconUrl: 'icon-close',
        ignore: true
    };
    editImg = pp_icons + '/' + 'Pencil_Icon.svg';
    emptyOpenTasks;
    emptyCompletedTasks;
    completedTasksList = [];
    expiredTasksList = [];
    ignoredTasksList = [];
    spinner;
    isMobile = false;

    connectedCallback() {
        console.log('tasks 123', this.tasksList);
        if (formFactor === 'Small') {
            this.isMobile = true;
        } else {
            this.isMobile = false;
        }
    }

    taskOpen(event) {
        let selectedTask;
        var taskId = event.currentTarget.dataset.index;
        console.log('sss', event.currentTarget.dataset.status);
        if (
            event.currentTarget.dataset.status == 'Expired' ||
            event.currentTarget.dataset.status == 'Completed'
        )
            return;
        if (event.currentTarget.dataset.actionurl != undefined) {
            communityService.navigateToPage(event.currentTarget.dataset.actionurl);
        }
    }
    showTaskCompleteModal(event) {
        let selectedTask;
        var taskId = event.currentTarget.dataset.index;
        for (let i = 0; i < this.tasksList.length; i++) {
            if (this.tasksList[i].task.Id == taskId) {
                selectedTask = this.tasksList[i];
                break;
            }
        }
        if (selectedTask.isClosed) return;
        if (selectedTask.task.Status == 'Expired') return;
        this.isShowModal = true;
        this.popUpTaskId = taskId;
        this.selectedTaskId = taskId;
        let radioTask = this.template.querySelector(
            '[data-parentdiv="' + this.selectedTaskId + '"]'
        );
        radioTask.classList.add('active-custom-box');
    }

    showIgnoreModal(event) {
        this.isTaskIgnoreModal = true;
    }
    hideModalBox() {
        this.isShowModal = false;
        let radioTask = this.template.querySelector(
            '[data-parentdiv="' + this.selectedTaskId + '"]'
        );
        radioTask.classList.remove('active-custom-box');
    }
    closeTheTask() {
        let taskOldStatus;
        this.hideModalBox();
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner.show();
        let radioTask = this.template.querySelector('[data-index="' + this.selectedTaskId + '"]');
        markAsCompleted({ taskId: this.selectedTaskId })
            .then(() => {
                this.tasksList = JSON.parse(JSON.stringify(this.tasksList));
                for (let i = 0; i < this.tasksList.length; i++) {
                    if (this.tasksList[i].task.Id == this.selectedTaskId) {
                        this.tasksList[i].isClosed = true;
                        taskOldStatus = this.tasksList[i].task.Status;
                        break;
                    }
                }
                this.spinner.hide();
                this.showToast(this.label.taskCompleted, this.label.taskCompleted, 'success');
                const taskCloseEvent = new CustomEvent('taskcreated', {
                    detail: {
                        tasksList: this.tasksList,
                        taskStatus: taskOldStatus
                    }
                });
                this.dispatchEvent(taskCloseEvent);
            })
            .catch((error) => {
                this.spinner.hide();
            });
    }
    expandtheCard(event) {
        this.popupTaskMenuItems = [];
        var taskId = event.currentTarget.dataset.popup;
        this.popUpTaskId = taskId;
        let radioTask = this.template.querySelector('[data-popup="' + taskId + '"]');
        let cl = radioTask.classList.value;
        let selectedTask;
        for (let i = 0; i < this.tasksList.length; i++) {
            if (this.tasksList[i].task.Id == this.popUpTaskId) {
                selectedTask = this.tasksList[i];
                break;
            }
        }

        if (
            this.taskCodeList.includes(selectedTask.task.Task_Code__c) &&
            selectedTask.task.Task_Code__c != 'Complete_Survey'
        ) {
            this.popupTaskMenuItems.push(this.reminderObj);
        } else {
            if (selectedTask.task.Task_Code__c == 'Complete_Survey') {
                this.popupTaskMenuItems.push(this.reminderObj, this.ignoreObj);
            } else {
                if (selectedTask.task.Originator__c == 'IQVIA Admin') {
                    this.popupTaskMenuItems.push(this.reminderObj, this.ignoreObj);
                } else {
                    this.popupTaskMenuItems.push(this.editObj, this.ignoreObj);
                }
            }
        }
        if (!cl.includes('slds-is-open')) radioTask.classList.add('slds-is-open');
        if (cl.includes('slds-is-open')) radioTask.classList.remove('slds-is-open');
    }
    closeMenu() {
        let radioTask = this.template.querySelector('[data-popup="' + this.popUpTaskId + '"]');
        radioTask.classList.remove('slds-is-open');
    }
    closeModel() {
        let radioTask = this.template.querySelector('[data-modalpopup="' + this.popUpTaskId + '"]');
        this.isShowModal = false;
        this.isTaskIgnoreModal = false;
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
        console.log('fillTheOpenIcon');
        var taskId = event.currentTarget.dataset.index;
        if (event.currentTarget.dataset.status == 'Expired') return;
        let radioTask2 = this.template.querySelector('[data-index="' + taskId + '"]');
        if (radioTask2.classList.value.includes('fill-oval')) {
            radioTask2.classList.remove('fill-oval');
            radioTask2.classList.add('empty-oval');
        } else {
            radioTask2.classList.add('fill-oval');
            radioTask2.classList.remove('empty-oval');
        }
    }
    stopBlurEvent(event) {
        event.preventDefault();
    }
    createReminder() {
        alert('createReminder');
    }
    editTask() {
        alert('editTask');
    }
    callMethod(event) {
        if (event.currentTarget.dataset.method == this.label.taskCreateReminder) {
            this.createReminder();
        }
        if (event.currentTarget.dataset.method == this.label.taskEdit) {
            this.editTask();
        }
        if (event.currentTarget.dataset.method == this.label.taskIgnore) {
            this.showIgnoreModal();
        }
        event.preventDefault();
    }
    markTheTaskIgnore() {
        this.isTaskIgnoreModal = false;
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner.show();

        markAsIgnore({ taskId: this.popUpTaskId })
            .then(() => {
                this.removeTheTaskfromList(this.popUpTaskId);
                this.spinner.hide();
                this.showToast(
                    this.label.taskIgnoredMessage,
                    this.label.taskIgnoredMessage,
                    'success'
                );
            })
            .catch((error) => {
                this.spinner.hide();
            });
    }
    getTaskDetailsById(taskId) {
        let selectedTask;
        for (let i = 0; i < this.tasksList.length; i++) {
            if (this.tasksList[i].task.Id == taskId) {
                selectedTask = this.tasksList[i];
                break;
            }
        }
        return selectedTask;
    }
    removeTheTaskfromList(taskId) {
        let i;
        for (i = 0; i < this.tasksList.length; i++) {
            if (this.tasksList[i].task.Id == taskId) {
                break;
            }
        }
        this.tasksList.splice(i, 1);
    }
}
