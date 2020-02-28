/**
 * Created by Yehor Dobrovolskyi
 */({
    saveCOIs: function (component) {
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
                cois: coiList
            }, function (returnValue) {
                let coiSaveWrapperList = [];
                returnValue.forEach(function (e) {
                    let coiSave = {};
                    coiSave.isSelected = true;
                    coiSave.coi = e;
                    coiSaveWrapperList.push(coiSave);
                });
                console.log('after update COI ' + JSON.stringify(coiSaveWrapperList));
                component.set('v.conditionOfInterestList', coiSaveWrapperList);
                component.set('v.showSpinner', false);
            });
            communityService.executeAction(component, 'createSubscribeConnection', {
                cois: coiList
            });
        }
    },

    swapElement: function (component, index1, index2) {
        let conditionOfInterestList = component.get('v.conditionOfInterestList');
        var temCoi = conditionOfInterestList[index1];
        conditionOfInterestList[index1] = conditionOfInterestList[index2];
        conditionOfInterestList[index2] = temCoi;
        component.set('v.conditionOfInterestList', conditionOfInterestList);
        component.set('v.isSaveList', !component.get('v.isSaveList'));
    },

    deleteCOI: function (component, idCOI) {
        let coiIds = [];
        coiIds.push(idCOI);
        let conditionOfInterestList = component.get('v.conditionOfInterestList');
        if (coiIds) {
            communityService.executeAction(component, 'deleteCOI', {
                coiIds: coiIds
            }, function () {
                conditionOfInterestList = conditionOfInterestList.filter(function (el) {
                    return el.coi.Id !== idCOI;
                });
                component.set('v.conditionOfInterestList', conditionOfInterestList);
                component.set('v.isSaveList', !component.get('v.isSaveList'));
            });
        }
    }
})