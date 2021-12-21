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
import getParticipantCount from '@salesforce/apex/DashboardParticipantCount.participantInvitationDashboard';
import getLoggedParticipantCount from '@salesforce/apex/DashboardParticipantCount.participantLoginDashboard';
 
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
    participantsCountResponse;
    error;
    loading = false;

    label = {
        PPInvitationStatusTitle,
        PPInvited,
        PPNotYetInvited,
        CountOfParticipants,
        SendInvitestoNotYetInvited,
        ViewParticipantsNotYetLoggedIn,
        PPLogin,
        PPNotYetLogin,
        PPLoginStatusTitle
    };
	  

    connectedCallback() {    
        if(this.isInvitationDashboard === 'true') {
            this.dashboardTitle = this.label.PPInvitationStatusTitle;
            this.buttonText = this.label.SendInvitestoNotYetInvited;
        } else {
            this.dashboardTitle = this.label.PPLoginStatusTitle;
            this.buttonText = this.label.ViewParticipantsNotYetLoggedIn;
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
                    console.log('result:'+JSON.stringify(result));                              
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
                    console.log('result:'+JSON.stringify(result));                              
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
                this.topBarStyle='width:'+width+'; background-color:'+this.peList[i].color+'; height: 50px; display: inline-block;';
                this.topBarRec=this.peList[i];
            
            } else if(this.peList[i].title === 'secondBar') {
                this.secondBarStyle='width:'+width+'; background-color:'+this.peList[i].color+'; height: 50px; display: inline-block'; 
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
    
}