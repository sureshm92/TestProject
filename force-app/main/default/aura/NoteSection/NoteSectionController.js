({
    doInit: function(component, event, helper) {
        component.set("v.notes", "");
        var action = component.get("c.getNotesdata");
        action.setParams({
            'MediaRecordId': component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                component.set("v.NotesData", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    submitDetails: function(component, event, helper) {
        var action = component.get("c.UpdateNotes");
        var dataval = component.get("v.notes");
        if (dataval == "" || dataval == " " || dataval == "  ") {
            component.set("v.validated", false);
        } else {
            component.set("v.validated", true);
        }
        if (component.get("v.validated")) {
            action.setParams({
                'MediaRecordId': component.get("v.recordId"),
                'notes': component.get("v.notes")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "duration": 400,
                        "type": "success",
                        "message": $A.get("$Label.c.MO_RecordUpdate")
                    });
                    toastEvent.fire();
                }
            });
            component.set("v.isOpen", false);
            $A.enqueueAction(action);
            location.reload();
        }
    },
    openModel: function(component, event, helper) {
        component.set("v.isOpen", true);
        component.set("v.notes", "");
    },
    closeModel: function(component, event, helper) {

        component.set("v.isOpen", false);
        component.set("v.notes", "");
    }

})