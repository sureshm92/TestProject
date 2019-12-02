(
    {
        doInit : function (component, event, helper) {

            component.set("v.initialized", false);
            communityService.executeAction(component, 'getResources', {
                resourceType: component.get('v.resourceType'),
                resourceMode: 'Default'
            }, function (returnValue) {
                component.set("v.initialized", true);
                let spinner = component.find('spinner');
                if(spinner) {
                    spinner.hide();
                }
                if(!returnValue.errorMessage) {
                    returnValue = helper.trimLongText(returnValue);
                    component.set("v.resourceWrappers", returnValue.wrappers);
                    component.set("v.errorMessage", "");
                } else {
                    component.set("v.errorMessage", returnValue.errorMessage);
                }
            });
        },

        navigateToPage : function (component, event, helper) {
            var resourceType = event.currentTarget.dataset.type;
            var resourceId = event.currentTarget.dataset.id;
            var trialId = component.get('v.trialId');
            let pathToNavigate = 'resources?resourceType=' + resourceType + '&id=' + trialId + '&resId=' + resourceId + '&ret=' + communityService.createRetString();
            communityService.navigateToPage(pathToNavigate);
        },
    }
)