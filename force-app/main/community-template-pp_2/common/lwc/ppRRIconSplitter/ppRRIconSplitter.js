import { LightningElement, api, track } from 'lwc';

export default class PpRRIconSplitter extends LightningElement {
    @api icons = '';
    @api backgroundColor = 'White';
    @api label = '';
    @api description = '';
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
        let index = event.target.dataset.index;
        let webIcons = this.template.querySelectorAll('.bio-icons');
        webIcons.forEach((ele) => {
            ele.classList.remove('active');
        });
        webIcons[index].classList.add('active');
        document.getElementById('.before-your-visits').scrollTo(0,0)
    }
}
