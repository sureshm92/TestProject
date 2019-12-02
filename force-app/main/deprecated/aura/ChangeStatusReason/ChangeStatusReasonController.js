({
    onReasonSelect: function (component, event, helper) {
        if(component.get("v.reasonResponse") === "Other"){
            component.set("v.reasonResponse", '');
            component.set("v.showOtherReason", true);
        }
    }
})