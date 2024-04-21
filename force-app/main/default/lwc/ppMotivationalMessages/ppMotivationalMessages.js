import { LightningElement, track, api, wire } from 'lwc';
import getMotivationalMessage from '@salesforce/apex/MotivationalMessagesRemote.getMotivationalMessage';

export default class PpMotivationalMessages extends LightningElement {
    connectedCallback() {
        this.initializeData();
    }
    initializeData(){
        getMotivationalMessage({ userMode: communityService.getUserMode()})
        .then((message) => {
            this.message=message;
            if(message){
                this.template.querySelector('c-custom-toast-message').showToast('', message, 'info','sticky');
            }
        })
        .catch((error) => {
            console.log(error);
        });

    }


}