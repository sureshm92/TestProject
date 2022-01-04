import { LightningElement, track, api } from 'lwc';
import BulkImport_Select_Study from '@salesforce/label/c.BulkImport_Select_Study';

export default class App extends LightningElement {
    label = {
                BulkImport_Select_Study
             }
    @api
    values = [];

    @api
    selectedvalues = [];

    @api
    picklistlabel;

    @api
    isreadonly = false;
    showdropdown;
    totalValues = 0;
    handleleave() {
        let sddcheck = this.showdropdown;

        if (sddcheck) {
            this.showdropdown = false;
            this.fetchSelectedValues();
        }
    }

    connectedCallback() {
        /*this.values.forEach((element) =>
            element.selected ? this.selectedvalues.push(element.value) : ''
        );*/
    }

    fetchSelectedValues() {
        this.selectedvalues = [];
        this.totalValues = 0;
        //get all the selected values
        this.template.querySelectorAll('c-picklist-value-l-w-c').forEach((element) => {
            if (element.selected && element.value) {
                console.log(element.value);
                this.selectedvalues.push(element.value);
            }
            if (element.value) {
                this.totalValues = this.totalValues + 1;
            }
        });

        //refresh original list
        this.refreshOrginalList();
    }
    @api
    refreshOrginalList() {
        //update the original value array to shown after close

        const picklistvalues = this.values.map((eachvalue) => ({ ...eachvalue }));

        picklistvalues.forEach((element, index) => {
            if (
                this.selectedvalues.includes(element.value) ||
                (this.selectedvalues.length == this.totalValues && !element.hasOwnProperty('value'))
            ) {
                picklistvalues[index].selected = true;
            } else {
                picklistvalues[index].selected = false;
            }
        });

        this.values = picklistvalues;
    }

    handleShowdropdown() {
        let sdd = this.showdropdown;
        if (sdd) {
            this.showdropdown = false;
            this.fetchSelectedValues();
        } else {
            this.showdropdown = true;
        }
    }

    closePill(event) {
        console.log(event.target.dataset.value);
        let selection = event.target.dataset.value;
        let selectedpills = this.selectedvalues;
        console.log(selectedpills);
        let pillIndex = selectedpills.indexOf(selection);
        console.log(pillIndex);
        this.selectedvalues.splice(pillIndex, 1);
        this.refreshOrginalList();
    }

    get selectedmessage() {
        if (this.selectedvalues.length > 0) {
            return this.selectedvalues.length + ' values are selected';
        } else {
            return this.label.BulkImport_Select_Study;
            
        }
    }
    handleSelectedPicklist(event) {
        this.fetchSelectedValues();
        let selectedValueMap = event.detail;
        let totalSelectedValues = 0;
        let eventValues = [...this.values];
        if (event.detail.value === '') {
            eventValues.forEach((element) => {
                if (event.detail.checked) {
                    element.selected = true;
                    if (element.value) {
                        this.selectedvalues.push(element.value);
                    }
                } else {
                    element.selected = false;
                    if (element.value) {
                        let index = eventValues.indexOf(element.value);
                        this.selectedvalues.splice(index, 1);
                    }
                }
            });
        } else {
            let allPicklistElement;
            eventValues.forEach((element) => {
                if (element.value) {
                    if (element.selected) {
                        totalSelectedValues = totalSelectedValues + 1;
                        if (!this.selectedvalues.includes(element.value)) {
                            this.selectedvalues.push(element.value);
                        }
                    } else {
                        if (this.selectedvalues.includes(element.value)) {
                            let index = this.selectedvalues.indexOf(element.value);
                            this.selectedvalues.slice(index, 1);
                        }
                    }
                }
                if (!element.hasOwnProperty('value')) {
                    allPicklistElement = element;
                }
            });
            if (this.totalValues == totalSelectedValues) {
                allPicklistElement.selected = true;
            } else {
                allPicklistElement.selected = false;
            }
        }
        console.log(this.selectedvalues.length);
        this.values = eventValues;
    }
}