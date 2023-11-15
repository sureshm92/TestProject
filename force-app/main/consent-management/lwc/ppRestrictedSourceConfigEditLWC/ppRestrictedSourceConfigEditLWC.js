import { LightningElement ,api,wire,track} from 'lwc';
import { getRecord ,getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SPONSER_FIELD from "@salesforce/schema/Clinical_Trial_Profile__c.Study_Sponsor__c";
import getRestrictedSourceConfigRecord from '@salesforce/apex/ppNewRestrictedSourceConfigCon.getRestrictedSourceConfigRecord';
import { NavigationMixin } from 'lightning/navigation';
import BTN_Save from '@salesforce/label/c.RH_RP_Save';
import BTN_Cancel from '@salesforce/label/c.BTN_Cancel';
import BTN_Close from '@salesforce/label/c.BTN_Close';
import Edit_Restricted_Source from '@salesforce/label/c.Edit_Restricted_Source';


const fields = [SPONSER_FIELD];

export default class ToastNotificationExampleLWC extends NavigationMixin(LightningElement){ 
	@api parentrecId;
    @api objectApiName='Restricted_Source_Config__c';
    configrecords;
    isShowModal = false;
    referralSource;
    recordId;
    isLoading = false;


    label = {
        BTN_Save,
        BTN_Cancel,
        BTN_Close,
        Edit_Restricted_Source
    };


    connectedCallback() {
        this.isLoading = true;
        getRestrictedSourceConfigRecord({ recordId: this.parentrecId })
		.then(result => {
            this.configrecords = result;
            this.referralSource = result.Referral_Resource__c;
            this.recordId = result.Id;
		})
		.catch(error => {
			this.error = error;
			this.configrecords = undefined;
            this.isLoading = false;
		})
        this.isShowModal = true; 
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
        const fields = event.detail.fields;
        this.template
            .querySelector('lightning-record-edit-form').submit();
        this.showSuccessToast();
        this.hideModalBox();
    }
    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Toast Success',
            message: 'Record Updated Successfully',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}