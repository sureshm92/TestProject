import { LightningElement, api } from 'lwc';
import partipantsDelegate from '@salesforce/label/c.Paticipant_s_Delegate';
import PP_DesktopLogos from '@salesforce/resourceUrl/PP_DesktopLogos';

export default class PatientPortalMenuList extends LightningElement {
    @api commModes = [];
    participantSettingImage = PP_DesktopLogos + '/Participant_Settings.svg';
    delegateLabel = partipantsDelegate;

    handleDisplay(event) {
        let participantName = event.currentTarget.dataset.id;
        let selectedItem;
        if (participantName) {
            selectedItem = this.commModes.filter(function (item) {
                return item.title == participantName;
            });
        }
        const selectedEvent = new CustomEvent('changemode', {
            detail: selectedItem
        });
        this.dispatchEvent(selectedEvent);

    }
}