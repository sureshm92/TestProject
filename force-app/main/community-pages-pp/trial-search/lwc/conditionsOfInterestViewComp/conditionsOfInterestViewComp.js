/**
 * Created by Yulia Yakushenkova on 12/10/2019.
 */
import {api, LightningElement, track} from 'lwc';

import Conditions_of_interest from '@salesforce/label/c.TrialSearch_Conditions_of_interest';
import Search_for_another_condition from '@salesforce/label/c.TrialSearch_Search_for_another_condition';
import Enrollment_Status from '@salesforce/label/c.TrialSearch_Enrollment_Status';
import Enrolling from '@salesforce/label/c.TrialSearch_Enrolling';
import Not_Yet_Enrolling from '@salesforce/label/c.TrialSearch_Not_Yet_Enrolling';
import Update_Search_Results from '@salesforce/label/c.TrialSearch_Update_Search_Results';

import searchForCOI from '@salesforce/apex/ConditionsOfInterestViewRemote.searchForConditionOfInterest';

export default class ConditionsOfInterestViewComp extends LightningElement {

    @api searchResults;
    @api filterText;
    @api participantId;
    @api initialized = false;
    @api showDropdown = false;
    @api taps;

    @track selection;
    @track enrolling = true;
    @track notYetEnrolling = true;

    currentTaps;

    customLabel = {
        Conditions_of_interest,
        Search_for_another_condition,
        Enrollment_Status,
        Enrolling,
        Not_Yet_Enrolling,
        Update_Search_Results
    };

    connectedCallback() {
        this.currentTaps = this.taps !== null ? this.taps : [];
    }

    doSearch(event) {
        let selectedCOIsIds = [];
        if (this.taps.length !== 0) {
            this.taps.forEach(function (tap) {
                console.log('Tap put in selected COI ' + tap.Therapeutic_Area__r.Id);
                selectedCOIsIds.push(tap.Therapeutic_Area__r.Id);
            });
        }
        searchForCOI({
            searchText: event.target.value,
            selectedCoisIds: selectedCOIsIds
        })
            .then(result => {
                this.searchResults = result;
                console.log('Result ' + JSON.stringify(this.searchResults));
                this.showDropdown = result.length !== 0;

            })
            .catch(error => {
                console.log('Error in searchForCOI. ' + JSON.stringify(error));
            });
    }

    onFocus(event) {
        this.doSearch(event);
    }

    onBlur(event) {
        setTimeout(() => {
            this.showDropdown = false;
        }, 150);
    }

    handleSelect(event) {
        let evId, tap;
        try {
            evId = event.currentTarget.dataset.id;
        } catch (exception) {
            console.log('Exception ' + exception);
        }
        this.searchResults.forEach(result => {
            if (result.Id === evId) tap = result;
        });
        this.currentTaps = this.putSelectedTaps(tap, this.currentTaps);
        this.taps = this.putSelectedTaps(tap, this.taps);
    }

    putSelectedTaps(tap, currentTaps) {
        let selectedTaps = [];
        if (!(currentTaps.length === 0)) {
            currentTaps.forEach(function (tap) {
                selectedTaps.push(tap);
            });
        }
        let newTap = {
            Participant__c: this.participantId,
            Therapeutic_Area__c: tap.Id,
            Condition_Of_Interest_Order__c: 1,
            Therapeutic_Area__r: tap
        };
        selectedTaps.push(newTap);
        return selectedTaps;
    }

    updateSearchResults(event) {
        const updateSearch = new CustomEvent('updateCOISearch', {
            detail: {
                taps: this.currentTaps,
                enrolling: this.enrolling,
                not_yet_enrolling: this.notYetEnrolling,
                participantId: this.participantId
            }
        });
        this.dispatchEvent(updateSearch);
        this.taps = this.currentTaps;
        this.template.querySelectorAll('.taps').forEach(checkBox => {
            checkBox.checked = true;
        });
    }

    handleCheckboxChange() {
        this.selection = Array.from(this.template.querySelectorAll('.checkbox')).map(element => element);

        for (let i = 0; i < this.selection.length; i++)
            if (this.selection[i].name === 'enrolling')
                this.enrolling = this.selection[i].checked;
            else if (this.selection[i].name === 'notYetEnrolling')
                this.notYetEnrolling = this.selection[i].checked;
    }

    editTaps(event) {
        let checkedTaps = [];
        let id = event.currentTarget.value;
        if (event.currentTarget.checked) {
            this.taps.forEach(tap => {
                if (tap.Therapeutic_Area__r.Id === id) checkedTaps.push(tap);
            });
            this.currentTaps.forEach(tap => {
                checkedTaps.push(tap);
            });
        } else this.currentTaps.forEach(tap => {
            if (tap.Therapeutic_Area__r.Id !== id) checkedTaps.push(tap);
        });
        this.currentTaps = checkedTaps;
    }
}