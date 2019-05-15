/**
 * Created by AlexKetch on 3/21/2019.
 */
({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getConditionOfInterest', {}, function (returnValue) {
            component.set('v.conditionOfInterestList', returnValue);
        });
    },

    doSelect: function (component, event, helper) {
        component.find('searchModal').show();
    },

    doSaveSortCOIs: function (component, event, helper) {
        helper.saveCOIs(component);
    },

    doDown: function (component, event, helper) {
            component.set('v.showSpinner', true);
            let indexCoi = event.getSource().get('v.value');
            helper.swapElement(component, indexCoi, (indexCoi + 1));
    },

    doUp: function (component, event, helper) {
            component.set('v.showSpinner', true);
            let indexCoi = event.getSource().get('v.value');
            helper.swapElement(component, indexCoi, (indexCoi - 1));
    },

    doDelete: function (component, event, helper) {
            component.set('v.showSpinner', true);
            let idCOI = event.getSource().get('v.value');
            helper.deleteCOI(component, idCOI);
    }
})