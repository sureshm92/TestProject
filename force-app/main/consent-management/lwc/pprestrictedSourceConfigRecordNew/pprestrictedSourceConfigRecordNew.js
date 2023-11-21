import { LightningElement ,api,wire,track} from 'lwc';
import { getRecord ,getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SPONSER_FIELD from "@salesforce/schema/Clinical_Trial_Profile__c.Study_Sponsor__c";
import NAME_FIELD from "@salesforce/schema/Clinical_Trial_Profile__c.Name";
import getRestrictedSourceConfigData from '@salesforce/apex/ppNewRestrictedSourceConfigCon.getRestrictedSourceConfigData';
import { NavigationMixin } from 'lightning/navigation';
import BTN_Save from '@salesforce/label/c.RH_RP_Save';
import BTN_Cancel from '@salesforce/label/c.BTN_Cancel';
import BTN_Close from '@salesforce/label/c.BTN_Close';
import TST_Something_went_wrong from '@salesforce/label/c.TST_Something_went_wrong';
import New_Restricted_Source from '@salesforce/label/c.New_Restricted_Source';
import Restricted_Source_Record_Error from '@salesforce/label/c.Restricted_Source_Record_Error';
import Restricted_Source_Creation from '@salesforce/label/c.Restricted_Source_Creation';
 
 
 
const fields = [SPONSER_FIELD,NAME_FIELD];
 
export default class ToastNotificationExampleLWC extends NavigationMixin(LightningElement) {
	@api parentrecId;
    @api objectApiName='Restricted_Source_Config__c';
    isShowModal = false;
    isLoading = false;
    restrictedconfigToBeShown;
 
    
    label = {
        BTN_Save,
        BTN_Cancel,
        BTN_Close,
        New_Restricted_Source,
        TST_Something_went_wrong,
        Restricted_Source_Record_Error,
        Restricted_Source_Creation
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
 
    get studyname() {
        return getFieldValue(this.record.data, NAME_FIELD);
    }
 
    handleOkay(event){
        getRestrictedSourceConfigData({ recordId: this.parentrecId })
		.then(result => {
            if(result >= 1){
              this.showErrorToast(this.label.Restricted_Source_Record_Error,'error','dismissable');
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
    handleSuccess(event) {
        this.restrictedconfigToBeShown = event.detail.id;
    }
    handleError(event) {
        let message = event.detail.detail;
        message = this.label.TST_Something_went_wrong;
        this.showErrorToast(message, 'error','dismissable');
    }
    showErrorToast(theMessage,theVariant,theMode) {
        const evt = new ShowToastEvent({
            message: theMessage,
            variant: theVariant,
            mode: theMode
        });
        this.dispatchEvent(evt);
    }
    showSuccessToast() {
        var stringToreplace = this.label.Restricted_Source_Creation.replace('{0}', this.studyname);
        const evt = new ShowToastEvent({
            message: stringToreplace,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}