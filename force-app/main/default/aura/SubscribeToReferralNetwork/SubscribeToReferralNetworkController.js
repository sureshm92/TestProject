/**
 * Created by RAMukhamadeev on 2019-04-17.
 */

({
    doInit: function (component, event, helper) {
        communityService.executeAction(
            component,
            'getReferralNetworkRecords',
            {
                sObjectType: component.get('v.sObjectType')
            },
            function (returnValue) {
                component.set('v.records', returnValue);
            }
        );
    },

    doSelect: function (component, event, helper) {
        component.find('searchModal').show();
    },

    doDelete: function (component, event, helper) {
        var recordId = event.getSource().get('v.value');
        var recordIds = [];
        recordIds.push(recordId);
        var records = component.get('v.records');
        if (recordIds) {
            communityService.executeAction(
                component,
                'deleteAndGetRefferalNetworks',
                {
                    sObjectType: component.get('v.sObjectType'),
                    recordIds: recordIds
                },
                function (returnValue) {
                    component.set('v.records', returnValue);
                }
            );
        }
    }
});
