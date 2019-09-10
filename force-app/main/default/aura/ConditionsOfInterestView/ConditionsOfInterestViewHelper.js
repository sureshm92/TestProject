({

    handleSelection : function(component, event, helper) {
        let justSelectedCondition = helper.getConditionFromSelectionById(event.currentTarget.id);
        let conditions = component.get('v.conditionOfInterestList');
        conditions.push(justSelectedCondition);
        component.set('v.conditionOfInterestList', conditions);
    },

    getConditionFromSelectionById : function(component, id) {
        let searchResults = component.get("v.searchResults");
        let condition;
        for (let i = 0; i < searchResults.length; i++) {
            if (searchResults[i].coi.Therapeutic_Area__c === id) {
                condition = searchResults.splice(i, 1);
                break;
            }
        }
        component.set('v.searchResults', searchResults);
        return condition;
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