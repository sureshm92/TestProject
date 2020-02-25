/**
 * Created by Nargiz Mamedova on 2/14/2020.
 */

({
    updateCoi : function(component, event, helper) {
        var conditions = 'none';
        if(component.get('v.conditions')) conditions = component.get('v.conditions');
        console.log('conditions' + JSON.stringify(conditions));
        console.log('recordId: ' + component.get('v.recordId'));
        communityService.executeAction(component, 'setCOILookup', {
            'recordId': component.get('v.recordId'),
            'chosenConditions': conditions
        });
    }
});