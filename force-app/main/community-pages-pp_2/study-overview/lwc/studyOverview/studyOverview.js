import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import DEVICE from '@salesforce/client/formFactor';
import IQVIA_Logo from '@salesforce/resourceUrl/IQVIA_Logo';
import GSK_Logo from '@salesforce/resourceUrl/GSK_Logos';
import openNewTabBlueIcon from '@salesforce/resourceUrl/openNewTabBlueIcon';
import getisRTL from '@salesforce/apex/HomePageParticipantRemote.getIsRTL';
import getInitData from '@salesforce/apex/AccountSettingsController.getInitData';

import PPLEARNMOREDESKTOPLabel from '@salesforce/label/c.PP_ProgramOverview_LearnMore_Desktop';
import PPLEARNMOREMBLELabel from '@salesforce/label/c.PP_StudyOverview_LearnMore_Mobile';
import PP_StudyOverview_homePage_shortDecs_DelAlu from '@salesforce/label/c.PP_StudyOverview_homePage_shortDecs_DelAlu';
import PP_Clinical_Research_by_IQVIA from '@salesforce/label/c.PP_Clinical_Research_by_IQVIA';


export default class StudyOverview extends NavigationMixin(LightningElement) {
    label = {
				PPLEARNMOREDESKTOPLabel,
                PPLEARNMOREMBLELabel,
                PP_StudyOverview_homePage_shortDecs_DelAlu,
                PP_Clinical_Research_by_IQVIA
    };

    iqviaLogoUrl = IQVIA_Logo+'/IQVIALogo.png';
    gskLogoUrl = GSK_Logo+'/gsk-full.png';
    open_new_tab = openNewTabBlueIcon;

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
                let briefsummary = this.clinicalrecord.Brief_Summary__c;
                console.log('this.clinicalrecord.Brief_Summary__c::'+this.clinicalrecord.Brief_Summary__c);
                if(briefsummary.length > 200) {
                    briefsummary = briefsummary.replace(/<[^>]*>?/gm, '');
                    console.log('briefsummary::'+briefsummary);
                    let firsttext = briefsummary.substring(0, 200);
                    console.log('firsttext'+firsttext); 
                    let secondtext = briefsummary.substring(200, 201);
                    console.log('secondtext'+secondtext);
                    if(secondtext == " "){
                        this.shortOverview = firsttext;
                    }
                    else {
                        let result = firsttext.substring(0, Math.min(firsttext.length,firsttext.lastIndexOf(" ")));
                        console.log('result::'+result);
                        this.shortOverview  = result+'...';
                    }
                }
				else{
					this.shortOverview = this.clinicalrecord.Brief_Summary__c;
				}
            } 
        }

        getisRTL()
            .then((data) => {
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

    handleclickClinicalResearch(){
        const config = {
            type: 'standard__webPage',
            attributes: {
                url: 'http://ClinicalResearch.com'
            }
        };
        this[NavigationMixin.Navigate](config);
    }
    
}