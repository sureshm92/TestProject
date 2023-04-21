/**
 * Created by Igor Malyuta on 20.01.2020.
 */

import { LightningElement, api, track } from 'lwc';
import getCounter from '@salesforce/apex/MessagePageRemote.getUnreadCount';
import New from '@salesforce/label/c.New';

export default class NavMessageCounter extends LightningElement {
    @api isOnPage = false;
    @track counter;
    @api isMessagePage = false;
    labels = {
        New
    };

    connectedCallback() {
        setInterval(
            () => {
                getCounter()
                    .then((data) => {
                        let unread = data;
                        if (unread === 0) {
                            this.counter = null;
                        } else {
                            this.counter = unread < 10 ? unread : '9+';
                        }
                    })
                    .catch((error) => {
                        console.error('Error in getCounter():' + JSON.stringify(error));
                    });
            },
            this.isOnPage ? 1000 : 5000
        );
    }
}