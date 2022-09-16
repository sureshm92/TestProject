import { LightningElement } from 'lwc';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import createNewTask from '@salesforce/label/c.BTN_Create_New_Task';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import getTaskEditData from '@salesforce/apex/TaskEditRemote.getTaskEditData';

export default class PpTasks extends LightningElement {
    initData;
    isNewTask;
    isRTL;
    taskId;
    task;
    label = {
        createNewTask
    };

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
    initializeData() {
        if (!communityService.isDummy()) {
            this.isRTL = rtlLanguages.includes(communityService.getLanguage()) ? true : false;
            getTaskEditData({ taskId: this.taskId })
                .then((result) => {
                    console.log('result from help', result);
                    this.initData = result;
                })
                .catch((error) => {
                    console.log('error', error);
                });
        } else {
        }
    }
    doCreateTask() {
        this.isCreateTask = !this.isCreateTask;
    }
}
