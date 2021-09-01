import { LightningElement, track, api } from 'lwc';

export default class App extends LightningElement {
    @api
    selected = false;

    @api
    label;

    @api
    value;

    handleSelect(event) {
        //this.selected = true;
        event.stopImmediatePropagation();
        event.preventDefault();
        if (this.selected) {
            this.selected = false;
        } else {
            this.selected = true;
        }
        let selectedValueMap = {
            checked: this.selected,
            value: this.template.querySelector('lightning-input').value
        };
        const selectedEvent = new CustomEvent('selectpicklist', { detail: selectedValueMap });
        this.dispatchEvent(selectedEvent);
    }
    handleCheckBoxChange(event) {
        let i;
        let checkboxes = this.template.querySelectorAll('[data-id="checkbox"]');
        for (i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = event.target.checked;
        }
    }
}