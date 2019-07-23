/**
 * Created by AlexKetch on 6/18/2019.
 */
({

    doInit: function (component, event, helper) {
        helper.getRelatedVisitPlans(component, event, helper);
        helper.getIconsUrl(component, event, helper);
        helper.getAllIconsNames(component, event, helper);

    },

    addVisit: function (component, event, helper) {
        helper.addVisit(component, event, helper);
    },

    preload: function (component, event, helper) {
        const recId = component.get('v.visitPlanId');
        component.find('visitPlan').set('v.value', recId);
    },
    deleteRecord: function (component, event, helper) {
        helper.deleteRecord(component, event, helper);
    },
    createVisitplan: function (component, event, helper) {
        component.find('createVisitPlan').show();
    },
    onCancelVisitPlan: function (component, event, helper) {
        component.find('createVisitPlan').hide();
    },
    handleRecordUpdated: function (component, event, helper) {
        debugger;
        helper.handleRecordUpdated(component, event, helper);
    },
    handleSuccessVP: function (component, event, helper) {
        helper.handleSuccessVP(component, event, helper);
    },

    editMode: function (component, event, helper) {
        helper.fireEditMode(component, event, helper);
    },

    closeModal: function (component, event, helper) {
        const recId = component.get('v.visitPlanId');
        component.find('customModal').hide();
    },

    submitForm: function (component, event, helper) {
        let icons = component.get('v.selectedIcons');
        let strCoins = icons.join(';');
        component.find('splittedIcons').set('v.value', strCoins);
        let name = component.find('nameId').get("v.value");
        if (name === null) {
            helper.notify({
                "title": "Name Is Empty",
                "message": "Complete Name field.",
                "type": "error"
            })
        } else {
            component.find('editForm').submit();
        }
    },

    shiftRight: function (component, event, helper) {
        helper.shiftRight(component, event, helper);
    },
    shiftLeft: function (component, event, helper) {
        helper.shiftLeft(component, event, helper);

    },
    handleSuccess: function (component, event, helper) {
        debugger;
        let spinner = component.find('mainSpinner');
        if (spinner) {
            spinner.show();
        }
        component.find('customModal').hide();
        helper.getRelatedVisitPlans(component, event, helper);
        helper.notify({
            "title": $A.get("$Label.c.Success"),
            "message": $A.get("$Label.c.Success_Creation"),
            "type": $A.get("$Label.c.successType")
        });
    },

    onSubmitCreateVisitPlan: function (component, event, helper) {
        helper.checkOnEmptyName(component, event, helper);
    }

})