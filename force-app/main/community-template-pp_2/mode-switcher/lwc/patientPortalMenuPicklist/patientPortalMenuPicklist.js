import { LightningElement,api } from 'lwc';

export default class PatientPortalMenuPicklist extends LightningElement {
    
    @api pickListOptions = [];
    @api defaultPickListValue;
    @api comboBoxHeader;   
    @api placeHolder;
    @api disablePicklist;
    selectedItemValue;


    handlePicklistSelection(event) {
        let currentValue = event.detail.value;
        let currentSubItem;
        if (currentValue) {
            currentSubItem = this.pickListOptions.filter(function (item) {
                return item.value == currentValue;
            });
        }
        this.selectedItemValue = currentSubItem[0].subItemValue;
        this.comboBoxHeader = currentSubItem[0].comboBoxLabel;
        const modeSelection = new CustomEvent('itemselection', {
            detail: {
                itemValue: this.selectedItemValue,
                navigateTo: ''
            },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(modeSelection);
    }
    get optionsList() {
        return this.pickListOptions;
    }

    get header() {
        return this.comboBoxHeader;
    }


}