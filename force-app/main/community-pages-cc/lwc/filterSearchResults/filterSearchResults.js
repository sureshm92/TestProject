import { LightningElement, api } from 'lwc';
import countryPlaceholderTxt from '@salesforce/label/c.CC_FilterPlaceholder_Country';
import studyPlaceholderTxt from '@salesforce/label/c.CC_FilterPlaceholder_StudyName';
import filterPanelLabel from '@salesforce/label/c.CC_FilterPanel_Label';
//import formFactor from '@salesforce/client/formFactor';
//import { registerListener, unregisterAllListeners } from 'c/pubSub';
//import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class FilterSearchResults extends LightningElement {
    label = {
        studyPlaceholderTxt,
        countryPlaceholderTxt,
        filterPanelLabel
    };
    initialized = false;
    @api filterCountryList;
    @api filterStudyList;
    renderedCallback() {
        if (this.initialized) {
            return;
        }
        this.initialized = true;
        let studyName = this.template.querySelector('datalist[data-study-id=studyName]').id;
        this.template
            .querySelector('input[data-study-id=studyName]')
            .setAttribute('list', studyName);

        let country = this.template.querySelector('datalist[data-study-id=country]').id;
        this.template.querySelector('input[data-study-id=country]').setAttribute('list', country);
    }

    handleChange(evt) {
        const filteredData = {
            key: evt.target.key,
            value: evt.target.value
        };
        this.dispatchEvent(
            new CustomEvent('filterchange', {
                detail: { filteredData }
            })
        );
    }
}
