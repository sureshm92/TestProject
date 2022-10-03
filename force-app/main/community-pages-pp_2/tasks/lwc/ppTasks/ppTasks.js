import { LightningElement } from 'lwc';
import tasksHeader from '@salesforce/label/c.PG_SW_Tab_Tasks';
import createNewTask from '@salesforce/label/c.BTN_Create_New_Task';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import getParticipantTasks from '@salesforce/apex/TasksRemote.getParticipantTasks';

export default class PpTasks extends LightningElement {
    initData;
    isNewTask = true;
    isRTL;
    taskId;
    task;
    taskExisting;
    label = {
        createNewTask,
        tasksHeader
    };
    isEnrolled;
    emailOptIn;
    smsOptIn;
    jsonState;
    showCreateTaskButton;
    openTasks;
    completedTasks;
    spinner;

    isCreateTask = false;
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
        getParticipantTasks()
            .then((participantTasks) => {
                this.showCreateTaskButton = participantTasks.showCreateTaskButton;
                this.openTasks = participantTasks.openTasksWrapper;
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
}
