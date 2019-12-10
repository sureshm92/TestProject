/**
 * Created by Yulia Yakushenkova on 11/29/2019.
 */

import {LightningElement, api} from 'lwc';

export default class WebCollapse extends LightningElement {

    @api isCollapsed;
    @api label;

    connectedCallback() {
        this.isCollapsed = true;
    }

    doSwitch() {
        this.isCollapsed = !this.isCollapsed;
    }

    get collapseCss() {
        return 'rr-collapse-panel ' + (this.isCollapsed ? ' collapsed' : '');
    }
}