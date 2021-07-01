import { LightningElement, track, api } from 'lwc';
import community_icon from '@salesforce/resourceUrl/rr_community_icons'

export default class App extends LightningElement {
    @api index;
    @api fname;
    @track icon_url;
    @track isEmpty;

    @track dataToDisplay;

    @api
    get rdata() {
        return this.dataToDisplay;
        
    }
    get rfname() {
        return this.fname;
    }

    set rdata(value) {
        this.dataToDisplay = JSON.parse(JSON.stringify(value));
    }
       
    connectedCallback()
    {
        this.isEmpty = true;
        console.log('fieldname1211'+this.fname);
        if(this.fname == false){
            this.isEmpty = false;
            this.icon_url = community_icon + '/close.svg';
        } else if(this.fname == true){
            this.isEmpty = false;
            this.icon_url = community_icon + '/checkGreen.svg';
        } else {
            this.isEmpty = true;
        }
    }
 }