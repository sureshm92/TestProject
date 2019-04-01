(
    {
        doInit : function (component, event, helper) {

            if (communityService.isInitialized()) {
                communityService.executeAction(component, 'getTrialId', {
                    userMode : communityService.getUserMode()
                }, function (returnValue) {
                    component.set("v.trialId", returnValue);
                });
                communityService.executeAction(component, 'getNoTAMessage', {}, function (returnValue) {
                    component.set("v.noTAMessage", returnValue);
                });
            }
        },

        navigateToPage : function (component, event, helper) {
            var trialId = component.get('v.trialId');
            communityService.navigateToPage('study-workspace?id=' + trialId + '&tab=tab-resources&resourcemode=Default');
        },
    }
)