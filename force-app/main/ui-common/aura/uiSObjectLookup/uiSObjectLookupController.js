/**
 * Created by Leonid Bartenev
 */
({
    doSearchByTerm: function (component, event, helper) {
        const params = event.getParam('arguments');
        communityService.executeAction(component, 'searchSSByTerm', {
            sObjectType: component.get('v.sObjectType'),
            pillIcon: component.get('v.pillIcon'),
            filter: component.get('v.filter'),
            searchTerm: component.get('v.searchTerm'),
            value: component.get('v.value'),
        }, function (searchResults) {
            params.callback(searchResults);
        })
    },

    doSearchByValue: function (component, event, helper) {
        const params = event.getParam('arguments');
        communityService.executeAction(component, 'searchSSByIds', {
            sObjectType: component.get('v.sObjectType'),
            pillIcon: component.get('v.pillIcon'),
            filter: component.get('v.filter'),
            value: component.get('v.value'),
        }, function (selection) {
            params.callback(selection);
        })
    }

})