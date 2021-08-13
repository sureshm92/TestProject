/**
 * Created by Igor Malyuta on 04.01.2020.
 */

import { LightningElement, api, track } from 'lwc';
import AvatarColorCalculator from 'c/avatarColorCalculator';

import markRead from '@salesforce/apex/MessagePageRemote.markConversationAsRead';

const defaultBG = 'white';
const selectedBG = 'rgb(238, 245, 255)';

export default class ConversationItem extends LightningElement {
    @api item;
    @api userMode;
    @track attachColor = '#000';
    @track isSelected = false;
    @api piContactNames;

    @api
    setSelectedMode(selected) {
        this.isSelected = selected;
        this.attachColor = selected ? '#297dfd' : '#000';

        this.calculateStyles();
    }

    renderedCallback() {
        this.template.querySelector(
            '.con-icon'
        ).style.background = new AvatarColorCalculator().getColorFromString(this.item.fullName);

        this.calculateStyles();
    }

    get initials() {
        let initials = this.item.fullName.match(/\b\w/g) || [];
        initials = ((initials.shift() || '') + (initials.shift() || '')).toUpperCase();

        return initials;
    }

    handleConversationClick(event) {
        if (this.item.unread) {
            markRead({
                conversation: this.item.conversation,
                isIE: navigator.userAgent.match(/Trident|Edge/) !== null,
                piContactNames: piContactNames
            })
                .then((data) => {
                    try {
                        this.item = data;
                    } catch (e) {
                        console.error('TRY mark:' + JSON.stringify(e));
                    }
                })
                .catch((error) => {
                    console.error('Error in markRead():' + JSON.stringify(error));
                });
        }

        this.dispatchEvent(
            new CustomEvent('openconversation', {
                detail: {
                    item: this.item
                }
            })
        );
    }

    get isPIMode() {
        return this.userMode === 'PI';
    }

    calculateStyles() {
        let bgColor = this.isSelected ? selectedBG : defaultBG;
        this.template.querySelector('.con-wrapper').style.background = bgColor;
        this.template.querySelectorAll('c-web-limit-text-by-lines').forEach(function (cmp) {
            cmp.setBackground(bgColor);
        });
    }
}
