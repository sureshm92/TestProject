import { LightningElement, wire, api } from 'lwc';
import image from '@salesforce/resourceUrl/createParticipantIcon';
import getAccessToken from '@salesforce/apex/CreateParticipantController.getAccessToken';
import getResponse from '@salesforce/apex/CreateParticipantController.getDocumentCollections';
import getConsentParams from '@salesforce/apex/CreateParticipantController.getCreateConsentParams';
import participantCreationOnEconsent from '@salesforce/apex/CreateParticipantController.participantCreationOnEconsent';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import POP_UP_Header from '@salesforce/label/c.Create_participant_header';
import DropDown_Label from '@salesforce/label/c.Pop_drop_down_label';
import Technical_Error from '@salesforce/label/c.Create_Participant_Technical_Error';
import BTN_OK from '@salesforce/label/c.BTN_OK';
import BTN_CANCEL from '@salesforce/label/c.BTN_Cancel';
import BTN_NAME from '@salesforce/label/c.Create_participant_button_label';
import Main_Header from '@salesforce/label/c.create_Participant_Main_Header';
import Message from '@salesforce/label/c.create_participant_message';
import Updated_Message from  '@salesforce/label/c.create_participant_updated_message';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex'

export default class CreateParticipant extends LightningElement {
    createParticipantIcon = image;
    consentData;
    innerspinner = true;
    @api participantenrollmentid;
    @api peid;
    okDisabled = true;
    isDropdownSelected = true;
    messages;
    userTimezone = TIME_ZONE;
    isModalOpen = false;
    returnValue = [];
    isbuttonvisible=true;
    @api SelectedCollection;
    initialdata ={"isDisabled": false,"isEnabled" : false}
    wiredIntialData={};

    label={
        BTN_NAME,
        POP_UP_Header,
        DropDown_Label,
        BTN_OK,
        BTN_CANCEL,
        Message,
        Technical_Error,
        Updated_Message,
        Main_Header
    }

    //fetch prerequisit to decide whether participant is consent eligible
    @wire(getConsentParams,{perId :'$participantenrollmentid'}) 
    getconsent(response,error){
       this.wiredIntialData = response;
        console.log('Response in load:'+JSON.stringify(response));
        if(response.data){
            this.messages  = this.label.Message;
            this.initialdata = response.data;
            if(this.initialdata.isDisabled){
                this.messages = this.label.Updated_Message;
            }
        }
        if(error){
            console.error(JSON.stringify(error));
        }
    } 

    creatingParticipant(){
        this.innerspinner = true;
        getAccessToken()
        .then(result =>{
            let docCollectionMap = new Map();
            let itemIndex = this.returnValue.findIndex(element=> element.value == this.SelectedCollection);
            if(itemIndex !== -1){
                let docCollection = this.returnValue[itemIndex];
                docCollectionMap[this.participantenrollmentid] = docCollection;
            }
            return participantCreationOnEconsent({perId:this.participantenrollmentid,
                                                  accesstoken : result,
                                                  documentCollection: JSON.stringify(docCollectionMap)
                                                 });
        })
        
        .then((result)=> {
            this.innerspinner = false;
            let statusInfo = result.statusdetails;
            if(statusInfo && statusInfo.length > 0){
             if(statusInfo[0].isSuccess){
                this.messages= this.label.Updated_Message;
                const event = new ShowToastEvent({
                    title: 'Success',
                    variant : 'success',
                    message:statusInfo[0].UI_MESSAGE
                });
                this.dispatchEvent(event);
             } 
             else{
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: statusInfo[0].UI_MESSAGE,
                    variant : 'error'
                });
                this.dispatchEvent(event);
              }
            }
            refreshApex(this.wiredIntialData);
            this.closeModal();
                
        }).catch(error=>{
            this.innerspinner = false;
            const event = new ShowToastEvent({
                title: 'Error',
                message: this.label.Technical_Error,
                variant : 'error'
            });
            this.dispatchEvent(event);
            
            console.error('error:'+JSON.stringify(error));
        });             
    }

     
    openModal() {
        this.isModalOpen = true;
        this.innerspinner = true;
        getAccessToken()
        .then(response =>{
            if(response && response != null){
                return getResponse({perId : this.participantenrollmentid,access_token : response});
            }
            return false;
        })
        .then(result=>{
            if(result === null || result.length === 0){
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: this.label.Technical_Error,
                    variant : 'error'
                });
                this.dispatchEvent(event); 
                this.isModalOpen = false;
                this.innerspinner = false;
            }else{
            this.returnValue = result;
            this.innerspinner = false;}
        })
        .catch(error=>{
            console.log('Error'+JSON.stringify(error));
           this.innerspinner = false;
           const event = new ShowToastEvent({
            title: 'Error',
            message: this.label.Technical_Error,
            variant : 'error'
        });
        this.dispatchEvent(event); 
        }); 
    }

    closeModal() {
        this.isModalOpen = false;
        this.returnValue = [];
        this.SelectedCollection=null;
        this.okDisabled=true;
    }
    
    submitDetails() {
        this.creatingParticipant();
    }
    
    handleChange(event) {
        this.SelectedCollection  = event.detail.value;
        this.okDisabled = false;
    }

   get options() {
        return this.returnValue;
    }
    get showDropdown(){
        return this.returnValue.length > 0
    }
     
}