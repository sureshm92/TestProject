(
    {
        doInit : function (component, event, helper) {

            component.set("v.resourcesLoading", true);
            communityService.executeAction(component, 'getResources', {
                resourceType: component.get('v.resourceType'),
                resourceMode: 'Default'
            }, function (returnValue) {
                component.set("v.resourcesLoading", false);
                if(!returnValue.errorMessage) {
                    component.set("v.resources", returnValue.wrappers);
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
            let pathToNavigate = 'resources?resourceType=' + resourceType + '&id=' + trialId + '&resId=' + resourceId;
            if (document.location.pathname === '/s/') {
                pathToNavigate += '#home';
            }
            communityService.navigateToPage(pathToNavigate);
        },
    }
)