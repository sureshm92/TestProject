import { LightningElement, api, track } from 'lwc';

export default class PpRRIconSplitter extends LightningElement {
    @api icons = '';
    @api backgroundColor = 'White';
    Label = '';
    Description = '';
    Index = '';
    @api iconColour = '#b2b2b2';
    @track classListArry = [];
    @track testArray = [];

    @api
    resetValues() {
        console.log('inside reset');
        this.Name = '';
        this.Description = '';
        this.Label = '';
        this.icons = '';
    }

    handleonclick(event) {
        this.Label = event.target.dataset.id;
        this.Description = event.target.dataset.description;
        this.Name = event.target.dataset.name;
        this.Index = event.target.dataset.index;

        let webIcons = this.template.querySelectorAll('.icons-pad');
        let firstItem = this.template.querySelector('.icons-pad:first-child');
    }
}
