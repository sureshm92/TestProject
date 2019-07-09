
(
    {
        doInit : function(component, event, helper) {

            component.set('v.initialized', false);
            let spinner = component.find('mainSpinner');
            if(spinner) {
                spinner.show();
            }
            if (communityService.isInitialized()) {
                communityService.executeAction(component, 'getInitData', {
                        visitResultsMode: component.get('v.labResultsMode')
                    }, function (returnValue) {
                    component.set('v.initData', returnValue);
                    component.set('v.initialized', true);
                    let spinner = component.find('mainSpinner');
                    if(spinner) {
                        spinner.hide();
                    }
                });
            }
        },

    }
)