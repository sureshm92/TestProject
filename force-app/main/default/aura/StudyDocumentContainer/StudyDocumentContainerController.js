(
    {
        doInit : function (component, event, helper) {

            let spinner = component.find('spinner');
            if(spinner){ spinner.show(); }
            let resourceMode = component.get("v.resourceMode");
            communityService.executeAction(component, 'getStudyDocuments', null, function (returnValue) {
                if(!returnValue.errorMessage) {
                    component.set("v.resourceWrappers", returnValue.wrappers);
                    component.set("v.errorMessage", "");
                } else {
                    component.set("v.errorMessage", returnValue.errorMessage);
                }
                let spinner = component.find('spinner');
                if(spinner){ spinner.hide(); }
            });
        },

        navigateToPage : function (component, event, helper) {
            var resourceType = event.currentTarget.dataset.type;
            var resourceId = event.currentTarget.dataset.id;
            var recId = communityService.getUrlParameter('id');
            communityService.navigateToPage("resources?resourceType=" + resourceType + "&id=" + recId + '&resId=' + resourceId + '&ret=' + communityService.createRetString());
        },

        newModeSelected : function(component, event, helper){
            var modeChanged = component.get('v.modeChanged');

            component.set('v.modeChanged', !modeChanged);
            console.log('isModeChanged ', component.get('v.modeChanged'));
        }
    }
)