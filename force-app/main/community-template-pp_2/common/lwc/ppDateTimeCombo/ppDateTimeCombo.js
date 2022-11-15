import { LightningElement, api, track } from 'lwc';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import moment from '@salesforce/resourceUrl/moment';
import momentTZ from '@salesforce/resourceUrl/momenttz';
import { loadScript } from 'lightning/platformResourceLoader';
import date from '@salesforce/label/c.TV_TH_Date';
import dueDate from '@salesforce/label/c.Due_Date';
import time from '@salesforce/label/c.TV_TH_Time';
import reminderdate from '@salesforce/label/c.Reminder_Date';
import remindertime from '@salesforce/label/c.Reminder_Time';
import timePlaceHolder from '@salesforce/label/c.PP_Time_Place_Holder';
import validTimeFormat from '@salesforce/label/c.Valid_Time_Format';
import noPastValues from '@salesforce/label/c.No_Past_Values';
import noFutureValues from '@salesforce/label/c.No_future_Values';
export default class PpDateTimeCombo extends LightningElement {
    @api compdate;
    @api comptime;
    @api mindate;
    @api mintime;
    @api maxdate;
    @api maxtime;
    @api reminder;
    @api iconSize = 'small';
    @api iconColor = '#00A3E0';
    @api createTask;
    @api taskReminder = false;
    @api editMode = false;
    @api readOnlyMode = false;
    @track compDateTime;
    @track dt;
    @track tm;
    @track diffInMinutes;
    @track initialDateLoaded = false;
    @track initialTimeLoaded = false;
    @track timeOnlyPresent = true;
    @api showDateTime;
    label = {
        date,
        time,
        reminderdate,
        remindertime,
        dueDate,
        timePlaceHolder,
        validTimeFormat,
        noPastValues,
        noFutureValues
    };

    @api
    callFromParent() {
        this.dt = '';
        this.tm = '';
        this.compDateTime = '';
        this.initialDateLoaded = false;
        this.initialTimeLoaded = false;
        this.timeOnlyPresent = true;
    }

    connectedCallback() {
        loadScript(this, moment).then(() => {
            loadScript(this, momentTZ).then(() => {
                var currentBrowserTime = window.moment();
                var localOffset = currentBrowserTime.utcOffset();
                var userTime = currentBrowserTime.tz(TIME_ZONE);
                var centralOffset = userTime.utcOffset();
                this.diffInMinutes = localOffset - centralOffset;
            });
        });
    }

    get dbDate() {
        if (this.editMode) {
            var inputField = this.template.querySelector('.timc');
            if (inputField) {
                inputField.reportValidity();
            }
        }
        if (!this.compdate) {
            this.initialDateLoaded = true;
            this.dt = '';
            return null;
        } else if (this.dt) {
            return this.dt;
        } else if (!this.initialDateLoaded || (this.editMode && this.compdate)) {
            var compdate;
            var dbCompDate = new Date(this.compdate);
            var localtimezonedate = dbCompDate.toLocaleString('en-US', { timeZone: TIME_ZONE });
            var processlocaltimezonedate = new Date(localtimezonedate);
            var dd = String(processlocaltimezonedate.getDate()).padStart(2, '0');
            var mm = String(processlocaltimezonedate.getMonth() + 1).padStart(2, '0');
            var yyyy = processlocaltimezonedate.getFullYear();
            compdate = yyyy + '-' + mm + '-' + dd;
            this.initialDateLoaded = true;
            this.timeOnlyPresent = false || this.readOnlyMode;
            this.dt = compdate;
            const dateEvent = new CustomEvent('initialdateload', {
                detail: {
                    compdate: this.dt
                }
            });
            this.dispatchEvent(dateEvent);
            return compdate;
        }
    }

    get dateCSS() {
        return this.readOnlyMode ? 'read-only-field' : '';
    }
    get timeCSS() {
        return this.readOnlyMode ? 'timc  read-only-field' : 'timc';
    }
    get dbTime() {
        if (this.editMode) {
            if (this.dbDate) {
                let selectedDateArray = this.dbDate.split('-');
                if (selectedDateArray.length > 0) {
                    var sdObj = new Date(
                        selectedDateArray[0],
                        selectedDateArray[1] - 1,
                        selectedDateArray[2]
                    );
                }
            }
            var inputField = this.template.querySelector('.timc');
            if (this.maxdate) {
                let maxDateArray = this.maxdate.split('-');
                if (maxDateArray.length > 0)
                    var duedObj = new Date(maxDateArray[0], maxDateArray[1] - 1, maxDateArray[2]);
            }
        }
        if (
            (!this.comptime && !this.editMode) ||
            (!this.comptime && !this.initialTimeLoaded && this.editMode)
        ) {
            this.initialTimeLoaded = true;
            this.tm = '';
            return null;
        } else if (this.tm) {
            return this.tm;
        } else if (
            (!this.initialTimeLoaded && !this.editMode) ||
            (this.comptime && this.editMode)
        ) {
            var comptime;
            var dbCompDate = new Date(this.comptime);
            var localtimezonedate = dbCompDate.toLocaleString('en-US', { timeZone: TIME_ZONE });
            var processlocaltimezonedate = new Date(localtimezonedate);
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
                comptime = hh + ':' + mm + ':' + ss;
                this.initialTimeLoaded = true;
                this.timeOnlyPresent = false || this.readOnlyMode;
                this.tm = comptime;
            } else {
                if (this.editMode) {
                    if (this.comptime) {
                        this.tm = this.comptime.substring(
                            0,
                            this.comptime.includes('.')
                                ? this.comptime.indexOf('.')
                                : this.comptime.length
                        );
                    } else {
                        this.tm = '';
                    }
                }
            }
            const dateEvent = new CustomEvent('initialtimeload', {
                detail: {
                    comptime: this.tm
                }
            });
            this.dispatchEvent(dateEvent);
            return comptime;
        }
    }

    get dateInputClass() {
        this.createTask = true ? 'task-due-date-time' : 'curve-input';
    }
    get dueDateClass() {
        return 'slds-col slds-size_1-of-1 slds-small-size_1-of-2 slds-large-size_1-of-2 slds-p-right_xx-small';
    }
    get timeClass() {
        return 'slds-col slds-size_1-of-1 slds-small-size_1-of-2 slds-large-size_1-of-2 slds-p-left_xx-small';
    }
    get gridClass() {
        return this.createTask == true
            ? this.taskReminder
                ? 'slds-grid slds-wrap slds-m-bottom_none'
                : 'slds-grid slds-wrap'
            : 'slds-grid slds-grid-visit slds-wrap';
    }

    get dueDateTimeGrid() {
        return this.createTask == true
            ? ''
            : 'slds-col slds-size_1-of-1 slds-small-size_1-of-2 slds-large-size_1-of-2 slds-p-right_xx-small';
    }

    handleDate(event) {
        this.initialDateLoaded = true;
        this.dt = event.target.value;
        this.tm = '';
        if (!this.dt) {
            this.timeOnlyPresent = true;
            this.tm = event.target.value;
            const nulldatetime = new CustomEvent('nulldatetime', {
                detail: {
                    compdate: this.dt,
                    comptime: this.tm
                }
            });
            this.dispatchEvent(nulldatetime);
        } else if (!this.tm) {
            this.timeOnlyPresent = false || this.readOnlyMode;
            const dateOnly = new CustomEvent('date', {
                detail: {
                    compdatetime: null,
                    compdate: this.dt,
                    comptime: null
                }
            });
            this.dispatchEvent(dateOnly);
        } else if (this.tm) {
            this.timeOnlyPresent = false || this.readOnlyMode;
            this.compDateTime = this.dt + 'T' + this.tm;
            var date = new Date(this.compDateTime);
            var ms = Date.parse(date);
            ms = ms + this.diffInMinutes * 60 * 1000;
            date = new Date(ms);
            this.compDateTime = date.toISOString();
            const dateEvent = new CustomEvent('datechange', {
                detail: {
                    compdatetime: this.compDateTime,
                    compdate: this.dt,
                    comptime: this.tm
                }
            });
            this.dispatchEvent(dateEvent);
        }
    }

    handleTime(event) {
        this.initialTimeLoaded = true;
        this.tm = event.target.value;
        if (!this.tm) {
            this.timeOnlyPresent = false || this.readOnlyMode;
            const timeOnly = new CustomEvent('time', {
                detail: {
                    comptime: null,
                    compdatetime: null,
                    compdate: this.dt
                }
            });
            this.dispatchEvent(timeOnly);
        } else if (!this.dt) {
            this.timeOnlyPresent = true;
            const timeOnly = new CustomEvent('timechange', {
                detail: {
                    comptime: this.tm,
                    compdatetime: null,
                    compdate: null
                }
            });
            this.dispatchEvent(timeOnly);
        } else if (this.dt) {
            this.timeOnlyPresent = false || this.readOnlyMode;
            this.compDateTime = this.dt + 'T' + this.tm;
            var date = new Date(this.compDateTime);
            var ms = Date.parse(date);
            ms = ms + this.diffInMinutes * 60 * 1000;
            date = new Date(ms);
            this.compDateTime = date.toISOString();
            const dateEvent = new CustomEvent('datechange', {
                detail: {
                    compdatetime: this.compDateTime,
                    compdate: this.dt,
                    comptime: this.tm
                }
            });
            this.dispatchEvent(dateEvent);
        }
    }
}
