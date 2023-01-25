import { LightningElement,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class PpMyTelevisitsList extends NavigationMixin (LightningElement) {
    pasttelevisitdata = [];
    showuppasttelevisits = false;
    @api pasttelevisitsrecords;
    connectedCallback() {
        this.pasttelevisitdata = this.pasttelevisitsrecords;
        this.showuppasttelevisits = true;
    }
}