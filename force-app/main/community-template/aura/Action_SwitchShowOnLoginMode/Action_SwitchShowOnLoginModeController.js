/**
 * Created by Leonid Bartenev
 */
({
    doExecute: function (component, event, helper) {
        var showOnLogin = event.getParam('arguments').showOnLogin;
        communityService.executeAction(component, 'switchShowOnLogin', {
            userMode: communityService.getUserMode(),
            showOnLogin: showOnLogin
        }, function () {
            communityService.setShowOnLogin(showOnLogin);
            $A.get('e.c:OnboardingSlideTourStartupModeChanged').fire();
        })
    }
})