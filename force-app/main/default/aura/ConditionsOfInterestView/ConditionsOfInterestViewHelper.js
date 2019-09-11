({

    handleSelection : function(component, event, helper) {
        let selectedCoi = helper.getConditionFromSelectionById(component, event.currentTarget.id);
        let taps = component.get('v.taps');
        let newTap = {
            Participant__c : component.get('v.participantId'),
            Therapeutic_Area__c : selectedCoi.Id,
            Condition_Of_Interest_Order__c : 1,
            Therapeutic_Area__r : selectedCoi
        };
        taps.push(newTap);
        component.set('v.taps', taps);
    },

    doSearch : function(component) {
        let selectedTaps = component.get('v.taps');
        let selectedCoisIds = [];
        for (let i = 0; i < selectedTaps.length; i++) {
            selectedCoisIds.push(selectedTaps[i].Therapeutic_Area__c);
        }
        console.log(selectedCoisIds);
        communityService.executeAction(component, 'searchForConditionOfInterest', {
            searchText : component.find('search').value,
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
        let updateEvt = component.getEvent('updateSearchEvent');
        let settings = component.get('v.conditionOfInterestList');
        updateEvt.setParam('settings', settings);
        communityService.executeAction(component, 'doSave', {
            data: settings
        });
    }

});