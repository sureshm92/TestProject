import { LightningElement } from 'lwc';
import getParticipantData from '@salesforce/apex/HomePageParticipantRemote.getInitData';

export default class HomePageParticipantNew extends LightningElement {
    participantState;
    clinicalrecord;
    error;

    connectedCallback() {
        getParticipantData()
            .then((result) => {
                if (result) {
                    this.participantState = JSON.parse(result);
                    if (this.participantState.pe) {
                        if (this.participantState.pe.Clinical_Trial_Profile__r) {
                            this.clinicalrecord = this.participantState.pe.Clinical_Trial_Profile__r;
                        }
                    }
                }
            })
            .catch((error) => {
                console.log('error::' + JSON.stringify(error));
                this.error = error;
            });
    }
}
