/**
 * Created by Andrii Kryvolap.
 */

import {LightningElement, api} from 'lwc';

import myPointsLabel from '@salesforce/label/c.IncentiveProgram_My_Points';
import totalPointsLabel from '@salesforce/label/c.IncentiveProgram_Total_Points';
import redeemPointsLabel from '@salesforce/label/c.IncentiveProgram_Redeem_Points';
import redeemPointsDisclaimerLabel from '@salesforce/label/c.IncentiveProgram_Redeem_Points_Disclaimer';

export default class IncentivesMyPointsHeader extends LightningElement {

    labels = {
        myPointsLabel,
        totalPointsLabel,
        redeemPointsLabel,
        redeemPointsDisclaimerLabel,
    };
    @api totalPoints;

}