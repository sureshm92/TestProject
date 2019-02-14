({
    doInit: function (component, event, helper) {

        component.set("v.showSpinner", true);

        communityService.executeAction(component, 'getInitData', {
            userMode: component.get('v.userMode')
        }, function (returnValue) {
            debugger;
            var initData = JSON.parse(returnValue);
            component.set("v.delegates", initData.delegates);
            component.set("v.delegateOptions", initData.delegateOptions);
            component.set("v.showSpinner", false);
            component.set("v.hasStudies", initData.hasStudies);
        })

    },

    inviteTeamMembers: function (component, event, helper) {
        communityService.navigateToPage('new-team-member');
    }
})