/**
 * Created by Igor Malyuta on 20.01.2020.
 */

import { LightningElement, api, track } from 'lwc';
import getCounter from '@salesforce/apex/MessagePageRemote.getUnreadCount';
import New from '@salesforce/label/c.New';
import Message_MinTime_DoNotTranslate from '@salesforce/label/c.Message_MinTime_DoNotTranslate';
import Message_MaxTime_DoNotTranslate from '@salesforce/label/c.Message_MaxTime_DoNotTranslate';

export default class NavMessageCounter extends LightningElement {
    @api isOnPage = false;
    @track counter;
    @track isTab;
    @api isMessagePage = false;
    @api portraitCount;
    labels = {
        New,
        Message_MinTime_DoNotTranslate,
        Message_MaxTime_DoNotTranslate
    };

    connectedCallback() {
        this.isTab = this.isTablet();
        if (this.portraitCount > 0) {
            this.counter = this.portraitCount;
        }
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
                        this.dispatchEvent(new CustomEvent('msgnotify', {
                            detail: {
                                message: this.counter
                            }
                        }));
                    })
                    .catch((error) => {
                        console.error('Error in getCounter():' + JSON.stringify(error));
                    });
            },
            this.isOnPage ? this.labels.Message_MinTime_DoNotTranslate : this.labels.Message_MaxTime_DoNotTranslate
            // this.isOnPage ? 1000 : 5000
        );
    }
    isTablet() {
        if (window.innerWidth >= 768 && window.innerWidth <= 1280) {
            if (/android/i.test(navigator.userAgent.toLowerCase())) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }
}