/**
 * Created by Andrii Kryvolap.
 */

import {LightningElement, track} from 'lwc';
import getPoints from '@salesforce/apex/IncentiveProgramRemote.getCurrentPoints';
export default class NavIncentiveCounter extends LightningElement {

    @track totalPoints=0;
    @track lastPoints=0;
    @track showDropDown;
    lastDatastamp;

    connectedCallback() {
        this.showDropDown = false;
        this.lastDatastamp = new Date();
        setInterval(() => {
            getPoints({
                timeStamp : this.lastDatastamp.toISOString()
            })
                .then(data => {
                    this.totalPoints = data.totalPoints;
                    this.lastPoints = data.lastPoints;
                })
                .catch(error => {
                    console.error('Error in getPointsCounter():' + JSON.stringify(error));
                });
        }, 5000);
    }

    doToggleDropDown() {
        if (!this.showDropDown){
            this.lastDatastamp = new Date();
        }
        this.showDropDown = !this.showDropDown;
    }

}