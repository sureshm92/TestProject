(
    {
        doInit : function (component, event, helper) {

            let spinner = component.find('spinner');
            if(spinner){ spinner.show(); }

            communityService.executeAction(component, 'getResources', {
                resourceType: component.get('v.resourceType'),
                resourceMode: 'Default'
            }, function (returnValue) {
                if(!returnValue.errorMessage) {
                    returnValue = helper.trimLongText(returnValue);
                    component.set("v.resources", returnValue.wrappers);
                    component.set("v.errorMessage", "");
                } else {
                    component.set("v.errorMessage", returnValue.errorMessage);
                }
                let spinner = component.find('spinner');
                if(spinner){ spinner.hide(); }
            });
        },

        navigateToPage : function (component, event, helper) {
            let resourceType = event.currentTarget.dataset.type;
            let resourceId = event.currentTarget.dataset.id;
            let trialId = component.get('v.trialId');
            communityService.navigateToPage("resources?resourceType=" + resourceType + "&id=" + trialId + '&resId=' + resourceId);
        },
    }
)