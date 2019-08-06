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
    editVisitLegend: function (component, event, helper) {
        helper.editVisitLegend(component, event, helper);
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
        debugger;
        let legendCmp = component.find('addVisit');
        if (legendCmp.isInstanceOf('c:Modalable')) {
            legendCmp.save(function (modalSpinner) {
                helper.handleSuccessSaveAddVisit(component, event, helper);
                modalSpinner.hide();
                component.find('editLegend').hide();
            }, function (errorcallBack) {
                errorcallBack();
            });
        }
    },

    shiftRight: function (component, event, helper) {
        helper.shiftRight(component, event, helper);
    },
    shiftLeft: function (component, event, helper) {
        helper.shiftLeft(component, event, helper);

    },
    handleSuccess: function (component, event, helper) {

    },
    saveLegend: function (component, event, helper) {
        debugger;
        let legendCmp = component.find('legend');
        if (legendCmp.isInstanceOf('c:Modalable')) {
            legendCmp.save(function () {
                helper.notify({
                    "title": "Success!",
                    "message": "saved successfully.",
                    "type": 'success'
                });
                component.find('editLegend').hide();
            }, function (error) {
                helper.notify({
                    title: 'error',
                    message: error,
                    type: 'error',
                });
            });
        }
    },
    closeLegend: function (component, event, helper) {
        component.find('editLegend').hide();
    },
    onSubmitCreateVisitPlan: function (component, event, helper) {
        helper.checkOnEmptyName(component, event, helper);
    }


})