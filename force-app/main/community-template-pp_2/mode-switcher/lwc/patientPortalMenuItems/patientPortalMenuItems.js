import { LightningElement, api } from 'lwc';
import partipantsDelegate from '@salesforce/label/c.Paticipant_s_Delegate';
import noActiveStudies from '@salesforce/label/c.No_active_studies';
import noActivePrograms from '@salesforce/label/c.No_Active_Programs';
import viewingAs from '@salesforce/label/c.Viewing_as';
import PP_DesktopLogos from '@salesforce/resourceUrl/PP_DesktopLogos';
import jsPDF_Fonts from '@salesforce/resourceUrl/jsPDF_Fonts';
import ISO_Download_Template from '@salesforce/label/c.ISO_Download_Template';

export default class PatientPortalMenuItems extends LightningElement {
    participantSettingImage = PP_DesktopLogos + '/Participant_Settings.svg';
    @api allModes;
    @api user;
    @api pickListOptions = [];
    @api defaultPickListValue;
    comboBoxHeading;
    isSingleCommMode;
    @api modList = [];
    selectedSubItem;
    currentSelection;
    selectedMode;
    showCurrentMode;
    setCurrentSelection;
    placeHolder;
    activeStudies = noActiveStudies;
    delegate = partipantsDelegate;
    activeProg = noActivePrograms;
    viewAs = viewingAs;
    show;
    showAll = false;

    connectedCallback() {
        if (this.allModes.ppModeItems.length == 1) {
            this.isSingleCommMode = true;
            let currentSubItems;
            currentSubItems = this.allModes.ppModeItems[0].subItems;
            this.pickListOptions = this.preparePickList(currentSubItems);
        } else {
            let mode;
            this.isSingleCommMode = false;
            let commModes = this.allModes.ppModeItems;
            for (let i = 0; i < commModes.length; i++) {
                mode = this.prepareRecords(commModes[i].subItems);
                this.modList.push(mode);
            }
        }
    }

    prepareRecords(currentSubItems) {
        let programList = [];
        let mode;
        let title;
        let isDelegate;
        let contactName = this.user.Contact.FirstName + ' ' + this.user.Contact.LastName;
        title = currentSubItems[0].title == contactName ? 'Self' : currentSubItems[0].title;
        isDelegate = currentSubItems[0].isDelegate;
        programList = this.preparePickList(currentSubItems);
        if (this.setCurrentSelection) {
            this.selectedMode = {
                title: this.currentSelection.title == contactName ? 'Self' : currentSubItems[0].title,
                isDelegate: this.currentSelection.isDelegate,
                programList: programList
            }
            this.pickListOptions = programList;
            this.setCurrentSelection = false;
        }
        mode = {
            title: title,
            isDelegate: isDelegate,
            programList: programList
        };
        return mode;

    }
    preparePickList(currentSubItems) {
        let programList = [];
        var pickList;
        for (let i = 0; i < currentSubItems.length; i++) {
            let comboBoxHeader;
            let peId;
            comboBoxHeader = currentSubItems[i].isProgram ? 'Program' : 'Study';
            let studyName = currentSubItems[i].subTitle;
            if (studyName == this.activeStudies || studyName == this.activeProg)
                peId = studyName;
            else
                peId = currentSubItems[i].peId;
            pickList = {
                label: studyName,
                value: peId,
                headerValue: comboBoxHeader,
                subItemValue: currentSubItems[i]
            };
            programList.push(pickList);
            if (currentSubItems[i].isSelected == true) {
                this.currentSelection = currentSubItems[i];
                this.defaultPickListValue = currentSubItems[i].peId;
                this.placeHolder = currentSubItems[i].subTitle;
                this.comboBoxHeading = comboBoxHeader;
                this.setCurrentSelection = true;
            }
        }
        return programList;

    }

    get ifSingleMode() {
        return this.isSingleCommMode;
    }

    get optionsList() {
        return this.pickListOptions;
    }

    get viewingAsLabel() {
        return this.viewAs;
    }
    get delegateLabel() {
        return this.delegate;
    }

    handlePicklistSelection(event) {
        let currentValue = event.detail.value;
        let currentSubItem;
        if (currentValue) {
            currentSubItem = this.pickListOptions.filter(function (option) {
                return option.value == currentValue;
            });
        }
        this.selectedSubItem = currentSubItem[0].subItemValue;
        const selectedEvent = new CustomEvent('itemselection', {
            detail: {
                itemValue: this.selectedSubItem,
                navigateTo: ''
            }
        });
        this.dispatchEvent(selectedEvent);

    }

    handleChangeMode(event) {
        this.showAll = false;
        const item = event.detail;
        let contactName = this.user.Contact.FirstName + ' ' + this.user.Contact.LastName;
        if (item[0].programList.length == 1) {
            this.comboBoxHeading = item[0].programList[0].headerValue;
            this.defaultPickListValue = item[0].programList[0].value;
            this.selectedMode = {
                title: item[0].title == contactName ? 'Self' : item[0].title,
                isDelegate: item[0].isDelegate,
                programList: item[0].programList
            }
            this.pickListOptions = item[0].programList;
            this.comboBoxHeading = item[0].programList[0].headerValue;

            const selectedEvent = new CustomEvent('itemselection', {
                detail: {
                    itemValue: item[0].programList[0].subItemValue,
                    navigateTo: ''
                }
            });
            this.dispatchEvent(selectedEvent);
        } else {
            this.selectedMode = {
                title: item[0].title == contactName ? 'Self' : item[0].title,
                isDelegate: item[0].isDelegate,
                programList: item[0].programList
            }
            this.pickListOptions = item[0].programList;
            this.comboBoxHeading = item[0].programList[0].headerValue;
            this.placeHolder = item[0].programList[0].label;
            this.defaultPickListValue = '';
        }
    }
    handleNavigation(event) {
        let item = this.selectedMode.programList[0].subItemValue;
        const selectedEvent = new CustomEvent('itemselection', {
            detail: {
                itemValue: item,
                navigateTo: 'account-settings'
            }
        });
        this.dispatchEvent(selectedEvent);

    }
    handleClick() {
        if (this.showAll) {
            this.showAll = false;
        }

        else
            this.showAll = true;
    }
    get svgClass() {
        return '';
    }
    get iconName() {
        return 'participant_settings';

    }
}
