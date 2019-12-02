({

    fillInitTaps : function(component) {
        let taps = component.get('v.taps');
        for (let i = 0; i < taps.length; i++) {
            taps[i].checked = true;
        }
        component.set('v.taps', taps);
    },

    handleSelection : function(component, event, helper) {
        let selectedCoi = helper.getConditionFromSelectionById(component, event.currentTarget.id);
        let taps = component.get('v.taps');
        if (taps === undefined || taps === null) {
            taps = [];
        }
        let newTap = {
            Participant__c : component.get('v.participantId'),
            Therapeutic_Area__c : selectedCoi.Id,
            Condition_Of_Interest_Order__c : 1,
            Therapeutic_Area__r : selectedCoi,
            checked : true
        };
        taps.push(newTap);
        component.set('v.taps', taps);
        component.find('search').set('v.value', '');
    },

    doSearch : function(component) {
        let selectedTaps = component.get('v.taps');
        let selectedCoisIds = [];
        if (selectedTaps !== null && selectedTaps !== undefined) {
            for (let i = 0; i < selectedTaps.length; i++) {
                selectedCoisIds.push(selectedTaps[i].Therapeutic_Area__c);
            }
        }
        communityService.executeAction(component, 'searchForConditionOfInterest', {
            searchText : component.find('search').get('v.value'),
            selectedCoisIds : selectedCoisIds
        }, function (data) {
            component.set('v.searchResults', data);
        });
    },

    getConditionFromSelectionById : function(component, id) {
        let searchResults = component.get('v.searchResults');
        let condition;
        for (let i = 0; i < searchResults.length; i++) {
            if (searchResults[i].Id === id) {
                condition = searchResults.splice(i, 1);
                break;
            }
        }
        component.set('v.searchResults', searchResults);
        return condition[0];
    },

    updateSearchResults : function(component) {
        let checkedTaps = [];
        let taps = component.get('v.taps');
        for (let i = 0; i < taps.length; i++) {
            if (taps[i].checked) {
                checkedTaps.push(taps[i]);
            }
        }
        let updateEvt = component.getEvent('updateSearchEvent');
        updateEvt.setParam('settings', checkedTaps);
        updateEvt.setParam('enrolling', component.find('enrolling').get("v.checked"));
        updateEvt.setParam('notYetEnrolling', component.find('notYetEnrolling').get("v.checked"));
        updateEvt.fire();
    },

    removeUncheckedTaps : function(component) {
        let tapsToLeft = [];
        let taps = component.get('v.taps');
        for (let i = 0; i < taps.length; i++) {
            if (taps[i].checked || taps[i].Id) {
                tapsToLeft.push(taps[i]);
            }
        }
        component.set('v.taps', tapsToLeft);
    }

});