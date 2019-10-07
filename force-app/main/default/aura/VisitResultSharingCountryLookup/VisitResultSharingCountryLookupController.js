/**
 * Created by Leonid Bartenev
 */

({
    doSearchByTerm: function (component, event, helper) {
        const params = event.getParam('arguments');
        communityService.executeAction(component, 'searchCountries', {
            searchTerm: component.get('v.searchTerm'),
            value: component.get('v.value'),
            includeStates: component.get('v.includeStates'),
            isInclude : component.get('v.isInclude'),
            ctpId : component.get('v.ctpId')
        }, function (searchResults) {
            params.callback(searchResults);
        })
    },

    doSearchByValue: function (component, event, helper) {
        const params = event.getParam('arguments');
        communityService.executeAction(component, 'searchResultsByValue', {
            value: component.get('v.value'),
            isInclude : component.get('v.isInclude'),
        }, function (selection) {
            params.callback(selection);
        })
    }

})