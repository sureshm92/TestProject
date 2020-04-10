/**
 * Created by Igor Malyuta on 07.04.2020.
 */

import {LightningElement, api, track} from 'lwc';
import isDummyMode from '@salesforce/apex/CommunityFacadeRemote.isDummyMode';

export default class BuilderStub extends LightningElement {

    @track pageName;
    @track buildMode = false;

    @api
    setPageName(name) {
        this.pageName = name.substring(1);
        this.buildMode = true;
    }

    //For LWC components
    @api
    isDummy(callback) {
        isDummyMode()
            .then(data => {
                callback(data);
            })
            .catch(error => {
                console.error('Error in BuilderStub:' + JSON.stringify(error));
            });
    }
}