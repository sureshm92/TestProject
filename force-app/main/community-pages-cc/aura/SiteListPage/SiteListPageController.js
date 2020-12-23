({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;

        if (!communityService.isDummy()) {
            let spinner = component.find('mainSpinner');
            spinner.show();
            component.set('v.userMode', communityService.getUserMode());
            component.set('v.isInitialized', true);
            spinner.hide();
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    }
});
