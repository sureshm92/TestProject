import { LightningElement, track, api } from 'lwc';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import loadDiary from '@salesforce/apex/ECOADiariesController.getToken';
import getSubjectGuid from '@salesforce/apex/ECOADiariesController.getSubjectGuid';
import ediaries from '@salesforce/label/c.Navigation_eDiary';
import homeLablel from '@salesforce/label/c.Navigation_Home';
import patientNotRegistered from '@salesforce/label/c.Patient_not_in_ecoa';
import { NavigationMixin } from 'lightning/navigation';

export default class ViewEcoaDiaries extends NavigationMixin(LightningElement) {

    @track ecoaUrl;
    @track subjectAvailable = true;
    labels = {
        ediaries,
        homeLablel,
        patientNotRegistered
    };
    //@track isLoading;
    connectedCallback() {
        //this.isLoading = true;
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                console.log('obj::' + communityService.getCurrentCommunityMode().currentPE);
                let subjectGuid = getSubjectGuid()
                    .then((result) => {
                        console.log('Subject GUID::' + result);
                        if (result) {
                            let ppGetter = loadDiary()
                                .then((result) => {
                                    this.subjectAvailable = true;
                                    this.ecoaUrl = result;
                                })
                                .catch(function (error) {
                                    console.error('Error: ' + JSON.stringify(error));
                                    //this.isLoading = false;
                                });
                        } else {
                            console.log('else' + result);
                            this.subjectAvailable = false;
                        }
                    })
                    .catch(function (error) {
                        console.error('Error: ' + JSON.stringify(error));
                    });
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading rr_community_js',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }
    goToPreviousPage(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'home'
            }
        });
    }
}
