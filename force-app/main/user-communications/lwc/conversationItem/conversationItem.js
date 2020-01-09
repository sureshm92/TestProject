/**
 * Created by Igor Malyuta on 04.01.2020.
 */

import { LightningElement, api, track } from 'lwc';
import AvatarColorCalculator from 'c/avatarColorCalculator';

export default class ConversationItem extends LightningElement {

    @api item;
    @api userMode;
    @track attachColor = '#000';

    @api
    setSelectedMode(selected) {
        this.template.querySelector('.con-wrapper').style.background = selected ? 'rgba(41,125,253,.08)' : 'none';
        this.attachColor = selected ? '#11a4de' : '#000';
    }

    renderedCallback() {
        this.template.querySelector('.con-icon').style.background =
            new AvatarColorCalculator().getColorFromString(this.item.fullName);
    }

    get initials() {
        let initials = this.item.fullName.match(/\b\w/g) || [];
        initials = ((initials.shift() || '') + (initials.shift() || '')).toUpperCase();

        return initials;
    }

    handleConversationClick(event) {
        this.dispatchEvent(new CustomEvent('openconversation', {
            detail: {
                item: this.item
            }
        }));
    }

    get isPIMode() {
        return this.userMode === 'PI';
    }
}