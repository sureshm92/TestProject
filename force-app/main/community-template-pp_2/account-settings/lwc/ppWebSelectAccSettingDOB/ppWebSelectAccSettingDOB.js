import { LightningElement, api } from 'lwc';

export default class PpWebSelect extends LightningElement {
    @api isRTL = false;
    @api labelHidden = false;
    @api label = '';
    @api placeHolder = 'Select';
    @api selectedValue = '';
    selectedLabel = '';
    @api options = [];
    availableOptionslst = [];
    @api customClass = '';
    @api hasError = false;
    @api isDisabled = false;
    @api isDisabledOptions = false;
    showPlaceHolder = false;
    placeHolderCounter = 0; 


    get isDisplayDropDownBox(){
        this.placeHolderCounter = 0;
        if(this.options != undefined && this.options != null && this.options != '') {
            return true;
        } 
        else {
            return false;
        }
    }
    get displayplaceHolderOneTime(){
         if(this.selectedValue){
            return false; 
         }
         else {
            this.placeHolderCounter = this.placeHolderCounter + 1;
            return this.placeHolderCounter == 1 ? true : false;
         }
    }
    get disableIsSelect(){
        if(this.options != undefined && this.options != null && this.options != '' && !this.isDisabled) {
            return false;
        } 
        else {
            return true;
        }
    }
    get comboboxClass() {
        return this.isRTL
            ? this.isDisabled
                ? 'header-combobox slds-text-align_right disabled-combobox'
                : 'header-combobox slds-text-align_right'
            : this.isDisabled
            ? 'header-combobox disabled-combobox'
            : 'header-combobox';
    }

    get dropdownClass() {
        let dropdownContainerClass = this.customClass
            ? this.isRTL
                ? 'dropdown-rtl ' + this.customClass
                : 'dropdown ' + this.customClass
            : this.isRTL
            ? 'dropdown-rtl'
            : 'dropdown';
        return this.isDisabled
            ? dropdownContainerClass + ' disabled-dropdown'
            : dropdownContainerClass;
    }

    get hideDropdownForRTL(){
       return  this.isRTL ? 'rtl' : '';
    }

    get handleForDelegate(){
        return this.isDisabled ? 'background-color: #F2F2F2; color: #757575;' : '';
    }
    handleOptionSelect(event) {
        if (this.selectedValue != event.target.value) {
            this.selectedLabel = event.target.value;
            this.selectedValue = event.target.value;
            //fire event to handle change
           const custEvent = new CustomEvent('changevalue', {
                detail: event.target.value
            });
            this.dispatchEvent(custEvent);
        }
    }
}