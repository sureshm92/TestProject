import { LightningElement,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions'; 
import { NavigationMixin } from 'lightning/navigation';
import callUCPMtoFetchLatestConsentsFromRecord from "@salesforce/apex/UCPM_FetchConsentFromButtonController.callUCPMtoFetchLatestConsentsFromRecord";

export default class uCPM_ConsentFetchButtonOnRecord extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    isLoading = false;
    disableButton =false;
    status;

    refreshRecord() {
        this.isLoading = true;
        this.disableButton = true;

        //call apex class
        callUCPMtoFetchLatestConsentsFromRecord({
            applicationId: this.recordId
        })
        .then((result) => {
            this.status=result;
            if(this.status=='TRUE'){
            const event = new ShowToastEvent({
                variant: 'success',
                message:
                    'Latest consent fetched from UCPM successfully.',
            });
            this.isLoading = false;
            this.disableButton = false ;
            this.dispatchEvent(event);
            this.closeAction();
            let redirect=window.location.origin +'/' + this.recordId; 
            window.open(redirect,'_self');
            }
            else if(this.status=='FALSE PPMID'){
                const event = new ShowToastEvent({
                    variant: 'error',
                    message:
                        'Failed to fetch latest consent from UCPM since PPMID is not present.',
                });
                this.dispatchEvent(event);
                this.isLoading = false;
                this.disableButton = true ;
            }
            else if(this.status=='FALSE'){
                const event = new ShowToastEvent({
                    variant: 'error',
                    message:
                        'Failed to fetch latest consent from UCPM.',
                });
                this.dispatchEvent(event);
                this.isLoading = false;
                this.disableButton = true ;
            }
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