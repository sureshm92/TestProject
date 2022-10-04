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
    isloaded = false;

    @api
    resetValues() {
        console.log('inside reset');
        this.name = '';
        this.description = '';
        this.label = '';
        this.icons = '';
    }

    renderedCallback() {
        let webIcons = this.template.querySelectorAll('.bio-icons');
        if (webIcons[0] && this.isloaded != true) {
            webIcons.forEach((ele) => {
                ele.classList.remove('active');
            });
            webIcons[0].classList.add('active');
            this.isloaded = true;
        }
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
        let pScroll = this.template.querySelector('.before-your-visits')
		pScroll.scrollTop=0;
    } 

        this.template.querySelector('.visit-desc').scrollTop = 0;
    }
}
