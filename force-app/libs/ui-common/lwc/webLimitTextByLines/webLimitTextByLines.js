/**
 * Created by Igor Malyuta on 08.01.2020.
 */

import {LightningElement, api} from 'lwc';

export default class WebLimitTextByLines extends LightningElement {

    @api classCss;
    @api maxLines;
    @api background;
    @api lineHeight = '1.4';
    @api unitsType = 'em';

    renderedCallback() {
        let block = this.template.querySelector('.block-with-text');
        if(block) {
            block.style.lineHeight = (this.lineHeight + this.unitsType);
            block.style.maxHeight = (this.lineHeight * this.maxLines) + this.unitsType;
            block.style.background = (this.background ? this.background : 'none');
        }
    }

    get cssClass() {
        return 'block-with-text ' + (this.classCss ? this.classCss : '');
    }
}