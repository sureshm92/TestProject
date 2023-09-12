import { LightningElement,api, track,wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Is_Program from '@salesforce/schema/Clinical_Trial_Profile__c.Is_Program__c';
import Status_Milestone_Available from '@salesforce/schema/Clinical_Trial_Profile__c.Status_Milestone_Available__c';
import Community_Template from '@salesforce/schema/Clinical_Trial_Profile__c.CommunityTemplate__c';
import fetchStatusConfig from '@salesforce/apex/ppStatusDescConfigController.fetchStatusConfig';
import updateStatusConfig from '@salesforce/apex/ppStatusDescConfigController.updateStatusConfig';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import PP_Study_Status_Unavailable from '@salesforce/label/c.PP_Study_Status_Unavailable';
import PP_Updated_Study_Status_Unavailable from '@salesforce/label/c.PP_Updated_Study_Status_Unavailable';
import { subscribe,createMessageContext } from 'lightning/messageService';
import ppToggleMessageChannel from "@salesforce/messageChannel/ppStudyUpdates__c";
import { refreshApex } from '@salesforce/apex';

const columns = [
    { label: 'Status Name', fieldName: 'Status_Name__c' },
    { label: 'Status Description', fieldName: 'Status_Description__c', editable: true },
    { label: 'Status Motivational Message', fieldName: 'Status_Motivational_Message__c', editable: true }
];

const titleColumns = [
    { label: 'Status Name', fieldName: 'Status_Label__c' },
    { label: 'Title', fieldName: 'Status_Description__c', editable: true },
    { label: 'Description', fieldName: 'Status_Motivational_Message__c', editable: true}
];

const milestoneColumns = [
    { label: 'Milestone Name', fieldName: 'Status_Label__c' },
    { label: 'Title', fieldName: 'Status_Description__c', editable: true },
    { label: 'Description', fieldName: 'Status_Motivational_Message__c', editable: true}
];

export default class PpStatusDescConfig extends LightningElement {
    @track ctpRecord;
    @api recordId;
    @track isDisabled = true;
    data = null;
    @track isProgram;
    @track isStatusMilestoneAvailable;
    @track communityTemplate;
    ctpData;
    statusTitleData = null;
    statusilestoneData = null;
    columns = columns;
    titleColumns = titleColumns;
    milestoneColumns = milestoneColumns;
    configResult;
    errors = { rows: {}};
    preTrialStatusErrors = { rows: {}};
    preTrialMilestoneErrors = { rows: {}};
    featureUnavailale = true;
    label = {
        PP_Study_Status_Unavailable,
        PP_Updated_Study_Status_Unavailable
    };
    receivedMessage = '';
    ppProgressBarMessage = '';
    subscription = null;
    context = createMessageContext();

    @wire(getRecord,{recordId:'$recordId', fields:[Is_Program,Status_Milestone_Available,Community_Template]})
    ctpDetail(response) {
        this.ctpData = response;
        const { data, error } = response; // destructure the provisioned value
        if (data) { 
            this.ctpRecord = data;
            this.isProgram = getFieldValue(response.data,Is_Program);
            this.isStatusMilestoneAvailable = getFieldValue(response.data,Status_Milestone_Available);
            this.communityTemplate = getFieldValue(response.data,Community_Template);
        }
        else if (error) {}
    }

    connectedCallback(){
        this.getData();
        this.subscribeToMessageChannel();
    }
    getData(){
        fetchStatusConfig({ recId: this.recordId })
            .then(result => {
                if(result != null){
                    this.featureUnavailale = false;
                    this.configResult = result;
                    this.statusTitleData = result[0];
                    this.data = result[1];
                    this.statusilestoneData = result[2];
                    this.handleCancel();
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
                        msg.splice(msg.indexOf(descriptionError),1);
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
            let draftConfigurations;
            if(this.communityTemplate!='Janssen'){
                draftConfigurations = this.template.querySelector("lightning-datatable[data-tabid=inTrialStatusTab]").draftValues;
                if(!this.isProgram && this.isStatusMilestoneAvailable){
                    draftConfigurations = draftConfigurations.concat(this.template.querySelector("lightning-datatable[data-tabid=preMileTab]").draftValues);
                    draftConfigurations = draftConfigurations.concat(this.template.querySelector("lightning-datatable[data-tabid=preStatusTab]").draftValues);
                }
            }else{
                if(!this.isProgram && this.isStatusMilestoneAvailable){
                    draftConfigurations = this.template.querySelector("lightning-datatable[data-tabid=preMileTab]").draftValues;
                    draftConfigurations = draftConfigurations.concat(this.template.querySelector("lightning-datatable[data-tabid=preStatusTab]").draftValues);
                }
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
        this.configResult = null;
        this.featureUnavailale = true;
        this.data=null;
        this.statusTitleData = null;
        this.statusilestoneData = null;
        this.getData();
        refreshApex(this.ctpData);
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
        if(this.template.querySelector("lightning-datatable[data-tabid=preStatusTab]") != null){
            this.template.querySelector("lightning-datatable[data-tabid=preStatusTab]").draftValues = [];
        }
        if(this.template.querySelector("lightning-datatable[data-tabid=preMileTab]") != null){
            this.template.querySelector("lightning-datatable[data-tabid=preMileTab]").draftValues = [];
        }
        if(this.template.querySelector("lightning-datatable[data-tabid=inTrialStatusTab]") != null){
            this.template.querySelector("lightning-datatable[data-tabid=inTrialStatusTab]").draftValues = [];
        }
        
        this.isDisabled = true;
    }
    get showStatusTitleTab(){
        return (!this.isProgram && this.isStatusMilestoneAvailable && this.configResult != null && this.statusTitleData!=null);
    }

    get showStatusMilestoneTab(){
        return (!this.isProgram && this.isStatusMilestoneAvailable && this.configResult != null && this.statusilestoneData!=null);
    }

    get showPreTrialConfigTab(){
        return (this.data != null && this.data!='' && this.communityTemplate!='Janssen' );
    }

    get featureUnavailaleMessage(){
        return (this.isProgram ? this.label.PP_Updated_Study_Status_Unavailable :this.label.PP_Study_Status_Unavailable);         
    }
}