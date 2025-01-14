/**
 * Created by Igor Malyuta on 16.09.2019.
 */

({
    doSearchByTerm: function (component, event, helper) {
        const params = event.getParam('arguments');
        communityService.executeAction(
            component,
            'searchSurveys',
            {
                searchTerm: component.get('v.searchTerm'),
                value: component.get('v.value')
            },
            function (searchResults) {
                params.callback(searchResults);
            }
        );
    },

    doSearchByValue: function (component, event, helper) {
        const params = event.getParam('arguments');
        communityService.executeAction(
            component,
            'searchSurveysByValue',
            {
                value: component.get('v.value')
            },
            function (selection) {
                params.callback(selection);
            }
        );
    }
});
