(
    {
        doInit : function(component, event, helper) {
            if(communityService.isInitialized()) {
                communityService.executeAction(component, 'getVisitResultWrappersForDashboard', {}, function(returnValue) {
                    component.set('v.visitResultWrappers', returnValue);
                });
            }
        },

        navigateToPage : function(component, event, helper) {
            var trialId = component.get('v.ctpId');
            communityService.navigateToPage('study-workspace?id=' + trialId + '&tab=tab-lab-results');
        },
    }
)