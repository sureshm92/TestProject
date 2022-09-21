import { LightningElement } from 'lwc';
import tasksHeader from '@salesforce/label/c.PG_SW_Tab_Tasks';
import createNewTask from '@salesforce/label/c.BTN_Create_New_Task';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';

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

    isCreateTask = false;
    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                console.log('NEW RR_COMMUNITY_JS loaded');
                this.initializeData();
            })
            .catch((error) => {
                console.error('Error in loading RR Community JS: ' + JSON.stringify(error));
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
            ? 'slds-button slds-button_brand create-task after-create-task'
            : 'slds-button slds-button_brand create-task before-create-task';
    }
    handleTaskCancel(event) {
        this.isCreateTask = event.detail.isCreate;
    }
}
