import { LightningElement,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions'; 
import callUCPMtoFetchLatestConsentsFromRecord from "@salesforce/apex/UCPM_FetchConsentFromButtonController.callUCPMtoFetchLatestConsentsFromRecord";

export default class uCPM_ConsentFetchButtonOnRecord extends LightningElement {
    @api recordId;
    @api objectApiName;
    isLoading = false;
    disableButton =false;

    refreshRecord() {
        this.isLoading = true;
        this.disableButton = true;

        //call apex class
        callUCPMtoFetchLatestConsentsFromRecord({
            applicationId: this.recordId
        })
        .then((result) => {
            const event = new ShowToastEvent({
                variant: 'success',
                message:
                    'Latest consent fetched from UCPM successfully.',
            });
            this.isLoading = false;
            this.disableButton = false ;
            this.dispatchEvent(event);
            this.closeAction();
        })
        .catch((error) => {
            const event = new ShowToastEvent({
                variant: 'error',
                message:
                    'Failed to fetch latest consent from UCPM.',
            });
            this.dispatchEvent(event);
            console.log(error);
            this.isLoading = false;
            this.disableButton = true ;
        });
    }

    closeAction() { 
        this.dispatchEvent(new CloseActionScreenEvent());
    } 
}