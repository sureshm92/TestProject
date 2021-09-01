import { LightningElement,track,wire,api } from 'lwc';
import getPEDetails from '@salesforce/apex/RPRecordReviewLogController.getPECountDetails';
import { refreshApex } from '@salesforce/apex';
export default class RPNonReferredOverview extends LightningElement {

    @track data = [];
    @track error;
    
    // Getting PE Details
    connectedCallback() {
         console.log('connectedcallback');
         getPEDetails()
         .then(result => {
             this.data = result;
             console.log('cc'+JSON.stringify(result));
         })
         .catch(error => { 
             this.error = error;
         });
    }
}