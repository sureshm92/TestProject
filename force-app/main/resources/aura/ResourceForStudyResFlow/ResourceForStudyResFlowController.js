/**
 * Created by Olga Skrynnikova on 1/29/2020.
 */

({
    doInit : function(component, event, helper) {
        communityService.executeAction(component, 'getResourceList', null, function (response) {
            var options = [];
            for(var i=0; i<response.resourceList.length; i++) {
                options.push({
                    label: response.resourceList[i].Name + ' ' + response.resourceList[i].Title__c,
                    value: response.resourceList[i].Id
                });
            }
            console.log(JSON.stringify(options));
            component.set('v.resourceList', options);
        });
    },

    doSelect : function(component, event, helper) {
        var selectedOption = component.get('v.resourceId');
        var evt = $A.get('e.c:GetResIdFlowEvent');
        evt.setParams({'recordId': selectedOption});
        evt.fire();
    }
});