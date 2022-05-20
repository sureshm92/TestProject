import { LightningElement, track, api } from 'lwc';
import CC_Welcome_Call_Complete from "@salesforce/label/c.CC_Welcome_Call_Complete";
import CC_First_Referral_Call_Complete from "@salesforce/label/c.CC_First_Referral_Call_Complete";
import CC_Aged_Referral_Call_Complete from "@salesforce/label/c.CC_Aged_Referral_Call_Complete";
import CC_Left_Message from "@salesforce/label/c.CC_Left_Message";
import CC_No_Answer from "@salesforce/label/c.CC_No_Answer";
import CC_Follow_up_needed from "@salesforce/label/c.CC_Follow_up_needed";
import PIR_Other from "@salesforce/label/c.PIR_Other";
export default class CallDispositionsDetails extends LightningElement {

    @api index;
    @api items;
    @api itemId;
    @api callDate;
    @api callCategory;
    @api selected;
    label = {
        CC_Welcome_Call_Complete,
        CC_First_Referral_Call_Complete,
        CC_Aged_Referral_Call_Complete,
        CC_Left_Message,
        CC_No_Answer,
        CC_Follow_up_needed,
        PIR_Other
    }

    @api
    get retitems() {
        return this.items
    }

    get retitemId() {
        return this.itemId
    }

    get retCallDate() {
        return this.callDate
    }

    get retCallCategory() {
        if(this.callCategory == "Welcome Call Complete"){
            return this.label.CC_Welcome_Call_Complete;
        }else if(this.callCategory == "First Referral Call Complete"){
            return this.label.CC_First_Referral_Call_Complete;
        }else if(this.callCategory == "Aged Referral Call Complete"){
            return this.label.CC_Aged_Referral_Call_Complete;
        }else if(this.callCategory == "Left Message"){
            return this.label.CC_Left_Message;
        }else if(this.callCategory == "No Answer"){
            return this.label.CC_No_Answer;
        }else if(this.callCategory == "Follow up needed"){
            return this.label.CC_Follow_up_needed;
        }else if(this.callCategory == "Other"){
            return this.label.PIR_Other;
        }else{
              return this.callCategory
        }
      
    }

    get highlight() {
        return this.index == 0 ? 'pointer highlight' : 'pointer';
    }

    @api
    unselect(target){
        this.template.querySelector('[data-value="0"]').classList.remove('highlight');        
    }
    @api
    unselectNew(){
       
        this.template.querySelector('[data-value="0"]').classList.remove('highlight');        
    }


}