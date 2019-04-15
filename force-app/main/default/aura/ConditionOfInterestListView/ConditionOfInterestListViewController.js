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
        let coiWrapperList = component.get('v.conditionOfInterestList');
        let coiList = [];
        for (let i = 0; i < coiWrapperList.length; i++) {
            let coi = coiWrapperList[i].coi;
            coi.Condition_Of_Interest_Order__c = i + 1;
            coiList.push(coi);
        }
        console.log('before update COI ' + JSON.stringify(coiList));
        if (coiList) {
            communityService.executeAction(component, 'upsertListCoi', {
                cois : coiList
            }, function (returnValue) {
                let coiSaveWrapperList = [];
                returnValue.forEach(e => {
                    let coiSave = {};
                    coiSave.isSelected = true;
                    coiSave.coi = e;
                    coiSaveWrapperList.push(coiSave);
                });
                console.log('after update COI ' + JSON.stringify(coiSaveWrapperList));
                component.set('v.conditionOfInterestList', coiSaveWrapperList);
            });
        }
    },

    doDown: function (component, event, helper) {
        let indexCoi = event.getSource().get('v.value');
        let conditionOfInterestList = component.get('v.conditionOfInterestList');
        [conditionOfInterestList[indexCoi], conditionOfInterestList[indexCoi + 1]] = [conditionOfInterestList[indexCoi + 1], conditionOfInterestList[indexCoi]];
        component.set('v.conditionOfInterestList', conditionOfInterestList);
        component.set('v.isSaveList', !component.get('v.isSaveList'));
    },

    doUp: function (component, event, helper) {
        let indexCoi = event.getSource().get('v.value');
        let conditionOfInterestList = component.get('v.conditionOfInterestList');
        [conditionOfInterestList[indexCoi], conditionOfInterestList[indexCoi - 1]] = [conditionOfInterestList[indexCoi - 1], conditionOfInterestList[indexCoi]];
        component.set('v.conditionOfInterestList', conditionOfInterestList);
        component.set('v.isSaveList', !component.get('v.isSaveList'));
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