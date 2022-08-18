import { LightningElement, api } from 'lwc';
import partipantsDelegate from '@salesforce/label/c.Participant_s_Delegate';
import PP_DesktopLogos from '@salesforce/resourceUrl/PP_DesktopLogos';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';

export default class PatientPortalMenuList extends LightningElement {
    @api commModes = [];
    icon_url = pp_icons + '/participant_settings.svg';
    participantSettingImage = PP_DesktopLogos + '/Participant_Settings.svg';
    label = {
        partipantsDelegate
    };
    handleListDisplay(event) {
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

    get svgClass() {
        return '';
    }
    get iconName() {
        return 'participant_settings';
    }
    handleNavigation(event) {
        let participantName = event.currentTarget.dataset.id;
        let selectedItem;
        if (participantName) {
            selectedItem = this.commModes.filter(function (item) {
                return item.title == participantName;
            });
        }
        let subItem = selectedItem[0].programList[0].subItemValue;
        console.log('????????????subItem' + JSON.stringify(subItem));
        const selectedEvent = new CustomEvent('itemselection', {
            detail: {
                itemValue: subItem,
                navigateTo: 'account-settings'
            },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(selectedEvent);
    }
}
