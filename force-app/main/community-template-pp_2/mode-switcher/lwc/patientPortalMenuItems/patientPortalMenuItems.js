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


    /* prepareList(currentSubItems) {
 
         let newItem;
         let isDisplay = true;
         let isDelegate = currentSubItems[0].isDelegate;
         let peId = currentSubItems[0].peId;
         let title = currentSubItems[0].title;
         let subTitle = currentSubItems[0].subTitle;
         let programList = [];
         let header;
         let userName = this.user.Contact.FirstName + ' ' + this.user.Contact.LastName;
 
         header = title == userName ? 'Self' : title;
 
         for (let i = 0; i < currentSubItems.length; i++) {
             let isProgram = currentSubItems[i].isProgram ? 'Program' : 'Study';
             programList.push({ label: subTitle, value: peId, headerValue: header, title: currentSubItems[i].title });
             // if (currentSubItems[i].isSelected == true)
         }
 
 
         newItem = {
             isDisplay: isDisplay,
             isDelegate: isDelegate,
             programList: programList,
             title: header
         }
         return newItem;
 
     }
     handleClick() {
         let newItem = this.newList;
         for (let i = 0; i < newItem.length; i++) {
             newItem[i].isDisplay = true;
         }
         this.newList = newItem;
         this.isDisplayList = true;
     }
     handleNavigation(event) {
         console.log('*********Navigation');
     }
 
     handleDisplay(event) {
         let currentTitle = event.currentTarget.dataset.id;
         let newItem = this.newList;
         for (let i = 0; i < newItem.length; i++) {
             if (newItem[i].title != currentTitle) {
                 newItem[i].isDisplay = false;
             } else {
                 newItem[i].isDisplay = true;
             }
         }
         this.newList = newItem;
     }
    
     getItemValue(peId) {
         let itemValue;
         for (let i = 0; i < this.allModes.ppModeItems.length; i++) {
             for (let j = 0; j < this.allModes.ppModeItems[i].subItems.length; j++) {
                 if (this.allModes.ppModeItems[i].subItems[j].peId == peId) {
                     itemValue = this.allModes.ppModeItems[i].subItems[j];
                     break;
                 }
             }
         }
         return itemValue;
 
     }
      
           containsTitle(newList, peId) {
                var i;
                for (i = 0; i < newList.length; i++) {
                    if (newList[i].peId == peId) {
                        return true;
                    }
                }
                return false;
            }
           
        
            handleValueChange(event) {
                this.pickListOptions = [];
                let pickListOptions = event.detail.pickListValues;
                this.navigateTo = event.detail.navigateTo;
                this.itemValue = event.detail.itemValue;
                console.log('?????LWC' + JSON.stringify(this.itemValue));
                console.log('?????LWC' + JSON.stringify(this.navigateTo));
                if (!this.navigateTo) {
                    this.pickListOptions = pickListOptions;
                    this.defaultPicklistValue = this.pickListOptions[0].label;
                    this.headerValue = this.pickListOptions[0].headerValue;
                    this.showProgramList = true;
                    if (this.pickListOptions.length == 1) {
                        let itemValue;
                        let label = this.pickListOptions[0].label;
                        let peId = this.pickListOptions[0].value;
                        for (let i = 0; i < this.allModes.ppModeItems.length; i++) {
                            for (let j = 0; j < this.allModes.ppModeItems[i].subItems.length; j++) {
                                if (this.allModes.ppModeItems[i].subItems[j].subTitle === label && this.allModes.ppModeItems[i].subItems[j].peId === peId) {
                                    this.headerValue = this.allModes.ppModeItems[i].subItems[j].isProgram ? 'Program' : 'Study';
                                    this.itemValue = this.allModes.ppModeItems[i].subItems[j];
                                } else if (this.allModes.ppModeItems[i].subItems[j].subTitle === label &&
                                    (!this.allModes.ppModeItems[i].subItems[j].peId)) {
                                    this.headerValue = this.allModes.ppModeItems[i].subItems[j].isProgram ? 'Program' : 'Study';
                                    this.itemValue = this.allModes.ppModeItems[i].subItems[j];
                                }
                            }
                        }
                        const selectedEvent = new CustomEvent('itemselection', {
                            detail: {
                                itemValue: this.itemValue,
                                navigateTo: this.navigateTo
                            }
                        });
                        this.dispatchEvent(selectedEvent);
        
                    }
                } else {
                    const selectedEvent = new CustomEvent('itemselection', {
                        detail: {
                            itemValue: this.itemValue,
                            navigateTo: this.navigateTo
                        }
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
                        } else if (this.allModes.ppModeItems[i].subItems[j].subTitle === label
                            && (!this.allModes.ppModeItems[i].subItems[j].peId)) {
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
            */
}