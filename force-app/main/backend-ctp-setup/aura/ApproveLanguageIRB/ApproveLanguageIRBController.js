/**
 * Created by Igor Malyuta on 22.08.2019.
 */

({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component, 'getInitData', {
            ctpId: component.get('v.recordId')
        }, function (data) {
            component.set('v.filter', data.filter);
            component.set('v.viewModePage', data.viewMode);
            helper.setSearchResponse(component, data.searchResponse);

            component.set('v.initialized', true);
        });
    },

    doUpdate: function (component, event, helper) {
        helper.updateItems(component);
    },

    doSaveAndUpdate: function(component, event, helper){
        helper.updateItems(component, true);
    },

    onCountriesChange: function (component, event, helper) {
        component.set('v.filter.selectedSSIds', '');
        helper.updateItems(component);
    },

    doSort: function (component, event, helper) {
        helper.updateItems(component);
    },

    columnCheckboxStateChange: function (component, event, helper) {
        let lang = event.target.dataset.lang;
        let state = event.target.dataset.state === 'Enabled';

        component.find('spinner').show();
        communityService.executeAction(component, 'setLanguageForAll', {
            filterJS: JSON.stringify(component.get('v.filter')),
            paginationJS: JSON.stringify(component.get('v.pagination')),
            ssItemsJSON: JSON.stringify(component.get('v.ssItems')),
            language: lang,
            state: state
        }, function (searchResponse) {
            helper.setSearchResponse(component, searchResponse);
        });
    }
});