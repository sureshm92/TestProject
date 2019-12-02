/**
 * Created by Igor Malyuta on 24.11.2019.
 */

import {LightningElement} from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import communityStyle from '@salesforce/resourceUrl/rr_community_css';

export default class WebPreviewTable extends LightningElement {

    connectedCallback() {
        loadStyle(this, communityStyle);
    }
}