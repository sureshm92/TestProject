({
    doExecute: function(component, event, helper) {
        component.find('Show_WarningPoP_Up').show();
    },
    confirmed: function(component, event, helper) {
        communityService.executeAction(component, 'UpdateRecord', {
            MediaRecordId: component.get("v.recordid"),
            Cancelrequest: 'true',
            updateval: 'false'
        }, function(returnValue) {
            var initData = JSON.parse(returnValue);
            component.find('Show_WarningPoP_Up').hide();
            communityService.showToast("success", "success", $A
                .get(
                    "$Label.c.MO_RecordUpdate"
                ));
        });
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "closeAllPopup": "yes"
        });
        cmpEvent.fire();
    },
    declined: function(component, event, helper) {
        component.find('Show_WarningPoP_Up').hide();
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "closeAllPopup": "no"
        });
        cmpEvent.fire();
    }
})