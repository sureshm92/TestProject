import { LightningElement,wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import callUCPMtoFetchLatestConsentsFromRecord from "@salesforce/apex/UCPM_FetchConsentFromButtonController.callUCPMtoFetchLatestConsentsFromRecord";

export default class UCPM_ConsentFetchButton extends LightningElement {
    clickedButtonLabel;
    recordId;
    objectname;
    @wire(CurrentPageReference) pageRef;

   
    handleClick(event) {
        this.clickedButtonLabel = event.target.label;
        console.log('inside method'+ this.clickedButtonLabel);
        this.recordId = this.pageRef.attributes.recordId;
        console.log('inside method'+ this.recordId);
        this.objectname = this.currentPageReference?.state?.objectname;
        
        //call apex class
        callUCPMtoFetchLatestConsentsFromRecord({
            applicationId: this.recordId
        })
            .then((result) => {
                console.log('result--->'+result);
                const event = new ShowToastEvent({
                    variant: 'success',
                    message:
                        'Latest consents fetched from UCPM successfully.',
                });
                this.dispatchEvent(event);
            })
            .catch((error) => {
                const event = new ShowToastEvent({
                    variant: 'error',
                    message:
                        'Latest consents fetched from UCPM failed.',
                });
                this.dispatchEvent(event);
                console.log(error);
            });
    }
}