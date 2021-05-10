/**
 * Created by Andrii Kryvolap.
 */

import { LightningElement, api, track } from 'lwc';
import totalLabel from '@salesforce/label/c.IncentiveProgram_Total';
import lastEarnedLabel from '@salesforce/label/c.IncentiveProgram_Last_Earned';
import ptsLabel from '@salesforce/label/c.IncentiveProgram_Pts';
import viewDetailsLabel from '@salesforce/label/c.IncentiveProgram_View_Details';
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
    rtlStyle;
    niddContainerStyle;

    connectedCallback() {
        this.rtlStyle = this.isRtl == true? 'nidd-total slds-p-around_xx-small rtl': 'nidd-total slds-p-around_xx-small';
        this.niddContainerStyle = this.isRtl == true? 'nidd-containerRTL': 'nidd-container';
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