({
	showToast : function(component, event, helper) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "duration" :400,
         "type": "success",
        "message": $A.get("$Label.c.MO_RecordUpdate")
    });
    toastEvent.fire();
}
})