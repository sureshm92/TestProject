import { LightningElement, api } from 'lwc';
import DEVICE from '@salesforce/client/formFactor';
import getisRTL from '@salesforce/apex/HomePageParticipantRemote.getIsRTL';
// importing Custom Label
import PPLEARNMOREMBLELabel from '@salesforce/label/c.PP_ProgramOverview_LearnMore_Mobile';
import PPLEARNMOREDESKTOPLabel from '@salesforce/label/c.PP_ProgramOverview_LearnMore_Desktop';


export default class ProgramOverview extends LightningElement {
    label = {
        PPLEARNMOREMBLELabel,
        PPLEARNMOREDESKTOPLabel
    };
    
    @api clinicalrecord;
    shortOverview;

    desktop = true;
    isRTL = false;

    get cardRTL() {
        return this.isRTL ? 'cardRTL' : '';
    }
    get borderPOHome(){
        return this.isRTL ? 'borderLeft' : 'borderRight';
    }
     
    connectedCallback(){

        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);

        if(this.clinicalrecord){
			console.log('this.clinicalrecord:::'+this.clinicalrecord);
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
    }
    
    handleclick(){
        communityService.navigateToPage('overview');
    }

}