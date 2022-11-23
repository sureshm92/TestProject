import { LightningElement, api } from 'lwc';
import DEVICE from '@salesforce/client/formFactor';
import IQVIA_Logo from '@salesforce/resourceUrl/IQVIA_Logo';
import GSK_Logo from '@salesforce/resourceUrl/GSK_Logos';
import getisRTL from '@salesforce/apex/HomePageParticipantRemote.getIsRTL';
import getInitData from '@salesforce/apex/AccountSettingsController.getInitData';

// importing Custom Label
import PPLEARNMOREMBLELabel from '@salesforce/label/c.PP_ProgramOverview_LearnMore_Mobile';
import PPLEARNMOREDESKTOPLabel from '@salesforce/label/c.PP_ProgramOverview_LearnMore_Desktop';
import When_a_program_is_active_you_will_find_a_brief_overview_about_it_here from '@salesforce/label/c.When_a_program_is_active_you_will_find_a_brief_overview_about_it_here';
import You_are_not_enrolled_in_any_program_at_the_moment from '@salesforce/label/c.You_are_not_enrolled_in_any_program_at_the_moment';
import No_active_program from '@salesforce/label/c.No_active_program';


export default class ProgramOverview extends LightningElement {
    label = {
        PPLEARNMOREMBLELabel,
        PPLEARNMOREDESKTOPLabel,
        When_a_program_is_active_you_will_find_a_brief_overview_about_it_here,
        You_are_not_enrolled_in_any_program_at_the_moment,
        No_active_program
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
    get noProgramOverviewAvailable(){
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
                let briefsummary = this.clinicalrecord.Brief_Summary__c;
                briefsummary = briefsummary.replace(/<[^>]*>?/gm, '');
                if(briefsummary.length > 200) {
                    let firsttext = briefsummary.substring(0, 200);
                    let secondtext = briefsummary.substring(200, 201);
                    if(secondtext == " "){
                        this.shortOverview = firsttext;
                    }
                    else {
                        let result = firsttext.substring(0, Math.min(firsttext.length,firsttext.lastIndexOf(" ")));
                        this.shortOverview  = result+'...';
                    }
                }
				else{
					this.shortOverview = briefsummary;
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
        communityService.navigateToPage('overview');
    }

}