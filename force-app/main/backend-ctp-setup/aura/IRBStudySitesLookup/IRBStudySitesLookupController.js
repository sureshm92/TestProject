/**
 * Created by Igor Malyuta on 19.09.2019.
 */

({
    doSearchByTerm: function (component, event, helper) {
        const params = event.getParam('arguments');
        communityService.executeAction(component, 'searchSSByTerm', {
            ctpId: component.get('v.ctpId'),
            searchTerm: component.get('v.searchTerm'),
            value: component.get('v.value'),
            selectedCountries : component.get('v.selectedCountries')
        }, function (searchResults) {
            params.callback(searchResults);
        })
    },

    doSearchByValue: function (component, event, helper) {
        const params = event.getParam('arguments');
        communityService.executeAction(component, 'searchSSByIds', {
            value: component.get('v.value'),
            selectedCountries : component.get('v.selectedCountries')
        }, function (selection) {
            params.callback(selection);
        })
    }
});