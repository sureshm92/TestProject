/**
 * Created by Andrii Kryvolap.
 */

import {LightningElement, track} from 'lwc';

import getInitialPlan from '@salesforce/apex/IncentiveProgramRemote.getInitialIncentivePlanResultWrapper';
import getPlanForStudySite from '@salesforce/apex/IncentiveProgramRemote.getIncentivePlanResultWrapperForStudySite';

import howDoIEarnLabel from '@salesforce/label/c.IncentiveProgram_How_Do_I_Earn';
import studySiteLabel from '@salesforce/label/c.IncentiveProgram_Study_Site';
import selectStudySiteLabel from '@salesforce/label/c.IncentiveProgram_Select_Study_Site';
import pointsLabel from '@salesforce/label/c.IncentiveProgram_Points';

export default class IncentivesMyPlan extends LightningElement {

    labels={
        howDoIEarnLabel,
        studySiteLabel,
        selectStudySiteLabel,
        pointsLabel,
    }

    @track studySitesOptions;
    @track tasksGroups;
    @track selectedStudySite;
    @track initialized;
    @track hasStudySitesWithActivePlan;
    spinner;

    connectedCallback() {
        getInitialPlan()
            .then(data => {
                this.studySitesOptions = data.studySitesOptions;
                this.hasStudySitesWithActivePlan = this.studySitesOptions.length > 0;
                if (this.hasStudySitesWithActivePlan){
                    this.selectedStudySite = this.studySitesOptions[0].value;
                    this.tasksGroups = data.tasksGroups;
                }
                this.initialized = true;
                this.spinner.hide();
            })
            .catch(error => {
                console.error('Error in getInitialPlan():' + JSON.stringify(error));
            });
    }

    doUpdateStudySite(event){
        let selectedSS = event.detail.value;
        this.spinner.show();
        getPlanForStudySite({
            ssId: selectedSS
        })
            .then(data => {
                this.tasksGroups = data.tasksGroups;
                this.spinner.hide();
            })
            .catch(error => {
                console.error('Error in getPlanForStudySite():' + JSON.stringify(error));
            });
    }

    renderedCallback(){
        this.spinner = this.template.querySelector('c-web-spinner');
        if (!this.initialized){
            this.spinner.show();
        }
    }
}