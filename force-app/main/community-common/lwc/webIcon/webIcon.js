/**
 * Created by Igor Malyuta on 18.11.2019.
 */

import {LightningElement, api} from 'lwc';
import rrIcons from '@salesforce/resourceUrl/rr_community_icons';
import rrImages from '@salesforce/resourceUrl/rr_community_images';

export default class WebIcon extends LightningElement {

    @api iconName;
    @api iconColor = '#CCCCCC';
    @api iconSize = 'default';//default/small/big
    @api printMode = false;

    get icon() {
        return rrIcons + '/icons.svg#' + this.iconName;
    }

    get imageSrc() {
        return rrImages + '/' + this.iconName + '.png';
    }

    get svgClass() {
        return 'rr-icon-' + this.iconSize;
    }
}