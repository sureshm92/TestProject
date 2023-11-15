import { LightningElement ,api,wire,track} from 'lwc';
import { getRecord ,getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SPONSER_FIELD from "@salesforce/schema/Clinical_Trial_Profile__c.Study_Sponsor__c";
import getRestrictedSourceConfigData from '@salesforce/apex/ppNewRestrictedSourceConfigCon.getRestrictedSourceConfigData';
import { NavigationMixin } from 'lightning/navigation';
import BTN_Save from '@salesforce/label/c.RH_RP_Save';
import BTN_Cancel from '@salesforce/label/c.BTN_Cancel';
import BTN_Close from '@salesforce/label/c.BTN_Close';
import New_Restricted_Source from '@salesforce/label/c.New_Restricted_Source';


const fields = [SPONSER_FIELD];

export default class ToastNotificationExampleLWC extends NavigationMixin(LightningElement) {
	@api parentrecId;
    @api objectApiName='Restricted_Source_Config__c';
    isShowModal = false;
    isLoading = false;

    
    label = {
        BTN_Save,
        BTN_Cancel,
        BTN_Close,
        New_Restricted_Source
    };

    connectedCallback() {
        this.isShowModal = true; 
        this.isLoading = true;
    }
    handleLoad(){
        this.isLoading = false;
    }
    hideModalBox() {  
        this.isShowModal = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.parentrecId,
                objectApiName: 'Clinical_Trial_Profile__c',
                actionName: 'view'
            },
        });
        const newEvent = new CustomEvent("modalvaluechange");
        this.dispatchEvent(newEvent);
    }
  
    @wire(getRecord, {
        recordId: "$parentrecId",
        fields
      })
      record;
    
 
    get sponsername() {
        return getFieldValue(this.record.data, SPONSER_FIELD);
    }

    handleOkay(event){
        getRestrictedSourceConfigData({ recordId: this.parentrecId })
		.then(result => {
            if(result >= 1){
              this.showErrorToast();
            }
            else{
                // Here you can execute any logic before submit
                this.template
                    .querySelector('lightning-record-edit-form').submit();
                this.showSuccessToast();
                this.hideModalBox();
            }
		})
    }
   
    showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Toast Error',
            message: 'Can not add more than one record . please update the existing record.',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Toast Success',
            message: 'Record Created Successfully',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}