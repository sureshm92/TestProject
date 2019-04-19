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
        let indexCoi = event.getSource().get('v.value');
        helper.swapElement(component, indexCoi, (indexCoi + 1));
    },

    doUp: function (component, event, helper) {
        let indexCoi = event.getSource().get('v.value');
        helper.swapElement(component, indexCoi, (indexCoi - 1));
    },

    doDelete: function (component, event, helper) {
        let idCOI = event.getSource().get('v.value');
        let coiIds = [];
        coiIds.push(idCOI);
        let conditionOfInterestList = component.get('v.conditionOfInterestList');
        if (coiIds) {
            communityService.executeAction(component, 'deleteCOI', {
                coiIds : coiIds
            }, function () {
                conditionOfInterestList = conditionOfInterestList.filter((el) => {
                    return el.coi.Id !== idCOI;
                });
                component.set('v.conditionOfInterestList', conditionOfInterestList);
                component.set('v.isSaveList', !component.get('v.isSaveList'));
            });
        }

    }
})