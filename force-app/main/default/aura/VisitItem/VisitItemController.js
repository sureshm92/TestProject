/**
 * Created by AlexKetch on 6/20/2019.
 */
({
    editMode: function (component, event, helper) {
        component.getEvent('onEdit').fire();
    },

    deleteRecord: function (component, event, helper) {
        component.getEvent('onDelete').fire();
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

    doMouseEnter: function (component, event, helper) {
        component.set('v.currentRowColor', component.get('v.selectedRowColor'));
    },

    doMouseLeave: function (component, event, helper) {
        component.set('v.currentRowColor', component.get('v.rowColor'));
    }
});