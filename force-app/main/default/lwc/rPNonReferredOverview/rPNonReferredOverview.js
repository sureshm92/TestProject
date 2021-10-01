import { LightningElement,track,wire,api } from 'lwc';
import getPEDetails from '@salesforce/apex/RPRecordReviewLogController.getPECountDetails';
import { refreshApex } from '@salesforce/apex';
import RH_RP_Overview_for from '@salesforce/label/c.RH_RP_Overview_for';
import RH_RP_Not_Yet_Referred from '@salesforce/label/c.RH_RP_Not_Yet_Referred';
import RH_RP_Total_Patients from '@salesforce/label/c.RH_RP_Total_Patients';
import RH_RP_Included_for_Referring from '@salesforce/label/c.RH_RP_Included_for_Referring';
import RH_RP_Excluded_for_Referring from '@salesforce/label/c.RH_RP_Excluded_for_Referring';
import RH_RP_Patient_Auth_Aquired from '@salesforce/label/c.RH_RP_Patient_Auth_Aquired';
import RH_RP_Medical_Review from '@salesforce/label/c.RH_RP_Medical_Review';
import BTN_Complete from '@salesforce/label/c.BTN_Complete';
import RH_RP_Outreach_Mail_Sent from '@salesforce/label/c.RH_RP_Outreach_Mail_Sent';
import RH_RP_Patients_Added from '@salesforce/label/c.RH_RP_Patients_Added';
import RH_RP_Last_Month from '@salesforce/label/c.RH_RP_Last_Month';
import RH_RP_Last_Week from '@salesforce/label/c.RH_RP_Last_Week';
import RH_RP_Yesterday from '@salesforce/label/c.RH_RP_Yesterday';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';

export default class RPNonReferredOverview extends LightningElement {

    @track data = [];
    @track error;
    @api userMode;
    @api delegateId;

    label = {
        RH_RP_Overview_for,
        RH_RP_Not_Yet_Referred,
        RH_RP_Total_Patients,
        RH_RP_Included_for_Referring,
        RH_RP_Excluded_for_Referring,
        RH_RP_Patient_Auth_Aquired,
        RH_RP_Medical_Review,
        BTN_Complete,
        RH_RP_Outreach_Mail_Sent,
        RH_RP_Patients_Added,
        RH_RP_Last_Month,
        RH_RP_Last_Week,
        RH_RP_Yesterday
    };
    
    // Getting PE Details
    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
        .then(() => {
            this.userMode = communityService.getUserMode();
            console.log('frmtablemode'+ this.userMode);
            this.delegateId = communityService.getDelegateId();
            console.log('frmtableid'+  this.delegateId );
        })
        .then(() => {
            getPEDetails({ userMode: this.userMode, delegateId: this.delegateId })
            .then(result => {
                this.data = result;
                console.log('cc'+JSON.stringify(result));
            }) .catch((error => {
                console.log('Err:'+JSON.stringify(error));
            })); 
        })
        .catch((error) => {
            console.log('Error: ' + error);
        });
        
    }
}