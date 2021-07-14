import { LightningElement, api } from 'lwc';

export default class PopupLWC extends LightningElement {
    @api showPositive;
    @api showNegative;
    @api showModal;
    @api header=false; 
    @api headerValue=''; 
    @api header2=false; 
    @api headerValue2=''; 
    @api modalsize=''; //small;large;medium

    constructor() {
        super();
        this.showNegative = true;
        this.showPositive = true;
        this.showModal = false;
      }
    
      handlePositive() {
        this.dispatchEvent(new CustomEvent('positive'));
      }
      
      handleNegative() {
        this.dispatchEvent(new CustomEvent('negative'));
      }
    
      handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
      }
      get hasHeader() {
        return this.header == 'true' ? true : false;
     }get hasHeader2() {
      return this.header2 == 'true' ? true : false;
   }
     get size() {
      if(this.modalsize ==="small")
      {
        return 'slds-modal_small';
      }else if(this.modalsize ==="large"){
        return  'slds-modal_large'; 
      }else if(this.modalsize ==="medium"){
        return 'slds-modal_medium';
      }else{
        return 'slds-modal_medium';
      }
   }
}