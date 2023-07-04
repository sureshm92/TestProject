import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import getConsentParams from '@salesforce/apex/CreateParticipantController.getConsentParams';
import consent_heading from '@salesforce/label/c.Informed_consent_heading';
import button_name from '@salesforce/label/c.consent_verification_btn_name';
import consent_toop_tip_info from '@salesforce/label/c.Informed_consent_tool_tip_content';

export default class PpConsentVerificationCard extends NavigationMixin(LightningElement) {
    label={
        consent_heading,
        button_name,
        consent_toop_tip_info
    }
    consenturl;
    visible = false;
    errorMessage;
    disabled = false;

   renderedCallback(){
        let linkCmp  = this.template.querySelector('button.econsentButton');
        if(this.disabled){
            linkCmp.classList.add('econsent-disable');
        }
    }

    
    handleClick(){

       /* this[NavigationMixin.Navigate]({
            "type" : "standard_webPage",
            "attributes":{
                url : this.consenturl
            }
        }); */
       if(!this.disabled){
        window.open(this.consenturl,"","height=650,width=650");
       } 
        
      
    }

    connectedCallback(){
        getConsentParams()
        .then(response =>{
            console.log('returned response:'+ JSON.stringify(response));
            this.visible = response.isEnabled;
            this.disabled = response.isDisabled
            this.consenturl = response.consentUrl;
            this.errorMessage = response.warningMessage;
            if(this.showConsentCard){
                const inform = new CustomEvent('successload',{detail:'ppconsentcard'});
                this.dispatchEvent(inform);
            }
        })
        .catch(error=>{
            console.log(error.body.message);
        })
    }

    get isUrlPresent(){

        return (this.consenturl) ? true : false;
    }

    get showConsentCard(){

        return (this.visible || this.disabled)
    }

    showHideInfo(event){
        let name = event.type;
        if(name === 'mouseover'){
            this.template.querySelector('div.info-tooltip_position').classList.remove('slds-hide');
        }
        else if(name === 'mouseleave'){
            this.template.querySelector('div.info-tooltip_position').classList.add('slds-hide');

        }
    }
    
}