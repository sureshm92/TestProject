/**
 * Created by Admin on 8/29/2019.
 */

({
    doSearchByTerm: function (component, event, helper) {
        const params = event.getParam('arguments');
        communityService.executeAction(component, 'searchVendorByTerm', {
            ctpId: component.get('v.ctpId'),
            searchTerm: component.get('v.searchTerm'),
            value: component.get('v.value'),
            includeSS : component.get('v.includeSS')
        }, function (searchResults) {
            params.callback(searchResults);
        })
    },

    doSearchByValue: function (component, event, helper) {
        const params = event.getParam('arguments');
        communityService.executeAction(component, 'searchVendorByIds', {
            value: component.get('v.value'),
            includeSS : component.get('v.includeSS')
        }, function (selection) {
            params.callback(selection);
        })
    }
});