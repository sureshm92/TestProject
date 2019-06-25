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
        const currentRec = component.getEvent('onDeleteRecord');
        currentRec.setParams({
            record:component.get('v.visit')
        });
        currentRec.fire();
    },

})