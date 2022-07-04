import { LightningElement, api } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';




export default class ProgramOverview extends LightningElement {
     @api clinicalrecord;
     shortOverview;
     
     connectedCallback(){
        if(this.clinicalrecord){
            if(this.clinicalrecord.Brief_Summary__c){
                if(this.clinicalrecord.Brief_Summary__c.length > 170) {
                    this.shortOverview = this.clinicalrecord.Brief_Summary__c.substring(0,170);
                }

            }

        }
        if(FORM_FACTOR )
     }
    
    handleclick(){
        communityService.navigateToPage('Overview');
    }

}