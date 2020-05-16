/**
 * Created by Andrii Kryvolap.
 */

import {LightningElement, track} from 'lwc';
import getInitialPlan from '@salesforce/apex/IncentiveProgramRemote.getInitialIncentivePlanResultWrapper';
import getPlanForStudySite from '@salesforce/apex/IncentiveProgramRemote.getIncentivePlanResultWrapperForStudySite';

export default class IncentivesMyPlan extends LightningElement {

    @track studySitesOptions;
    @track tasksGroups;
    @track selectedStudySite;
    @track initialized=false;

    connectedCallback() {
        getInitialPlan()
            .then(data => {
                console.log(data);
                this.studySitesOptions = data.studySitesOptions;
                this.selectedStudySite = this.studySitesOptions[0].value;
                this.tasksGroups = data.tasksGroups;
                this.initialized = true;
            })
            .catch(error => {
                console.error('Error in getInitialPlan():' + JSON.stringify(error));
            });
    }

    doUpdateStudySite(event){
        let selectedSS = event.detail.value;
        console.log(selectedSS);
        getPlanForStudySite({
            ssId: selectedSS
        })
            .then(data => {
                console.log(data);
                this.tasksGroups = data.tasksGroups;
            })
            .catch(error => {
                console.error('Error in getPlanForStudySite():' + JSON.stringify(error));
            });
    }
}