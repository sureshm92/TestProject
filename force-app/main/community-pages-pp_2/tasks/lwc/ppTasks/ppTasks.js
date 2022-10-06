import { LightningElement, track } from 'lwc';
import tasksHeader from '@salesforce/label/c.PG_SW_Tab_Tasks';
import createNewTask from '@salesforce/label/c.BTN_Create_New_Task';
import taskCompleted from '@salesforce/label/c.Task_Completed';
import taskCreateReminder from '@salesforce/label/c.Task_create_reminder';
import taskEdit from '@salesforce/label/c.Task_Edit';
import taskIgnore from '@salesforce/label/c.Task_Ignore';


import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import getPPParticipantTasks from '@salesforce/apex/TasksRemote.getPPParticipantTasks';
import markAsCompleted from '@salesforce/apex/TaskEditRemote.markAsCompleted';
import { NavigationMixin } from 'lightning/navigation';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PpTasks extends NavigationMixin(LightningElement) {
    initData;
    isNewTask = true;
    isRTL;
    taskId;
    task;
    taskExisting;
    label = {
        createNewTask,
        tasksHeader,
        taskCompleted,
        taskCreateReminder,
        taskEdit,
        taskIgnore
    };
    isEnrolled;
    emailOptIn;
    smsOptIn;
    jsonState;
    showCreateTaskButton;
    @track openTasks;
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
    carList = ['Create Reminder', 'Ignore', 'Edit'];
    threedots_imgUrl = pp_icons + '/' + 'three_dots.png';
    systemTaskImg = pp_icons + '/' + 'Task_Illustration.svg';
    openTaskImg = pp_icons + '/' + 'Oval.svg';
    closeTaskImg = pp_icons + '/' + 'Oval_Completed.svg';
    reminderObj = {name: this.label.taskCreateReminder,iconUrl :'reminderbell_icom',reminder:true};
    editObj = {name: this.label.taskEdit,iconUrl :'Pencil_Icon',edit:true};
    ignoreObj = {name: this.label.taskIgnore,iconUrl :'icon-close',ignore:true};

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
        this.spinner.show();
        getPPParticipantTasks()
            .then((participantTasks) => {
                console.log('ppp',participantTasks);
                this.showCreateTaskButton = participantTasks.showCreateTaskButton;
                this.openTasks = participantTasks.openTasksWrapper;
                this.populateSystemTasks(this.openTasks);
                this.completedTasks = participantTasks.completedTasks;
                this.spinner.hide();
            })
            .catch((error) => {
                console.log('error in ppTasks ', error);
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
    }

    populateSystemTasks(tasks) {
        for (let i = 0; i < tasks.length; i++) {
            tasks[i].isClosed = false;
            tasks[i].systemTask =
                tasks[i].openTask.Task_Code__c === undefined
                    ? false
                    : this.taskCodeList.includes(tasks[i].openTask.Task_Code__c);
            tasks[i].dueDate = tasks[i].openTask.activityDate ? true : false;
            tasks[i].startDate =
                tasks[i].openTask.Start_Date__c && tasks[i].openTask.activityDate === undefined
                    ? true
                    : false;
            tasks[i].createdDate =
                tasks[i].openTask.Start_Date__c === undefined &&
                tasks[i].openTask.activityDate === undefined
                    ? true
                    : false;
        }
    }
    taskOpen(event) {
        let selectedTask;
        var taskId = event.currentTarget.dataset.index;
        console.log(event.currentTarget.dataset.actionurl);
        communityService.navigateToPage(event.currentTarget.dataset.actionurl);
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
    }
    hideModalBox() {
        this.isShowModal = false;
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
        try{
        this.popupTaskMenuItems = [];
        var taskId = event.currentTarget.dataset.popup;
        console.log('taskid', taskId);
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
        console.log(selectedTask.openTask.Task_Code__c);

        if (
            this.taskCodeList.includes(selectedTask.openTask.Task_Code__c) &&
            selectedTask.openTask.Task_Code__c != 'Complete_Survey'
        ) {
            this.popupTaskMenuItems.push(this.reminderObj);

        } else {
            if(selectedTask.openTask.Task_Code__c =='Complete_Survey'){
this.popupTaskMenuItems.push(this.ignoreObj,this.reminderObj); //reminderObj
            }
            else{
                this.popupTaskMenuItems.push(this.editObj,this.ignoreObj,this.reminderObj); 
            }

            //this.popupTaskMenuItems.push('Edit');
        }

        for(var i=0;i<this.popupTaskMenuItems.length;i++)
            {
            console.log(this.popupTaskMenuItems[i].name);
            console.log(this.popupTaskMenuItems[i].iconUrl);

            }
        console.log(this.popupTaskMenuItems);
        console.log(this.openTasks);
        console.log(cl.includes('slds-is-open'));
        if (!cl.includes('slds-is-open')) radioTask.classList.add('slds-is-open');
        console.log(radioTask.classList.value);
        if (cl.includes('slds-is-open')) radioTask.classList.remove('slds-is-open');
    }catch(e)
    {
        alert(e);
    }
    }

    closeMenu() {
        console.log('closeMenu');
        console.log(this.popUpTaskId);

        try {
            let radioTask = this.template.querySelector('[data-popup="' + this.popUpTaskId + '"]');
            radioTask.classList.remove('slds-is-open');
        } catch (e) {
            alert(e);
        }
    }
    closeModel() {
        let radioTask = this.template.querySelector('[data-modalpopup="' + this.popUpTaskId + '"]');
        console.log(this.popUpTaskId);
        this.isShowModal = false;
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
}
