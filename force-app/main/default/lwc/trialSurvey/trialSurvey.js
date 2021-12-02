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
import remDateError from '@salesforce/label/c.reminder_greaterthan_one_year_error';
import { loadScript } from 'lightning/platformResourceLoader';
import momentJs from '@salesforce/resourceUrl/moment_js';

export default class trialSurvey extends NavigationMixin(LightningElement) {
    @api ctpId;
    @api recordId;
    @api recordTypeId;
    @api recordTypeName;
    @track reminderDisabled = false;
    isModalOpen = false;
    isctpId = false;
    isrecordtype = false;
    //isStatusBasedTrialSurvey = false;
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
        activeOnStatus,
        remDateError
    };

    connectedCallback() {
        this.isModalOpen = true;
        if (this.ctpId !== null) {
            this.isctpId = true;
        }
        if (this.recordTypeId !== null) {
            this.isrecordtype = true;
        }
        /*if (this.recordTypeName === 'Status based') {
            this.isStatusBasedTrialSurvey = true;
        }*/
        loadScript(this, momentJs).then(() => {
            console.log('scriptLoaded');
        });
    }
    handleFrequencyChange(event) {
        const inputFields = this.template.querySelectorAll('.remDate');
        if (inputFields) {
            inputFields.forEach((field) => {
                field.reset();
            });
        }
        var remFreq = event.target.value;
        if (remFreq != 'Daily') {
            this.reminderDisabled = false;
        } else {
            this.reminderDisabled = true;
        }
    }
    handleSubmit(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        var frequency;
        let expiryDays;
        //var recType = fields.RecordTypeId;
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
        if (
            fields.Reminder_in_days_before_the_end_date__c != null &&
            fields.Reminder_in_days_before_the_end_date__c != ''
        ) {
            if (fields.Reminder_in_days_before_the_end_date__c > 365) {
                communityService.showErrorToast('', this.labels.remDateError, 3000);
                return;
            }
        }
        expiryDays = fields.Expires_After_Days__c;
        if (this.recordTypeName == 'Status based') {
            // ststus based
            var activeOnStatus = fields.Active_On_Status__c;
            let today = new Date();
            let dueDate = new Date();
            let currentDate = today.toISOString().split('T')[0];
            dueDate.setDate(today.getDate() + parseInt(expiryDays));
            let newDate = moment(dueDate, 'YYYY-MM-DD');

            let yearsDiff = newDate.diff(currentDate, 'years');
            let monthdiff = newDate.diff(currentDate, 'months');
            let weekDiff = newDate.diff(currentDate, 'days');

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
            let todaysDate = new Date();
            let currentDate = todaysDate.toISOString().split('T')[0];
            let startDate = new Date(fields.Survey_start_date__c);
            let endDate = new Date(fields.Survey_end_date__c);
            let momentEnddate = moment(fields.Survey_end_date__c, 'YYYY-MM-DD');

            if (fields.Survey_start_date__c == '' || fields.Survey_start_date__c == null) {
                communityService.showErrorToast('', this.labels.startDateNotBlank, 3000);
                return;
            }
            if (fields.Survey_end_date__c == '' || fields.Survey_end_date__c == null) {
                communityService.showErrorToast('', this.labels.endDateNotBlank, 3000);
                return;
            }

            if (fields.Survey_start_date__c < currentDate) {
                communityService.showErrorToast('', 'Start date cannot be a past date', 3000);
                return;
            }
            if (fields.Survey_end_date__c < fields.Survey_start_date__c) {
                communityService.showErrorToast(
                    '',
                    'End date cannot be less than start date',
                    3000
                );
                return;
            }
            let yearsDiff = momentEnddate.diff(fields.Survey_start_date__c, 'years');
            let monthdiff = momentEnddate.diff(fields.Survey_start_date__c, 'months');
            let weekDiff = momentEnddate.diff(fields.Survey_start_date__c, 'days');

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
    //Navigate to current CTP page on click of Save/Cancel button. 
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
        this.dispatchEventToAura();
    }
    handleCheckBoxChange(event) {
        this.reminderDisabled = true;
        this.isRecurrenceSurvey = event.target.value;
    }
    handleSuccess(event) {
        communityService.showSuccessToast('Success!', this.labels.tsSuccessMsg, 3000);
    }
    closeModal(event) {
        this.naviagetOnSuccess();
    }

    //Set RecordTypeName flag
		get isStatusBasedTrialSurvey(){
            return (this.recordTypeName === 'Status based' ? true : false); 
    }

    //Dispatch event to Parent aura component to refresh the paga.
    dispatchEventToAura(){
            const selectedEvent = new CustomEvent('pagerefresh');
            this.dispatchEvent(selectedEvent);
    }
}
