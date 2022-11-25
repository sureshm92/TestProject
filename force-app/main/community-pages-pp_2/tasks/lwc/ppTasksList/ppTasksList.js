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
    paramTaskId;

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
    task_arrow = pp_icons + '/' + 'Arrow_Icon_Final.svg';
    threedots_imgUrl = pp_icons + '/' + 'three_dots.png';
    systemTaskImg = pp_icons + '/' + 'Task_Illustration.svg';
    openTaskImg = pp_icons + '/' + 'Oval.svg';
    closeTaskImg = pp_icons + '/' + 'Oval_Completed.svg';
    reminderObj = {
        name: this.label.taskCreateReminder,
        iconUrl: 'reminderbell_icon',
        reminder: true
    };
    editObj = {
        name: this.label.taskEdit,
        iconUrl: 'Pencil_Icon',
        edit: true
    };
    ignoreObj = {
        name: this.label.taskIgnore,
        iconUrl: 'pp-close-new',
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
    selectedTaskId;
    readOnlyMode = false;
    ishomepage = false;
    @api
    get passTaskId() {
        return tthis.selectedTaskId;
    }
    set passTaskId(value) {
        this.selectedTaskId = value;
    }

    get showTaskCreateCard() {
        return this.selectedTaskId ? true : false;
    }

    get subjectSize() {
        return this.ishomepage ? 8 : this.isMobile ? 8 : 9;
    }

    get actionButtonSize() {
        return this.ishomepage ? 2 : this.isMobile ? 2 : 1;
    }

    get actionButtonCssClass() {
        return this.ishomepage
            ? 'slds-p-around_small slds-size_2-of-12'
            : this.isMobile
            ? 'slds-p-right_medium slds-size_2-of-12'
            : 'slds-p-right_large slds-size_1-of-12';
    }

    connectedCallback() {
        console.log('tasks 123', this.tasksList);
        if (formFactor === 'Small') {
            this.isMobile = true;
        } else {
            this.isMobile = false;
        }
        var pageurl = communityService.getFullPageName();
        if (pageurl.includes('tasks')) {
            this.ishomepage = false;
        } else {
            this.ishomepage = true;
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
        if (radioTask) radioTask.classList.add('active-custom-box');
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
                var localtimezonedate = new Date().toLocaleString('en-US', {
                    timeZone: 'UTC'
                });
                var processlocaltimezonedate = new Date(localtimezonedate);
                var dd = String(processlocaltimezonedate.getDate()).padStart(2, '0');
                var mm = String(processlocaltimezonedate.getMonth() + 1).padStart(2, '0');
                var yyyy = processlocaltimezonedate.getFullYear();
                var currentdate = yyyy + '-' + mm + '-' + dd;
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
                var currentTime = hh + ':' + mm + ':' + ss;
                var currentDatetime = currentdate + 'T' + currentTime;
                for (let i = 0; i < this.tasksList.length; i++) {
                    if (this.tasksList[i].task.Id == this.selectedTaskId) {
                        this.tasksList[i].isClosed = true;
                        this.tasksList[i].task.Activity_Datetime__c = currentDatetime;
                        taskOldStatus = this.tasksList[i].task.Status;
                        break;
                    }
                }
                this.spinner.hide();
                this.showToast(this.label.taskCompleted, this.label.taskCompleted, 'success');
                const taskCloseEvent = new CustomEvent('taskcompleted', {
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
    showTaskActionMenu(event) {
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
                if (selectedTask.task.Status != 'Ignored') {
                    this.popupTaskMenuItems.push(this.reminderObj);
                } else {
                    this.popupTaskMenuItems.push(this.reminderObj);
                }
            } else {
                if (selectedTask.task.Originator__c == 'IQVIA Admin') {
                    if (selectedTask.task.Status != 'Ignored') {
                        this.popupTaskMenuItems.push(this.reminderObj, this.ignoreObj);
                    } else {
                        this.popupTaskMenuItems.push(this.reminderObj);
                    }
                } else {
                    if (selectedTask.task.Status != 'Ignored') {
                        this.popupTaskMenuItems.push(this.editObj, this.ignoreObj);
                    } else {
                        this.popupTaskMenuItems.push(this.editObj);
                    }
                }
            }
        }
        if (!cl.includes('slds-is-open')) radioTask.classList.add('slds-is-open');
        if (cl.includes('slds-is-open')) radioTask.classList.remove('slds-is-open');
    }
    closeMenu() {
        try {
            let radioTask = this.template.querySelector('[data-popup="' + this.popUpTaskId + '"]');
            if (this.popUpTaskId) {
                let selectedTask = this.getTaskDetailsById(this.popUpTaskId);
            }
            if (radioTask) {
                radioTask.classList.remove('slds-is-open');
            }
        } catch (e) {
            console.error(e);
        }
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
        try {
            this.selectedTaskId = '';
            this.clearAllTaskExpandStatus();
            let selectedTask = this.getTaskDetailsById(this.popUpTaskId);
            this.selectedTaskId = this.popUpTaskId;
            selectedTask.expandCard = true;
            this.readOnlyMode = true;
            this.tasksList = JSON.parse(JSON.stringify(this.tasksList));
            const taskEditEvent = new CustomEvent('taskedit', {
                detail: {
                    isClose: true,
                    editMode: true
                }
            });
            this.dispatchEvent(taskEditEvent);
        } catch (e) {
            console.error(e);
        }
    }
    editTask() {
        try {
            this.selectedTaskId = '';
            this.clearAllTaskExpandStatus();
            let selectedTask = this.getTaskDetailsById(this.popUpTaskId);
            if (selectedTask) {
                this.selectedTaskId = this.popUpTaskId;
                selectedTask.expandCard = true;
                const taskEditEvent = new CustomEvent('taskedit', {
                    detail: {
                        isClose: true,
                        editMode: true
                    }
                });
                this.dispatchEvent(taskEditEvent);
                this.readOnlyMode = false;
                this.tasksList = JSON.parse(JSON.stringify(this.tasksList));
            }
        } catch (e) {
            console.error(e);
        }
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
                console.error(error);
                this.spinner.hide();
            });
    }
    getTaskDetailsById(taskId) {
        if (this.tasksList) {
            this.tasksList = JSON.parse(JSON.stringify(this.tasksList));
            for (let i = 0; i < this.tasksList.length; i++) {
                if (this.tasksList[i].task.Id == taskId) {
                    return this.tasksList[i];
                }
            }
            return '';
        }
    }
    clearAllTaskExpandStatus() {
        if (this.tasksList) {
            this.tasksList = JSON.parse(JSON.stringify(this.tasksList));
            for (let i = 0; i < this.tasksList.length; i++) {
                if (this.tasksList[i].expandCard) {
                    delete this.tasksList[i].expandCard;
                }
            }
        }
    }
    removeTheTaskfromList(taskId) {
        let i;
        for (i = 0; i < this.tasksList.length; i++) {
            if (this.tasksList[i].task.Id == taskId) {
                this.tasksList[i].task.Status = 'Ignored';
                break;
            }
        }
    }
    handleTaskClose(event) {
        this.selectedTaskId = '';
        let taskId = event.detail.taskId;
        this.clearAllTaskExpandStatus();
        const taskCreatedEvent = new CustomEvent('taskcreated');
        this.dispatchEvent(taskCreatedEvent);
        const taskEditEvent = new CustomEvent('taskedit', {
            detail: {
                isClose: false,
                editMode: false
            }
        });
        this.dispatchEvent(taskEditEvent);
    }
    handleonclick(event) {
        var taskId = event.currentTarget.dataset.index;
        this.redirectPage(taskId);
    }
    redirectPage(taskId) {
        communityService.navigateToPage('tasks?id=' + taskId);
    }
}
