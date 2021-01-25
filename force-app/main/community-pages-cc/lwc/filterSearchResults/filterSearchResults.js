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
        console.log('renderedCallback');
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

    handleCountryChange(evt) {
        let nodeName = evt.target.getAttribute('name');
        let value = evt.target.value;
        let keyArray = [];

        if (nodeName === 'country' && value) {
            let index = this.filterCountryList.findIndex((country) => country.value === value);
            keyArray = this.filterCountryList[index].key;
        }
        const filteredData = {
            key: keyArray,
            value: value,
            name: nodeName
        };
        this.value = evt.target.value;
        this.dispatchEvent(
            new CustomEvent('countryfilterchange', {
                detail: { filteredData }
            })
        );
    }

    handleStudyChange(evt) {
        let nodeName = evt.target.getAttribute('name');
        let value = evt.target.value;
        let keyArray = [];

        if (nodeName === 'studyName' && value) {
            let index = this.filterStudyList.findIndex((study) => study.value === value);
            keyArray = this.filterStudyList[index].key;
        }
        const filteredData = {
            key: keyArray,
            value: value,
            name: nodeName
        };
        this.value = evt.target.value;
        this.dispatchEvent(
            new CustomEvent('studyfilterchange', {
                detail: { filteredData }
            })
        );
    }
}
