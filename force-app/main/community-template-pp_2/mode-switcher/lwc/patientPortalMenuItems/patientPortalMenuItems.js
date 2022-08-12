import { LightningElement, api } from 'lwc';
import partipantsDelegate from '@salesforce/label/c.Paticipant_s_Delegate';
import noActiveStudies from '@salesforce/label/c.No_active_studies';
import noActivePrograms from '@salesforce/label/c.No_Active_Programs';
import viewingAs from '@salesforce/label/c.Viewing_as';
import PP_DesktopLogos from '@salesforce/resourceUrl/PP_DesktopLogos';
import self from '@salesforce/label/c.PP_Self';
import study from '@salesforce/label/c.CC_Study';
import program from '@salesforce/label/c.PP_Program';

export default class PatientPortalMenuItems extends LightningElement {
    participantSettingImage = PP_DesktopLogos + '/Participant_Settings.svg';
    @api allModes;
    @api user;
    @api pickListOptions = [];
    @api defaultPickListValue;
    comboBoxHeader;
    isSingleCommMode;
    @api commModeList = [];
    selectedItemValue;
    currentSelection;
    currentMode;
    setCurrentMode;
    placeHolder;
    showAllModes = false;
    label = {
        viewingAs,
        noActiveStudies,
        partipantsDelegate,
        noActivePrograms
    };
    contactName;

    connectedCallback() {
        console.log('????????????? data' + JSON.stringify(this.allModes));
        this.contactName = this.user.Contact.FirstName + ' ' + this.user.Contact.LastName;
        if (this.allModes.ppModeItems.length == 1) {
            this.isSingleCommMode = true;
            let allSubModes = this.allModes.ppModeItems[0].subItems;
            this.pickListOptions = this.preparePickListOptions(allSubModes);
        } else {
            let mode;
            this.isSingleCommMode = false;
            let commModes = this.allModes.ppModeItems;
            for (let i = 0; i < commModes.length; i++) {
                mode = this.prepareRecords(commModes[i].subItems);
                if (mode.isSelected) {
                    this.commModeList.unshift(mode);
                } else {
                    this.commModeList.push(mode);
                }
            }
        }
    }

    prepareRecords(allSubModes) {
        let pickListValues = [];
        let mode;
        let title;
        let isDelegate;
        let isSelected;
        title = allSubModes[0].title == this.contactName ? self : allSubModes[0].title;
        isDelegate = allSubModes[0].isDelegate;
        pickListValues = this.preparePickListOptions(allSubModes);
        if (this.setCurrentMode) {
            this.currentMode = {
                title:
                    this.currentSelection.title == this.contactName ? self : allSubModes[0].title,
                isDelegate: this.currentSelection.isDelegate,
                programList: pickListValues
            };
            this.pickListOptions = pickListValues;
            this.setCurrentMode = false;
            isSelected = true;
        }
        mode = {
            title: title,
            isDelegate: isDelegate,
            programList: pickListValues,
            isSelected: isSelected
        };
        return mode;
    }
    preparePickListOptions(allSubModes) {
        let pickListOptions = [];
        let pickList;
        for (let i = 0; i < allSubModes.length; i++) {
            let comboBoxHeader;
            let peId;
            comboBoxHeader = allSubModes[i].isProgram ? program : study;
            let studyName = allSubModes[i].subTitle;
            if (studyName == this.label.noActiveStudies || studyName == this.label.noActivePrograms)
                peId = studyName;
            else peId = allSubModes[i].peId;
            pickList = {
                label: studyName,
                value: peId,
                comboBoxLabel: comboBoxHeader,
                subItemValue: allSubModes[i],
                isSelected: allSubModes[i].isSelected
            };
            pickListOptions.push(pickList);
            if (allSubModes[i].isSelected == true) {
                this.currentSelection = allSubModes[i];
                this.defaultPickListValue = allSubModes[i].peId;
                this.placeHolder = allSubModes[i].subTitle;
                this.comboBoxHeader = comboBoxHeader;
                this.setCurrentMode = true;
            }
        }
        return pickListOptions;
    }

    get hasSingleCommMode() {
        return this.isSingleCommMode;
    }

    get optionsList() {
        return this.pickListOptions;
    }

    get disablePicklist() {
        let disablePicklistValue = this.pickListOptions.length == 1 ? true : false;
        return disablePicklistValue;
    }

    handlePicklistSelection(event) {
        let currentValue = event.detail.value;
        let currentSubItem;
        if (currentValue) {
            currentSubItem = this.pickListOptions.filter(function (item) {
                return item.value == currentValue;
            });
        }
        this.selectedItemValue = currentSubItem[0].subItemValue;
        const modeSelection = new CustomEvent('itemselection', {
            detail: {
                itemValue: this.selectedItemValue,
                navigateTo: ''
            }
        });
        this.dispatchEvent(modeSelection);
    }

    handleChangeMode(event) {
        this.showAllModes = false;
        const item = event.detail;
        if (item[0].programList.length == 1) {
            this.comboBoxHeader = item[0].programList[0].comboBoxLabel;
            this.defaultPickListValue = item[0].programList[0].value;
            this.currentMode = {
                title: item[0].title == this.contactName ? self : item[0].title,
                isDelegate: item[0].isDelegate,
                programList: item[0].programList
            };
            this.pickListOptions = item[0].programList;
            this.comboBoxHeader = item[0].programList[0].comboBoxLabel;

            const modeselection = new CustomEvent('itemselection', {
                detail: {
                    itemValue: item[0].programList[0].subItemValue,
                    navigateTo: ''
                }
            });
            this.dispatchEvent(modeselection);
        } else {
            this.currentMode = {
                title: item[0].title == this.contactName ? self : item[0].title,
                isDelegate: item[0].isDelegate,
                programList: item[0].programList
            };
            this.pickListOptions = item[0].programList;
            this.comboBoxHeader = item[0].programList[0].comboBoxLabel;
            this.placeHolder = item[0].programList[0].label;
            this.defaultPickListValue = '';
        }
    }
    handleNavigation(event) {
        let item = this.currentMode.programList[0].subItemValue;
        const selectedEvent = new CustomEvent('itemselection', {
            detail: {
                itemValue: item,
                navigateTo: 'account-settings'
            }
        });
        this.dispatchEvent(selectedEvent);
    }
    handleClick() {
        if (this.showAllModes == true) {
            this.showAllModes = false;
        } else if (this.showAllModes == false) {
            this.showAllModes = true;
        }
    }
    get svgClass() {
        return '';
    }
    get iconName() {
        return 'participant_settings';
    }
}
