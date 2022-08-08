import { LightningElement, api } from 'lwc';

export default class PpWebSelect extends LightningElement {
    @api isRTL = false;
    @api labelHidden = false;
    @api label = '';
    @api placeHolder = 'Select';
    @api selectedValue = '';
    selectedLabel = '';
    @api options = [];
    @api customClass = '';
    @api hasError = false;
    @api isDisabled = false;

    get comboboxClass() {
        return this.isRTL
            ? this.isDisabled
                ? 'header-combobox slds-text-align_right disabled-combobox'
                : 'header-combobox slds-text-align_right'
            : this.isDisabled
            ? 'header-combobox disabled-combobox'
            : 'header-combobox';
    }

    get labelClass() {
        return this.isRTL
            ? 'slds-p-bottom_medium sub-header slds-p-top_small rtl'
            : 'slds-p-bottom_medium sub-header slds-p-top_small';
    }

    get dropdownClass() {
        let dropdownContainerClass = this.customClass
            ? this.isRTL
                ? 'dropdown-rtl rtl ' + this.customClass
                : 'dropdown ' + this.customClass
            : this.isRTL
            ? 'dropdown-rtl rtl'
            : 'dropdown';
        return this.isDisabled
            ? dropdownContainerClass + ' disabled-dropdown'
            : dropdownContainerClass;
    }

    get currentHeaderLabel() {
        if (this.selectedValue) {
            let optionArray = JSON.parse(JSON.stringify(this.options));
            let currentOption = optionArray.filter((option) => {
                return option.value === this.selectedValue;
            });
            return currentOption.length ? currentOption[0].label : this.placeHolder;
        } else {
            return this.placeHolder;
        }
    }

    toggleElement() {
        let ddMenu = this.template.querySelector('[data-id="dropdown-menu"]');
        ddMenu.classList.toggle('active');
    }

    handleOptionSelect(event) {
        if (this.selectedValue != event.currentTarget.dataset.value) {
            this.selectedLabel = event.currentTarget.dataset.label;
            this.selectedValue = event.currentTarget.dataset.value;
            //fire event to handle change
            const custEvent = new CustomEvent('changevalue', {
                detail: this.selectedValue
            });
            this.dispatchEvent(custEvent);
        }
    }

    removeElementFocus() {
        let ddMenu = this.template.querySelector('[data-id="dropdown-menu"]');
        ddMenu.classList.remove('active');
    }
}
