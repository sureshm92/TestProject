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
            let pathToNavigate = 'resources?resourceType=' + resourceType + '&id=' + trialId + '&resId=' + resourceId;
            if (document.location.pathname === '/s/') {
                pathToNavigate += '#home';
            }
            communityService.navigateToPage(pathToNavigate);
        },
    }
)