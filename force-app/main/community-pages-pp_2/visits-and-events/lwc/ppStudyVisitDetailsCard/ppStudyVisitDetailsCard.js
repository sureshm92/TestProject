import { LightningElement, api, track, wire } from 'lwc';
import moment from '@salesforce/resourceUrl/moment_js';
import momentTZ from '@salesforce/resourceUrl/momenttz';
import COMETD_LIB from '@salesforce/resourceUrl/cometd';
import getSessionId from '@salesforce/apex/TelevisitMeetBannerController.getSessionId';
import { loadScript } from 'lightning/platformResourceLoader';
import recheckOptIns from '@salesforce/apex/TaskEditRemote.checkSmsEmailOptIn';
import updatePatientVisits from '@salesforce/apex/TaskEditRemote.updatePatientVisits';
import createTask from '@salesforce/apex/TaskEditRemote.upsertTaskForVisit';
import deleteReminder from '@salesforce/apex/TaskEditRemote.deleteReminder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DEVICE from '@salesforce/client/formFactor';
import USER_ID from '@salesforce/user/Id';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import date from '@salesforce/label/c.TV_TH_Date';
import location from '@salesforce/label/c.SS_Location';
import reminder from '@salesforce/label/c.Home_Page_StudyVisit_Reminder';
import PREFERENCES from '@salesforce/label/c.PP_TASK_COMM_PREF';
import saveChanges from '@salesforce/label/c.BTN_Save';
import REMIND_ME from '@salesforce/label/c.Remind_Me';
import discard from '@salesforce/label/c.BTN_Cancel';
import selectreminder from '@salesforce/label/c.Select_reminder';
import email from '@salesforce/label/c.Email';
import sms from '@salesforce/label/c.SMS_Text';
import onehour from '@salesforce/label/c.PP_One_Hour_Before';
import fourhour from '@salesforce/label/c.PP_Four_Hours_Before';
import oneday from '@salesforce/label/c.One_day_before';
import oneweek from '@salesforce/label/c.PP_One_Week_Before';
import none from '@salesforce/label/c.PP_None';
import custom from '@salesforce/label/c.PP_Custom';
import visitdetailsupdated from '@salesforce/label/c.Visit_details_updated_successfully';
import eventdetailsupdated from '@salesforce/label/c.Event_details_updated_successfully';

export default class PpStudyVisitDetailsCard extends LightningElement {
    label = {
        date,
        location,
        reminder,
        PREFERENCES,
        saveChanges,
        discard,
        selectreminder,
        email,
        sms,
        onehour,
        fourhour,
        oneday,
        oneweek,
        custom,
        visitdetailsupdated,
        eventdetailsupdated,
        none,
        REMIND_ME
    };

    @api visitid;
    @api isinitialvisit;
    @api taskid;
    @api visitdata;
    @api tasksubject;
    @api remindmepub;
    @api url;
    @api siteaddress;
    @api sitename;
    @api sitephone;
    @api past;
    @api isevent;
    @track todaydate;
    @track todaytime;
    @track calculatedDate;
    @track visitDate;
    @track visitTime;
    @track selectedReminderDate;
    @track selectedReminderTime;
    @track selectedReminderDateTime;
    @track emailOptIn = false;
    @track smsOptIn = false;
    @track email;
    @track sms;
    @track date;
    @track reminderDateChanged = false;
    @track visitDateChanged = false;
    @track reminderChanged = false;
    @track visitDateTime;
    @track disableButtonSaveCancel = true;
    @track showreminderdatepicker = false;
    @track diffInMinutes;
    @track currentBrowserTime;
    @track communicationChanged = false;
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
    booleanFalse = false;
    booleanTrue = true;
    spinner;
    desktop = true;
    communicationTab = '_blank';

    /**Platform Event */
    cometd;
    subscription;
    channel = '/event/Communication_Preference_Change__e';

    connectedCallback() {
        if (DEVICE != 'Small') {
            this.desktop = true;
        } else {
            this.desktop = false;
            this.communicationTab = '_self';
        }
        loadScript(this, COMETD_LIB).then(() => {
            loadScript(this, moment).then(() => {
                loadScript(this, momentTZ).then(() => {
                    this.currentBrowserTime = window.moment();
                    var localOffset = this.currentBrowserTime.utcOffset();
                    var userTime = this.currentBrowserTime.tz(TIME_ZONE);
                    var centralOffset = userTime.utcOffset();
                    this.diffInMinutes = centralOffset - localOffset;
                    this.initializeData(true);
                });
            });
        });
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
                            let refreshRequired = message.data.payload.Payload__c.includes(USER_ID);
                            if (refreshRequired) {
                                this.initializeData(false);
                            }
                        });
                    } else {
                        this.showToast(status, status, 'error');
                    }
                });
            })
            .catch((error) => {
                let message = error.body.message || error.body.message;
                this.showErrorToast(message, message, 'error');
            });
    }

    initializeData(isInitial) {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner != null && this.spinner != undefined) {
            this.spinner.show();
        }
        recheckOptIns()
            .then((result) => {
                let initialData = result[0];
                this.emailOptIn = !initialData.Permit_Mail_Email_contact_for_this_study__c;
                this.smsOptIn = !initialData.Permit_SMS_Text_for_this_study__c;
                this.email = this.emailOptIn ? false : this.email;
                this.sms = this.smsOptIn ? false : this.sms;
                if (!(this.sms || this.email)) {
                    this.disableButtonSaveCancel = true;
                }
                if (this.spinner != null && this.spinner != undefined) {
                    this.spinner.hide();
                }
                if (isInitial) {
                    this.loadSessionId();
                }
            })
            .catch((error) => {
                this.showToast('', error.body.message, 'error');
            });
    }
    @api
    callFromParent() {
        this.visitDate = '';
        this.visitTime = '';
        this.visitDateTime = '';
        this.remindmepub = '';
        this.showreminderdatepicker = false;
        this.visitDateChanged = false;
        this.sms = false;
        this.email = false;
        this.communicationChanged = false;
        this.disableButtonSaveCancel = true;
        this.template.querySelector('[data-id="visitDateTime"]').callFromParent();
        this.template.querySelector('[data-id="reminderDateTime"]').callFromParent();
    }

    get dbreminderdate() {
        if (
            this.visitdata.task.Reminder_Date__c &&
            !this.visitDateChanged &&
            !this.reminderDateChanged
        ) {
            this.selectedReminderDateTime = this.visitdata.task.Reminder_Date__c;
            var reminderDate = this.visitdata.task.Reminder_Date__c;
            return reminderDate;
        } else if (this.selectedReminderDateTime) {
            return this.selectedReminderDateTime;
        } else {
            return null;
        }
    }

    get dbremindertime() {
        if (
            this.visitdata.task.Reminder_Date__c &&
            !this.visitDateChanged &&
            !this.reminderDateChanged
        ) {
            var reminderTime = this.visitdata.task.Reminder_Date__c;
            return reminderTime;
        } else if (this.selectedReminderDateTime) {
            return this.selectedReminderDateTime;
        } else {
            return null;
        }
    }

    get compDate() {
        if (this.visitdata.visitDate && !this.visitDateChanged) {
            this.visitDateTime = this.visitdata.visitDate;
            var visitDate = this.visitdata.visitDate;
            return visitDate;
        } else if (this.visitDateTime) {
            return this.visitDateTime;
        } else {
            return null;
        }
    }

    get compTime() {
        if (this.visitdata.visitDate) {
            var visitTime = this.visitdata.visitDate;
            return visitTime;
        } else if (this.visitDateTime) {
            return this.visitDateTime;
        } else {
            return null;
        }
    }

    handleInitialDateLoad(event) {
        this.visitDate = event.detail.compdate;
    }

    handleInitialTimeLoad(event) {
        this.visitTime = event.detail.comptime;
    }

    handleInitialReminderDateLoad(event) {
        this.selectedReminderDate = event.detail.compdate;
    }

    handleInitialReminderTimeLoad(event) {
        this.selectedReminderTime = event.detail.comptime;
    }

    get disableDiscard() {
        if (this.visitDateChanged || this.reminderChanged || this.reminderDateChanged) {
            return false;
        } else {
            return true;
        }
    }

    get dbCompletedDate() {
        if (this.visitdata.visitStatus == 'Missed') {
            return null;
        } else if (this.visitdata.visit.Completed_Date__c) {
            var completedDate, completedTime;
            var dbvisitDate = new Date(this.visitdata.visit.Completed_Date__c);
            var localtimezonedate = dbvisitDate.toLocaleString('en-US', { timeZone: TIME_ZONE });
            var processlocaltimezonedate = new Date(localtimezonedate);
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
            completedTime = hh + ':' + mm + ':' + ss;
            var dd = String(processlocaltimezonedate.getDate()).padStart(2, '0');
            var mm = String(processlocaltimezonedate.getMonth() + 1).padStart(2, '0');
            var yyyy = processlocaltimezonedate.getFullYear();
            completedDate = yyyy + '-' + mm + '-' + dd;
            return completedDate;
        } else {
            return null;
        }
    }

    get showReminders() {
        if (this.visitDate && this.visitTime) {
            let currentUserTime = new Date().toLocaleString('en-US', { timeZone: TIME_ZONE });
            let taskDueDateTime = new Date(this.visitDateTime).toLocaleString('en-US', {
                timeZone: TIME_ZONE
            });
            if (new Date(taskDueDateTime) < new Date(currentUserTime)) {
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
    }

    get maxReminderTime() {
        if (this.selectedReminderDate == this.visitDate) {
            if (this.visitTime) {
                return this.visitTime;
            } else {
                return null;
            }
        } else {
            return null;
        }
    }

    get minReminderTime() {
        if (this.todaydate == this.selectedReminderDate) {
            return this.todaytime;
        } else {
            return null;
        }
    }

    get showEmailSms() {
        if (!this.communicationChanged) {
            if (this.emailOptIn) {
                this.email = false;
            } else {
                this.email = this.visitdata.task
                    ? this.visitdata.task.Remind_Using_Email__c
                    : false;
            }
            if (this.smsOptIn) {
                this.sms = false;
            } else {
                this.sms = this.visitdata.task ? this.visitdata.task.Remind_Using_SMS__c : false;
            }
            this.communicationChanged = true;
        }
        if (this.remindmepub && this.remindmepub !== this.label.none) {
            return true;
        } else if (this.remindmepub === this.label.none) {
            return false;
        } else {
            return false;
        }
    }

    get dbReminderOption() {
        if (this.remindmepub) {
            if (this.remindmepub == this.label.custom) {
                this.showreminderdatepicker = true;
            }
            return this.remindmepub;
        } else if (
            this.visitdata.task &&
            this.visitdata.task.Remind_Me__c &&
            !this.reminderChanged
        ) {
            this.remindmepub = this.visitdata.task.Remind_Me__c;
            if (this.remindmepub == this.label.custom) {
                this.showreminderdatepicker = true;
            }
            return this.remindmepub;
        } else if (!this.remindmepub) {
            this.remindmepub = '';
            this.showreminderdatepicker = false;
            return null;
        } else {
            this.remindmepub = '';
            this.showreminderdatepicker = false;
        }
    }

    @track initialReminderOptions = [
        { label: this.label.none, value: 'No reminder', itemClass: 'dropdown-li' },
        {
            label: this.label.onehour,
            value: '1 hour before',
            itemClass: 'dropdown-li'
        },
        {
            label: this.label.fourhour,
            value: '4 hours before',
            itemClass: 'dropdown-li'
        },
        {
            label: this.label.oneday,
            value: '1 day before',
            itemClass: 'dropdown-li'
        },
        {
            label: this.label.oneweek,
            value: '1 week before',
            itemClass: 'dropdown-li'
        },
        { label: this.label.custom, value: 'Custom', itemClass: 'dropdown-li' }
    ];

    get reminderOptions() {
        let differenceTimeHours = this.calculateTimezoneDifference();
        let updatedReminderOptions = [];
        if (this.remindmepub) {
            updatedReminderOptions = [...updatedReminderOptions, this.initialReminderOptions[0]];
        }
        if (differenceTimeHours > 1) {
            updatedReminderOptions = [...updatedReminderOptions, this.initialReminderOptions[1]];
        }
        if (differenceTimeHours > 4) {
            updatedReminderOptions = [...updatedReminderOptions, this.initialReminderOptions[2]];
        }
        if (differenceTimeHours > 24) {
            updatedReminderOptions = [...updatedReminderOptions, this.initialReminderOptions[3]];
        }
        if (differenceTimeHours > 168) {
            updatedReminderOptions = [...updatedReminderOptions, this.initialReminderOptions[4]];
        }
        updatedReminderOptions = [...updatedReminderOptions, this.initialReminderOptions[5]];

        return updatedReminderOptions;
    }

    calculateTimezoneDifference() {
        let currentUserTime = new Date().toLocaleString('en-US', { timeZone: TIME_ZONE });
        let visitDateTime = new Date(this.visitDateTime).toLocaleString('en-US', {
            timeZone: TIME_ZONE
        });
        let differenceTimeHours = (new Date(visitDateTime) - new Date(currentUserTime)) / 3600000;

        return differenceTimeHours;
    }

    get disablereminder() {
        if (this.visitDate) {
            return false;
        } else {
            return true;
        }
    }

    get currentDate() {
        var currentDate;
        if (this.diffInMinutes <= 0) {
            var currentDateTime = this.currentBrowserTime + this.diffInMinutes * 60 * 1000;
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

    get currentTime() {
        var currentDate;
        if (this.diffInMinutes <= 0) {
            var currentDateTime = this.currentBrowserTime + this.diffInMinutes * 60 * 1000;
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
        if (this.calculatedDate == this.visitDate) {
            return currentTime;
        } else {
            return null;
        }
    }

    setAttributeValueEmail(event) {
        this.reminderChanged = true;
        if ((event.target.checked || this.sms) && this.remindmepub !== this.label.custom) {
            this.disableButtonSaveCancel = false;
        } else if ((event.target.checked || this.sms) && this.selectedReminderDateTime) {
            this.disableButtonSaveCancel = false;
        } else {
            this.disableButtonSaveCancel = true;
        }
        this.email = event.target.checked;
    }

    setAttributeValueSms(event) {
        this.reminderChanged = true;
        if ((event.target.checked || this.email) && this.remindmepub !== this.label.custom) {
            this.disableButtonSaveCancel = false;
        } else if ((event.target.checked || this.email) && this.selectedReminderDateTime) {
            this.disableButtonSaveCancel = false;
        } else {
            this.disableButtonSaveCancel = true;
        }
        this.sms = event.target.checked;
    }

    doValidateFields(event) {
        this.reminderChanged = true;
        this.disableButtonSaveCancel = false;
        this.remindmepub = event.detail;
        var remindMe = event.detail;
        var today = new Date(new Date() + 60 * 1000);
        var dueDateOrplanDate = this.visitDateTime;
        this.selectedReminderDateTime = '';
        this.selectedReminderDate = '';
        this.selectedReminderTime = '';
        this.reminderDateChanged = true;
        if (this.sms || this.email) {
            this.disableButtonSaveCancel = false;
        } else {
            this.disableButtonSaveCancel = true;
        }
        if (remindMe !== this.label.custom && remindMe !== this.label.none) {
            this.showreminderdatepicker = false;
            if (remindMe === this.label.oneweek) {
                this.selectedReminderDateTime = new Date(dueDateOrplanDate) - 3600 * 1000 * 24 * 7;
            } else if (remindMe === this.label.oneday) {
                this.selectedReminderDateTime = new Date(dueDateOrplanDate) - 3600 * 1000 * 24;
            } else if (remindMe === this.label.onehour) {
                this.selectedReminderDateTime = new Date(dueDateOrplanDate) - 3600 * 1000;
            } else if (remindMe === this.label.fourhour) {
                this.selectedReminderDateTime = new Date(dueDateOrplanDate) - 4 * 3600 * 1000;
            }
            var date = new Date(this.selectedReminderDateTime);
            this.selectedReminderDateTime = date.toISOString();
        } else if (remindMe === this.label.custom) {
            if (!this.selectedReminderDateTime) {
                this.disableButtonSaveCancel = true;
            }
            this.showreminderdatepicker = true;
        } else if (remindMe === this.label.none) {
            this.remindmepub = this.label.none;
            this.selectedReminderDateTime = '';
            this.selectedReminderTime = '';
            this.selectedReminderTime = '';
            this.showreminderdatepicker = false;
            this.reminderChanged = true;
            this.disableButtonSaveCancel = false;
            if (this.emailOptIn) {
                this.email = false;
            } else {
                this.email = this.visitdata.task.Remind_Using_Email__c;
            }
            if (this.smsOptIn) {
                this.sms = false;
            } else {
                this.sms = this.visitdata.task.Remind_Using_SMS__c;
            }
        }
    }

    handleOnlyDate(event) {
        this.visitDateChanged = true;
        this.visitDate = event.detail.compdate;
        this.visitDateTime = event.detail.compdate;
        this.visitTime = event.detail.comptime;
        this.selectedReminderDateTime = '';
        this.selectedReminderDate = '';
        this.selectedReminderTime = '';
        this.remindmepub = '';
        this.reminderChanged = true;
        this.reminderDateChanged = true;
        this.disableButtonSaveCancel = true;
        this.showreminderdatepicker = false;
    }

    handleOnlyTime(event) {
        this.visitDateChanged = true;
        this.visitDate = event.detail.compdate;
        this.visitTime = '';
        this.selectedReminderDateTime = '';
        this.selectedReminderDate = '';
        this.selectedReminderTime = '';
        this.reminderDateChanged = true;
        this.reminderChanged = true;
        this.disableButtonSaveCancel = true;
        this.remindmepub = '';
        this.showreminderdatepicker = false;
    }

    handleOnlyDateReminder(event) {
        this.reminderDateChanged = true;
        this.reminderChanged = true;
        this.selectedReminderDate = event.detail.compdate;
        this.selectedReminderDateTime = event.detail.compdate;
        this.selectedReminderTime = event.detail.comptime;
        if ((this.sms || this.email) && this.selectedReminderTime) {
            this.disableButtonSaveCancel = false;
        } else {
            this.disableButtonSaveCancel = true;
        }
        this.minReminderTime();
    }

    handleOnlyTimeReminder(event) {
        this.reminderDateChanged = true;
        this.reminderChanged = true;
        this.selectedReminderDate = event.detail.compdate;
        this.selectedReminderDateTime = event.detail.compdate;
        this.selectedReminderTime = event.detail.comptime;
        this.selectedReminderTime = '';
        if ((this.sms || this.email) && this.selectedReminderTime) {
            this.disableButtonSaveCancel = false;
        } else {
            this.disableButtonSaveCancel = true;
        }
    }

    handleReminderDate(event) {
        this.reminderDateChanged = true;
        this.reminderChanged = true;
        this.selectedReminderDate = event.detail.compdate;
        this.selectedReminderDateTime = event.detail.compdatetime;
        let visitDateTime = new Date(this.visitDateTime).toLocaleString('en-US', {
            timeZone: TIME_ZONE
        });
        let reminderDateTime = new Date(this.selectedReminderDateTime).toLocaleString('en-US', {
            timeZone: TIME_ZONE
        });
        let currentUserTime = new Date().toLocaleString('en-US', { timeZone: TIME_ZONE });
        if (
            new Date(visitDateTime) < new Date(reminderDateTime) ||
            new Date(reminderDateTime) < new Date(currentUserTime)
        ) {
            this.disableButtonSaveCancel = true;
        } else {
            if (this.sms || this.email) {
                this.disableButtonSaveCancel = false;
            } else {
                this.disableButtonSaveCancel = true;
            }
        }
        this.minReminderTime();
    }

    handleReminderTime(event) {
        this.reminderDateChanged = true;
        this.reminderChanged = true;
        if (this.sms || this.email) {
            this.disableButtonSaveCancel = false;
        } else {
            this.disableButtonSaveCancel = true;
        }
        this.selectedReminderTime = event.detail.comptime;
        this.selectedReminderDateTime = event.detail.compdatetime;
    }

    handleTime(event) {
        this.visitDateChanged = true;
        this.reminderDateChanged = true;
        this.selectedReminderDate = '';
        this.selectedReminderTime = '';
        this.selectedReminderDateTime = '';
        this.visitDateTime = event.detail.compdatetime;
        this.visitTime = event.detail.comptime;
        this.visitDate = event.detail.compdate;
        this.remindmepub = '';
        this.showreminderdatepicker = false;
        if (this.visitDate && this.visitTime) {
            this.disableButtonSaveCancel = false;
        } else {
            this.disableButtonSaveCancel = true;
        }
        this.reminderOptions();
    }

    handleDate(event) {
        this.visitDateChanged = true;
        this.reminderDateChanged = true;
        this.selectedReminderDate = '';
        this.selectedReminderTime = '';
        this.selectedReminderDateTime = '';
        this.visitDateTime = event.detail.compdatetime;
        this.visitDate = event.detail.compdate;
        this.visitTime = event.detail.comptime;
        this.email = false;
        this.sms = false;
        this.remindmepub = '';
        this.showreminderdatepicker = false;
        this.reminderChanged = true;
        if (this.visitDateTime) {
            let currentUserTime = new Date().toLocaleString('en-US', { timeZone: TIME_ZONE });
            let visitDueDateTime = new Date(this.visitDateTime).toLocaleString('en-US', {
                timeZone: TIME_ZONE
            });
            if (new Date(visitDueDateTime) < new Date(currentUserTime)) {
                this.disableButtonSaveCancel = true;
            } else {
                this.disableButtonSaveCancel = false;
            }
        } else {
            this.disableButtonSaveCancel = true;
        }
        this.reminderOptions();
    }

    handleNullDateTime(event) {
        this.disableButtonSaveCancel = false;
        this.visitDateTime = '';
        this.visitDate = '';
        this.visitTime = '';
        this.visitDateChanged = true;
        this.remindmepub = '';
        this.email = false;
        this.sms = false;
        this.selectedReminderDateTime = '';
        this.selectedReminderDate = '';
        this.selectedReminderTime = '';
        this.showreminderdatepicker = false;
        this.reminderChanged = true;
        this.reminderDateChanged = true;
        this.reminderChanged = true;
        this.showEmailSms = false;
    }

    handleNullDateTimeReminder(event) {
        this.disableButtonSaveCancel = true;
        this.selectedReminderDateTime = '';
        this.selectedReminderDate = '';
        this.selectedReminderTime = '';
        this.reminderDateChanged = true;
        this.reminderChanged = true;
    }

    doSave() {
        this.disableButtonSaveCancel = true;
        var errorInDml = false;
        var reminderDate;
        if (!this.reminderDateChanged) {
            reminderDate = this.visitdata.task.Reminder_Date__c;
        } else {
            reminderDate = this.selectedReminderDateTime;
        }
        var patientVisit;
        if (this.visitDateTime) {
            patientVisit = {
                sobjectType: 'Patient_Visit__c',
                Id: this.visitid,
                Planned_Date__c: this.visitDateTime,
                Status__c: 'Scheduled'
            };
        } else {
            patientVisit = {
                sobjectType: 'Patient_Visit__c',
                Id: this.visitid,
                Planned_Date__c: this.visitDateTime,
                Status__c: 'Pending'
            };
        }
        var visitTask = '';

        if (this.remindmepub !== this.label.none && this.remindmepub !== '') {
            if (this.selectedReminderDateTime)
                this.initData.reminderDate = this.selectedReminderDateTime;
            if (this.email) this.initData.emailOptIn = this.email;
            if (this.sms) this.initData.smsOptIn = this.sms;
            if (this.remindmepub) this.initData.reminderOption = this.remindmepub;
            if (this.visitDateTime) this.initData.planDate = this.visitDateTime;
            if (this.visitid) this.initData.visitId = this.visitid;
            if (this.email) this.paramTask.Remind_Using_Email__c = this.email;
            if (this.sms) this.paramTask.Remind_Using_SMS__c = this.sms;
            if (this.selectedReminderDateTime)
                this.paramTask.ReminderDateTime = this.selectedReminderDateTime;
            this.paramTask.Subject = this.tasksubject;
            if (this.taskid) this.paramTask.Id = this.taskid;
            visitTask = this.initData + this.paramTask;
        }
        if (this.visitDateChanged) {
            updatePatientVisits({
                visit: JSON.stringify(patientVisit)
            })
                .then((result) => {
                    if ((this.reminderChanged || this.reminderDateChanged) && visitTask !== '') {
                        createTask({
                            wrapper: JSON.stringify(this.initData),
                            paramTask: JSON.stringify(this.paramTask)
                        })
                            .then((result) => {
                                const event = new ShowToastEvent({
                                    message: this.isevent
                                        ? this.label.eventdetailsupdated
                                        : this.label.visitdetailsupdated,
                                    variant: 'success',
                                    mode: 'dismissable'
                                });
                                this.dispatchEvent(event);
                                const selectEvent = new CustomEvent('dataupdated');
                                this.dispatchEvent(selectEvent);
                            })
                            .catch((error) => {
                                this.showErrorToast('Error occured', error.body.message, 'error');
                            });
                    } else if (visitTask === '' && this.taskid !== '') {
                        deleteReminder({
                            taskId: this.taskid
                        })
                            .then((result) => {
                                if (result) {
                                    const event = new ShowToastEvent({
                                        message: this.isevent
                                            ? this.label.eventdetailsupdated
                                            : this.label.visitdetailsupdated,
                                        variant: 'success',
                                        mode: 'dismissable'
                                    });
                                    this.dispatchEvent(event);
                                    const selectEvent = new CustomEvent('dataupdated');
                                    this.dispatchEvent(selectEvent);
                                }
                            })
                            .catch((error) => {
                                this.showErrorToast('Error occured', error.body.message, 'error');
                            });
                    } else {
                        const event = new ShowToastEvent({
                            message: this.isevent
                                ? this.label.eventdetailsupdated
                                : this.label.visitdetailsupdated,
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                        const selectEvent = new CustomEvent('dataupdated');
                        this.dispatchEvent(selectEvent);
                    }
                })
                .catch((error) => {
                    this.showErrorToast('Error occured', error.body.message, 'error');
                });
        } else if (this.reminderChanged && visitTask !== '') {
            createTask({
                wrapper: JSON.stringify(this.initData),
                paramTask: JSON.stringify(this.paramTask)
            })
                .then((result) => {
                    const event = new ShowToastEvent({
                        message: this.isevent
                            ? this.label.eventdetailsupdated
                            : this.label.visitdetailsupdated,
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    const selectEvent = new CustomEvent('dataupdated');
                    this.dispatchEvent(selectEvent);
                })
                .catch((error) => {
                    this.showErrorToast('Error occured', error.body.message, 'error');
                });
        } else if (visitTask === '' && this.taskid !== '') {
            deleteReminder({
                taskId: this.taskid
            })
                .then((result) => {
                    if (result) {
                        const event = new ShowToastEvent({
                            message: this.isevent
                                ? this.label.eventdetailsupdated
                                : this.label.visitdetailsupdated,
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                        const selectEvent = new CustomEvent('dataupdated');
                        this.dispatchEvent(selectEvent);
                    }
                })
                .catch((error) => {
                    this.showErrorToast('Error occured', error.body.message, 'error');
                });
        } else {
            const event = new ShowToastEvent({
                message: this.isevent
                    ? this.label.eventdetailsupdated
                    : this.label.visitdetailsupdated,
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            const selectEvent = new CustomEvent('dataupdated');
            this.dispatchEvent(selectEvent);
        }
    }

    doCancel() {
        const discardEvent = new CustomEvent('discard');
        this.dispatchEvent(discardEvent);
    }

    showErrorToast(titleText, messageText, variantType) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: titleText,
                message: messageText,
                variant: variantType
            })
        );
    }
}
