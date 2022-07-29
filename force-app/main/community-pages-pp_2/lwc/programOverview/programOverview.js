import { LightningElement, api } from 'lwc';



export default class ProgramOverview extends LightningElement {
     @api clinicalrecord;
     shortOverview;
     
     connectedCallback(){
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
     }
    
    handleclick(){
        communityService.navigateToPage('overview');
    }

}