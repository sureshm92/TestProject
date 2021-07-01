import { LightningElement, api,track } from 'lwc';
import community_icon from '@salesforce/resourceUrl/rr_community_icons';
import getpatient from '@salesforce/apex/NonReferredPatientController.getpatientdetails';
import RPR_Actions from '@salesforce/label/c.RPR_Actions';
import RPR_Patient_Id from '@salesforce/label/c.RPR_Patient_Id';
import RPR_First_Name from '@salesforce/label/c.RPR_First_Name';
import RPR_Last_Name from '@salesforce/label/c.RPR_Last_Name';
import RPR_Excluded from '@salesforce/label/c.RPR_Excluded';
import RPR_Outreach_Status from '@salesforce/label/c.RPR_Outreach_Status';
import RPR_Consent from '@salesforce/label/c.RPR_Consent';
import RPR_Attestation from '@salesforce/label/c.RPR_Attestation';
import RPR_Medical_Review from '@salesforce/label/c.RPR_Medical_Review';
import RPR_Email from '@salesforce/label/c.RPR_Email';
import RPR_Study_Code_Name from '@salesforce/label/c.RPR_Study_Code_Name';
import RPR_YOB from '@salesforce/label/c.RPR_YOB';
import RPR_Site_Name from '@salesforce/label/c.RPR_Site_Name';
import RPR_Country from '@salesforce/label/c.RPR_Country';
import RPR_State from '@salesforce/label/c.RPR_State';
 
export default class NonReferredParticipantList extends LightningElement {
    @api currentPageList = [];
    @api studyFilterEnabled; @track isModalOpen = false;  @api patdetails={};
    @track showModal = false;
    @track showNegativeButton;
    @track showPositiveButton = true;
    @track positiveButtonLabel = 'Close';

    close_icon = community_icon + '/close.svg';
    check_icon = community_icon + '/checkGreen.svg';
    lock_icon = community_icon + '/lock.svg';
    comment_icon = community_icon + '/comments.svg';
    sendtostudy_icon = community_icon + '/sendToStudy.svg';

    label = {
        RPR_Actions,
        RPR_Patient_Id,
        RPR_First_Name,
        RPR_Last_Name,
        RPR_Excluded,
        RPR_Outreach_Status,
        RPR_Consent,
        RPR_Attestation,
        RPR_Medical_Review,
        RPR_Email,
        RPR_YOB,
        RPR_Study_Code_Name,
        RPR_Site_Name,
        RPR_Country,
        RPR_State

    };
    connectedCallback(){
    }
   /**showModalPopup() {
        this.showModal = true;
   }
   closeModal() {
        this.showModal = false;
    }**/
    openModal(event) {
        console.log('RecId-->'+event.currentTarget.dataset.value);
        getpatient({ patid: event.currentTarget.dataset.value })
        .then((result) => {
            this.patdetails = result;
            console.log('Record-->'+ this.patdetails.Id);
        })
        .catch((error) => {
            console.log(error);
        });
        console.log('<---Refresh-->');
        this.showModal = true;
    }
    closeModal() {
        this.showModal = false;
    }
    get title() {
        return this.patdetails.Patient_ID__c+'<p>&nbsp;</p>'+this.patdetails.Participant_Name__c+'<p>&nbsp;</p>'+this.patdetails.Participant_Name__c;
     }  
}