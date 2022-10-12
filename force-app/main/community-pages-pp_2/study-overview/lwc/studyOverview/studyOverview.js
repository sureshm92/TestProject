import { LightningElement, api } from 'lwc';
import DEVICE from '@salesforce/client/formFactor';
import IQVIA_Logo from '@salesforce/resourceUrl/IQVIA_Logo';
import GSK_Logo from '@salesforce/resourceUrl/GSK_Logos';
import getisRTL from '@salesforce/apex/HomePageParticipantRemote.getIsRTL';
import getInitData from '@salesforce/apex/AccountSettingsController.getInitData';

import PPLEARNMOREDESKTOPLabel from '@salesforce/label/c.PP_ProgramOverview_LearnMore_Desktop';


export default class StudyOverview extends LightningElement {
    label = {
				PPLEARNMOREDESKTOPLabel
    };

    iqviaLogoUrl = IQVIA_Logo+'/IQVIALogo.png';
    gskLogoUrl = GSK_Logo+'/gsk-full.png';
    
    @api clinicalrecord;
    shortOverview;

    desktop = true;
    isRTL = false;

    alumniParticipant = false;
    delegateSelfView = false;
    communityName;
    userMode;

    get cardRTL() {
        return this.isRTL ? 'cardRTL' : '';
    }
    get borderPOHome(){
        return this.isRTL ? 'borderLeft' : 'borderRight';
    }
    get noStudyOverviewAvailable(){
       return (this.alumniParticipant || this.delegateSelfView) ? true : false;
    }  
    get isIqviaLogo(){
        return (this.communityName == 'IQVIA Referral Hub' || this.communityName == 'IQVIA Patient Portal') ? true : false ;
     }
     
    get isGskLogo(){
        return (this.communityName == 'GSK Community') ? true : false;
     }

     connectedCallback(){
        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);

        if(this.clinicalrecord){
            if(this.clinicalrecord.Brief_Summary__c){
                if(this.clinicalrecord.Brief_Summary__c.length > 170) {
                    this.shortOverview = this.clinicalrecord.Brief_Summary__c.substring(0,170);
                }
				else{
					this.shortOverview = this.clinicalrecord.Brief_Summary__c;
				}
            }
        }

        getisRTL()
            .then((data) => {
                debugger;
                this.isRTL = data;
            })
            .catch(function (error) {
                console.error('Error RTL: ' + JSON.stringify(error));
        });

        this.userMode = communityService.getUserMode();

        // check who has logged in if delegate or alumni show no active programs UI
        getInitData({ userMode: this.userMode })
         .then((data) => {
            let programOverViewData = JSON.parse(data).programOverViewData;
             this.alumniParticipant = programOverViewData.isAlumniParticipant;
             this.delegateSelfView = programOverViewData.isDelegateSelfView;
             this.communityName = programOverViewData.communityName;
            })
         .catch(function (error) {
             console.error(JSON.stringify(error));
         });
         
    }

    handleclick(){
        communityService.navigateToPage('about-study-and-overview');
    }
    
}