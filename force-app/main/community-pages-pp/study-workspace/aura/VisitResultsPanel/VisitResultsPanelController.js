({
    doInit: function (component, event, helper) {
        component.set('v.initialized', false);
        component.set('v.displayPanel', true);
        let spinner = component.find('mainSpinner');
        if (spinner) {
            spinner.show();
        }
        let visitResultsShares = JSON.stringify(component.get('v.initData.visitResultsShares'));
        communityService.executeAction(
            component,
            'getVisitResultsContainer',
            {
                visitResultGroupName: component.get('v.visitResultGroupName'),
                visitResultsShares: visitResultsShares
            },
            function (returnValue) {
                if (returnValue === null) {
                    component.set('v.displayPanel', false);
                } else {
                    component.set('v.visitResultsContainer', returnValue);
                    if (
                        component.get('v.visitResultsContainer.visitDate') ==
                        $A.get('$Label.StudyVisit_Information_Not_Available')
                    ) {
                        component.set('v.isVisitResultAvailable', false);
                    } else {
                        component.set('v.isVisitResultAvailable', true);
                    }
                    component.set('v.initialized', true);
                }
                let spinner = component.find('mainSpinner');
                if (spinner) {
                    spinner.hide();
                }
            }
        );
    }
});
