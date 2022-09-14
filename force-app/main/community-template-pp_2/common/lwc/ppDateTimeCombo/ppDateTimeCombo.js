import { LightningElement, api, track } from 'lwc';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import moment from '@salesforce/resourceUrl/moment';
import momentTZ from '@salesforce/resourceUrl/momenttz';
import { loadScript } from 'lightning/platformResourceLoader';
import date from '@salesforce/label/c.TV_TH_Date';
import time from '@salesforce/label/c.TV_TH_Time';
export default class PpDateTimeCombo extends LightningElement {
    @api compdate;
    @api comptime;
    @api mindate;
    @api mintime;
    @api maxdate;
    @api maxtime;
    @track compDateTime;
    @track dt;
    @track tm;
    @track diffInMinutes;

    label = {
        date,
        time
    };

    @api
    callFromParent() {
        this.dt = '';
        this.tm = '';
        this.compDateTime = '';
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
        if (!this.compdate) {
            return null;
        } else if (this.dt) {
            return this.dt;
        } else {
            var compdate;
            var dbCompDate = new Date(this.compdate);
            var localtimezonedate = dbCompDate.toLocaleString('en-US', { timeZone: TIME_ZONE });
            var processlocaltimezonedate = new Date(localtimezonedate);
            var dd = String(processlocaltimezonedate.getDate()).padStart(2, '0');
            var mm = String(processlocaltimezonedate.getMonth() + 1).padStart(2, '0');
            var yyyy = processlocaltimezonedate.getFullYear();
            compdate = yyyy + '-' + mm + '-' + dd;
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

    get dbTime() {
        if (!this.comptime) {
            return null;
        } else if (this.tm) {
            return this.tm;
        } else {
            var comptime;
            var dbCompDate = new Date(this.comptime);
            var localtimezonedate = dbCompDate.toLocaleString('en-US', { timeZone: TIME_ZONE });
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
            comptime = hh + ':' + mm + ':' + ss;
            this.tm = comptime;
            const dateEvent = new CustomEvent('initialtimeload', {
                detail: {
                    comptime: this.tm
                }
            });
            this.dispatchEvent(dateEvent);
            return comptime;
        }
    }

    handleDate(event) {
        this.dt = event.target.value;
        if (!this.tm) {
            const dateOnly = new CustomEvent('date', {
                detail: {
                    compdate: this.dt
                }
            });
            this.dispatchEvent(dateOnly);
        } else if (this.tm) {
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
        this.tm = event.target.value;
        if (!this.dt) {
            const timeOnly = new CustomEvent('time', {
                detail: {
                    comptime: this.tm
                }
            });
            this.dispatchEvent(timeOnly);
        } else if (this.dt) {
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
