/**
 * Created by Igor Malyuta on 19.09.2019.
 */

({
    doSearchByTerm: function (component, event, helper) {
        const params = event.getParam('arguments');
        communityService.executeAction(component, 'searchVPByTerm', {
            searchTerm: component.get('v.searchTerm'),
            value: component.get('v.value')
        }, function (searchResults) {
            params.callback(searchResults);
        })
    },

    doSearchByValue: function (component, event, helper) {
        const params = event.getParam('arguments');
        communityService.executeAction(component, 'searchVPByIds', {
            value: component.get('v.value')
        }, function (selection) {
            params.callback(selection);
        })
    }
});