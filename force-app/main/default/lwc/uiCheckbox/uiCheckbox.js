/**
 * Created by Igor Malyuta on 19.09.2019.
 */

import {LightningElement, api} from 'lwc';

export default class UiCheckbox extends LightningElement {

    @api keyId;
    @api forField;
    @api fieldLabel;
    @api fieldValue;

    handleEvent(event) {
        // Creates the event with the data.
        const selectedEvent = new CustomEvent('valuechanged', {
            detail: {
                keyId: this.keyId,
                field: this.forField,
                value: event.target.checked
            }
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}