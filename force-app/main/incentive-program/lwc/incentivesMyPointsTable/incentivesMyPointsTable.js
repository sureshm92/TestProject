/**
 * Created by Andrii Kryvolap.
 */

import { LightningElement, api } from 'lwc';

import dateLabel from '@salesforce/label/c.IncentiveProgram_Date';
import taskLabel from '@salesforce/label/c.IncentiveProgram_Task';
import ptsLabel from '@salesforce/label/c.IncentiveProgram_Pts';
import getisRTL from '@salesforce/apex/ParticipantVisitsRemote.getIsRTL';
import pointsEarnedLabel from '@salesforce/label/c.IncentiveProgram_Points_Earned';

export default class IncentivesMyPointsTable extends LightningElement {
    labels = {
        dateLabel,
        taskLabel,
        ptsLabel,
        pointsEarnedLabel
    };
    rtl;
    rtlPointsEarned;
    @api completedTasks;
    connectedCallback() {
        getisRTL()
        .then((data) => {
            this.rtl = data === true? 'rtl': '';
            this.rtlPointsEarned = data === true? 'rtlPoints': '';
        })
        .catch(function(error) {
            console.error('Error: ' + JSON.stringify(error));
        });
    }
}