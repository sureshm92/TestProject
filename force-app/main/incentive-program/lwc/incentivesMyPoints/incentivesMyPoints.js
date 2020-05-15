/**
 * Created by Andrii Kryvolap.
 */

import {LightningElement, track} from 'lwc';
import getIncentiveHistory from '@salesforce/apex/IncentiveProgramRemote.getIncentiveHistory';

export default class IncentivesMyPoints extends LightningElement {


    @track totalPoints;
    @track completedTasks;
    @track initialized=false;

    connectedCallback() {
        getIncentiveHistory()
            .then(data => {
                this.totalPoints = data.totalPoints;
                this.completedTasks = data.completedTasks;
                this.initialized = true;
            })
            .catch(error => {
                console.error('Error in getIncentiveHistory():' + JSON.stringify(error));
            });
    }
}