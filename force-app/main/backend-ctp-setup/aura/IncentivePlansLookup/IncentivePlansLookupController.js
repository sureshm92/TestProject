/**
 * Created by Alexey Moseev on 5/7/20.
 */

({
    doSearchByTerm: function (component, event, helper) {
        const params = event.getParam('arguments');
        communityService.executeAction(component, 'searchIPByTerm', {
            searchTerm: component.get('v.searchTerm'),
            value: component.get('v.value'),
            ctpId: component.get('v.ctpId')
        }, function (searchResults) {
            params.callback(searchResults);
        })
    },

    doSearchByValue: function (component, event, helper) {
        const params = event.getParam('arguments');
        communityService.executeAction(component, 'searchIPByIds', {
            value: component.get('v.value'),
            ctpId: component.get('v.ctpId')
        }, function (selection) {
            params.callback(selection);
        })
    }
});