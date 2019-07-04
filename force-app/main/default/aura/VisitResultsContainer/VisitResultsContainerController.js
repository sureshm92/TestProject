
(
    {
        doInit : function(component, event, helper) {

            component.set('v.initialized', false);
            var spinner = component.find('mainSpinner');
            if(spinner) {
                spinner.show();
            }
            communityService.executeAction(component, 'getVisitResultsGroupNames', {
                    visitResultsMode: component.get('v.labResultsMode')
                }, function (returnValue) {
                    component.set('v.visitResultsGroupNames', returnValue);
                    component.set('v.initialized', true);
                    var spinner = component.find('mainSpinner');
                    if(spinner) {
                        spinner.hide();
                    }
                }
            );
        },

    }
)