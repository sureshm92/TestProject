/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        var pathList = component.get('v.pathItems');
        var currentIndex;
        for(var i = 0; i < pathList.length; i++){
            if(pathList[i].isCurrent){
                currentIndex = i;
                break;
            }
        }
        var reversedList = [];
        for(i = pathList.length - 1; i >= 0; i--){
            var step = pathList[i];
            if(i <= currentIndex) reversedList.push(step);
        }
        component.set('v.pathItemsReversed', reversedList);
    },

    doLoadHistory: function (component, event, helper) {
        if(component.get('v.historyLoaded')) return;
        component.set('v.showStepSpinner', true);
        var action = component.get('c.getPEStatusHistory');
        action.setParams({
            peId: component.get('v.peId'),
            userMode: communityService.getUserMode()
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var historyMap = JSON.parse(response.getReturnValue());
                var steps = component.get('v.pathItemsReversed');
                for(var i = 0; i < steps.length; i ++){
                    steps[i].history = historyMap[steps[i].name];
                }
                component.set('v.pathItemsReversed', steps);
                component.set('v.historyLoaded', true);
            } else {
                communityService.logErrorFromResponse(response);
                communityService.showErrorToastFromResponse(response);
            }
            component.set('v.showStepSpinner', false);
        });
        $A.enqueueAction(action);
    }
})