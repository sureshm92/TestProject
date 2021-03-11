/**
 * Created by Andrii Kryvolap.
 */

import { LightningElement, api, track } from 'lwc';
import totalLabel from '@salesforce/label/c.IncentiveProgram_Total';
import lastEarnedLabel from '@salesforce/label/c.IncentiveProgram_Last_Earned';
import ptsLabel from '@salesforce/label/c.IncentiveProgram_Pts';
import viewDetailsLabel from '@salesforce/label/c.IncentiveProgram_View_Details';
import getisRTL from '@salesforce/apex/ParticipantVisitsRemote.getIsRTL';
export default class NavIncentiveDropDown extends LightningElement {
    labels = {
        totalLabel,
        lastEarnedLabel,
        ptsLabel,
        viewDetailsLabel
    };
    @api isRtl;
    @api totalPoints;
    @api lastPoints;

    connectedCallback() {
        getisRTL()
        .then((data) => {
            this.isRtl = data === true? 'nidd-total slds-p-around_xx-small rtl': 'nidd-total slds-p-around_xx-small';
        })
        .catch(function(error) {
            console.error('Error: ' + JSON.stringify(error));
        });
    }
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