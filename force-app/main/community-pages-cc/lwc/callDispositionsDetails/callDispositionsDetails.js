import { LightningElement, track, api } from 'lwc';

export default class CallDispositionsDetails extends LightningElement {

    @api index;
    @api items;
    @api itemId;
    @api callDate;
    @api callCategory;
    @api selected;

    @api
    get retitems() {
        return this.items
    }

    get retitemId() {
        return this.itemId
    }

    get retCallDate() {
        return this.callDate
    }

    get retCallCategory() {
        return this.callCategory
    }

    get highlight() {
        return this.index == 0 ? 'pointer highlight' : 'pointer';
    }

    @api
    unselect(target){
        this.template.querySelector('[data-value="0"]').classList.remove('highlight');        
    }
    @api
    unselectNew(){
       
        this.template.querySelector('[data-value="0"]').classList.remove('highlight');        
    }


}