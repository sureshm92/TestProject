import { LightningElement,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getisRTL from '@salesforce/apex/PreferenceManagementController.getIsRTL';

export default class PpMyTelevisitsList extends NavigationMixin (LightningElement) {
    pasttelevisitdata = [];
    showuppasttelevisits = false;
    @api pasttelevisitsrecords;
    @api ismobile;
    @api zonetime;
    @api isRTL = false;

    get leftLine2Style() {
        return this.isRTL ? 'left-line2-rtl' : 'left-line2';
    }

    get leftLine1Style() {
        return this.isRTL ? 'left-line1-rtl' : 'left-line1';
    }

    connectedCallback() {
        this.pasttelevisitdata = this.pasttelevisitsrecords;
        this.showuppasttelevisits = true;
        getisRTL()
            .then((data) => {
                this.isRTL = data;
                console.log('rtl--->'+this.isRTL);
            })
            .catch(function (error) {
                console.error('Error RTL: ' + JSON.stringify(error));
            });
    }
}