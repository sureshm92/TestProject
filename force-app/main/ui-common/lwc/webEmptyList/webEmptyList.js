/**
 * Created by Igor Malyuta on 28.11.2019.
 */

import {LightningElement, api} from 'lwc';
import defaultMessage from '@salesforce/label/c.PG_VP_L_No_Items_display';

export default class WebEmptyList extends LightningElement {

    @api id;
    @api cssClass;
    @api iconName = 'sad';//sad/happy/neutral
    @api icnColor = '#CCCCCC';
    @api message = defaultMessage;
    @api targetList;

    get isShow() {
        return !this.targetList || this.targetList.length === 0;
    }

    get showIcon() {
        return this.iconName !== 'none';
    }

    get iconFace() {
        return 'icon-face-' + this.iconName;
    }
}