import { LightningElement, api, track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import moment from '@salesforce/resourceUrl/moment_js';
import momentTZ from '@salesforce/resourceUrl/momenttz';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';
//static resources
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import COMETD_LIB from '@salesforce/resourceUrl/cometd';
import getTaskEditData from '@salesforce/apex/TaskEditRemote.getTaskEditData';
import getSessionId from '@salesforce/apex/TelevisitMeetBannerController.getSessionId';
import checkEmailSMSPreferencesForPPTask from '@salesforce/apex/TaskEditRemote.checkEmailSMSPreferencesForPPTask';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import REMINDER from '@salesforce/label/c.Remind_Me';
import SELECT_REMINDER from '@salesforce/label/c.PP_SELECT_REMINDER';
import ONE_HOUR from '@salesforce/label/c.PP_One_Hour_Before';
import FOUR_HOUR from '@salesforce/label/c.PP_Four_Hours_Before';
import ONE_DAY from '@salesforce/label/c.One_day_before';
import ONE_WEEK from '@salesforce/label/c.PP_One_Week_Before';
import CUSTOM from '@salesforce/label/c.PP_Custom';
import PP_NO_REMINDER from '@salesforce/label/c.PP_NO_REMINDER';
import REMIND_USING from '@salesforce/label/c.PP_Remind_Using';
import EMAIL from '@salesforce/label/c.Email';
import SMS_TEXT_MESSAGE from '@salesforce/label/c.PP_SMSTexMessage';
import PP_TASK_COMM_PREF from '@salesforce/label/c.PP_TASK_COMM_PREF';

export default class PpCreateTaskReminder extends LightningElement {
    @api taskDueDate;
    @api taskDueTime;
    @api taskDueDateTime;
    @api isTaskDueDateTimeSelected = false;
    @api taskId;
    @api initData;
    @api currentDate;
    @api currentTime;
    @api isRTL = false;
    @api isMobile = false;
    @api taskInfo;

    isInitialized = false;
    spinner;
    /**Platform Event */
    cometd;
    subscription;
    channel = '/event/Communication_Preference_Change__e';

    selectedReminderOption;
    selectedReminderDate;
    selectedReminderDateTime;
    isEmailReminderDisabled = false;
    isSMSReminderDisabled = false;
    smsReminderOptIn = false;
    emailReminderOptIn = false;

    taskCodeList = ['Complete_Your_Profile', 'Update_Your_Phone_Number', 'Select_COI'];
    businessTask = false;
    systemTask = false;
    labels = {
        ERROR_MESSAGE,
        REMINDER,
        SELECT_REMINDER,
        ONE_HOUR,
        FOUR_HOUR,
        ONE_DAY,
        ONE_WEEK,
        CUSTOM,
        PP_NO_REMINDER,
        REMIND_USING,
        EMAIL,
        SMS_TEXT_MESSAGE,
        PP_TASK_COMM_PREF
    };
    @track initialReminderOptions = [
        {
            label: this.labels.ONE_HOUR,
            value: '1 hour before',
            itemClass: 'dropdown-li li-item-disabled'
        },
        {
            label: this.labels.FOUR_HOUR,
            value: '4 hours before',
            itemClass: 'dropdown-li li-item-disabled'
        },
        {
            label: this.labels.ONE_DAY,
            value: '1 day before',
            itemClass: 'dropdown-li li-item-disabled'
        },
        {
            label: this.labels.ONE_WEEK,
            value: '1 week before',
            itemClass: 'dropdown-li li-item-disabled'
        },
        { label: this.labels.CUSTOM, value: 'Custom', itemClass: 'dropdown-li' }
    ];
    @api editMode = false;

    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                Promise.all([
                    loadScript(this, COMETD_LIB),
                    loadScript(this, moment),
                    loadScript(this, momentTZ)
                ])
                    .then(() => {
                        this.spinner = this.template.querySelector('c-web-spinner');
                        this.loadSessionId();
                        if (!this.initData) {
                            this.initializeData();
                        } else {
                            this.isEmailReminderDisabled = !this.initData.emailOptIn;
                            this.isSMSReminderDisabled = !this.initData.smsOptIn;
                            if (this.taskInfo) {
                                this.taskInfo = JSON.parse(JSON.stringify(this.taskInfo));
                                this.taskId = this.taskInfo.Id;
                                this.systemTask =
                                    this.taskInfo.Originator__c != 'Participant'
                                        ? this.taskCodeList.includes(this.taskInfo.Task_Code__c)
                                        : false;
                                this.businessTask =
                                    this.taskInfo.Originator__c != 'Participant'
                                        ? !this.systemTask
                                        : false;
                                this.emailReminderOptIn = this.initData.task.Remind_Using_Email__c;
                                this.smsReminderOptIn = this.initData.task.Remind_Using_SMS__c;
                                if (this.systemTask) {
                                    this.selectedReminderOption = 'Custom';
                                } else {
                                    this.selectedReminderOption = this.initData.task.Remind_Me__c;
                                }
                                this.selectedReminderDate = this.initData.reminderDate;
                                this.selectedReminderDateTime = this.initData.reminderDate;
                            }
                            this.handleCommPrefChange();
                            this.isInitialized = true;
                        }
                    })
                    .catch((error) => {
                        console.log(error);
                    });
            })
            .catch((error) => {
                this.showToast(error.message, error.message, 'error');
            });
    }

    get reminderOptions() {
        try {
            let differenceTimeHours = this.calculateTimezoneDifference();
            if (!this.systemTask) {
                if (differenceTimeHours > 1) {
                    this.initialReminderOptions[0].itemClass = 'dropdown-li';
                } else {
                    this.initialReminderOptions[0].itemClass = 'dropdown-li li-item-disabled';
                }
                if (differenceTimeHours > 4) {
                    this.initialReminderOptions[1].itemClass = 'dropdown-li';
                } else {
                    this.initialReminderOptions[1].itemClass = 'dropdown-li li-item-disabled';
                }
                if (differenceTimeHours > 24) {
                    this.initialReminderOptions[2].itemClass = 'dropdown-li';
                } else {
                    this.initialReminderOptions[2].itemClass = 'dropdown-li li-item-disabled';
                }
                if (differenceTimeHours > 168) {
                    this.initialReminderOptions[3].itemClass = 'dropdown-li';
                } else {
                    this.initialReminderOptions[3].itemClass = 'dropdown-li li-item-disabled';
                }
            }
            if (this.systemTask) {
                if (this.initialReminderOptions.length > 1) {
                    let customOption = this.initialReminderOptions[4];
                    this.initialReminderOptions = [];
                    this.initialReminderOptions.push(customOption);
                }
                this.selectedReminderOption = 'Custom';
                this.handleReminderDataChange();
            }
            return this.initialReminderOptions;
        } catch (e) {
            console.error(e);
        }
    }

    get isDisabledOptions() {
        return this.systemTask ? true : true;
    }

    get minimumReminderTime() {
        let currentDateTime = new Date().toLocaleString('en-US', {
            timeZone: TIME_ZONE
        });
        let currentDateTimeObject = new Date(currentDateTime);
        let currentDateTimeString = [
            currentDateTimeObject.getFullYear(),
            ('0' + (currentDateTimeObject.getMonth() + 1)).slice(-2),
            ('0' + currentDateTimeObject.getDate()).slice(-2)
        ].join('-');
        let hh = String(
            (currentDateTimeObject.getHours() < 10 ? '0' : '') + currentDateTimeObject.getHours()
        );
        let mm = String(
            (currentDateTimeObject.getMinutes() < 10 ? '0' : '') +
                currentDateTimeObject.getMinutes()
        );
        let ss = String(
            (currentDateTimeObject.getSeconds() < 10 ? '0' : '') +
                currentDateTimeObject.getSeconds()
        );
        this.currentTime = hh + ':' + mm + ':' + ss;
        return this.selectedReminderDate == currentDateTimeString ? this.currentTime : null;
    }

    get maximumReminderTime() {
        let taskDueDateTime = new Date(this.taskDueDateTime).toLocaleString('en-US', {
            timeZone: TIME_ZONE
        });
        let taskDueDateTimeObject = new Date(taskDueDateTime);
        if (this.taskInfo) {
            let taskReminderDateTim = new Date(this.selectedReminderDate).toLocaleString('en-US', {
                timeZone: TIME_ZONE
            });
            let taskReminderDateTimeObject = new Date(taskReminderDateTim);
            if (!isNaN(taskDueDateTimeObject.valueOf())) {
                this.selectedReminderDate = this.getDateFromDateTime(taskReminderDateTimeObject);
            }
        }
        if (!isNaN(taskDueDateTimeObject.valueOf())) {
            let taskDueDateTimeString = [
                taskDueDateTimeObject.getFullYear(),
                ('0' + (taskDueDateTimeObject.getMonth() + 1)).slice(-2),
                ('0' + taskDueDateTimeObject.getDate()).slice(-2)
            ].join('-');
            return this.selectedReminderDate == taskDueDateTimeString ? this.taskDueTime : null;
        } else {
            return this.taskDueDateTime;
        }
    }

    get isReminderOptionSelected() {
        return !this.selectedReminderOption || this.selectedReminderOption == 'No reminder'
            ? false
            : true;
    }

    get isCustomReminderOptionSelected() {
        return this.selectedReminderOption == 'Custom' ? true : false;
    }

    get isReminderDisabled() {
        if (this.taskInfo) return false;
        return this.isTaskDueDateTimeSelected ? false : true;
    }

    get dbreminderdate() {
        if (this.selectedReminderDate) {
            return this.selectedReminderDate;
        } else {
            return null;
        }
    }

    get dbremindertime() {
        if (this.selectedReminderDateTime) {
            return this.selectedReminderDateTime;
        } else {
            return null;
        }
    }

    loadSessionId() {
        getSessionId()
            .then((sessionId) => {
                this.cometd = new window.org.cometd.CometD();
                this.cometd.configure({
                    url:
                        window.location.protocol +
                        '//' +
                        window.location.hostname +
                        '/cometd/49.0/',
                    requestHeaders: { Authorization: 'OAuth ' + sessionId },
                    appendMessageTypeToURL: false
                });
                this.cometd.websocketEnabled = false;
                this.cometd.handshake((status) => {
                    if (status.successful) {
                        this.subscription = this.cometd.subscribe(this.channel, (message) => {
                            this.handleCommPrefChange();
                        });
                    } else {
                        this.showToast(status, status, 'error');
                    }
                });
            })
            .catch((error) => {
                let message = error.message || error.body.message;
                this.showToast(message, message, 'error');
            });
    }

    initializeData() {
        this.spinner.show();
        getTaskEditData({ taskId: this.taskId })
            .then((result) => {
                let initialData = result;
                this.handleCommPrefChange();
                this.isEmailReminderDisabled = !initialData.emailOptIn;
                this.isSMSReminderDisabled = !initialData.smsOptIn;
                this.emailReminderOptIn = this.isEmailReminderDisabled
                    ? false
                    : this.emailReminderOptIn;
                this.smsReminderOptIn = this.isSMSReminderDisabled ? false : this.smsReminderOptIn;
                this.handleReminderDataChange();
                this.isInitialized = true;
                this.spinner.hide();
            })
            .catch((error) => {
                this.showToast('', error.message, 'error');
            });
    }

    handleReminderOptionChange(event) {
        this.selectedReminderOption = event.detail;
        if (this.selectedReminderOption == 'No reminder') {
            this.selectedReminderDateTime = '';
            this.smsReminderOptIn = false;
            this.emailReminderOptIn = false;
            this.handleReminderDataChange();
        } else {
            this.handleReminderDataChange();
        }
    }

    handleReminderDate(event) {
        this.selectedReminderDate = event.detail.compdate;
        this.selectedReminderDateTime = event.detail.compdatetime;
        if (this.selectedReminderDateTime) {
            this.handleReminderDataChange();
        }
    }

    handleReminderTime(event) {
        this.selectedReminderDate = event.detail.compdate;
        this.selectedReminderDateTime = event.detail.compdatetime;
        if (this.selectedReminderDateTime) {
            this.handleReminderDataChange();
        }
    }
    handleNullTimeReminder(event) {
        this.selectedReminderDateTime = event.detail.comptime;
        this.handleReminderDataChange();
    }

    handleOnlyDate(event) {
        this.selectedReminderDate = event.detail.compdate;
        if (this.selectedReminderDateTime) {
            this.handleReminderDataChange();
        }
    }

    handleOnlyTime(event) {
        this.selectedReminderDateTime = event.detail.compdatetime;
        if (this.selectedReminderDateTime) {
            this.handleReminderDataChange();
        }
    }

    handleNullDateTimeReminder(event) {
        this.selectedReminderDate = '';
        this.selectedReminderDateTime = '';
        this.handleReminderDataChange();
    }

    handleEmailReminder(event) {
        this.emailReminderOptIn = event.target.checked;
        this.handleReminderDataChange();
    }

    handleReminderDataChange() {
        if (this.selectedReminderOption == 'Custom') {
            this.handleCustomEvent(
                'customreminderdata',
                this.selectedReminderOption,
                this.selectedReminderDateTime
            );
        } else {
            this.handleCustomEvent('reminderdata', this.selectedReminderOption, '');
        }
    }
    handleSMSReminder(event) {
        this.smsReminderOptIn = event.target.checked;
        this.handleReminderDataChange();
    }

    calculateTimezoneDifference() {
        let currentUserTime = new Date().toLocaleString('en-US', { timeZone: TIME_ZONE });
        let taskDueDateTime = new Date(this.taskDueDateTime).toLocaleString('en-US', {
            timeZone: TIME_ZONE
        });
        let differenceTimeHours = (new Date(taskDueDateTime) - new Date(currentUserTime)) / 3600000;

        return differenceTimeHours;
    }

    @api
    handleDueDateChange() {
        if (!this.taskInfo) {
            this.selectedReminderOption = '';
            this.selectedReminderDate = '';
            this.selectedReminderDateTime = '';
            this.smsReminderOptIn = false;
            this.emailReminderOptIn = false;
        }
    }

    handleCustomEvent(eventName, reminderType, reminderDateTime) {
        let reminderEvent = new CustomEvent(eventName, {
            detail: {
                reminderType: reminderType,
                reminderDateTime: reminderDateTime,
                emailReminderOptIn: this.emailReminderOptIn,
                smsReminderOptIn: this.smsReminderOptIn
            }
        });
        this.dispatchEvent(reminderEvent);
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
    getDateFromDateTime(dateTimeObj) {
        let dbCompDate = new Date(dateTimeObj);
        let localtimezonedate = dbCompDate.toLocaleString('en-US', { timeZone: TIME_ZONE });
        let processlocaltimezonedate = new Date(localtimezonedate);
        let dd = String(processlocaltimezonedate.getDate()).padStart(2, '0');
        let mm = String(processlocaltimezonedate.getMonth() + 1).padStart(2, '0');
        let yyyy = processlocaltimezonedate.getFullYear();
        return yyyy + '-' + mm + '-' + dd;
    }
    handleCommPrefChange() {
        this.spinner.show();
        checkEmailSMSPreferencesForPPTask({ taskId: this.taskId })
            .then((consentData) => {
                this.isEmailReminderDisabled = !consentData.emailConsent;
                this.isSMSReminderDisabled = !consentData.smsConsent;
                this.emailReminderOptIn = this.isEmailReminderDisabled
                    ? false
                    : this.emailReminderOptIn;
                this.smsReminderOptIn = this.isSMSReminderDisabled ? false : this.smsReminderOptIn;
                this.spinner.hide();
            })
            .catch((error) => {
                console.error(error);
            });
    }
}
