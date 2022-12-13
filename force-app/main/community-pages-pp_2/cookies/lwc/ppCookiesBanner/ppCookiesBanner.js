import { LightningElement, track, api } from 'lwc';

export default class PpCookiesBanner extends LightningElement {
    showmodal = false;
    @api
    loginPage = false;

    showManagePreferences() {
        alert('showManagePreferences');
        this.showmodal = true;
    }

    get backDropClass() {
        return 'slds-backdrop ' + (this.showmodal ? ' slds-backdrop_open ' : '');
    }
}
