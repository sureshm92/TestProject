import { LightningElement,api } from 'lwc';
import fetchStatusConfig from '@salesforce/apex/ppStatusDescConfigController.fetchStatusConfig';
import updateStatusConfig from '@salesforce/apex/ppStatusDescConfigController.updateStatusConfig';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import PP_Study_Status_Unavailable from '@salesforce/label/c.PP_Study_Status_Unavailable';
import { subscribe,createMessageContext } from 'lightning/messageService';
import ppToggleMessageChannel from "@salesforce/messageChannel/ppStudyUpdates__c";
const columns = [
    { label: 'Status Name', fieldName: 'Status_Name__c' },
    { label: 'Status Description', fieldName: 'Status_Description__c', editable: true },
    { label: 'Status Motivational Message', fieldName: 'Status_Motivational_Message__c', editable: true }
];

export default class PpStatusDescConfig extends LightningElement {
    @api recordId;
    data = null;
    columns = columns;
    errors = { rows: {}};
    featureUnavailale = false;
    label = {
        PP_Study_Status_Unavailable
    };
    receivedMessage = '';
    ppProgressBarMessage = '';
    subscription = null;
    context = createMessageContext();
    connectedCallback(){
        this.getData();
        this.subscribeToMessageChannel();
    }
    getData(){
        fetchStatusConfig({ recId: this.recordId })
            .then(result => {
                if(result == null){
                    this.featureUnavailale = true;
                }else{
                    this.data = result;
                }
            })
            .catch(error => {
                console.log(error);
            });
    }
    handleEditCellChange(event){
        var rowsError = this.errors.rows;
        for(var i = 0; i<event.detail.draftValues.length; i++){
            var msg = [];
            var fldNm = [];
            var currRecErr = rowsError[event.detail.draftValues[0].Id];
            if(currRecErr && currRecErr.messages){
                msg = currRecErr.messages;
                fldNm = currRecErr.fieldNames;
            }
            if(event.detail.draftValues[i].Status_Description__c || event.detail.draftValues[i].Status_Description__c == ""){
                if(event.detail.draftValues[0].Status_Description__c.length>200){
                    if(!fldNm.includes('Status_Description__c')){
                        msg.push('Please enter Status Description under 200 characters');
                        fldNm.push('Status_Description__c');
                    }
                }
                else{
                    if(fldNm.includes('Status_Description__c')){
                        msg.splice(msg.indexOf('Please enter Status Description under 200 characters'),1);
                        fldNm.splice(fldNm.indexOf('Status_Description__c'),1);
                    }
                }
            }
            if(event.detail.draftValues[i].Status_Motivational_Message__c || event.detail.draftValues[i].Status_Motivational_Message__c == ""){
                if(event.detail.draftValues[0].Status_Motivational_Message__c.length>100){
                    if(!fldNm.includes('Status_Motivational_Message__c')){
                        msg.push('Please enter Status Motivational Message under 100 characters');
                        fldNm.push('Status_Motivational_Message__c');
                    }
                }
                else{
                    if(fldNm.includes('Status_Motivational_Message__c')){
                        msg.splice(msg.indexOf('Please enter Status Motivational Message under 100 characters'),1);
                        fldNm.splice(fldNm.indexOf('Status_Motivational_Message__c'),1);
                    }
                }
            }
            if(msg.length>0){
                rowsError[event.detail.draftValues[i].Id]={
                    messages : msg,
                    fieldNames : fldNm,
                    title : 'Error'
                };
            }
            else{
                rowsError[event.detail.draftValues[i].Id]={};
            }
        }
        
        this.errors = { rows: rowsError};
        
    }

    handleSave(event) {
        if(JSON.stringify(this.errors).includes('Status_Motivational_Message__c') || JSON.stringify(this.errors).includes('Status_Description__c')){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: "Please correct all error messages.",
                    variant: "error"
                })
            );
        }
        else{
            updateStatusConfig({ recs: event.detail.draftValues })
                .then(result => {
                    if(result){
                        this.data=null;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Success",
                                message: "Records updated",
                                variant: "success"
                            })
                        );
                        this.getData();
                    }
                })
                .catch(error => {
                    console.log(error);
                });
        }
    }
    handleChange(event) {
        this.data=null;
        this.getData();

    }
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(this.context, ppToggleMessageChannel, (message) => {
                this.handleChange(message);
            });
        }
    }
    handleCancel(){
        this.errors = { rows: {}};
    }
}