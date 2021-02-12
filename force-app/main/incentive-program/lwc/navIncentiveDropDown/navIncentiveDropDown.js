/**
 * Created by Andrii Kryvolap.
 */

import { LightningElement, api, track } from 'lwc';
import totalLabel from '@salesforce/label/c.IncentiveProgram_Total';
import totalLabelRTL from '@salesforce/label/c.IncentiveProgram_TotalRTL';
import lastEarnedLabel from '@salesforce/label/c.IncentiveProgram_Last_Earned';
import lastEarnedLabelRTL from '@salesforce/label/c.IncentiveProgram_Last_EarnedRTL';
import ptsLabel from '@salesforce/label/c.IncentiveProgram_Pts';
import viewDetailsLabel from '@salesforce/label/c.IncentiveProgram_View_Details';

export default class NavIncentiveDropDown extends LightningElement {
    labels = {
        totalLabel,
        totalLabelRTL,
        lastEarnedLabel,
        lastEarnedLabelRTL,
        ptsLabel,
       
        viewDetailsLabel
    };
    @api isRtl;
    @api totalPoints;
    @api lastPoints;
  
    doViewDetails() {
        console.log('viewDetails');
        const navigateToIncentivesEvent = new CustomEvent('navigatetoincentives', {
            detail: {
                page: 'incentives'
            }
        });
        this.dispatchEvent(navigateToIncentivesEvent);
    }
}