/**
 * Created by Yehor Dobrovolskyi
 */
({
    valueChange: function (component, event, helper) {
        component.set('v.bypass', false);
        let value = event.getSource().get('v.value');
        if (!value) {
            value = null;
        }
        communityService.executeAction(component, 'searchConditionOfInterest', {
            nameTA: value
        }, function (returnValue) {
            let coiList = component.get('v.conditionsOfInterestTemp');
            let coiWrappers = returnValue;
            coiWrappers.forEach(function (coiWrapper) {
                if (coiList.some(function (coiEl) {
                    return coiEl.coi.Therapeutic_Area__c === coiWrapper.coi.Therapeutic_Area__c
                })) {
                    coiWrapper.isSelected = true;
                }
            });
            component.set('v.displayedItems', coiWrappers);
        });
    },

    saveElement: function (component) {
        debugger;
        const deleteCOI = component.get('v.conditionsOfInterest');
        const conditionsOfInterestTemp = component.get('v.conditionsOfInterestTemp');
        let deleteCoiId = [];
        conditionsOfInterestTemp.sort(function (a, b) {
            return a.coi.Condition_Of_Interest_Order__c - b.coi.Condition_Of_Interest_Order__c;
        });
        for (var i = deleteCOI.length - 1; i >= 0; i--) {
            for (var j = 0; j < conditionsOfInterestTemp.length; j++) {
                if (deleteCOI[i] && (deleteCOI[i].coi.Id == conditionsOfInterestTemp[j].coi.Id)) {
                    deleteCOI.splice(i, 1);
                }
            }
        }
        if (deleteCOI) {
            deleteCoiId = deleteCOI.map(function (e) {
                return e.coi.Id;
            });
        }
        if (deleteCoiId) {
            communityService.executeAction(component, 'deleteCOI', {
                coiIds: deleteCoiId
            }, function (returnValue) {
            });
        }
        let copy = Object.assign([],conditionsOfInterestTemp);
        component.set('v.conditionsOfInterest', copy);
        component.find('searchModal').hide();
        let arr = [];
        component.set('v.displayedItems', arr);
        component.find('searchInput').set('v.value', '');
        component.set('v.isSaveList', !component.get('v.isSaveList'));
    },

    changeCheckBox: function (component, event) {
        let taWrapper = event.getSource().get('v.value');
        let taList = component.get('v.conditionsOfInterestTemp');
        if (event.getParam('checked')) {
            if (taList.length < 5) {
                taList.push(taWrapper);
            } else {
                event.getSource().set('v.checked', false);
            }
        } else {
            taList = taList.filter(function (e) {
                e.coi.Therapeutic_Area__r.Id !== taWrapper.coi.Therapeutic_Area__r.Id
            });
        }
        component.set('v.conditionsOfInterestTemp', taList);
    }
})