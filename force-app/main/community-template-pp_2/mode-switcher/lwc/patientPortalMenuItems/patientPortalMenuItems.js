import { LightningElement, api } from 'lwc';
import changeMode from '@salesforce/apex/CommunityModeSwitcherRemote.changeMode';
import getCommunityUserVisibility from '@salesforce/apex/CommunityModeSwitcherRemote.getCommunityUserVisibility';
import partipantsDelegate from '@salesforce/label/c.Paticipant_s_Delegate';
import PP_DesktopLogos from '@salesforce/resourceUrl/PP_DesktopLogos';
import jsonTV1 from '@salesforce/resourceUrl/jsonTV1';

export default class PatientPortalMenuItems extends LightningElement {
    participantSettingImage = PP_DesktopLogos + '/Participant_Settings.svg';
    @api allModes;
    @api user;
    delegateLabel = partipantsDelegate;
    pickListOptions = [];
    value;
    showProgramList;
    comboBoxHeading;
    currentMode;
    error;
    isSingleMode = false;
    itemValue;
    navigateTo;
    @api newList = [];
    isDisplayList = false;
    selectedItem;

    connectedCallback() {
        if (this.allModes.ppModeItems.length == 1) {
            this.isSingleMode = true;
            let currentSubItems;
            let programList = [];
            var pickList;
            currentSubItems = this.allModes.ppModeItems[0].subItems;
            for (let i = 0; i < currentSubItems.length; i++) {
                let comboBoxHeader;
                comboBoxHeader = currentSubItems[i].isProgram ? 'Program' : 'Study';
                pickList = { label: currentSubItems[i].subTitle, value: currentSubItems[i].peId, headerValue: comboBoxHeader, subItemValue: currentSubItems[i] };
                programList.push(pickList);
                if (currentSubItems[i].isSelected == true) {
                    this.selectedItem = currentSubItems[i];
                    this.value = currentSubItems[i].peId;
                    this.comboBoxHeading = comboBoxHeader;
                }
            }
            this.pickListOptions = programList;
        }
    }
    get ifSingleMode() {
        return this.isSingleMode;
    }

    get optionsList() {
        return this.pickListOptions;
    }

    handlePicklistSelection(event) {


    }
}