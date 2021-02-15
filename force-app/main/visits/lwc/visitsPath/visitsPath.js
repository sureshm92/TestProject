/**
 * Created by Igor Malyuta on 06.12.2019.
 */

import { LightningElement, track, api } from 'lwc';
//import lwcStyleResource from '@salesforce/resourceUrl/lwcCss';
import { loadStyle } from 'lightning/platformResourceLoader';
import formFactor from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addLabel from '@salesforce/label/c.Add_Date';
import incorrectData from '@salesforce/label/c.Incorrect_data';
import detailsLabel from '@salesforce/label/c.PP_Details';
import saveBTNLabel from '@salesforce/label/c.BTN_Save';
import cancelBTNLabel from '@salesforce/label/c.BTN_Cancel';
import noDateSet from '@salesforce/label/c.PP_NoDateSet';
import emailLabel from '@salesforce/label/c.PP_Remind_Using_Email';
import smsLabel from '@salesforce/label/c.PP_Remind_Using_SMS';
import planDate from '@salesforce/label/c.VPN_AddDate';
import ReminderDate from '@salesforce/label/c.PP_Reminder_Date';
import whatToExpect from '@salesforce/label/c.Home_Page_StudyVisit_WhToEx';
import VisitDate from '@salesforce/label/c.PP_Visit_Date';
import visitDateandTime from '@salesforce/label/c.PP_Visit_DateTime';
import remindMe from '@salesforce/label/c.Remind_Me';
import ChangeNotifications from '@salesforce/label/c.PP_Change_Notification_Settings';
import remindUsing from '@salesforce/label/c.PP_Remind_Using';
import selDate from '@salesforce/label/c.VPN_Sel_Date';
import visitUnavailable from '@salesforce/label/c.Study_Visit_Unavailable';
import CompleteByDate from '@salesforce/label/c.Complete_By_Date';
import Onedaybefore from '@salesforce/label/c.One_day_before';
import OneHourBefore from '@salesforce/label/c.PP_One_Hour_Before';
import FourHoursBefore from '@salesforce/label/c.PP_Four_Hours_Before';
import OneWeekBefore from '@salesforce/label/c.PP_One_Week_Before';
import CustomDate from '@salesforce/label/c.PP_Custom';
import reminderError from '@salesforce/label/c.PP_Reminder_Error_Message';
import reminderUnderFlow from '@salesforce/label/c.PP_Reminder_Underflow';
import reminderOverFlow from '@salesforce/label/c.PP_Reminder_Overflow';
import remindUsingRequired from '@salesforce/label/c.PP_Remind_Using_Required';
import getCardVisits from '@salesforce/apex/ParticipantVisitsRemote.getCardPatientVisits';
import updatePV from '@salesforce/apex/ParticipantVisitsRemote.updatePatientVisit';
import getisRTL from '@salesforce/apex/ParticipantVisitsRemote.getIsRTL';
import getVisitsDetails from '@salesforce/apex/ParticipantVisitsRemote.getParticipantVisitsDetails';
import getTaskEditDetails from '@salesforce/apex/TaskEditRemote.getTaskEditData';
import createTask from '@salesforce/apex/TaskEditRemote.upsertTaskForVisit';

const stateClass = 'slds-col width-basis state ';
const lineClass = 'slds-col width-basis line-div ';
const iconCalendar = 'icon-calendar-3';
const iconMissed = 'icon-minus';
const stateNeutral = 'neutral';
const statePlan = 'planned';
const stateMissed = 'missed';
const stateSucc = 'success';

export default class VisitsPath extends LightningElement {
    labels = {
        addLabel,
        saveBTNLabel,
        cancelBTNLabel,
        selDate,
        planDate,
        CompleteByDate,
        Onedaybefore,
        reminderUnderFlow,
        reminderOverFlow,
        remindUsingRequired,
        ReminderDate,
        VisitDate,
        ChangeNotifications,
        remindUsing,
        whatToExpect,
        emailLabel,
        smsLabel,
        OneHourBefore,
        FourHoursBefore,
        OneWeekBefore,
        CustomDate,
        reminderError,
        detailsLabel,
        incorrectData,
        noDateSet,
        visitDateandTime,
        remindMe
    };

    initialized = false;
    spinner;
    @track showAccountNavigation = false;
    @track isVisitsEmpty = false;
    @track isVisitCompleted = false;
    @track isRTL;
    @track patientVisits;
    @track visits;
    @track pathItems = [];
    @track isLessThanToday = false;
    @track reminderClass = 'mr_50';

    @track selectedPV = {
        Id: null,
        Planned_Date__c: null,
        Status__c: 'Scheduled'
    };
    @track today;
    @track emailOpted;
    @track smsOpted;
    @track planDate = null;
    @track patientVisitName;
    @track visitDetails;
    @track showCustomDateTime = false;
    @track taskDetails;
    @track visitIconDetails = [];
    @track iconDetails = [];
    @track disableSave = true;
    @track isVisitMissed = false;
    @track reRender = true;
    // = [{ "Id": "a0M1100000DDOfGEAX", "Name": "biopsy", "Label__c": "Biopsy" }, { "Id": "a0M1100000DDOfQEAX", "Name": "height-and-weight", "Label__c": "Height and weight" }, { "Id": "a0M1100000DDOfVEAX", "Name": "multiple-users-2", "Label__c": "Demographics" }];
    //= [{ "Id": "a2t3O0000000xQ2QAI", "Name": "biopsy", "Label__c": "Biopsy" }, { "Id": "a2t3O0000000xQ1QAI", "Name": "Hand-X-Ray", "Label__c": "Hand and feet X-rays" }, { "Id": "a2t3O0000000xQ8QAI", "Name": "health_checkup", "Label__c": "Physical examination" }];
    @track visitTaskId;
    @track visitTitle;
    @track visitId;
    @track reminderDate;
    @track completedDate;
    @track showTravelSupportDetails = false;
    @track initData = {
        reminderDate: null,
        emailOptIn: false,
        smsOptIn: false,
        reminderOption: null,
        planDate: null,
        createdByAdmin: false
    };
    @track paramTask = {
        sobjectType: 'Task',
        Task_Type__c: 'Visit',
        Remind_Me__c: null,
        Remind_Using_Email__c: false,
        Remind_Using_SMS__c: false,
        ReminderDateTime: null,
        Subject: null,
        Task_Code__c: null,
        Id: null,
        CronTriggerId__c: null,
        Is_Reminder_Sent__c: false
    };
    @track reminderOption;
    @track emailOptIn;
    @track smsOptIn;
    @track visitNumber;
    pathContainer;
    elementWidth;
    centredIndex;
    maxScrollValue;
    scrollStep;
    nextScrollLeft;
    nextScrollRight;
    fromLeftCorner;
    fromRightCorner;

    connectedCallback() {
        let context = this;
        context.showTravelSupportDetails = false;
        /* Promise.all([
            loadStyle(this, lwcStyleResource)
        ]).then(() => {
            console.log('Files loaded.');
        })
            .catch(error => {
                console.log(error.body.message);
            });*/
        getisRTL()
            .then(function (data) {
                context.isRTL = data;
            })
            .catch(function (error) {
                console.error('Error: ' + JSON.stringify(error));
            });

        getCardVisits()
            .then(function (data) {
                context.patientVisits = data;
                context.isVisitsEmpty = data.length === 0;
                context.constructPathItems();
                context.initialized = true;
            })
            .catch(function (error) {
                console.error('Error: ' + JSON.stringify(error));
            });
    }

    renderedCallback() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (!this.initialized) this.spinner.show();
        switch (formFactor) {
            case 'Medium':
                this.elementWidth = 145;
                break;
            case 'Small':
                this.elementWidth = 250;
                break;
            default:
                this.elementWidth = 125;
        }
        this.pathContainer = this.template.querySelector('.vis-path');
        if (this.pathContainer) {
            this.maxScrollValue = this.pathContainer.scrollWidth - this.pathContainer.clientWidth;
            if (this.pathContainer.scrollWidth > this.pathContainer.clientWidth)
                this.doScrollInto(this.centredIndex);
            let context = this;
            setTimeout(function () {
                if (context.pathItems.length > 0) {
                    context.calculateWidth();

                    window.addEventListener('touchmove', function () {
                        context.changeArrowsStyle();
                    });
                    window.addEventListener('resize', function () {
                        context.calculateWidth();
                    });
                }
            }, 150);
        }

        if (this.initialized) this.spinner.hide();
    }
    get reminderOptions() {
        return [
            { label: this.labels.OneHourBefore, value: '1 hour before' },
            { label: this.labels.FourHoursBefore, value: '4 hours before' },
            { label: this.labels.Onedaybefore, value: '1 day before' }
            { label: this.labels.OneWeekBefore, value: '1 Week before' },
            { label: this.labels.CustomDate, value: 'Custom' }
        ];
    }

    constructPathItems() {
        if (this.patientVisits) {
            let firstPending;
            this.centredIndex = 1;
            for (let i = 0; i < this.patientVisits.length; i++) {
                let isCompleted = this.patientVisits[i].Status__c === 'Completed';
                let isMissed = this.patientVisits[i].Status__c === 'Missed';
                let item = {
                    id: this.patientVisits[i].Id,
                    visitName: this.patientVisits[i].Portal_Name__c
                        ? this.patientVisits[i].Portal_Name__c
                        : this.patientVisits[i].Name,
                    isPending: !isCompleted && !isMissed,
                    icon: isMissed ? iconMissed : iconCalendar,
                    complDate: isCompleted ? this.patientVisits[i].Completed_Date__c : null,
                    planDate:
                        !isMissed && !isCompleted && this.patientVisits[i].Planned_Date__c
                            ? this.patientVisits[i].Planned_Date__c
                            : null,
                    stateStatus: isCompleted ? stateSucc : stateNeutral
                };
                if (isMissed) {
                    item.stateStatus = stateMissed;
                    if (this.patientVisits[i].Planned_Date__c) {
                        item.complDate = this.patientVisits[i].Planned_Date__c;
                    }
                }

                this.pathItems.push(item);
                if (!firstPending && !isCompleted && !isMissed) {
                    firstPending = item;
                    if (this.isRTL) {
                        this.centredIndex = this.patientVisits.length - i;
                    } else {
                        this.centredIndex = i;
                    }
                }
            }
            if (firstPending) {
                firstPending.stateStatus = statePlan;
            }

            for (let i = 0; i < this.pathItems.length; i++) {
                let item = this.pathItems[i];
                item.right =
                    i < this.pathItems.length - 1
                        ? lineClass + this.pathItems[i + 1].stateStatus
                        : lineClass + item.stateStatus;
                item.left = lineClass + item.stateStatus;
                item.state = stateClass + item.stateStatus;
                item.headerTitle = this.pathItems[i].visitName + ' ' + this.labels.detailsLabel;
            }

            console.log('VISIT_ITEMS: ' + JSON.stringify(this.pathItems));
        }
    }

    isEmpty(value) {
        if (value == null || value == undefined || value == '') return true;
        else return false;
    }

    doValidateReminder(event) {
        if (event.target.value != 'Custom' || this.reminderOption != 'Custom') {
            var visitPlanDate = new Date(this.planDate);
            var reminderdate;
            console.log('visitPlanDate-->' + visitPlanDate);
            if (event.target.value == '1 day before' || this.reminderOption == '1 day before') {
                reminderdate = visitPlanDate - 24 * 3600 * 1000;
            } else if (
                event.target.value == '1 hour before' ||
                this.reminderOption == '1 hour before'
            ) {
                reminderdate = visitPlanDate - 3600 * 1000;
            } else if (
                event.target.value == '4 hours before' ||
                this.reminderOption == '4 hours before'
            ) {
                reminderdate = visitPlanDate - 4 * 3600 * 1000;
            } else if (
                event.target.value == '1 Week before' ||
                this.reminderOption == '1 Week before'
            ) {
                reminderdate = visitPlanDate - 7 * 24 * 3600 * 1000;
            }
            console.log('reminderdate-->' + reminderdate);
            var isGreaterThanToday = new Date() > new Date(reminderdate);
            console.log('isGreaterThanToday' + isGreaterThanToday);
            this.isLessThanToday = isGreaterThanToday;
            if (isGreaterThanToday) {
                this.template
                    .querySelector('lightning-combobox')
                    .setCustomValidity(this.labels.reminderError);
                this.template.querySelector('lightning-combobox').reportValidity();
                // this.disableSave = true;
            } else {
                this.template.querySelector('lightning-combobox').setCustomValidity(' ');
                this.template.querySelector('lightning-combobox').reportValidity();
                //this.disableSave = false;
            }
        } else {
            this.template.querySelector('lightning-combobox').setCustomValidity(' ');
            this.template.querySelector('lightning-combobox').reportValidity();
        }
        const allValid = [...this.template.querySelectorAll('lightning-input')].reduce(
            (validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            },
            true
        );

        if (
            this.isEmpty(this.planDate) ||
            !allValid ||
            this.isLessThanToday ||
            (this.isEmpty(this.reminderDate) && this.reminderOption == 'Custom')
        ) {
            this.disableSave = true;
        } else {
            this.disableSave = false;
        }
    }
    //Planned Date Logic:-----------------------------------------------------------------------------------------------
    handleOpenDialog(event) {
        // let spinner = this.template.querySelector('c-web-spinner');
        // console.log('spinner' + spinner);
        // spinner.show();
        //this.doValidateReminder(event);
        this.reRender = true;
        let eventItemId = event.currentTarget.dataset.id;
        this.visitId = eventItemId;

        //this.patientVisitName = event.currentTarget.dataset.name;
        this.patientVisitName = event.currentTarget.dataset.name;
        this.visitTitle = event.currentTarget.dataset.title;
        this.completedDate = event.currentTarget.dataset.completeddate;
        console.log('completedDate-->' + this.completedDate);
        console.log('visiTitle-->' + this.visitTitle);
        //+ ' ' + 'Details';
        console.log('visitname-->' + this.patientVisitName);
        console.log('eventItemId-->' + this.visitId);
        this.getVisitDetails(this.visitId);
        this.selectedPV.Id = this.visitId;
        this.selectedPV.Status__c = 'Scheduled';

        console.log('visitIconDetails-->' + this.visitIconDetails);
        console.log('iconDetails-->' + JSON.stringify(this.iconDetails));
        this.template.querySelector('c-web-popup').show();
    }

    getVisitDetails(itemId) {
        getVisitsDetails({ visitId: itemId })
            .then((result) => {
                console.log('result-->', result);
                const [first] = result;
                this.visitDetails = first;
                this.planDate = this.visitDetails.visit.Planned_Date__c;
                this.reminderDate = this.visitDetails.reminderDate;
                this.visitNumber = this.visitDetails.visit.Visit_Number__c;
                this.showTravelSupportDetails = true;
                console.log('visitnum-->' + this.visitNumber);
                this.isVisitCompleted =
                    this.visitDetails.visitStatus == 'Completed' ||
                    this.visitDetails.visitStatus == 'Missed';
                this.isVisitMissed = this.visitDetails.visitStatus == 'Missed';
                if (this.visitDetails.task) {
                    this.visitTaskId = this.visitDetails.task.Id;
                }
                if (this.visitDetails.task) {
                    if (this.visitDetails.task.Remind_Me__c == 'Custom') {
                        this.showCustomDateTime = true;
                        this.reminderClass = 'mr_25';
                    } else {
                        this.showCustomDateTime = false;
                    }
                }
                if (this.visitDetails.task) {
                    this.reminderOption = this.visitDetails.task.Remind_Me__c;
                    console.log('reminderOption-->' + this.reminderOption);
                    this.emailOptIn = this.visitDetails.task.Remind_Using_Email__c;
                    console.log('emailOptIn-->' + this.emailOptIn);
                    this.smsOptIn = this.visitDetails.task.Remind_Using_SMS__c;
                    console.log('smsOptIn-->' + this.smsOptIn);
                }
                this.getTaskDetails(this.visitTaskId);
                if (this.visitDetails.iconDetails) {
                    console.log(first.iconDetails);
                    this.iconDetails = first.iconDetails;
                    console.log('this.icon-->' + JSON.stringify(this.iconDetails));
                }
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            });
    }
    getTaskDetails(tasksId) {
        getTaskEditDetails({ taskId: tasksId })
            .then((result) => {
                console.log('task-->' + JSON.stringify(result));
                this.taskDetails = result;
                if (this.taskDetails) {
                    this.isEmailEnabled = this.taskDetails.emailOptIn;
                    this.emailOpted = !this.taskDetails.emailOptIn || this.isVisitCompleted;
                    this.smsOpted = !this.taskDetails.smsOptIn || this.isVisitCompleted;
                    this.today = this.taskDetails.today;
                    if (!this.taskDetails.smsOptIn || !this.taskDetails.emailOptIn) {
                        this.showAccountNavigation = true;
                    }
                }
                //this.error = undefined;
            })
            .catch((error) => {
                //this.error = error;
                console.log(JSON.stringify(error));
            });
    }

    handleHideDialog() {
        this.template.querySelector('c-web-popup').hide();
        this.reRender = false;
        //this.reRender = true;
    }
    doNavigateToAccountSettings() {
        window.open('account-settings', '_blank');
        window.focus();
        this.handleHideDialog();
    }

    handleDateChange(event) {
        console.log('inside data change');
        if (event.target.name == 'planDate') {
            this.planDate = event.target.value;
            console.log('this.planDate-->' + this.planDate);
        }
        if (event.target.name == 'reminder') {
            this.reminderOption = event.detail.value;
            console.log('this.reminderOption-->' + this.reminderOption);
        }
        if (this.reminderOption == 'Custom') {
            this.showCustomDateTime = true;
            this.reminderClass = 'mr_25';
        } else {
            this.showCustomDateTime = false;
            this.reminderClass = 'mr_50';
        }
        if (event.target.name == 'emailOptin') {
            this.emailOptIn = event.target.checked;
            console.log('this.emailOptIn-->' + this.emailOptIn);
        }
        if (event.target.name == 'smsOptIn') {
            this.smsOptIn = event.target.checked;
            console.log('this.smsOptIn-->' + this.smsOptIn);
        }
        if (event.target.name == 'reminderDate') {
            this.reminderDate = event.target.value;
            console.log('this.reminderDate-->' + this.reminderDate);
        }
        const allValid = [...this.template.querySelectorAll('lightning-input')].reduce(
            (validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            },
            true
        );
        console.log('allValid-->' + allValid);
        console.log('this.isEmpty(this.planDate)' + this.isEmpty(this.planDate));
        console.log('!allValid' + !allValid);
        console.log('this.isLessThanToday' + this.isLessThanToday);
        console.log('this.isEmpty(this.reminderDate)' + this.isEmpty(this.reminderDate));
        console.log(
            'plan-->' +
                (this.isEmpty(this.planDate) ||
                    !allValid ||
                    this.isLessThanToday ||
                    this.isEmpty(this.reminderDate))
        );
        if (
            this.isEmpty(this.planDate) ||
            !allValid ||
            this.isLessThanToday ||
            this.isEmpty(this.reminderDate)
        ) {
            console.log(
                'plan-->' +
                    (this.isEmpty(this.planDate) ||
                        !allValid ||
                        this.isLessThanToday ||
                        this.isEmpty(this.reminderDate))
            );
            this.disableSave = true;
        } else {
            this.disableSave = false;
        }
    }

    savePlannedDate() {
        let spinner = this.template.querySelector('c-web-spinner');
        spinner.show();
        console.log('planDate-->' + this.planDate);
        if (this.showCustomDateTime == true) {
            if (
                this.isEmpty(this.reminderDate) &&
                this.emailOptIn == false &&
                this.smsOptIn == false
            ) {
                communityService.showErrorToast('', this.labels.incorrectData, 3000);
                return;
            }
        }
        if (this.reminderOption) {
            if (this.emailOptIn == false && this.smsOptIn == false) {
                communityService.showErrorToast('', this.labels.remindUsingRequired, 3000);
                return;
            }
        }

        if (this.planDate) this.selectedPV.Planned_Date__c = this.planDate;
        else this.selectedPV.Planned_Date__c = null;
        if (this.reminderDate) this.initData.reminderDate = this.reminderDate;
        if (this.emailOptIn) this.initData.emailOptIn = this.emailOptIn;
        if (this.smsOptIn) this.initData.smsOptIn = this.smsOptIn;
        if (this.reminderOption) this.initData.reminderOption = this.reminderOption;
        if (this.planDate) this.initData.planDate = this.planDate;
        if (this.visitId) this.initData.visitId = this.visitId;
        this.initData.createdByAdmin = this.taskDetails.createdByAdmin;
        console.log('inside initData-->', this.initData);
        //  if (this.reminderOption) {
        console.log('inside this.reminderOption-->' + this.reminderOption);

        // }
        if (this.emailOptIn) this.paramTask.Remind_Using_Email__c = this.emailOptIn;
        if (this.smsOptIn) this.paramTask.Remind_Using_SMS__c = this.smsOptIn;
        if (this.reminderDate) this.paramTask.ReminderDateTime = this.reminderDate;
        this.paramTask.Subject = this.patientVisitName;
        console.log('visitTaskId-->' + this.visitTaskId);
        if (this.visitTaskId) this.paramTask.Id = this.visitTaskId;
        console.log('paramTask-->' + JSON.stringify(this.paramTask));

        let context = this;
        updatePV({ visit: JSON.stringify(this.selectedPV) })
            .then(() => {
                let tmpItems = [];
                context.pathItems.forEach((item) => {
                    let tmpItem = item;
                    if (item.id === context.selectedPV.Id) tmpItem.planDate = context.planDate;

                    tmpItems.push(tmpItem);
                });
                context.pathItems = tmpItems;
                spinner.hide();
            })
            .catch((error) => {
                console.log('Error: ' + JSON.stringify(error));
            });
        // if (this.reminderOption) {
        createTask({
            wrapper: JSON.stringify(this.initData),
            paramTask: JSON.stringify(this.paramTask)
        })
            .then(() => {
                console.log('inside success-->');
                eval("$A.get('e.force:refreshView').fire();");
                spinner.hide();
            })
            .catch((error) => {
                let message = 'Unknown error';
                if (error.body) {
                    if (Array.isArray(error.body)) {
                        console.log('isnide aaray');
                        message = error.body.map((e) => e.message).join(', ');
                    } else if (typeof error.body.message === 'string') {
                        console.log('isnide strunf');
                        message = error.body.message;
                        if (message.includes('\n')) {
                            message = message.split('\n')[0];
                        }
                    }
                } else {
                    console.log('isnide else');
                    message = error.message;
                }
                const event = new ShowToastEvent({
                    title: '',
                    message: message,
                    variant: 'error'
                });
                this.dispatchEvent(event);

                console.log('Error: ' + JSON.stringify(error));
            });
        this.handleHideDialog();
        spinner.hide();

        //}
    }

    //Scroll Arrows handlers:-------------------------------------------------------------------------------------------
    handleScrollLeft() {
        if (this.fromRightCorner) {
            this.fromRightCorner = false;
            this.pathContainer.scrollLeft -= this.nextScrollLeft;
        } else {
            this.pathContainer.scrollLeft -= this.nextScrollLeft;
        }

        let context = this;
        setTimeout(function () {
            context.nextScrollLeft = context.scrollStep;
            context.changeArrowsStyle();
        }, 450);
    }

    handleScrollRight() {
        if (this.fromLeftCorner) {
            this.doScrollInto(formFactor === 'Large' ? 4 : 2);
            this.nextScrollLeft = this.scrollStep;
            this.fromLeftCorner = false;
        } else {
            this.pathContainer.scrollLeft += this.nextScrollRight;
        }

        let context = this;
        setTimeout(function () {
            context.nextScrollRight = context.scrollStep;
            context.changeArrowsStyle();
        }, 450);
    }

    handleScrollLeftRTL() {
        if (this.fromLeftCorner) {
            this.fromLeftCorner = false;
        } else if (this.fromRightCorner) {
            this.nextScrollLeft = this.scrollStep;
            this.pathContainer.scrollLeft -= this.nextScrollLeft;
            this.fromRightCorner = false;
        } else {
            this.pathContainer.scrollLeft -= this.nextScrollLeft;
        }

        let context = this;
        setTimeout(function () {
            context.changeArrowsStyle();
        }, 450);
    }

    handleScrollRightRTL() {
        this.pathContainer.scrollLeft += this.nextScrollLeft;

        let context = this;
        setTimeout(function () {
            context.nextScrollRight = context.scrollStep;
            context.fromLeftCorner = false;
            context.changeArrowsStyle();
        }, 600);
    }

    //Scroll logic:-----------------------------------------------------------------------------------------------------
    calculateWidth() {
        this.scrollStep = this.elementWidth;
        this.nextScrollLeft = this.scrollStep;
        this.nextScrollRight = this.scrollStep;
        if (this.pathContainer.scrollWidth > this.pathContainer.clientWidth) {
            this.changeArrowsStyle();
        }
    }

    isLeftScrollEnd() {
        if (this.isRTL) {
            return this.maxScrollValue - Math.abs(Math.ceil(this.pathContainer.scrollLeft)) <= 2;
        } else {
            return this.pathContainer.scrollLeft === 0;
        }
    }

    isRightScrollEnd() {
        if (this.isRTL) {
            return this.pathContainer.scrollLeft === 0;
        } else {
            return this.maxScrollValue <= Math.ceil(this.pathContainer.scrollLeft);
        }
    }

    changeArrowsStyle() {
        let arrLeft = 1;
        let arrRight = 1;
        let arrLeftRTL = 1;
        let arrRightRTL = 1;

        if (this.isRightScrollEnd()) {
            arrRight = 0.3;
            arrRightRTL = 0.3;
            this.fromRightCorner = true;
        }
        if (this.isLeftScrollEnd()) {
            arrLeftRTL = 0.3;
            arrLeft = 0.3;
            this.fromLeftCorner = true;
        }

        if (this.isRTL) {
            this.template.querySelector('.arrow-leftRTL').style.opacity = arrRightRTL;
            this.template.querySelector('.arrow-rightRTL').style.opacity = arrLeftRTL;
        } else {
            this.template.querySelector('.arrow-left').style.opacity = arrLeft;
            this.template.querySelector('.arrow-right').style.opacity = arrRight;
        }
    }

    checkCloserIsNeeded(context) {
        if (
            context.maxScrollValue - (context.pathContainer.scrollLeft + context.nextScrollRight) <
            context.scrollStep / 2
        ) {
            context.nextScrollRight = context.maxScrollValue;
        }
        if (context.pathContainer.scrollLeft - context.nextScrollLeft < context.scrollStep / 2) {
            context.nextScrollLeft = context.maxScrollValue;
        }
    }

    doScrollInto(index) {
        this.pathContainer.scrollLeft =
            index * this.elementWidth - this.elementWidth / 2 - this.pathContainer.clientWidth / 2;
    }

    addADay(paramDate) {
        paramDate = moment(paramDate, 'YYYY-MM-DD').add(1, 'days');
        return paramDate.format('YYYY-MM-DD');
    }
}
