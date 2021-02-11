/**
 * Created by Andrii Kryvolap.
 */

import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getPageEnabled from '@salesforce/apex/IncentiveProgramRemote.getIncentivesPageEnabled';
import getisRTL from '@salesforce/apex/ParticipantVisitsRemote.getIsRTL';
import incentivesLabel from '@salesforce/label/c.IncentiveProgram_Incentives';

export default class IncentivePage extends NavigationMixin(LightningElement) {
    labels = {
        incentivesLabel
    };
    @track isRTL;
    connectedCallback() {
        getPageEnabled()
            .then((data) => {
                if (!data) {
                    this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            pageName: 'home'
                        }
                    });
                }
            })
            .catch((error) => {
                console.error('Error in getPageEnabled():' + JSON.stringify(error));
            });
            getisRTL()
            .then((data) => {
                this.isRTL = data === true? 'rtl': '';
            })
            .catch(function(error) {
                console.error('Error: ' + JSON.stringify(error));
            });
    }
}