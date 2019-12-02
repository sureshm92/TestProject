/**
 * Created by Igor Malyuta on 29.11.2019.
 */

import {LightningElement} from 'lwc';

export default class LwcTestPage extends LightningElement {

    handleShow() {
        this.template.querySelector('c-web-popup').show();
    }

    doShare() {
        alert('Share@');
    }

    doCancel() {
        this.template.querySelector('c-web-popup').hide();
    }
}