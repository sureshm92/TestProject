import { LightningElement, api } from 'lwc';

export default class WebSelect extends LightningElement {
    isEmptylabel = true;
    @api containerClass = '';
    @api label = '';
    @api isRequired = false;
    @api errorMessage = '';
    @api value = '';
    @api options = {};

    get applyContainerClass() {
        return 'rrs-container' + ' ' + this.containerClass;
    }
    get isEmptylabel() {
        return this.label.length === 0;
    }
    get labelClass() {
        return this.errorMessage.length === 0 ? 'rrs-error' : '';
    }
    get comboxClass() {
        return this.errorMessage.length === 0 ? ' rr-select-error' : '';
    }
    get errorMessageClass() {
        return 'rr-error-message' + this.errorMessage.length === 0 ? ' slds-hide' : '';
    }
    handleChange(event) {
        console.log(event.target.value);
        const custEvent = new CustomEvent('passtotelevisitparent', {
            detail: event.target.value
        });
        this.dispatchEvent(custEvent);
    }
}
