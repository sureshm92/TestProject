(
    {
        doInit : function(component, event, helper) {
            if(communityService.isInitialized()) {
                communityService.executeAction(component, 'getVisitResultWrappersForDashboard', {}, function(returnValue) {
                    if(returnValue.length){
                        component.set('v.visitReportHeader',returnValue[0].recordtype+'s');
                        communityService.executeAction(component, 'toggleState', {
                            visitResultsMode: component.get('v.visitReportHeader')
                        }, function(returnValue) {
                            component.set('v.toggleVitalsIsOn', returnValue);
                        });
                    }
                    returnValue.forEach(function (wrapper) {
                        if(wrapper.value) {
                            wrapper.value = +(Math.round(wrapper.value + "e+3")  + "e-3");
                        }
                    });
                    component.set('v.visitResultWrappers', returnValue);
                    var trialId = component.get('v.ctpId');
                    component.set('v.VisitResultPage', 'study-workspace?id=' + trialId + '&tab=tab-lab-results');
                });
            }
        },
        navigateToPage : function(component, event, helper) {
            var trialId = component.get('v.ctpId');
            communityService.navigateToPage('study-workspace?id=' + trialId + '&tab=tab-lab-results');
        },
    }
);