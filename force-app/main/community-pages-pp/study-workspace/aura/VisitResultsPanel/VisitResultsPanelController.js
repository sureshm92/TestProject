(
    {
        doInit : function(component, event, helper) {

            component.set('v.initialized', false);
            component.set('v.displayPanel', true);
            let asd = component.get('v.visitResultGroupName');
            let dsa = component.get('v.visitResultsShares');
            debugger
            let spinner = component.find('mainSpinner');
            if(spinner) {
                spinner.show();
            }
            let sad = component.get('v.visitResultsShares');
            debugger
            communityService.executeAction(component, 'getVisitResultsContainer', {
                    visitResultGroupName: component.get('v.visitResultGroupName'),
                    visitResultsShares: component.get('v.visitResultsShares')
                }, function (returnValue) {
                    if(returnValue === null) {
                        component.set('v.displayPanel', false);
                    } else {
                        component.set('v.visitResultsContainer', returnValue);
                        component.set('v.initialized', true);
                    }
                    let spinner = component.find('mainSpinner');
                    if(spinner) {
                        spinner.hide();
                    }
                }
            );
        },
    }
)