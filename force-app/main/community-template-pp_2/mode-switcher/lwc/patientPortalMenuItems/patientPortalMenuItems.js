import { LightningElement, api } from 'lwc';
import changeMode from '@salesforce/apex/CommunityModeSwitcherRemote.changeMode';
import getCommunityUserVisibility from '@salesforce/apex/CommunityModeSwitcherRemote.getCommunityUserVisibility';
import partipantsDelegate from '@salesforce/label/c.Paticipant_s_Delegate';
import jsonTV1 from '@salesforce/resourceUrl/jsonTV1';

export default class PatientPortalMenuItems extends LightningElement {
    @api allModes;
    @api user;
    delegateLabel = partipantsDelegate;
    pickListOptions = [];
    defaultPicklistValue;
    showProgramList;
    headerValue = 'Program';
    currentMode;
    @api communityService;
    error;
    isSingleMode;

    connectedCallback() {
        // console.log('=======' + this.user.Contact.FirstName + ' ' + this.user.Contact.LastName);
        if (this.allModes.ppModeItems.length == 1) {
            this.isSingleMode = true;
            for (let i = 0; i < this.allModes.ppModeItems[0].subItems.length; i++) {
                let header = this.allModes.ppModeItems[0].subItems[i].isProgram ? 'Program' : 'Study';
                if (i = 0) {
                    this.headerValue = header;
                }
                this.pickListOptions.push({
                    label: this.allModes.ppModeItems[0].subItems[i].subTitle,
                    value: this.allModes.ppModeItems[0].subItems[i].peId,
                    headerValue: header
                });
            }
            this.showProgramList = true;
            if (this.pickListOptions.length == 1) {
                let itemValue = this.allModes.ppModeItems[0].subItems[0];
                const selectedEvent = new CustomEvent('itemselection', {
                    detail: { itemValue }
                });
                this.dispatchEvent(selectedEvent);

            }
        }
    }
    get ifSingleMode() {
        return this.isSingleMode;
    }

    handleValueChange(event) {
        this.pickListOptions = [];
        let titleValue = event.detail;
        this.pickListOptions = titleValue;
        this.defaultPicklistValue = this.pickListOptions[0].label;
        this.headerValue = this.pickListOptions[0].headerValue;
        this.showProgramList = true;
        if (this.pickListOptions.length === 1) {
            let itemValue;
            let label = this.pickListOptions[0].label;
            let peId = this.pickListOptions[0].value;
            for (let i = 0; i < this.allModes.ppModeItems.length; i++) {
                for (let j = 0; j < this.allModes.ppModeItems[i].subItems.length; j++) {
                    if (this.allModes.ppModeItems[i].subItems[j].subTitle === label && this.allModes.ppModeItems[i].subItems[j].peId === peId) {
                        this.headerValue = this.allModes.ppModeItems[i].subItems[j].isProgram ? 'Program' : 'Study';
                        itemValue = this.allModes.ppModeItems[i].subItems[j];
                    } else if (this.allModes.ppModeItems[i].subItems[j].subTitle === label) {
                        this.headerValue = this.allModes.ppModeItems[i].subItems[j].isProgram ? 'Program' : 'Study';
                        itemValue = this.allModes.ppModeItems[i].subItems[j];
                    }
                }
            }
            const selectedEvent = new CustomEvent('itemselection', {
                detail: { itemValue }
            });
            this.dispatchEvent(selectedEvent);

        }

    }

    get optionList() {
        return this.pickListOptions;
    }
    get showList() {
        return this.showProgramList;
    }
    handlePicklistSelection(event) {
        let currentValue = event.detail.value;
        let currentLabel = this.pickListOptions.filter(function (option) {
            return option.value == currentValue;
        });
        let itemValue;
        if (currentLabel)
            var label = currentLabel[0].label;

        for (let i = 0; i < this.allModes.ppModeItems.length; i++) {
            for (let j = 0; j < this.allModes.ppModeItems[i].subItems.length; j++) {
                if (this.allModes.ppModeItems[i].subItems[j].subTitle === label && this.allModes.ppModeItems[i].subItems[j].peId === currentValue) {
                    this.headerValue = this.allModes.ppModeItems[i].subItems[j].isProgram ? 'Program' : 'Study';
                    itemValue = this.allModes.ppModeItems[i].subItems[j];
                } else if (this.allModes.ppModeItems[i].subItems[j].subTitle === label) {
                    this.headerValue = this.allModes.ppModeItems[i].subItems[j].isProgram ? 'Program' : 'Study';
                    itemValue = this.allModes.ppModeItems[i].subItems[j];
                }
            }
        }
        console.log('===LWC EVENT');
        console.log('===LWC EVENT' + JSON.stringify(itemValue));

        const selectedEvent = new CustomEvent('itemselection', {
            detail: { itemValue }
        });
        this.dispatchEvent(selectedEvent);
    }
}