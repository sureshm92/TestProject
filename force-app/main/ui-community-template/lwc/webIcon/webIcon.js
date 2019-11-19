/**
 * Created by Igor Malyuta on 18.11.2019.
 */

import {LightningElement, api} from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import rrIcons from '@salesforce/resourceUrl/rr_community_icons';
import communityPack from '@salesforce/resourceUrl/rr_community';

export default class WebIcon extends LightningElement {

    @api iconName;
    @api classCss;

    connectedCallback() {
        loadStyle(this, communityPack + '/rr_community_css.css');
    }

    get icon() {
        return rrIcons + '/icons.svg#' + this.iconName;
    }

    get cssClass() {
        return this.classCss + ' rr-icon-default';
    }
}