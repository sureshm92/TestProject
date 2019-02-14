({
    doAcceptReferral: function (component, peId) {
        var spinner = component.find('mainSpinner');
        spinner.show();
        var action = component.get('c.acceptPE');
        action.setParams({
            peId: peId
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                component.set('v.piData', JSON.parse(response.getReturnValue()));
            } else {
                communityService.logErrorFromResponse(response);
                communityService.showErrorToastFromResponse(response);
            }
            component.set("v.tmpPEId", '');
            spinner.hide();
        });
        $A.enqueueAction(action);
    }
})