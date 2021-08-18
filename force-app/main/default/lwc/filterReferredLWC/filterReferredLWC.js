import { LightningElement,api,track } from 'lwc';
// importing Custom Label
import RPR_Date_Range from '@salesforce/label/c.RPR_Date_Range';
import RPR_Review_Results from '@salesforce/label/c.RPR_Review_Results';
import RPR_Patient_Status from '@salesforce/label/c.RPR_Patient_Status';
import RPR_Apply from '@salesforce/label/c.RPR_Apply';
import RPR_Studies from '@salesforce/label/c.RPR_Studies';
import RPR_Select_Range from '@salesforce/label/c.RPR_Select_Range';
import RPR_Select_Results from '@salesforce/label/c.RPR_Select_Results';
import RPR_Included_for_Referred from '@salesforce/label/c.RPR_Included_for_Referred';



export default class FilterReferredLWC extends LightningElement {
    @api filterData;  
    label = {
        RPR_Date_Range,
        RPR_Review_Results,
        RPR_Patient_Status,
        RPR_Apply,
        RPR_Studies,
        RPR_Select_Range,
        RPR_Select_Results,
        RPR_Included_for_Referred
    };

    studiesValueChange(event) {
        this.studiesValue = event.detail.value;
    }

    dateRangeValueChange(event) {
        this.dateRangeValue = event.detail.value;
    }

    reviewResultsValueChange(event) {
        this.reviewResultsValue = event.detail.value;
    }

    excludedFromReferringeValueChange(event) {
        this.excludedFromReferringValue = event.detail.value;
    }
    //To get the picklist values in container component
    fetchSelectedValues() {
        let selections = this.template.querySelector('c-mutli-select-picklist-l-w-c');
        alert(JSON.stringify(selections.values));
    }

    applyFilterClick(event) {
        //this.fetchSelectedValues();
        let selections = this.template.querySelector('c-mutli-select-picklist-l-w-c');
        var studiesselectedvalue = selections.values;
        let studiesList = [];
        let allSelected = false;

        for(let key in studiesselectedvalue) {
            if(studiesselectedvalue[key].selected == true && studiesselectedvalue[key].value != null){
                studiesList.push(studiesselectedvalue[key].value);
            }
            else if(studiesselectedvalue[key].selected == true && studiesselectedvalue[key].value == null) {
                allSelected = true;
                break;
            }
        }
        if(allSelected)
        {
            studiesList =[];
            for(let key in studiesselectedvalue) {
                if(studiesselectedvalue[key].value != null){
                    studiesList.push(studiesselectedvalue[key].value);
                }
            }
        }
        //alert(JSON.stringify(studiesList));
        // Creates the event
       const selectedfiltervalue = {datevalue:this.dateRangeValue, 
                                        reviewResultsValue:this.reviewResultsValue, 
                                        excludedFromReferringValue:this.excludedFromReferringValue,studies:studiesList
                                    };

        const selectedEvent = new CustomEvent('valueclick', {
            detail : selectedfiltervalue
        });
        //dispatching the custom event
        this.dispatchEvent(selectedEvent);
    }
}