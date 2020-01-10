/**
 * Created by Igor Malyuta on 04.01.2020.
 */

import {LightningElement, api} from 'lwc';
import profileTZ from '@salesforce/i18n/timeZone';
import AvatarColorCalculator from 'c/avatarColorCalculator';

export default class MessageItem extends LightningElement {

    @api item;
    @api userMode;

    renderedCallback() {
        this.template.querySelector('.ms-item-icon').style.background =
                new AvatarColorCalculator().getColorFromString(this.item.message.Sender_Name__c);
    }

    get initials() {
        let initials = this.item.message.Sender_Name__c.match(/\b\w/g) || [];
        initials = ((initials.shift() || '') + (initials.shift() || '')).toUpperCase();

        return initials;
    }

    get timeZone() {
        return profileTZ;
    }
}