/**
 * Created by Igor Malyuta on 19.09.2019.
 */

import {LightningElement, api, track} from 'lwc';

export default class UiIndeterminatedCheckbox extends LightningElement {

    @api keyId;
    @api fieldLabel;
    @api hideCheckBox = false;
    @track cssClass = 'checkbox';

    handleClick(event) {
        if(this.indeterminate && !this.fieldValue) {
            this.indeterminate = false;
            this.fieldValue = false;
        } else {
            this.fieldValue = !this.fieldValue;
            this.indeterminate = false;
            if(!this.fieldValue) this.cssClass = 'checkbox';
        }

        // Creates the event with the data.
        const selectedEvent = new CustomEvent('valuechanged', {
            detail: {
                keyId : this.keyId,
                value: this.fieldValue
            }
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    @api
    get fieldValue() {
        return this._fieldValue;
    }
    set fieldValue(value) {
        this._fieldValue = value;
    }

    @api
    get indeterminate() {
        return this._indeterminate;
    }
    set indeterminate(value) {
        this.cssClass = 'checkbox';
        this._indeterminate = value;
        if (value) {
            this.cssClass += ' indeterminated';
        } else if (this.fieldValue) {
            this.cssClass += ' checked';
        }
    }

    @api
    setState(value, indeterminate) {
        this.fieldValue = value;
        this.indeterminate = indeterminate;
    }
}