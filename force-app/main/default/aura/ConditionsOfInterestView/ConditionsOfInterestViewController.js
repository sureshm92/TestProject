({

    doInit : function(component, event, helper) {
        communityService.executeAction(component, 'getConditionOfInterest', {}, function (data) {
            component.set('v.conditionOfInterestList', data);
        });
    },

    doSearch : function(component, event, helper) {
        communityService.executeAction(component, 'searchForConditionOfInterest', {
            searchText : component.find('search').value,
            selectedValues : component.get('v.conditionOfInterestList')
        }, function (data) {
            component.set('v.searchResults', data);
        });
    },

    handleSelection : function(component, event, helper) {
        helper.handleSelection(component, event, helper);
    },

    updateSearchResults : function(component, event, helper) {
        helper.updateSearchResults(component);
    }

});