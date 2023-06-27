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
    @api studyemailconsent;
    @api studyinfostorageconsent;
    @api studyphoneconsent;
    @api studysmsconsent;

    //newchange
    @api alreadyconsent;
    @api alreadyconsentedrow;

    consentValue=false;
    @api
    get options() {
        return [
            { label: this.utilLabels.Continue, value: "true" },
            { label:  this.utilLabels.Do_Not_Continue, value: "false" },
        ];
    }
    
    checkFields(event){
       var smsconsent;
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
            this.studyemailconsent=this.template.querySelector('[data-name="consentCheckbox"]').checked;
            this.studyinfostorageconsent=this.template.querySelector('[data-name="consentCheckbox"]').checked;
            this.studyphoneconsent=this.template.querySelector('[data-name="consentCheckbox"]').checked;
            this.studysmsconsent=this.template.querySelector('[data-name="consentCheckbox"]').checked;
          }
          else if(event.target.dataset.value === "consentCheckboxROW"){
            this.consent =false;
            this.consentrow = this.template.querySelector('[data-name="consentCheckboxROW"]').checked;
            this.studyemailconsent=this.template.querySelector('[data-name="consentCheckboxROW"]').checked;
            this.studyinfostorageconsent=this.template.querySelector('[data-name="consentCheckboxROW"]').checked;
            this.studyphoneconsent=this.template.querySelector('[data-name="consentCheckboxROW"]').checked;
          }
          else if(event.target.dataset.value === "consentCheckboxSMS"){
            this.consent =false;
            this.consentsms = this.template.querySelector('[data-name="consentCheckboxSMS"]').checked;
            this.studysmsconsent=this.template.querySelector('[data-name="consentCheckboxSMS"]').checked
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
                indexvalue:this.indexvalue,
                studyemailconsent:this.studyemailconsent,
                studyinfostorageconsent:this.studyinfostorageconsent,
                studyphoneconsent:this.studyphoneconsent,
                studysmsconsent:this.studysmsconsent
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
                indexvalue:this.indexvalue,
                studyemailconsent:this.studyemailconsent,
                studyinfostorageconsent:this.studyinfostorageconsent,
                studyphoneconsent:this.studyphoneconsent,
                studysmsconsent:this.studysmsconsent
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
        get showConsent() {
          if (this.continuedelegate ==='false') {
              return false;
            } else {
              if(this.iscountryus == true){
                 if(this.studyemailconsent == true && this.studyinfostorageconsent == true && this.studyphoneconsent == true && this.studysmsconsent == true){
                    this.consent = true; console.log('thisconsent-->'+this.consent);
                                     if(this.alreadyconsent && !this.alreadyconsentedrow){
                                      return false; 
                                     }else{ return true; }
                                    
                 }else{ return true;}
              }else{
                if(this.studyemailconsent == true && this.studyinfostorageconsent == true && this.studyphoneconsent == true){
                       this.consentrow = true;
                       if(this.studysmsconsent == true){
                          this.consentsms = true;
                       }
                        if(this.alreadyconsent){
                          return false; 
                         }else{ return true; }
               }else{ return true;} 
              } 
            }
          }
        
      }