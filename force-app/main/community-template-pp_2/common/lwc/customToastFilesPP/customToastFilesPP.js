import { LightningElement, track, api } from 'lwc';

export default class CommonToast extends LightningElement {
    @api isMobile;
    @track type = 'success';
    @track message;
    @track messageIsHtml = false;
    @track showToastBar = false;
    @api autoCloseTime = 5000;
    @track icon = '';


    @api
    showToast(type, message, icon, time) {
        this.type = type;
        this.message = message;
        this.icon = icon;
        this.autoCloseTime = time;
        this.showToastBar = true;
        setTimeout(() => {
            this.closeModel();
        }, this.autoCloseTime);
    }

    closeModel() {
        this.showToastBar = false;
        this.type = '';
        this.message = '';
    }

    get getIconName() {
        if (this.icon) {
            return this.icon;
        }
        return 'utility:' + this.type;
    }

    get innerClass() {
        return (
            'slds-icon_container slds-icon-utility-' +
            this.type +
            ' slds-m-right_small slds-no-flex  '
        );
    }

    get outerClass() {
        if (!this.isMobile) {
            return (
                ' forceToastMessageF  forceActionsTextF  PP-Mot-Message-Toast slds-notify slds-notify_toast slds-theme_' +
                this.type
            );
        } else {
            return 'cust-pad slds-theme_' + this.type;
        }
    }
}