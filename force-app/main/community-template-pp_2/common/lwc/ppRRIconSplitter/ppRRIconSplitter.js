import { LightningElement, api } from 'lwc';

export default class PpRRIconSplitter extends LightningElement {
    @api value = 'true';
    @api cVal = '';
    @api icons = '';
    @api backgroundColor = 'White';
    @api boolRTL = '';
    Label = '';
    Description = '';
    Name = '';
    @api iconColour = '#b2b2b2';

    connectedCallback() {
        var value = this.value;
    }

    get bgColour() {
        return this.backgroundColor ? 'background-color:' + this.backgroundColor : '';
    }

    get iconItemClass() {
        return this.cVal ? 'icon-item' + this.cVal : '';
    }

    handleonclick(event) {
        this.Label = event.target.dataset.id;
        this.Description = event.target.dataset.description;
        this.Name = event.target.dataset.name;
    }

    get iconColour() {
        return this.Label != '' ? '#00A3E0' : '#b2b2b2';
    }
}
