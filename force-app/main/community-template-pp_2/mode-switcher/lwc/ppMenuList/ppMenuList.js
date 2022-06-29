import { LightningElement, api } from 'lwc';
import partipantsDelegate from '@salesforce/label/c.Paticipant_s_Delegate';
import PP_DesktopLogos from '@salesforce/resourceUrl/PP_DesktopLogos';
export default class PpMenuList extends LightningElement {
    delegateLabel = partipantsDelegate;
    label;
    options;
    pickListValues = [];
    participantSettingImage = PP_DesktopLogos + '/Participant_Settings.svg';
    @api currentSubItems;
    @api user;
    isDelegate;
    subTitle;
    connectedCallback() {
        let userName = user.Contact.FirstName + ' ' + this.user.Contact.LastName;
        this.subTitle = this.currentSubItems[0].title == userName ? 'Self' : this.currentSubItems[0].title;
        this.isDelegate = this.currentSubItems[0].isDelegate;
        for (let i = 0; i < this.currentSubItems.length; i++) {
            let header = this.currentSubItems[i].isProgram ? 'Program' : 'Study';
            this.pickListValues.push({ label: this.currentSubItems[i].subTitle, value: this.currentSubItems[i].peId, headerValue: header });
        }

    }
    handleClick() {
        const selectedEvent = new CustomEvent("submodeselection", {
            detail: this.pickListValues
        });
        this.dispatchEvent(selectedEvent);
    }


}