({
    doInit: function (component, event, helper) {

        var statusHistory = component.get("v.statusHistory");
        if(!statusHistory) return;

        component.set("v.status", statusHistory.NewStatus__c.split(' (')[0]);
    }
})