import { LightningElement, track, api } from 'lwc';
import community_icon from '@salesforce/resourceUrl/rr_community_icons'

export default class App extends LightningElement {
    @api medstatus;
    @track icon_url;

    @api
    get medicalstatus() {
        return this.medstatus;
    }
       
    connectedCallback()
    {
        this.isEmpty = true;
        if(this.medstatus == 'Pass'){
            this.icon_url = community_icon + '/checkGreen.svg';
        } else {
            this.icon_url = community_icon + '/close.svg';
        } 
    }
 }