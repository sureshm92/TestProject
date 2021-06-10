({
    doInit: function (component, event, helper) {
        if (communityService.isInitialized()) {
            communityService.executeAction(
                component,
                'getVisitResultWrappersForDashboard',
                {},
                function (returnValue) {
                    if (returnValue.length) {
                        component.set('v.visitReportHeader', returnValue[0].recordtype + 's');
                        communityService.executeAction(
                            component,
                            'toggleState',
                            {
                                visitResultsMode: component.get('v.visitReportHeader')
                            },
                            function (returnValue) {
                                if (returnValue) {
                                    communityService.executeAction(
                                        component,
                                        'showVisitResults',
                                        {
                                        },
                                        function (response) {
                                            let toggleValue = returnValue && response;
                                            component.set('v.toggleVitalsIsOn', toggleValue);
                                        }
                                    );
                                }
                            }
                        );
                    }
                    returnValue.forEach(function (wrapper) {
                        if (wrapper.value) {
                            wrapper.value = +(Math.round(wrapper.value + 'e+3') + 'e-3');
                        }
                    });
                    component.set('v.visitResultWrappers', returnValue);
                    if (
                        component.get('v.visitResultWrappers[0].visitDate') ==
                        $A.get('$Label.StudyVisit_Information_Not_Available')
                    ) {
                        component.set('v.isVisitResultAvailable', false);
                    } else {
                        component.set('v.isVisitResultAvailable', true);
                    }
                    var trialId = component.get('v.ctpId');
                    component.set(
                        'v.VisitResultPage',
                        'study-workspace?id=' + trialId + '&tab=tab-lab-results'
                    );
                }
            );
        }
    },
    navigateToPage: function (component, event, helper) {
        var trialId = component.get('v.ctpId');
        communityService.navigateToPage('study-workspace?id=' + trialId + '&tab=tab-lab-results');
    }
});