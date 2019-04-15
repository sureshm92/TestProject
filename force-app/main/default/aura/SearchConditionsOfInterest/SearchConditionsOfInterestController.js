/**
 * Created by Yehor Dobrovolskyi
 */
({
    doInit: function (component, event, helper) {
        component.set('v.conditionsOfInterestTemp', component.get('v.conditionsOfInterest'));
        helper.valueChange(component, event, helper);
    },

    show: function (component) {
        component.find('searchModal').show();
    },

    hide: function(component, event, helper) {
        component.find('searchModal').hide();
    },

    bulkSearch: function (component, event, helper) {
        var bypass = component.get('v.bypass');
        if (bypass) {
            return;
        } else {
            component.set('v.bypass', true);
            window.setTimeout(
                $A.getCallback(function () {
                    helper.valueChange(component, event, helper);
                }), 500
            );
        }
    },

    handleChange: function (component, event) {
        let taWrapper = event.getSource().get('v.value');
        let taList = component.get('v.conditionsOfInterestTemp');
        if (event.getParam('checked')) {
            if (taList.length < 5) {
                taList.push(taWrapper);
            } else {
                event.getSource().set('v.checked', false);
            }
        } else {
            taList = taList.filter(e => e.coi.Therapeutic_Area__r.Id !== taWrapper.coi.Therapeutic_Area__r.Id);
        }
        component.set('v.conditionsOfInterestTemp', taList);
    },

    doCancel: function (component, event, helper) {
        component.find('searchModal').hide();
        let arr = [];
        component.set('v.displayedItems', arr);
        component.find('searchInput').set('v.value', '');
    },

    doSave: function (component, event, helper) {
        let deleteCOI = component.get('v.conditionsOfInterest');
        let conditionsOfInterestTemp = component.get('v.conditionsOfInterestTemp');
        let deleteCoiId = [];
        console.log(JSON.stringify(conditionsOfInterestTemp));
        conditionsOfInterestTemp.sort((a, b) => {
            return a.coi.Condition_Of_Interest_Order__c - b.coi.Condition_Of_Interest_Order__c;
        });
        console.log(JSON.stringify(conditionsOfInterestTemp));
        for( let i=deleteCOI.length - 1; i>=0; i--){
            for( let j=0; j<conditionsOfInterestTemp.length; j++){
                if(deleteCOI[i] && (deleteCOI[i].coi.Id === conditionsOfInterestTemp[j].coi.Id)){
                    deleteCOI.splice(i, 1);
                }
            }
        }
        if (deleteCOI) {
            deleteCoiId = deleteCOI.map((e) => {
                return e.coi.Id;
            });
        }
        if (deleteCoiId) {
            communityService.executeAction(component, 'deleteCOI', {
                coiIds : deleteCoiId
            }, function (returnValue) {
            });
        }
        console.log('DELETE COI' + JSON.stringify(deleteCoiId));
        component.set('v.conditionsOfInterest', conditionsOfInterestTemp);
        component.find('searchModal').hide();
        let arr = [];
        component.set('v.displayedItems', arr);
        component.find('searchInput').set('v.value', '');
        component.set('v.isSaveList', !component.get('v.isSaveList'));

    }

})