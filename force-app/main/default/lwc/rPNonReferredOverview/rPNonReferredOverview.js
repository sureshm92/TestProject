import { LightningElement,track,wire,api } from 'lwc';
import getPEDetails from '@salesforce/apex/RPRecordReviewLogController.getPECountDetails';

export default class RPNonReferredOverview extends LightningElement {

    @track data = [];
    @track error;
    
    // Getting PE using Wire Service
    @wire(getPEDetails)
    PE(result) {
        if (result.data) {
            this.data = result.data;
            console.log(JSON.stringify(this.data));
            this.error = undefined;
        } else if (result.error) {
            console.log('Error'+JSON.stringify(result.error));
            this.error = result.error;
            this.data = undefined;
        }
    }
  
}