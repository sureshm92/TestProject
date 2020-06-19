/**
 * Created by Andrii Kryvolap.
 */

import {LightningElement, api} from 'lwc';

import dateLabel from '@salesforce/label/c.IncentiveProgram_Date';
import taskLabel from '@salesforce/label/c.IncentiveProgram_Task';
import ptsLabel from '@salesforce/label/c.IncentiveProgram_Pts';
import pointsEarnedLabel from '@salesforce/label/c.IncentiveProgram_Points_Earned';


export default class IncentivesMyPointsTable extends LightningElement {

    labels={
        dateLabel,
        taskLabel,
        ptsLabel,
        pointsEarnedLabel,
    }
    @api completedTasks;

}