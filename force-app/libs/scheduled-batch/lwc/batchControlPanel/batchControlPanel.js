/**
 * Created by Igor Malyuta on 20.11.2019.
 */

import {LightningElement, track, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import getData from '@salesforce/apex/BatchControlPanelRemote.getData';
import getJobs from '@salesforce/apex/BatchControlPanelRemote.getJobs';
import getState from '@salesforce/apex/BatchControlPanelRemote.getState';
import runBatch from '@salesforce/apex/BatchControlPanelRemote.runBatch';
import stopBatch from '@salesforce/apex/BatchControlPanelRemote.stopBatch';
import deleteBatch from '@salesforce/apex/BatchControlPanelRemote.deleteBatch';
import addBatch from '@salesforce/apex/BatchControlPanelRemote.addBatch';

export default class BatchControlPanel extends NavigationMixin(LightningElement) {

    @track notAddedBatches;
    @track showAddNew;
    mods;
    minScheduledDate;

    @track jobs;
    @track jobMap = new Map();

    @track initialized = false;
    @track inProcess = false;
    spinner;

    //Add new batch
    @track batchDetail;
    @track batchClass;
    @track batchLabel;
    @track batchIntervalMode;
    @track batchInterval;
    @track batchScopeSize;

    connectedCallback() {
        this.resetInputFields();

        setInterval(() => {
            if (!this.inProcess) {
                if (this.initialized) {

                    this.inProcess = true;
                    getJobs()
                        .then(data => {
                            if(this.jobs) {
                                this.jobMap.clear();
                                let context = this;
                                this.jobs.forEach(function (job) {
                                    context.jobMap.set(job.detail.Id, job);
                                });

                                data.forEach(function (job) {
                                    if (context.jobMap.has(job.detail.Id)) {
                                        let jw = context.jobMap.get(job.detail.Id);
                                        jw.css = job.css;
                                        jw.detail = job.detail;
                                        jw.jobId = job.jobId;
                                        jw.prevJob = job.prevJob;
                                        jw.prevLaunch = job.prevLaunch;
                                        jw.nextLaunch = job.nextLaunch;
                                        jw.state = job.state;
                                        jw.isStopped = job.isStopped;
                                        context.jobMap.set(job.detail.Id, jw);
                                    } else {
                                        context.jobMap.set(job.detail.Id, job);
                                    }
                                });

                                let tmpJobs = [];
                                this.jobMap.forEach(function (value) {
                                    tmpJobs.push(value);
                                });

                                this.jobs = tmpJobs;
                            }

                            this.inProcess = false;
                        })
                        .catch(error => {
                            console.log('Interval refresh error: ' + JSON.stringify(error));
                        });
                }
            }
        }, 1500);
    }

    renderedCallback() {
        if (!this.initialized) {
            this.spinner = this.template.querySelector('c-web-spinner');
            this.spinner.show();
        }
    }

    @wire(getData)
    wireData({data, error}) {
        if (data) {
            this.mods = data.intervalMods;
            this.minScheduledDate = new Date();
            this.initPageContent(data);

            this.resetInputFields();
            if (!this.initialized) {
                this.spinner.hide();
                this.initialized = true;
            }
        } else if(error) {
            console.log('Wire error:' + JSON.stringify(error));
        }
    }

    //Select options: --------------------------------------------------------------------------------------------------
    get batchClasses() {
        let options = [];
        if (this.notAddedBatches) {
            this.notAddedBatches.forEach((name) => {
                options.push({
                    label: name,
                    value: name
                });
            });
        }
        return options;
    }

    get intervalMods() {
        let mods = [];
        if (this.mods) {
            this.mods.forEach((mod) => {
                mods.push({
                    label: mod,
                    value: mod
                });
            });
        }
        return mods;
    }

    //Batch Action Handlers: -------------------------------------------------------------------------------------------
    handleSetLaunchTime(event) {
        let jobDetailId = event.currentTarget.dataset.id;
        let nextDT = event.target.value;

        try {
            let tmpJobs = [];
            this.jobs.forEach(function (job) {
                if (job.detail.Id === jobDetailId) job.nextSchedule = nextDT;
                tmpJobs.push(job);
            });
            this.jobs = tmpJobs;
        } catch (e) {
            console.log('Error' + JSON.stringify(e));
        }
    }

    handleRun(event) {
        let jobName = event.target.value;
        let wrapper;
        this.jobs.forEach(function (job) {
            if (job.detail.Name === jobName) wrapper = job;
        });

        let currentInput;
        this.template.querySelectorAll('.scheduleDT').forEach(input => {
            if(input.dataset.id === wrapper.detail.Id) currentInput = input;
        });
        if(currentInput && !currentInput.checkValidity()) {
            this.showToast('','Only future date/time are supported!', 'warning');
            return;
        }

        this.spinner.show();
        this.inProcess = true;

        if (wrapper) {
            runBatch({wrapper: JSON.stringify(wrapper)})
                .then((data) => {
                    if(data) {
                        this.waitStateChange(jobName, 'RUNNING,SCHEDULED', this.spinner, () => {
                            this.showToast('', 'Batch launched successfully!', 'success');
                        });
                    } else {
                        this.spinner.hide();
                    }

                })
                .catch(error => {
                    console.log('Error in: handleRun(' + jobName + ') ' + JSON.stringify(error));
                    this.spinner.hide();
                });
        }
    }

    handleStop(event) {
        let jobName = event.target.value;
        this.spinner.show();
        this.inProcess = true;

        stopBatch({jobName: jobName})
            .then(() => {
                this.waitStateChange(jobName, 'STOPPED', this.spinner, () => {
                    this.showToast('', 'Batch stopped successfully!', 'success');
                })
            })
            .catch(error => {
                console.log('Error in: handleStop(' + jobName + ') ' + JSON.stringify(error));
            });
    }

    handleDelete(event) {
        let detailId = event.target.value;
        this.spinner.show();
        this.inProcess = true;

        deleteBatch({detailId: detailId})
            .then(data => {
                this.initPageContent(data);
                this.inProcess = false;
            })
            .catch(error => {
                console.log('Error in deleteBatch. ' + JSON.stringify(error));
            })
            .finally(() => {
                this.spinner.hide();
            });
    }

    handleEditDetail(event) {
        let detailId = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: detailId,
                objectApiName: 'Batch_Detail__c',
                actionName: 'edit'
            },
        });
    }

    //Create Record Handlers: ------------------------------------------------------------------------------------------
    handleClassChange(event) {
        this.batchDetail.Name = event.target.value;
        this.batchDetail.Panel_Label__c = this.batchDetail.Name.substring(6, this.batchDetail.Name.length);
    }

    handleLabelChange(event) {
        this.batchDetail.Panel_Label__c = event.target.value;
    }

    handleModeChange(event) {
        this.batchDetail.Interval_Mode__c = event.target.value;
    }

    handleIntervalChange(event) {
        this.batchDetail.Relaunch_Interval__c = event.target.value;
    }

    handleScopeChange(event) {
        this.batchDetail.Scope_Size__c = event.target.value;
    }

    handleAddBatch(event) {
        if (!this.batchDetail.Name || !this.batchDetail.Panel_Label__c) {
            this.showToast('Failed', 'Please fill required fields');
            return;
        }

        if (!this.batchDetail.Relaunch_Interval__c || this.batchDetail.Relaunch_Interval__c === 0) {
            this.batchDetail.Relaunch_Interval__c = 10;
        }
        if (!this.batchDetail.Scope_Size__c || this.batchDetail.Scope_Size__c === 0) {
            this.batchDetail.Scope_Size__c = 200;
        }

        this.inProcess = true;
        this.spinner.show();

        addBatch({detail: this.batchDetail})
            .then(data => {
                this.initPageContent(data);

                this.inProcess = false;
                this.resetInputFields();
            })
            .catch(error => {
                console.log('Error after add batch. ' + JSON.stringify(error));
            })
            .finally(() => {
                if(this.spinner) this.spinner.hide();
                let modal = this.template.querySelector('c-web-modal');
                if(modal) modal.hide();
                this.showAddNew = this.notAddedBatches.length > 0;
            });
    }

    handleAddJobClick(event) {
        this.batchDetail.Name = this.notAddedBatches[0];
        this.batchDetail.Panel_Label__c = this.batchDetail.Name.substring(6, this.batchDetail.Name.length);

        this.template.querySelector('c-web-modal').show();
    }

    //Service methods: -------------------------------------------------------------------------------------------------
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant === undefined ? 'info' : variant
        });
        this.dispatchEvent(event);
    }

    resetInputFields() {
        this.batchDetail = {
            objectApiName: 'Batch_Detail__c',
            Interval_Mode__c: 'Minutes',
            Relaunch_Interval__c: 10,
            Scope_Size__c: 200
        };
    }

    waitStateChange(jobName, waitedState, spinner, callback) {
        let context = this;

        getState({jobName: jobName})
            .then(wrapper => {
                if (waitedState.indexOf(wrapper.state) !== -1) {
                    let jobList = this.jobs;
                    for (let i = 0; i < jobList.length; i++) {
                        if (jobList[i].detail.Name === jobName) {
                            jobList[i] = wrapper;
                            break;
                        }
                    }
                    this.jobs = jobList;
                    spinner.hide();
                    this.inProcess = false;
                    callback();
                } else {
                    setTimeout(() => {
                        context.waitStateChange(jobName, waitedState, spinner, callback);
                    }, 500);
                }
            });
    }

    initPageContent(data) {
        this.notAddedBatches = data.availableBatches;
        this.showAddNew = this.notAddedBatches.length > 0;
        this.jobMap.clear();

        let context = this;
        data.jobWrappers.forEach(function (jw) {
            let job = {
                css: jw.css,
                detail: jw.detail,
                jobId: jw.jobId,
                prevJob: jw.prevJob,
                prevLaunch: jw.prevLaunch,
                nextLaunch: jw.nextLaunch,
                state: jw.state,
                isStopped: jw.isStopped,
                nextSchedule: null,
                description: jw.description
            };
            context.jobMap.set(job.detail.Id, job);
        });

        if(this.jobMap.size > 0) {
            this.jobs = [];
            this.jobMap.forEach(function (value) {
                context.jobs.push(value);
            });
        }
    }
}