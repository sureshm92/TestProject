/**
 * Created by AlexKetch on 6/20/2019.
 */
({

    editMode: function (component, event, helper) {
        debugger;
        const currentRec = component.getEvent('onEditRecord');
        currentRec.setParams({
           record:component.get('v.visit')
        });
        currentRec.fire();
    },
    deleteRecord: function (component, event, helper) {
        debugger;
        let currentRec = component.getEvent('onDeleteRecord');
        currentRec.setParams({
            record:component.get('v.visit')
        });
        currentRec.fire();
    },

    navToRecord : function (component, event, helper) {
        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.visit.Id"),
            "slideDevName": "Related",
            "isredirect": 'true'
        });
        navEvt.fire();
    },
})