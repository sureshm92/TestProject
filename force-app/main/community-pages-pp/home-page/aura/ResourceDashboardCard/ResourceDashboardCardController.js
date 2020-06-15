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
        var navService = component.find("navService");
    var pageReference = {

        type: "comm__namedPage",
        attributes: {  
            pageName: "account-settings"  
        },    
        state: {
            sampleVar: true
        }
    };
    sessionStorage.setItem('pageTransfer', JSON.stringify(pageReference.state));  
    navService.navigate(pageReference);
}
   
})