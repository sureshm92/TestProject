import { LightningElement,api, track,wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
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

const CTP_Fields = ['Clinical_Trial_Profile__c.Is_Program__c', 'Clinical_Trial_Profile__c.Status_Milestone_Available__c'];

const titleColumns = [
    { label: 'Status Name', fieldName: 'Status_Name__c' },
    { label: 'Title', fieldName: 'Status_Description__c', editable: true },
    { label: 'Description', fieldName: 'Status_Motivational_Message__c', editable: true}
];

const milestoneColumns = [
    { label: 'Milestone Name', fieldName: 'Status_Name__c' },
    { label: 'Title', fieldName: 'Status_Description__c', editable: true },
    { label: 'Description', fieldName: 'Status_Motivational_Message__c', editable: true}
];

export default class PpStatusDescConfig extends LightningElement {
    @track ctpRecord;
    @api recordId;
    @track isDisabled = true;
    data = null;
    isprogram;
    isstatusmilestoneavailable;
    statusTitleData = null;
    statusilestoneData = null;
    columns = columns;
    titleColumns = titleColumns;
    milestoneColumns = milestoneColumns;
    configResult;
    errors = { rows: {}};
    preTrialStatusErrors = { rows: {}};
    preTrialMilestoneErrors = { rows: {}};
    showConfig = true;
    featureUnavailale = false;
    label = {
        PP_Study_Status_Unavailable
    };
    receivedMessage = '';
    ppProgressBarMessage = '';
    subscription = null;
    context = createMessageContext();

    @wire(getRecord,{recordId:'$recordId', fields: CTP_Fields})
    ctpDetail({error,data}){
        if(data){
            this.ctpRecord=data;
            this.isprogram = getFieldValue(data,'Clinical_Trial_Profile__c.Is_Program__c');
            this.isstatusmilestoneavailable = getFieldValue(data,'Clinical_Trial_Profile__c.Status_Milestone_Available__c');
            console.log('both field value', this.isprogram,this.isstatusmilestoneavailable);
        } else if(error){
            console.error('Error fetching ctp record', error);
        }
    }

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
                    this.configResult = result;
                    this.data = result[1];
                    this.statusTitleData = result[0];
                    this.statusilestoneData = result[2];
                    this.showConfig=true;
                    this.handleCancel();
                    console.log('program is '+this.program);
                } 
            })
            .catch(error => {
                console.log(error);
            });
    }
    handleEditCellChange(event){
        var rowsError = this.errors.rows;
        let targetName = event.target.name;
        let messageCharacterLimit = 100;
        let descriptionError = 'Please enter Status Description under 200 characters';
        let motiationalFieldError = 'Please enter Status Motivational Message under 100 characters';
        if(targetName == 'statusConfig'){
            messageCharacterLimit = 200;
            descriptionError = 'Please enter Status Title under 200 characters';
            motiationalFieldError = 'Please enter Status Description under 200 characters';
        }
        if(targetName == 'milestoneConfig'){
            messageCharacterLimit = 200;
            descriptionError = 'Please enter Milestone Title under 200 characters';
            motiationalFieldError = 'Please enter Milestone Description under 200 characters';
        }
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
                        msg.push(descriptionError);
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
                if(event.detail.draftValues[0].Status_Motivational_Message__c.length>messageCharacterLimit){
                    if(!fldNm.includes('Status_Motivational_Message__c')){
                        msg.push(motiationalFieldError);
                        fldNm.push('Status_Motivational_Message__c');
                    }
                }
                else{
                    if(fldNm.includes('Status_Motivational_Message__c')){
                        msg.splice(msg.indexOf(motiationalFieldError),1);
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
        
        if(targetName == 'statusConfig'){
            this.preTrialStatusErrors =  { rows: rowsError};
        }
        if(targetName == 'milestoneConfig'){
            this.preTrialMilestoneErrors =  { rows: rowsError};
        }
        if(targetName == 'studyConfig'){
            this.errors =  { rows: rowsError};
        }
        this.isDisabled = false;
    }

    handleSave() {
        console.log('handleSave');
        if(JSON.stringify(this.errors).includes('Status_Motivational_Message__c') || JSON.stringify(this.errors).includes('Status_Description__c')
        || JSON.stringify(this.preTrialStatusErrors).includes('Status_Motivational_Message__c') || JSON.stringify(this.preTrialStatusErrors).includes('Status_Description__c')
        || JSON.stringify(this.preTrialMilestoneErrors).includes('Status_Motivational_Message__c') || JSON.stringify(this.preTrialMilestoneErrors).includes('Status_Description__c')){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: "Please correct all error messages.",
                    variant: "error"
                })
            );
        }
        else{
            let draftConfigurations = this.template.querySelector("lightning-datatable[data-tabid=inTrialStatusTab]").draftValues;
            if(!this.isprogram && this.isstatusmilestoneavailable){
                draftConfigurations = draftConfigurations.concat(this.template.querySelector("lightning-datatable[data-tabid=preMileTab]").draftValues);
                draftConfigurations = draftConfigurations.concat(this.template.querySelector("lightning-datatable[data-tabid=preStatusTab]").draftValues);
            }
            
            updateStatusConfig({ recs: draftConfigurations })
                .then(result => {
                    if(result){
                        this.data=null;
                        this.statusTitleData = null;
                        this.statusilestoneData = null;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Success",
                                message: "Records updated",
                                variant: "success"
                            })
                        );
                        this.getData();
                        //this.hasChanges = false;
                        this.isDisabled = true;
                    }
                })
                .catch(error => {
                    console.log(error);
                });
                
        }
        
    }
    handleChange(event) {
        this.data=null;
        this.statusTitleData = null;
        this.statusilestoneData = null;
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
        this.preTrialStatusErrors = { rows: {}};
        this.preTrialMilestoneErrors = { rows: {}};
        this.template.querySelector("lightning-datatable[data-tabid=preStatusTab]").draftValues = [];
        this.template.querySelector("lightning-datatable[data-tabid=preMileTab]").draftValues = [];
        this.template.querySelector("lightning-datatable[data-tabid=inTrialStatusTab]").draftValues = [];
        this.isDisabled = true;
    }

    get showPreTrialConfig(){
        if(this.ctpRecord){
        return (!this.isprogram && this.isstatusmilestoneavailable);
        }
    }
}