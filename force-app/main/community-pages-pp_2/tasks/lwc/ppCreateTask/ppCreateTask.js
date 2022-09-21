import { LightningElement, api } from 'lwc';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import moment from '@salesforce/resourceUrl/moment_js';
import momentTZ from '@salesforce/resourceUrl/momenttz';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import { loadScript } from 'lightning/platformResourceLoader';
import upsertTask from '@salesforce/apex/TaskEditRemote.upsertTask';
import getTaskEditData from '@salesforce/apex/TaskEditRemote.getTaskEditData';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import taskCreationSuccess from '@salesforce/label/c.PP_TaskCreationSuccess';

export default class PpCreateTask extends LightningElement {
    task_icon = pp_icons + '/' + 'createTask_illustration.svg';
    taskNamelength;
    currentBrowserTime;
    diffInMinutes;
    todaydate;
    past = false;
    task;
    calculatedDate;
    booleanFalse = false;
    todaytime;
    taskDateTime;
    taskTime;
    taskDate;
    initData;
    subject;
    jsonState;

    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                console.log('RR_COMMUNITY_JS loaded');
            })
            .catch((error) => {
                console.error('Error in loading RR Community JS: ' + JSON.stringify(error));
            });
        loadScript(this, moment).then(() => {
            loadScript(this, momentTZ).then(() => {
                this.currentBrowserTime = window.moment();
                var localOffset = this.currentBrowserTime.utcOffset();
                var userTime = this.currentBrowserTime.tz(TIME_ZONE);
                var centralOffset = userTime.utcOffset();
                this.diffInMinutes = localOffset - centralOffset;
                this.initializeData();
            });
        });
    }
    initializeData() {
        if (!communityService.isDummy()) {
            this.isRTL = rtlLanguages.includes(communityService.getLanguage()) ? true : false;
            getTaskEditData({ taskId: this.taskId })
                .then((wrapper) => {
                    this.initData = wrapper;
                    var task = wrapper.task;
                    task.Status = 'Open';
                    task.Task_Type__c = 'Not Selected';
                    this.task = task;
                    this.jsonState = JSON.stringify(wrapper) + '' + JSON.stringify(task);
                })
                .catch((error) => {
                    console.log('error', error);
                });
        } else {
        }
    }
    handleuserNameChange(event) {
        var val = event.target.value;
        this.taskNamelength = val.length;
        this.subject = event.target.value;
        if (event.target.value !== '') {
            this.template.querySelector('[data-id="taskName"]').value = event.target.value;
        }
    }
    get currentDate() {
        var currentDate;
        if (this.diffInMinutes < 0) {
            var currentDateTime = this.currentBrowserTime - this.diffInMinutes * 60 * 1000;
            currentDate = new Date(currentDateTime);
        } else {
            var currentDateTime = this.currentBrowserTime + this.diffInMinutes * 60 * 1000;
            currentDate = new Date(currentDateTime);
        }
        var dd = String(currentDate.getDate()).padStart(2, '0');
        var mm = String(currentDate.getMonth() + 1).padStart(2, '0');
        var yyyy = currentDate.getFullYear();
        var today = yyyy + '-' + mm + '-' + dd;
        this.todaydate = today;
        this.calculatedDate = today;
        return today;
    }
    handleTime(event) {
        this.taskDateTime = event.detail.compdatetime;
        this.taskTime = event.detail.comptime;
        this.taskDate = event.detail.compdate;
        this.initData.activityDate = this.taskDateTime;
    }

    handleDate(event) {
        this.taskDateTime = event.detail.compdatetime;
        this.taskDate = event.detail.compdate;
        this.taskTime = event.detail.comptime;
        this.initData.activityDate = this.taskDateTime;
    }
    doCreateTask() {
        this.task.Subject = this.subject;
        upsertTask({
            wrapper: JSON.stringify(this.initData),
            paramTask: JSON.stringify(this.task)
        })
            .then((result) => {
                communityService.showToast('', 'success', taskCreationSuccess, 100);
            })
            .catch((error) => {
                console.log(' error ', error);
            });
    }

    get currentTime() {
        var currentDate;
        if (this.diffInMinutes < 0) {
            var currentDateTime = this.currentBrowserTime - this.diffInMinutes * 60 * 1000;
            currentDate = new Date(currentDateTime);
        } else {
            var currentDateTime = this.currentBrowserTime + this.diffInMinutes * 60 * 1000;
            currentDate = new Date(currentDateTime);
        }
        var hh = String((currentDate.getHours() < 10 ? '0' : '') + currentDate.getHours());
        var mm = String((currentDate.getMinutes() < 10 ? '0' : '') + currentDate.getMinutes());
        var ss = String((currentDate.getSeconds() < 10 ? '0' : '') + currentDate.getSeconds());
        var currentTime = hh + ':' + mm + ':' + ss;
        this.todaytime = currentTime;
        return currentTime;
    }
}
