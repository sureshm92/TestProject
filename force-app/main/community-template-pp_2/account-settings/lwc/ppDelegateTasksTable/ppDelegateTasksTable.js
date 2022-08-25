import { LightningElement, api, track } from 'lwc';
import DELEGATE_TASK from '@salesforce/label/c.PP_AS_DelegateTasks';
import COMPLETE_TASK from '@salesforce/label/c.PP_AS_COMPLETE_TASK';
import RECEIVE_EMAIL from '@salesforce/label/c.PP_AS_RECEIVE_EMAIL';
import LAB_RESULTS from '@salesforce/label/c.PP_AS_LAB_RESULTS';
import VITALS from '@salesforce/label/c.PP_AS_VITALS';
import MEASUREMENTS from '@salesforce/label/c.PP_AS_MEASUREMENTS';
import CONDITIONAL_FEATURE from '@salesforce/label/c.PP_AS_CONDITIONAL_FEATURE';

export default class PpDelegateTasksTable extends LightningElement {
    @api userMode = '';
    @api isMobile = false;
    @api isRTL = false;
    header = '';
    labels = {
        CONDITIONAL_FEATURE,
        DELEGATE_TASK
    };
    @track accessList = [
        { label: COMPLETE_TASK, value: '01' },
        { label: RECEIVE_EMAIL, value: '02' },
        { label: LAB_RESULTS, value: '03' },
        { label: VITALS, value: '04' },
        { label: MEASUREMENTS, value: '05' }
    ];

    get listClass() {
        return this.isMobile
            ? this.isRTL
                ? 'slds-m-right_xx-small'
                : 'slds-m-left_xx-small'
            : this.isRTL
            ? 'slds-m-right_small'
            : 'slds-m-left_small';
    }

    toggleSection() {
        let sectionContainer = this.template.querySelector(`[data-id="section-container"]`);
        if (sectionContainer) {
            if (sectionContainer.classList.contains('slds-is-close')) {
                sectionContainer.classList.remove('slds-is-close');
                sectionContainer.classList.add('slds-is-open');
            } else if (sectionContainer.classList.contains('slds-is-open')) {
                sectionContainer.classList.remove('slds-is-open');
                sectionContainer.classList.add('slds-is-close');
            }
        }
    }
}
