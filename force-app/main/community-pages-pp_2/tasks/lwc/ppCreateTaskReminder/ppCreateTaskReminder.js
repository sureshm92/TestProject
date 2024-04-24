import { LightningElement, api, track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import moment from '@salesforce/resourceUrl/moment_js';
import momentTZ from '@salesforce/resourceUrl/momenttz';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import DEVICE from '@salesforce/client/formFactor';
//static resources
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import COMETD_LIB from '@salesforce/resourceUrl/cometd';
import USER_ID from '@salesforce/user/Id';
import getTaskEditData from '@salesforce/apex/TaskEditRemote.getTaskEditData';
import getSessionId from '@salesforce/apex/TelevisitMeetBannerController.getSessionId';
import checkEmailSMSPreferencesForPPTask from '@salesforce/apex/TaskEditRemote.checkEmailSMSPreferencesForPPTask';
import getConsentPreferences from '@salesforce/apex/RestrictedSourceConfigService.getConsentPreferences';
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
    @api maxReminderDate;
    @api maxReminderTime;
    restrictedCon;

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
    oldReminderDateForSystemTask;
    communicationTab = '_blank';

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
    taskPlaceholder = this.labels.SELECT_REMINDER;
    @track initialReminderOptions = [
        {
            label: this.labels.PP_NO_REMINDER,
            value: 'No reminder',
            itemClass: 'dropdown-li'
        },
        {
            label: this.labels.ONE_HOUR,
            value: '1 hour before',
            itemClass: 'dropdown-li'
        },
        {
            label: this.labels.FOUR_HOUR,
            value: '4 hours before',
            itemClass: 'dropdown-li'
        },
        {
            label: this.labels.ONE_DAY,
            value: '1 day before',
            itemClass: 'dropdown-li'
        },
        {
            label: this.labels.ONE_WEEK,
            value: '1 week before',
            itemClass: 'dropdown-li'
        },
        { label: this.labels.CUSTOM, value: 'Custom', itemClass: 'dropdown-li' }
    ];
    @api editMode = false;

    get reminderClass() {
        return DEVICE == 'Small'
            ? 'slds-size_1-of-1 slds-p-horizontal_none'
            : 'slds-size_1-of-1';
    }
    connectedCallback() {
        if (DEVICE != 'Large') {
            this.isMobile = true;
        }
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
                                this.maxReminderDate =
                                    this.maxReminderDate != null
                                        ? this.maxReminderDate
                                        : this.taskDueDate;
                                this.taskId = this.taskInfo.Id;
                                this.systemTask =
                                    this.taskInfo.Originator__c != 'Participant'
                                        ? this.taskCodeList.includes(this.taskInfo.Task_Code__c)
                                        : false;
                                this.businessTask =
                                    this.taskInfo.Originator__c == 'IQVIA Admin' &&
                                    !this.taskCodeList.includes(this.taskInfo.Task_Code__c)
                                        ? true
                                        : false;
                                this.emailReminderOptIn = this.initData.task.Remind_Using_Email__c;
                                this.smsReminderOptIn = this.initData.task.Remind_Using_SMS__c;
                                if (this.systemTask) {
                                    this.isEmailReminderDisabled = true;
                                }
                                if (this.systemTask || this.businessTask) {
                                    this.oldReminderDateForSystemTask = this.initData.reminderDate;
                                    if (this.oldReminderDateForSystemTask) {
                                        this.selectedReminderOption = 'Custom';
                                        this.taskPlaceholder = this.labels.CUSTOM;
                                    } else {
                                        this.taskPlaceholder = this.labels.SELECT_REMINDER;
                                        this.selectedReminderOption = this.initData.task.Remind_Me__c;
                                    }
                                } else {
                                    this.selectedReminderOption = this.initData.task.Remind_Me__c;
                                }
                                this.editMode
                                    ? (this.isTaskDueDateTimeSelected = true)
                                    : 'Not Today!!';
                                //for past tasks with no reminder disable reminder dropdown
                                let currentDateTime = new Date().toLocaleString('en-US', {
                                    timeZone: TIME_ZONE
                                });
                                if (
                                    this.editMode &&
                                    this.taskDueDateTime &&
                                    !this.initData.reminderDate &&
                                    new Date(this.taskDueDateTime) <= new Date(currentDateTime)
                                ) {
                                    this.isTaskDueDateTimeSelected = false;
                                }
                                this.maxremtime();
                                this.selectedReminderDate = this.initData.reminderDate;
                                this.maxReminderDate = this.getDateFromDateTime(this.maxReminderDate);
                                this.selectedReminderDateTime = this.initData.reminderDate;
                                this.restrictedConData();
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
            let updatedReminderOptions = [];
            if (!this.systemTask && !this.businessTask) {
                if (this.selectedReminderOption) {
                    updatedReminderOptions = [
                        ...updatedReminderOptions,
                        this.initialReminderOptions[0]
                    ];
                }
                if (differenceTimeHours > 1) {
                    updatedReminderOptions = [
                        ...updatedReminderOptions,
                        this.initialReminderOptions[1]
                    ];
                }
                if (differenceTimeHours > 4) {
                    updatedReminderOptions = [
                        ...updatedReminderOptions,
                        this.initialReminderOptions[2]
                    ];
                }
                if (differenceTimeHours > 24) {
                    updatedReminderOptions = [
                        ...updatedReminderOptions,
                        this.initialReminderOptions[3]
                    ];
                }
                if (differenceTimeHours > 168) {
                    updatedReminderOptions = [
                        ...updatedReminderOptions,
                        this.initialReminderOptions[4]
                    ];
                }
                updatedReminderOptions = [
                    ...updatedReminderOptions,
                    this.initialReminderOptions[5]
                ];
            }
            if (this.systemTask || this.businessTask) {
                if (this.initialReminderOptions.length > 1) {
                    if (this.selectedReminderOption || this.oldReminderDateForSystemTask) {
                        updatedReminderOptions = [
                            ...updatedReminderOptions,
                            this.initialReminderOptions[0]
                        ];
                    }
                    updatedReminderOptions = [
                        ...updatedReminderOptions,
                        this.initialReminderOptions[5]
                    ];
                }
                this.handleReminderDataChange();
            }
            return updatedReminderOptions;
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

    maxremtime(){
        this.maxReminderTime = new Date(
            this.maxReminderTime
        ).toLocaleString('en-US', {
            timeZone: TIME_ZONE
        });
        var processlocaltimezonedate = new Date(this.maxReminderTime);
        if (!isNaN(processlocaltimezonedate.valueOf())) {
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
            this.maxReminderTime = hh + ':' + mm + ':' + ss;
        } 
    }
    restrictedConData(){
        var conlst = new Array();
        this.restrictedCon = false;
        conlst.push(this.taskInfo.WhoId);
        getConsentPreferences({ contactIdslst: conlst})
        .then((result) => {
            let restrictedLst = result;
            let recordCount= Object.keys(restrictedLst).length; 
            if(recordCount > 0){
                if(restrictedLst.hasOwnProperty(this.taskInfo.WhoId) && !restrictedLst[this.taskInfo.WhoId]){
                    this.restrictedCon = false;
                }
                else if(!restrictedLst.hasOwnProperty(this.taskInfo.WhoId)){ // My Map{"0033O000017FxHjQAK":true} // 0033O000017FxHjQAK
                    this.restrictedCon = false;
                }
                else{
                    this.restrictedCon = true;
                }
            }
            else{
                this.restrictedCon = false;
            }
        })
        .catch((error) => {
            this.showToast('', error.message, 'error');
        });
    }
    get maximumReminderTime() {
        if (this.maxReminderTime != null) {
            return this.selectedReminderDate == this.maxReminderDate ? this.maxReminderTime : null;
        } else {
            return this.selectedReminderDate == this.maxReminderDate ? this.taskDueTime : null;
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
        if (this.taskInfo.Id && this.isTaskDueDateTimeSelected) {
            return false;
        }
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
                            let refreshRequired = message.data.payload.Payload__c.includes(USER_ID);
                            if (refreshRequired) {
                                this.handleCommPrefChange();
                            }
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
                if (this.taskId) {
                    this.taskInfo = initialData.task;
                    this.restrictedConData();
                }
                this.handleCommPrefChange();
                this.isInitialized = true;
                this.spinner.hide();
            })
            .catch((error) => {
                this.showToast('', error.message, 'error');
            });
    }

    handleReminderOptionChange(event) {
        this.selectedReminderOption = event.detail;
        this.selectedReminderDate = '';
        this.selectedReminderDateTime = '';
        if (this.selectedReminderOption == 'No reminder') {
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
        this.selectedReminderDateTime = '';
        this.selectedReminderDate = event.detail.compdate;
        this.handleReminderDataChange();
    }

    handleOnlyTime(event) {
        this.selectedReminderDateTime = event.detail.compdatetime;
        this.handleReminderDataChange();
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
        this.selectedReminderOption = '';
        this.selectedReminderDate = '';
        this.selectedReminderDateTime = '';
        this.smsReminderOptIn = false;
        this.emailReminderOptIn = false;
        this.handleReminderDataChange();
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
                if(this.businessTask || this.systemTask){
                    if(this.taskInfo && this.taskInfo.Survey_Invitation__c != null && !this.restrictedCon && !this.taskInfo.Survey_Invitation__r.IsTrialSurvey__c){
                        this.isEmailReminderDisabled = true;  
                    }
                    else{
                        this.isEmailReminderDisabled = !consentData.emailConsent; 
                    }
                    this.isSMSReminderDisabled = !consentData.smsConsent;
                }else{
                    this.checkEmailSMSConsentEnabled(consentData.emailConsent,consentData.smsConsent);
                }
                this.emailReminderOptIn = this.isEmailReminderDisabled
                    ? false
                    : this.emailReminderOptIn;
                this.smsReminderOptIn = this.isSMSReminderDisabled ? false : this.smsReminderOptIn;
                this.handleReminderDataChange();
                this.spinner.hide();
            })
            .catch((error) => {
                console.error(error);
            });
    }
    setSessionCookie() {
        localStorage.setItem('Cookies', 'Accepted');
        return true;
    }
    //This Method Enables and Disables the Email and SMS Reminder based on Logged IN User Mode and Comm Pref
    checkEmailSMSConsentEnabled(emailConsent,smsConsent){
        let currentMode = communityService.getCurrentCommunityMode();

        if(!currentMode.isDelegate){  
            //participant View or Delegate self View
            if(currentMode.currentPE != null && currentMode.participantState != 'ALUMNI'){    
                //Active Participant View/ Half Alumni Participant View
                this.isEmailReminderDisabled = !emailConsent;
                this.isSMSReminderDisabled = !smsConsent;
            }else{             
                //Alumni Participant View or Delegate self View
                this.isEmailReminderDisabled = false;
                this.isSMSReminderDisabled = false;
            }
            if(this.taskInfo && this.taskInfo.Survey_Invitation__c != null && !this.restrictedCon && !this.taskInfo.Survey_Invitation__r.IsTrialSurvey__c){ // unrestricted = as it as true , restricted - disable
                this.isEmailReminderDisabled = true;
            }
        }
        else{
            //Delegate switched to Participant View                                                       
            if(currentMode.participantState == 'ALUMNI' && currentMode.currentPE == null){
                //Delegate switched to Full Alumni Participant View
                this.isEmailReminderDisabled = false;
                this.isSMSReminderDisabled = false;
            }else{
                //Delegate switched to Active Participant View / Half alumni Participant View
                this.isEmailReminderDisabled = !emailConsent;
                this.isSMSReminderDisabled = !smsConsent;
            }
            if(this.taskInfo && this.taskInfo.Survey_Invitation__c != null && !this.restrictedCon && !this.taskInfo.Survey_Invitation__r.IsTrialSurvey__c){
                this.isEmailReminderDisabled = true;

            }
        }
    }
}