/**
 * Created by Andrii Kryvolap.
 */

import {LightningElement} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';

import getPageEnabled from '@salesforce/apex/IncentiveProgramRemote.getIncentivesPageEnabled';

import incentivesLabel from '@salesforce/label/c.IncentiveProgram_Incentives';

export default class IncentivePage extends NavigationMixin(LightningElement) {

    labels={
        incentivesLabel
    }
    connectedCallback() {
        getPageEnabled()
            .then(data => {
               if (!data){
                   this[NavigationMixin.Navigate]({
                       type: 'comm__namedPage',
                       attributes: {
                           pageName: 'home'
                       }
                   });
               }
            })
            .catch(error => {
                console.error('Error in getPageEnabled():' + JSON.stringify(error));
            });
    }
}