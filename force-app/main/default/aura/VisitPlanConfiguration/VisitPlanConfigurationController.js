/**
 * Created by AlexKetch on 6/18/2019.
 */
({

    doInit: function (component, event, helper) {
        debugger;
        helper.getRelatedVisitPlans(component, event, helper);
        let staticResName = component.get('v.IconsPackageName');
        let path = component.get('v.IconsPackageFIlePath');
        let iconsStaticURL = $A.get('$Resource.' + staticResName) + path;
        component.set('v.iconsURL', iconsStaticURL);
    },
    addVisit: function (component, event, helper) {
        helper.addVisit(component, event, helper);
    },
    onEditIcon: function (component, event, helper) {
        component.find('iconEdit').show();
        component.find('iconEdit').loadIconsDescription();
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
        name === null ? helper.notify({
            "title": "Name Is Empty",
            "message": "Complete Name field.",
            "type": "error"
        }) : component.find('editForm').submit();
    },

    shiftRight: function (component, event, helper) {
        helper.shiftRight(component, event, helper);
    },
    shiftLeft: function (component, event, helper) {
        helper.shiftLeft(component, event, helper);

    },
    handleSuccess: function (component, event, helper) {
        debugger;
        component.find('customModal').hide();
        helper.getRelatedVisitPlans(component, event, helper);
        helper.notify({
            "title": $A.get("$Label.c.Success"),
            "message": $A.get("$Label.c.Success_Creation"),
            "type": $A.get("$Label.c.successType")
        });
    },
})