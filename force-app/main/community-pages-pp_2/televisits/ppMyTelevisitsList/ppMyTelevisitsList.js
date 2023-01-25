import { LightningElement,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class PpMyTelevisitsList extends NavigationMixin (LightningElement) {
    showupcomingtelevisits = false;
    upcomingtelevisitdata = [];
    @api upcomingtelevisitsrecords;
    connectedCallback() {
        this.upcomingtelevisitdata = this.upcomingtelevisitsrecords;
        this.showupcomingtelevisits = true;
    }

    joinmeeting (event){
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: event.currentTarget.dataset.id
            }
        }).then(generatedUrl => {
            window.open(generatedUrl);
        });

    }
}