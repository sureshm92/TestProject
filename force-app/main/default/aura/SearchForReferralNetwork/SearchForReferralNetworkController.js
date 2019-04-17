/**
 * Created by RAMukhamadeev on 2019-04-17.
 */

({
    doInit: function (component, event, helper) {

    },

    show: function (component, event, helper) {
        helper.doSearch(component, event, helper);
        component.find('searchModal').show();
    },

    hide: function (component, event, helper) {
        component.find('searchModal').hide();
    },

    bulkSearch: function (component, event, helper) {
        helper.doSearch(component, event, helper);
    },

    handleChange: function (component, event, helper) {
        helper.changeCheckBox(component, event);
    },

    doClose: function (component, event, helper) {
        component.find('searchModal').hide();
        component.find('searchInput').set('v.value', '');

        communityService.executeAction(component, 'getReferralNetworkRecords', {
            sObjectType: component.get("v.sObjectType")
        }, function (returnValue) {
            component.set('v.currChosenRefNetworks', returnValue);
        });
    }
});