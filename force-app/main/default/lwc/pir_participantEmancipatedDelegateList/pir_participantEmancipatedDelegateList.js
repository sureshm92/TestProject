import { LightningElement,api,track } from 'lwc';
import { label } from "c/pir_label";
export default class Pir_participantEmancipatedDelegateList extends LightningElement {
    @api phoneNumber = '';
    @api phoneTypeValue = '';
    @api email = '';
    @api consent= false;
    @api consentrow =false;
    @api consentsms=false ;
    @api indexvalue;
    @track utilLabels = label;
    @api delegateMsgWithName = '';
    @api phoneTypes = [];
    @api inviteOptions = false;
    @api delegatecontinue;
    @api continuedelegate; 
    @api maindivcls;
    @api iscountryus;
    consentValue=false;
    @api
    get options() {
        return [
            { label: this.utilLabels.Continue, value: "true" },
            { label:  this.utilLabels.Do_Not_Continue, value: "false" },
        ];
    }
    
    checkFields(event){
        if(event.target.dataset.value === "TelephoneNumber") {
            this.phoneNumber = event.target.value;
          }else if(event.target.dataset.value === "TelephoneType"){
            this.phoneTypeValue = event.target.value;
          }else if(event.target.dataset.value === "email"){
            this.email = event.target.value;
          }
          else if(event.target.dataset.value === "consentCheckbox"){
            this.consentsms =false;
            this.consentrow=false;
            this.consent = this.template.querySelector('[data-name="consentCheckbox"]').checked;
          }
          else if(event.target.dataset.value === "consentCheckboxROW"){
            this.consent =false;
            this.consentrow = this.template.querySelector('[data-name="consentCheckboxROW"]').checked;
          }
          else if(event.target.dataset.value === "consentCheckboxSMS"){
            this.consent =false;
            this.consentsms = this.template.querySelector('[data-name="consentCheckboxSMS"]').checked;
          }
          var delegcont = '';
          if(this.continuedelegate == "true"){
              delegcont = this.utilLabels.Continue;
          }else{
              delegcont = this.utilLabels.Do_Not_Continue; 
          }
          const selectedEvent = new CustomEvent("datavaluechange", {
            detail: {
                phoneNumber:this.phoneNumber,
                phoneTypeValue:this.phoneTypeValue,
                email:this.email,
                iscont:this.continuedelegate,
                delegcont:delegcont,
                consent:this.consent,
                consentrow:this.consentrow,
                consentsms:this.consentsms,
                indexvalue:this.indexvalue
            }
          }); 
          this.dispatchEvent(selectedEvent);
    }
    handleContinue(event){
        this.continuedelegate = event.target.value;
        var delegcont = '';
        if(event.target.value == "true"){
            delegcont = this.utilLabels.Continue;
        }else{
            delegcont = this.utilLabels.Do_Not_Continue; 
        }
        const selectedEvent = new CustomEvent("datavaluechange", {
            detail: {
                phoneNumber:this.phoneNumber,
                phoneTypeValue:this.phoneTypeValue,
                email:this.email,
                iscont:event.target.value,
                delegcont:delegcont,
                consent:this.consent,
                consentrow:this.consentrow,
                consentsms:this.consentsms,
                indexvalue:this.indexvalue
            }
          });  
          this.dispatchEvent(selectedEvent);
     }
      //Changes made for for adding alternate option for do not continue  
     get isrequired() {
        if (this.continuedelegate ==='false') {
            return false;
          } else {
            return true;
          }
        }
        
      }