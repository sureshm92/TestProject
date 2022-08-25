import { LightningElement } from 'lwc';
import getParticipantData from '@salesforce/apex/HomePageParticipantRemote.getInitData';
import DEVICE from '@salesforce/client/formFactor';
// importing Custom Label
import PPWELCOME from '@salesforce/label/c.PP_Welcome';


export default class HomePageParticipantNew extends LightningElement {
    label = {
        PPWELCOME
    };
    
    participantState;
    clinicalrecord;
    error;
    userName = "Sarah";

    desktop = true;
    isDelegateSelfview = false;
    
    get showProgramOverview (){
        return (this.clinicalrecord || this.isDelegateSelfview) ? true : false;
    }

    connectedCallback() {
        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);
        getParticipantData()
            .then((result) => {
                if (result) {
                    this.participantState = JSON.parse(result);
                    if(this.participantState){
                            this.userName = this.label.PPWELCOME +', ' +this.participantState.loggedInUserName;
                    }
                    if (this.participantState.pe) {
                        if (this.participantState.pe.Clinical_Trial_Profile__r) {
                            this.clinicalrecord = this.participantState.pe.Clinical_Trial_Profile__r;
                        }
                    }
                    //For Delegate Self view
                    this.isDelegateSelfview = (this.participantState.value == 'ALUMNI') && this.participantState.hasPatientDelegates && !this.participantState.isDelegate;

                }
            })
            .catch((error) => {
                console.log('error::' + JSON.stringify(error));
                this.error = error;
            });
    }
}