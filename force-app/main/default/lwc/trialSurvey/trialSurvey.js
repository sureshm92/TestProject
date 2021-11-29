import { LightningElement, api } from 'lwc';
//import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import weeklyError from '@salesforce/label/c.weekly_task_error';
import monthlyError from '@salesforce/label/c.monthly_task_error';
import yearlyError from '@salesforce/label/c.yearly_task_error';

export default class trialSurvey extends NavigationMixin(LightningElement) {
    @api ctpId;
    @api recordId;
    @api recordTypeId;
    @api recordTypeName;
    isModalOpen = false;
    isctpId = false;
    isrecordtype = false;
    isStatusBasedTrialSurvey = false;
    isRecurrenceSurvey = false;

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
        var expiryDays;
        expiryDays = fields.Expires_After_Days__c;
        var today = new Date();
        this.date = today.toISOString();
        console.log(today.toISOString());
        var last = new Date(new Date().getFullYear(), 11, 32);
        this.date1 = last.toISOString();
        console.log('expiryDays: ' + last);
        if (fields.is_Recurrence_Survey__c) {
            frequency = fields.Recurrence_Frequency__c;
        }
        console.log('frequency: ' + frequency);
        if (frequency == 'Weekly' && expiryDays < 7) {
            communityService.showErrorToast('', 'Cannot create weekly survey for these days', 3000);
        } else if (frequency == 'Monthly' && expiryDays < 7) {
            communityService.showErrorToast(
                '',
                'Cannot create monthly survey for these days',
                3000
            );
        }
        /*this.isModalOpen = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.ctpId,
                objectApiName: 'Clinical_Trial_Profile__c',
                actionName: 'view'
            }
        });*/
    }
    handleCheckBoxChange(event) {
        this.isRecurrenceSurvey = event.target.value;
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