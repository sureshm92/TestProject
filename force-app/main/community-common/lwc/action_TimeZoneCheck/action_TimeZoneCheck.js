/**
 * Created by Igor Malyuta on 02.12.2019.
 */

import {LightningElement} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import profileTZ from '@salesforce/i18n/timeZone';
import toastMessage from '@salesforce/label/c.Toast_TimeZone';

const accUrl = 'settings?tab=account-settings';

export default class ActionTimeZoneCheck extends NavigationMixin(LightningElement) {

    renderedCallback() {
        if(Intl.DateTimeFormat().resolvedOptions().timeZone !== profileTZ) {
            const event = new ShowToastEvent({
                title: '',
                message: toastMessage,
                messageData: [
                    {
                        url: accUrl,
                        label: 'here'
                    }
                ],
                mode: 'sticky',
                variant: 'warning'
            });
            this.dispatchEvent(event);
        }
    }
}