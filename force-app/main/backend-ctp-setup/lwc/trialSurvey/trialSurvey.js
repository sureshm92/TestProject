import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import weeklyError from '@salesforce/label/c.weekly_survey_error';
import monthlyError from '@salesforce/label/c.monthly_survey_error';
import yearlyError from '@salesforce/label/c.yearly_survey_error';
import tsSuccessMsg from '@salesforce/label/c.ts_success_msg';
import startDateError from '@salesforce/label/c.Start_Date_Error_Message';
import endDateError from '@salesforce/label/c.End_Date_Error_Message';
import inActiveSurveyError from '@salesforce/label/c.TS_InActive_Status_Error';
import errorOnNumberOfOccurrence from '@salesforce/label/c.Number_Of_Occurrence_Error';
import numericFieldValidationMessage from '@salesforce/label/c.TS_NegativeNumberError';

import remDateError from '@salesforce/label/c.reminder_greaterthan_one_year_error';
import { loadScript } from 'lightning/platformResourceLoader';
import momentJs from '@salesforce/resourceUrl/moment_js';
import fetchTrialSurvey from '@salesforce/apex/TrialSurveyContainerController.getTrialSurveyRecords';

export default class trialSurvey extends NavigationMixin(LightningElement) {
    @api ctpId;
    @api recordId;
    @api recordTypeId;
    @api recordTypeName;
    reminderDisabled = false;
    isModalOpen = false;
    isctpId = false;
    isrecordtype = false;
    isRecurrenceSurvey = false; 
    activeOnStatusDisabled = false;
    recurringSurveyDisabled = false;
    whoseResponseNeededDisabled = false;
    startDateDisabled = false;
    endDateDisabled = false;
    isEdit=false; 
    surveyStartDate;
    surveyEndDate;
    recurrenceFrequency;
    lastOccurrenceDate;  
    status;
    error;
    executeRenderedCallbackk = true;
    notNumericValue = false;
    labels = {
        weeklyError,
        monthlyError,
        yearlyError,
        tsSuccessMsg,
        remDateError,
        startDateError, 
        endDateError,
        errorOnNumberOfOccurrence,
        inActiveSurveyError,
        numericFieldValidationMessage
    };
   
    connectedCallback() {
        this.isModalOpen = true;
        if (this.ctpId !== null) {
            this.isctpId = true;
        }
        if (this.recordTypeId !== null) {
            this.isrecordtype = true;
        }
        if (this.recordId !== null) {
            this.isEdit = true;
            this.activeOnStatusDisabled=true;
            this.recurringSurveyDisabled=true;
            this.whoseResponseNeededDisabled=true;
        }

        loadScript(this, momentJs).then(() => {
            console.log('scriptLoaded');           
        });
    }

    renderedCallback(){
        let number = ++this.number;
        //Check to avoid unneccessary calls
        if(this.executeRenderedCallbackk && this.isEdit){
            //fetch Trial Survey data in case of edit. 
            this.fetchTrialSurveyOnEdit();
            this.executeRenderedCallbackk = false;    
        }
    }
    handleFrequencyChange(event) {
        const inputFields = this.template.querySelectorAll('.remDate');
        var remFreq = event.target.value;
        if (inputFields) {
            if (this.isEdit && remFreq == 'Daily') {
                inputFields.forEach((field) => {
                        field.value  = null;
                });
            }else{
                inputFields.forEach((field) => {
                    field.reset();
                });
            }
        }
        var remFreq = event.target.value;
        if (remFreq != 'Daily') {
            this.reminderDisabled = false;
        } else {
            this.reminderDisabled = true;
        }
    }
    isNumberKey(event) {
        var fieldValue = event.target.value;
        //check if the field value is positive number. 
        this.checkIfFieldIsPositaveNumber(fieldValue);
    }
    //this method checks if the field value is positive number. 
    checkIfFieldIsPositaveNumber(fieldValue){
        var numbers = /^[0-9]+$/;
        if (fieldValue!= '' && fieldValue != null && fieldValue != undefined) {
            //convert fieldValue to String as 'match method compares only for string value' 
            fieldValue = fieldValue.toString();
            if (!fieldValue.match(numbers)) {
                this.notNumericValue = true;
                communityService.showErrorToast('', this.labels.numericFieldValidationMessage, 3000);
                return;
            }
        }else{
            this.notNumericValue = false;
        }
    }

    handleSubmit(event) {
        // Stop the form from submitting so that UI validation can be processed. 
        event.preventDefault(); 
        //Stop the form to save if InActive Trial Survey is edited.
        if(this.isEdit && this.status ==='InActive'){
            communityService.showErrorToast('', this.labels.inActiveSurveyError, 3000);
            return;
        }
        const fields = event.detail.fields;
        var frequency;
        //Throw Validation error if any number field has -ve value.
        if (this.notNumericValue) {
            communityService.showErrorToast('', this.labels.numericFieldValidationMessage, 3000);
            return;
        }
        if (fields.Is_Recurrence_Survey__c) {
            frequency = fields.Recurrence_Frequency__c;
        }

        //Check Reminder Days before survey expires should not be greater than one year.
        if (
            fields.Reminder_in_days_before_the_end_date__c != null &&
            fields.Reminder_in_days_before_the_end_date__c != ''   &&
            fields.Reminder_in_days_before_the_end_date__c != undefined
        ) {
            if (fields.Reminder_in_days_before_the_end_date__c > 365) {
                communityService.showErrorToast('', this.labels.remDateError, 3000);
                return;
            }
        }
        if (this.recordTypeName == 'Status based') {
            // Field validations for status based Trial Survey

            var numberOfOccurrence = fields.Number_of_occurrences__c;
            var IsRecurrenceSurvey = fields.Is_Recurrence_Survey__c;
            
            //for recurring Survey, number of occurance should be greater than zero. 
            if ( IsRecurrenceSurvey && numberOfOccurrence <=0 ) {
                communityService.showErrorToast('', this.labels.errorOnNumberOfOccurrence, 3000);
                return;
            }
             // save record after all validation got successed.
             this.template.querySelector('lightning-record-edit-form').submit(fields);
             this.naviagetOnSuccess();
        } else if (this.recordTypeName == 'Time based') {
            // time based
            let todaysDate = new Date();
            let currentDate = todaysDate.toISOString().split('T')[0];
            let momentEnddate = moment(fields.Survey_end_date__c, 'YYYY-MM-DD');
            
            //For new TrialSurvey, start date cannot be less than current date. 
            if (!this.isEdit && fields.Survey_start_date__c < currentDate) {
                communityService.showErrorToast('', this.labels.startDateError, 3000);
                return;
            }
            // Survey End Date should not be less than Survey start Date. 
            if (fields.Survey_end_date__c < fields.Survey_start_date__c) {
                communityService.showErrorToast(
                    '',
                    this.labels.endDateError,
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
                // save record after all validation got successed.
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
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.ctpId,
                objectApiName: 'Clinical_Trial_Profile__c',
                relationshipApiName: 'Trial_Surveys__r',
                actionName: 'view'
            },
        });
        this.dispatchEventToAura();
    }
    handleCheckBoxChange(event) {
        const inputFields = this.template.querySelectorAll('.remDate');
        //Reset the field value 
        if (inputFields) {
            inputFields.forEach((field) => {
                field.reset();
            });
        }
        const inputExpAftDaysFields = this.template.querySelectorAll('.expAftDays');
        if (inputExpAftDaysFields) {
            inputExpAftDaysFields.forEach((field) => {
                field.reset();
            });
        }
        
        if (event.target.value) {
            this.reminderDisabled = true;
        } else {
            this.reminderDisabled = false;
        }
        
        this.isRecurrenceSurvey = event.target.value;
    }
    handleSuccess(event) {
        communityService.showSuccessToast('Success!', this.labels.tsSuccessMsg, 3000);
    }
    closeModal(event) {
        this.naviagetOnSuccess();
    }

    //Set RecordTypeName flag
    get isStatusBasedTrialSurvey() {
        return this.recordTypeName === 'Status based' ? true : false;
    }

    //Dispatch event to Parent aura component to refresh the paga.
    dispatchEventToAura() {
        const selectedEvent = new CustomEvent('pagerefresh');
        this.dispatchEvent(selectedEvent);
    }
    //Fetch trial survey for edit 
    fetchTrialSurveyOnEdit() {
        fetchTrialSurvey({ tsRecordId: this.recordId })
            .then(result => {
                if(result){
                    this.recordTypeId = result.RecordTypeId;
                    this.recordTypeName = result.RecordType.Name;
                    this.isRecurrenceSurvey = result.Is_Recurrence_Survey__c;
                    this.surveyStartDate = result.Survey_start_date__c;
                    this.surveyEndDate = result.Survey_end_date__c;
                    this.lastOccurrenceDate =result.Last_Occurrence_Date__c;
                    this.recurrenceFrequency = result.Recurrence_Frequency__c
                    this.status = result.Status__c;
                    this.error = undefined;
                    // validation logic begins
                    let today = new Date();
                    let currentDate = today.toISOString().split('T')[0];
                    if(this.recordTypeName === 'Time based'){
                        this.recurringSurveyDisabled = false;
                        if(this.lastOccurrenceDate!=null){
                            this.recurringSurveyDisabled = true;
                        }
                        if (this.surveyStartDate <= currentDate) {
                            this.recurringSurveyDisabled = true;
                            if(!this.isRecurrenceSurvey){
                                this.startDateDisabled = true;      
                            }
                        }
                        if (this.surveyEndDate <= currentDate) {
                            this.endDateDisabled = true;
                            if(this.isRecurrenceSurvey){
                                    this.startDateDisabled = true;      
                            }
                        }    
                    }  
                    if (this.isRecurrenceSurvey && this.recurrenceFrequency =='Daily') {
                        this.reminderDisabled = true;
                    }     
                }     
            })
            .catch(error => {
                this.error = error;
                
            });
    }

}