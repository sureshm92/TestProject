/**
 * Created by Igor Malyuta on 18.11.2019.
 */

import {LightningElement, api} from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import rrIcons from '@salesforce/resourceUrl/rr_community_icons';
import rrImages from '@salesforce/resourceUrl/rr_community_images';

export default class WebIcon extends LightningElement {

    @api iconName;
    @api iconColor = '#CCCCCC';
    @api classCss;
    @api printMode = false;

    get icon() {
        return rrIcons + '/icons.svg#' + this.iconName;
    }

    get imageSrc() {
        return rrImages + '/' + this.iconName + '.png';
    }

    get svgClass() {
        return (this.classCss !== undefined ? this.classCss : 'rr-icon-default');
    }
}