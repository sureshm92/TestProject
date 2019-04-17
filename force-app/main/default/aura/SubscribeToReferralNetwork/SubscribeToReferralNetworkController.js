/**
 * Created by RAMukhamadeev on 2019-04-17.
 */

({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getReferralNetworkRecords', {
            sObjectType: component.get("v.sObjectType")
        }, function (returnValue) {
            component.set('v.records', returnValue);
        });
    },

    doSelect: function (component, event, helper) {
        component.find('searchModal').show();
    },

    doDelete: function (component, event, helper) {
        let recordId = event.getSource().get('v.value');
        let recordIds = [];
        recordIds.push(recordId);
        let records = component.get('v.records');
        if (recordIds) {
            communityService.executeAction(component, 'deleteRecords', {
                recordIds: recordIds
            }, function () {
                records = records.filter((el) => {
                    return el.Id !== recordId;
                });
                component.set('v.records', records);
            });
        }
    }
});