import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import weeklyError from '@salesforce/label/c.weekly_survey_error';
import monthlyError from '@salesforce/label/c.monthly_survey_error';
import yearlyError from '@salesforce/label/c.yearly_survey_error';
import reminderDaysError from '@salesforce/label/c.reminder_days_for_daily';
import noOfDaysBeforeSurveyExpireError from '@salesforce/label/c.no_of_days_before_survey_expire';
import startDateNotBlank from '@salesforce/label/c.ts_start_date_not_blank';
import tsSuccessMsg from '@salesforce/label/c.ts_success_msg';
import endDateNotBlank from '@salesforce/label/c.ts_end_date_not_blank';
import activeOnStatus from '@salesforce/label/c.Active_on_status';

export default class trialSurvey extends NavigationMixin(LightningElement) {
    @api ctpId;
    @api recordId;
    @api recordTypeId;
    @api recordTypeName;
    @track reminderDisabled;
    isModalOpen = false;
    isctpId = false;
    isrecordtype = false;
    isStatusBasedTrialSurvey = false;
    isRecurrenceSurvey = false;
    labels = {
        weeklyError,
        monthlyError,
        yearlyError,
        reminderDaysError,
        noOfDaysBeforeSurveyExpireError,
        startDateNotBlank,
        tsSuccessMsg,
        endDateNotBlank,
        activeOnStatus
    };

    connectedCallback() {
        this.isModalOpen = true;
        if (this.ctpId !== null) {
            this.isctpId = true;
        }
        if (this.recordTypeId !== null) {
            this.isrecordtype = true;
        }
        if (this.recordTypeName === 'Status based') {
            this.isStatusBasedTrialSurvey = true;
        }
    }

    handleSubmit(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        var frequency;
        let expiryDays;
        var recType = fields.RecordTypeId;
        if (fields.Is_Recurrence_Survey__c) {
            frequency = fields.Recurrence_Frequency__c;
        }
        if (fields.Is_Recurrence_Survey__c && frequency == 'Daily') {
            console.log('rem error');
            if (fields.Reminder_in_days_before_the_end_date__c > 0) {
                communityService.showErrorToast('', this.labels.reminderDaysError, 3000);
                return;
            }
        }
        expiryDays = fields.Expires_After_Days__c;
        if (this.recordTypeName == 'Status based') {
            // ststus based
            var activeOnStatus = fields.Active_On_Status__c;
            let today = new Date();
            const dueDate = new Date();
            dueDate.setDate(today.getDate() + parseInt(expiryDays));
            var diffYear = (dueDate.getTime() - today.getTime()) / 1000;
            diffYear /= 60 * 60 * 24;
            let yearsDiff = Math.abs(Math.round(diffYear / 365.25));

            var diffMonth = (dueDate.getTime() - today.getTime()) / 1000;
            diffMonth /= 60 * 60 * 24 * 7 * 4;
            let monthdiff = Math.abs(Math.round(diffMonth));

            if (activeOnStatus == '' || activeOnStatus == null) {
                communityService.showErrorToast('', this.labels.activeOnStatus, 3000);
                return;
            }
            if ((expiryDays == '' || expiryDays == null) && !fields.Is_Recurrence_Survey__c) {
                communityService.showErrorToast(
                    '',
                    this.labels.noOfDaysBeforeSurveyExpireError,
                    3000
                );
                return;
            }
            if (frequency == 'Weekly' && expiryDays < 7) {
                communityService.showErrorToast('', this.labels.weeklyError, 3000);
                return;
            } else if (frequency == 'Monthly' && monthdiff < 1) {
                communityService.showErrorToast('', this.labels.monthlyError, 3000);
                return;
            } else if (frequency == 'Yearly' && yearsDiff < 1) {
                communityService.showErrorToast('', this.labels.yearlyError, 3000);
                return;
            } else {
                // save record
                this.template.querySelector('lightning-record-edit-form').submit(fields);
                this.naviagetOnSuccess();
            }
        } else if (this.recordTypeName == 'Time based') {
            // time based
            let startDate = new Date(fields.Survey_start_date__c);
            let endDate = new Date(fields.Survey_end_date__c);
            //startDate = fields.Survey_start_date__c;
            //endDate = fields.Survey_end_date__c;
            if (fields.Survey_start_date__c == '' || fields.Survey_start_date__c == null) {
                communityService.showErrorToast('', this.labels.startDateNotBlank, 3000);
                return;
            }
            if (fields.Survey_end_date__c == '' || fields.Survey_end_date__c == null) {
                communityService.showErrorToast('', this.labels.endDateNotBlank, 3000);
                return;
            }
            var diffYear = (endDate.getTime() - startDate.getTime()) / 1000;
            diffYear /= 60 * 60 * 24;
            let yearsDiff = Math.abs(Math.round(diffYear / 365.25));

            var diffMonth = (endDate.getTime() - startDate.getTime()) / 1000;
            diffMonth /= 60 * 60 * 24 * 7 * 4;
            let monthdiff = Math.abs(Math.round(diffMonth));

            var diffWeek = (endDate.getTime() - startDate.getTime()) / 1000;
            diffWeek /= 60 * 60 * 24;
            let weekDiff = Math.abs(Math.round(diffWeek));

            if (frequency == 'Weekly' && weekDiff < 7) {
                communityService.showErrorToast('', this.labels.weeklyError, 3000);
                return;
            } else if (frequency == 'Monthly' && monthdiff < 1) {
                communityService.showErrorToast('', this.labels.monthlyError, 3000);
                return;
            } else if (frequency == 'Yearly' && yearsDiff < 1) {
                communityService.showErrorToast('', this.labels.yearlyError, 3000);
                return;
            } else {
                // save record
                this.template.querySelector('lightning-record-edit-form').submit(fields);
                this.naviagetOnSuccess();
            }
        }
    }
    naviagetOnSuccess(event) {
        this.isModalOpen = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.ctpId,
                objectApiName: 'Clinical_Trial_Profile__c',
                actionName: 'view'
            }
        });
    }
    handleCheckBoxChange(event) {
        this.isRecurrenceSurvey = event.target.value;
    }
    handleSuccess(event) {
        communityService.showSuccessToast('Success!', this.labels.tsSuccessMsg, 3000);
    }
    closeModal(event) {
        this.isModalOpen = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.ctpId,
                objectApiName: 'Clinical_Trial_Profile__c',
                actionName: 'view'
            }
        });
    }
}
