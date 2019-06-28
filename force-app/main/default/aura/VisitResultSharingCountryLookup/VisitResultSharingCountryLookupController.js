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
            ctpId : component.get('v.ctpId')
        }, function (searchResults) {
            params.callback(searchResults);
        })
    },

    doSearchByValue: function (component, event, helper) {
        const params = event.getParam('arguments');
        communityService.executeAction(component, 'searchResultsByValue', {
            value: component.get('v.value')
        }, function (selection) {
            params.callback(selection);
        })
    }

})