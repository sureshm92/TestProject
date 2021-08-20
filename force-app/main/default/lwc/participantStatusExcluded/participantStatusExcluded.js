import { LightningElement, track, api } from 'lwc';
import community_icon from '@salesforce/resourceUrl/rr_community_icons'

export default class App extends LightningElement {
    @api status;
    @track icon_url;

    @api
    get participantstatus() {
        return this.status;
    }
       
    connectedCallback()
    {
        if(this.status === 'Excluded from Referring' || this.status === 'Failed Referral' || this.status === 'Pending Referral'){
            this.icon_url = community_icon + '/close.svg';
        } else {
            this.icon_url = community_icon + '/checkGreen.svg';
        } 
    }
 }