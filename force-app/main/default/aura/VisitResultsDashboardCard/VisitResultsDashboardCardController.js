(
    {
        doInit : function(component, event, helper) {
            if(communityService.isInitialized()) {
                communityService.executeAction(component, 'getVisitResultWrappersForDashboard', {}, function(returnValue) {
                    returnValue.forEach(function (wrapper) {
                        if(wrapper.value) {
                            wrapper.value = +(Math.round(wrapper.value + "e+3")  + "e-3");
                        }
                    });
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