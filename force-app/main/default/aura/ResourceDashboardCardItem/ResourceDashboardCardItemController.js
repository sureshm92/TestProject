(
    {
        doInit : function (component, event, helper) {

            var spinner = component.find('spinner');
            if(spinner){ spinner.show(); }

            communityService.executeAction(component, 'getResources', {
                resourceType: component.get('v.resourceType'),
                resourceMode: 'Default'
            }, function (returnValue) {
                if(!returnValue.errorMessage) {
                    for(let i = 0; i < returnValue.wrappers.length; i++) {
                        let title = returnValue.wrappers[i].title;
                        returnValue.wrappers[i].title = title.length > 40 ? title.substring(0, 37) + '...' : title;
                        let description = returnValue.wrappers[i].description;
                        returnValue.wrappers[i].description = description.length > 120 ? description.substring(0, 117) + '...' : description;
                    }
                    component.set("v.resources", returnValue.wrappers);
                    component.set("v.errorMessage", "");
                } else {
                    component.set("v.errorMessage", returnValue.errorMessage);
                }
                var spinner = component.find('spinner');
                if(spinner){ spinner.hide(); }
            });
        },

        navigateToPage : function (component, event, helper) {
            var resourceType = event.currentTarget.dataset.type;
            var resourceId = event.currentTarget.dataset.id;
            var trialId = component.get('v.trialId');
            communityService.navigateToPage("resources?resourceType=" + resourceType + "&id=" + trialId + '&resId=' + resourceId);
        },
    }
)