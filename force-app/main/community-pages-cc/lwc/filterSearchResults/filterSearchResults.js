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
            console.log('renderedCallback');
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

    handleCountryChange(evt, targetName, targetValue) {
        let nodeName =
            targetName == 'undefined' || targetName == null
                ? evt.target.getAttribute('name')
                : targetName;
        let value =
            targetValue == 'undefined' || targetValue == null ? evt.target.value : targetValue;
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
        this.value =
            targetValue == 'undefined' || targetValue == null ? evt.target.value : targetValue;
        this.dispatchEvent(
            new CustomEvent('countryfilterchange', {
                detail: { filteredData }
            })
        );
    }

    handleStudyChange(evt, targetName, targetValue) {
        let nodeName =
            targetName == 'undefined' || targetName == null
                ? evt.target.getAttribute('name')
                : targetName;
        let value =
            targetValue == 'undefined' || targetValue == null ? evt.target.value : targetValue;
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
        this.value =
            targetValue == 'undefined' || targetValue == null ? evt.target.value : targetValue;
        this.dispatchEvent(
            new CustomEvent('studyfilterchange', {
                detail: { filteredData }
            })
        );
    }

    resetFilterTxt(evt) {
        let nodeName = evt.target.name;
        let country = this.template.querySelector('input[data-study-id=country]').value;
        let studyName = this.template.querySelector('input[data-study-id=studyName]').value;
        console.log(nodeName);
        if (nodeName === 'forCountry' && country) {
            this.template.querySelector('input[data-study-id=country]').value = '';
            this.handleCountryChange(evt, 'country', '');
        }
        if (nodeName === 'forStudyName' && studyName) {
            this.template.querySelector('input[data-study-id=studyName]').value = '';
            this.handleStudyChange(evt, 'studyName', '');
        }
    }
}
