({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getStudyDocuments', null, function (returnValue) {
            component.set('v.resourceWrappers', returnValue.wrappers);
            component.set('v.errorMessage', returnValue.errorMessage);
            component.find('spinner').hide();
        });
    }

})