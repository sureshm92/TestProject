/**
 * Created by RAMukhamadeev on 2019-04-17.
 */

({
    doSearch: function (component, event, helper) {
        component.set('v.bypass', false);
        let value = event.getSource().get('v.value');
        if (!value) {
            value = null;
        }
        communityService.executeAction(component, 'searchForReferralNetworks', {
            term: value,
            sObjectType: component.get("v.sObjectType")
        }, function (returnValue) {
            component.set('v.displayedRefNetworks', returnValue);
        });
    },

    changeCheckBox: function (component, event) {
        let currElement = event.getSource().get('v.value');

        communityService.executeAction(component, 'saveReferralNetworks', {
            referralNetworkJSON: JSON.stringify(currElement)
        }, function (returnValue) {
        });
    }
});