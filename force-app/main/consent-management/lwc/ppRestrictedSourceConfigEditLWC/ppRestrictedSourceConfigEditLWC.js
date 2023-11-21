import { LightningElement ,api,wire,track} from 'lwc';
import { getRecord ,getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SPONSER_FIELD from "@salesforce/schema/Clinical_Trial_Profile__c.Study_Sponsor__c";
import NAME_FIELD from "@salesforce/schema/Clinical_Trial_Profile__c.Name";
import getRestrictedSourceConfigRecord from '@salesforce/apex/ppNewRestrictedSourceConfigCon.getRestrictedSourceConfigRecord';
import { NavigationMixin } from 'lightning/navigation';
import BTN_Save from '@salesforce/label/c.RH_RP_Save';
import BTN_Cancel from '@salesforce/label/c.BTN_Cancel';
import BTN_Close from '@salesforce/label/c.BTN_Close';
import TST_Something_went_wrong from '@salesforce/label/c.TST_Something_went_wrong';
import Edit_Restricted_Source from '@salesforce/label/c.Edit_Restricted_Source';
import Restricted_Source_Updation from '@salesforce/label/c.Restricted_Source_Updation';
 
const fields = [SPONSER_FIELD,NAME_FIELD];
 
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
        Edit_Restricted_Source,
        TST_Something_went_wrong,
        Restricted_Source_Updation
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
    get studyname() {
        return getFieldValue(this.record.data, NAME_FIELD);
    }
 
    handleError(event){
        let message = event.detail.detail;
        //do some stuff with message to make it more readable
        message = this.label.TST_Something_went_wrong;
        this.showErrorToast(message,'error','dismissable');
    }
    handleOkay(event){
        const fields = event.detail.fields;
        this.template
            .querySelector('lightning-record-edit-form').submit();
        this.showSuccessToast();
        this.hideModalBox();
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
        var stringToReplace = this.label.Restricted_Source_Updation.replace('{0}', this.studyname);
        const evt = new ShowToastEvent({
            message: stringToReplace,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}