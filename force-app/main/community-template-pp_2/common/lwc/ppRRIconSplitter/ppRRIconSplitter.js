import { LightningElement, api, track } from 'lwc';

export default class PpRRIconSplitter extends LightningElement {
    @api icons = '';
    @api backgroundColor = 'White';
    @api label = '';
    @api description = '';
    Index = '';
    @api iconColour = '#b2b2b2';
    @track classListArry = [];
    @track testArray = [];
    @api name = '';

    @api
    resetValues() {
        console.log('inside reset');
        this.name = '';
        this.description = '';
        this.label = '';
        this.icons = '';
    }

    handleonclick(event) {
        this.label = event.target.dataset.label;
        this.description = event.target.dataset.description;
        this.name = event.target.dataset.name;
        this.Index = event.target.dataset.index;

        let webIcons = this.template.querySelectorAll('.icons-pad');
        let firstItem = this.template.querySelector('.icons-pad:first-child');
    }
}