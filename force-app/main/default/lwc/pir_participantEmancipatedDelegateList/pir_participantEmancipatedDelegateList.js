import { LightningElement,api,track } from 'lwc';
import { label } from "c/pir_label";
export default class Pir_participantEmancipatedDelegateList extends LightningElement {
    @api phoneNumber = '';
    @api phoneTypeValue = '';
    @api email = '';
    @api indexvalue;
    @track utilLabels = label;
    @api delegateMsgWithName = '';
    @api phoneTypes = [];
    @api inviteOptions = false;
    @api delegatecontinue;
    @api continuedelegate; 
    @api maindivcls;
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
                indexvalue:this.indexvalue
            }
          });  
          this.dispatchEvent(selectedEvent);
     }
}