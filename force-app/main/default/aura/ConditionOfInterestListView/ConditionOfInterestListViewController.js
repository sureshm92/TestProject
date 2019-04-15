/**
 * Created by AlexKetch on 3/21/2019.
 */
({
    doInit: function (component, event, helper) {
        var action = component.get("c.getConditionOfInterest");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let taWrappers = response.getReturnValue();
                component.set('v.conditionOfInterestList', taWrappers);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
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
    }
})