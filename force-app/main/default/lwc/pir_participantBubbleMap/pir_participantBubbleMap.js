import { LightningElement,api } from 'lwc';
import pirResources from '@salesforce/resourceUrl/pirResources';
export default class Pir_participantBubbleMap extends LightningElement {
   @api status = false;
   @api index;
   @api pathdetails;
   @api isrtl = false;
   maindivcls;
   checkIcon = pirResources+'/pirResources/icons/status-good.svg';
   noneIcon = pirResources+'/pirResources/icons/circle.svg';
   nonecls = 'neutral';
   connectedCallback() {
    if(this.isrtl) {
      this.maindivcls = 'rtl';
    }else{
      this.maindivcls = 'ltr';
    }
  }
   get chkstyle(){
       return 'neutral';
   }
}