import { LightningElement, track, api } from 'lwc';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import loadDiary from '@salesforce/apex/ecoaDiariesController.getToken';

export default class ViewEcoaDiaries extends LightningElement {
    @track ecoaUrl;
    //@track isLoading;
    connectedCallback() {
        //this.isLoading = true;
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                let ppGetter = loadDiary()
                    .then((result) => {
                        //this.isLoading = false;
                        this.ecoaUrl = result;
                    })
                    .catch(function (error) {
                        console.error('Error: ' + JSON.stringify(error));
                        //this.isLoading = false;
                    });
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading RR_COMMUNITY_JS',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }
}
