import { api, LightningElement} from 'lwc';
import PPInvitationStatusTitle from '@salesforce/label/c.Site_DB_Patient_Portal_Invitation_Status';
import PPInvited from '@salesforce/label/c.Site_DB_Invited';
import PPNotYetInvited from '@salesforce/label/c.Site_DB_Not_Yet_Invited';
import PPLogin from '@salesforce/label/c.Site_DB_Logged_In';
import PPNotYetLogin from '@salesforce/label/c.Site_DB_Not_Yet_Logged_In';
import PPLoginStatusTitle from '@salesforce/label/c.Site_DB_Patient_Portal_Login_Status';
import CountOfParticipants from '@salesforce/label/c.Site_DB_Participants';
import SendInvitestoNotYetInvited from '@salesforce/label/c.Site_DB_Send_Invites_to_Not_Yet_Invited';
import ViewParticipantsNotYetLoggedIn from '@salesforce/label/c.Site_DB_View_Participants_Not_Yet_Logged_In';
import SendInviteSuccessMsg from '@salesforce/label/c.Send_Invite_Success_Msg';
import getParticipantCount from '@salesforce/apex/DashboardParticipantCount.participantInvitationDashboard';
import getLoggedParticipantCount from '@salesforce/apex/DashboardParticipantCount.participantLoginDashboard';
import getNotYetInvitedParticipants from '@salesforce/apex/DashboardParticipantCount.fetchParticipantsNotYetInvitedDetails';
import getNotYetLoginParticipants from '@salesforce/apex/DashboardParticipantCount.fetchParticipantsNotYetLogInDetails';
import sendInvites from '@salesforce/apex/DashboardParticipantCount.sendInviteToNotInvitedParticipants';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LoginModalTitle from '@salesforce/label/c.Site_DB_Model_Login_Title';
import InviteModalTitle from '@salesforce/label/c.Site_DB_Model_Title';
import SelectAll from '@salesforce/label/c.Select_All_PI';
import Cancel from '@salesforce/label/c.BTN_Cancel';
import InviteSelected from '@salesforce/label/c.RH_RP_Invite_Selected';
export default class DashboardParticipantCount extends LightningElement {
    @api selectedCTP;
    @api selectedPI;
    @api isInvitationDashboard;
    peList=[];
    topBarStyle;
    secondBarStyle;
    topBarRec='';
    secondBarRec='';
    dashboardTitle='';
    topBarLabel='';
    secondBarLabel='';
    participantText = '';
    buttonText = '';
    ModalRender='';
    participantsCountResponse;
    error;
    loading = false;
    popupLoading = false;
    isParticipantModalOpen = false;
    isParticipantModalOpenlogin = false;

    disableButton = false;
    selectedPEList = [];

    label = {
        PPInvitationStatusTitle,
        PPInvited,
        PPNotYetInvited,
        CountOfParticipants,
        SendInvitestoNotYetInvited,
        ViewParticipantsNotYetLoggedIn,
        PPLogin,
        PPNotYetLogin,
        PPLoginStatusTitle,
        SendInviteSuccessMsg,
        LoginModalTitle,
        InviteModalTitle
        SelectAll,
        Cancel,
        InviteSelected
    };
	  

    connectedCallback() {    
        if(this.isInvitationDashboard === 'true') {
            this.dashboardTitle = this.label.PPInvitationStatusTitle;
            this.buttonText = this.label.SendInvitestoNotYetInvited;
            this.ModalRender=this.retrieveNotInvitedParticipants();

        } else {
            this.dashboardTitle = this.label.PPLoginStatusTitle;
            this.buttonText = this.label.ViewParticipantsNotYetLoggedIn;
            this.ModalRender= this.retrieveNotLoginParticipants();

        }    
        this.fetchDashboardValues();        
    }

    @api
    fetchDashboardValues() {
        if(this.selectedCTP && this.selectedPI) {
            this.loading = true;

            if(this.isInvitationDashboard === 'true') {
                getParticipantCount({ pIid: this.selectedPI,ctpId: this.selectedCTP })            
                .then(result => {
                    this.peList=result;
                    this.parseResult();
                })
                .catch(error => {                        
                    this.error = error;                    
                    this.loading = false;                
                });
            } else {
                getLoggedParticipantCount({ pIid: this.selectedPI,ctpId: this.selectedCTP })            
                .then(result => {
                    this.peList=result;
                    this.parseResult();
                })
                .catch(error => {                        
                    this.error = error;                    
                    this.loading = false;                
                });

            }
        }

    }

    parseResult() {
        for(let i=0 ; i<this.peList.length; i++) {
            let width=this.peList[i].width=='0%'?'1%':this.peList[i].width;

            if(this.peList[i].title === 'topBar') {                
                this.topBarStyle='width:'+width+'; background-color:'+this.peList[i].color+';  display: inline-block;';
                this.topBarRec=this.peList[i];
            
            } else if(this.peList[i].title === 'secondBar') {
                this.secondBarStyle='width:'+width+'; background-color:'+this.peList[i].color+';  display: inline-block'; 
                this.secondBarRec=this.peList[i];
            }    
        }
        if(this.isInvitationDashboard === 'true') {
            this.topBarLabel = this.label.PPInvited;
            this.secondBarLabel = this.label.PPNotYetInvited;
        } else {
            this.topBarLabel = this.label.PPLogin;
            this.secondBarLabel = this.label.PPNotYetLogin;
        }
        this.participantText = this.label.CountOfParticipants;
        this.loading = false;
    }

    openParticipantModal() {
        this.popupLoading = true; 
        this.disableButton = true;
        if(this.isInvitationDashboard === 'true') {
            this.retrieveNotInvitedParticipants();
            this.isParticipantModalOpen = true;
          
        } else{        
            this.retrieveNotLoginParticipants();
            this.isParticipantModalOpenlogin=true;
        }
        this.popupLoading = true; 
        this.disableButton = true;
    }

    retrieveNotInvitedParticipants() {          
        getNotYetInvitedParticipants({ pIid: this.selectedPI,ctpId: this.selectedCTP })            
        .then(result => {
            const cloneResult = [...result];          
            cloneResult.sort(this.compareParticipantName);
            this.peList=cloneResult;            
            this.popupLoading = false; 
        })
        .catch(error => {  
            this.error = error;                    
            this.popupLoading = false;                
        });
         
    }
    retrieveNotLoginParticipants() {          
        getNotYetLoginParticipants({ pIid: this.selectedPI,ctpId: this.selectedCTP })            
        .then(result => {
            const cloneResult = [...result];          
            cloneResult.sort(this.compareParticipantName);
            this.peList=cloneResult;            
            this.popupLoading = false; 
        })
        .catch(error => {  
            this.error = error;                    
            this.popupLoading = false;                
        });
         
    }

    //close model for refresh
    closeParticipantModal() {
        this.peList = [];
        this.selectedPEList = [];
        if(this.isInvitationDashboard === 'true') {
            this.isParticipantModalOpen = false;
        } else {
            this.isParticipantModalOpenlogin = false;
        }
    }
    

    // To sort array by property name
    compareParticipantName(a, b) {

        // converting to uppercase to have case-insensitive comparison
        const participant1 = a.participantName.toUpperCase();
        const participant2 = b.participantName.toUpperCase();
    
        let comparison = 0;
    
        if (participant1 > participant2) {
            comparison = 1;
        } else if (participant1 < participant2) {
            comparison = -1;
        }
        return comparison;
    }

    doRecordSelection(event) {    

        for (var i = 0; i < this.peList.length; i++) {
            let row = Object.assign({}, this.peList[i]);   
            let selectedRow = event.target.dataset.id;
            if(row.datasetId === selectedRow) {
                if(event.target.checked) {                    
                    row.isChecked = true                  
                    this.selectedPEList.push(row);
                } else {
                    for(let j = 0; j < this.selectedPEList.length; j++) {
                        if(this.selectedPEList[j].datasetId === row.datasetId) {
                            this.selectedPEList.splice(j,1);
                        }
                    }

                }          
                
            }
        }
        if(this.selectedPEList.length>0){
            this.disableButton = false;
        }else{
            this.disableButton = true;
        }
    }

    sendToSelected(event) {
        if(this.selectedPEList.length > 0) {
            this.sendInvitesToApex(this.selectedPEList);
        }
    }

    sendToAll(event) {
      
        if(this.peList.length > 0) {
            this.sendInvitesToApex(this.peList);
        }
    }

    sendInvitesToApex(finalPEList) {
        this.popupLoading = true; 
        sendInvites({ participantJson: JSON.stringify(finalPEList), ctpId: this.selectedCTP })            
        .then(result => {
            this.popupLoading = false;
            let message = this.labelFormat(SendInviteSuccessMsg,finalPEList.length);
            //let messsage = '['+finalPEList.length+'] Invite(s) to Patient Portal sent! Dashboard may take several minutes to update.';
            this.showNotification('success',message,'success');
            this.closeParticipantModal();
        })
        .catch(error => {  
            this.error = error;                    
            this.popupLoading = false; 
            this.showNotification('error',JSON.stringify(error),'error');
            this.closeParticipantModal();
        });
        
    }

    labelFormat(stringToFormat, ...formattingArguments) {
        if (typeof stringToFormat !== 'string') throw new Error('\'stringToFormat\' must be a String');
        return stringToFormat.replace(/{(\d+)}/gm, (match, index) =>
            (formattingArguments[index] === undefined ? '' : `${formattingArguments[index]}`));
    }

    showNotification(title,message,variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    selectAll() {
        this.popupLoading = true;
        this.disableButton = true;
        let allRows = this.peList;
        this.selectedPEList = [];
        for (var i = 0; i < allRows.length; i++) {
            let row = Object.assign({}, allRows[i]);  
            row.isChecked = true;
            this.disableButton = false;
            let targetId = row.datasetId;
            let target = this.template.querySelector(`[data-id="${targetId}"]`);
            target.checked = true;
            this.selectedPEList.push(row);
        }
        this.peList = allRows;
        this.popupLoading = false;
    }
}