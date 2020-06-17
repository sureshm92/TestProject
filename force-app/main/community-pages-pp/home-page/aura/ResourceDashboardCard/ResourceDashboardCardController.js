({
    doInit: function (component, event, helper) {
        component.set('v.initialized', false);
        if (communityService.isInitialized()) {
            communityService.executeAction(component, 'getTrialId', {}, function (returnValue) {
                component.set('v.trialId', returnValue);
                communityService.executeAction(component, 'getNoTAMessage', {}, function (returnValue) {
                    component.set('v.noTAMessage', returnValue);
                    component.set('v.initialized', true);
                    let spinner = component.find('mainSpinner');
                    if (spinner) {
                        spinner.hide();
                    }
                });
            });
        }
    },
    navigateToCoi: function(component, event, helper){
    communityService.navigateToPage('account-settings?changePref');
}
   
})