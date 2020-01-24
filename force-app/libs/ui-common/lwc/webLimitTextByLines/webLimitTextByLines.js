/**
 * Created by Igor Malyuta on 08.01.2020.
 */

import {LightningElement, api} from 'lwc';

export default class WebLimitTextByLines extends LightningElement {

    @api title;
    @api classCss;
    @api maxLines;
    @api background;
    @api lineHeight = '1.4';
    @api unitsType = 'em';

    blockWithTxt;

    @api
    setBackground(color) {
        this.blockWithTxt.style.background = color;
    }

    renderedCallback() {
        if (!this.blockWithTxt) this.blockWithTxt = this.template.querySelector('.block-with-text');

        this.blockWithTxt.style.lineHeight = (this.lineHeight + this.unitsType);
        this.blockWithTxt.style.maxHeight = (this.lineHeight * this.maxLines) + this.unitsType;
        this.blockWithTxt.style.background = (this.background ? this.background : 'white');

    }

    get cssClass() {
        return 'block-with-text ' + (this.classCss ? this.classCss : '');
    }
}