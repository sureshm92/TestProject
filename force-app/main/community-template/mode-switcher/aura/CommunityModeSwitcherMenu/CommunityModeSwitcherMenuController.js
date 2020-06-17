/**
 * Created by Nargiz Mamedova on 6/11/2020.
 */

({
    doInit: function (component, event, helper) {
        // communityService.executeAction(component, 'getSwitcherInitData', null, function (returnValue) {
        //     const userData = JSON.parse(returnValue);
        //     component.set('v.user', userData.user);
        //     component.set('v.communityModes', userData.communityModes);
        //     component.set('v.currentMode', communityService.getCurrentCommunityMode());
        // });
    },

    logout: function (component, event, helper) {
        communityService.executeAction(component, 'getLogoutURL', null, function (url) {
            window.location.replace(url + "/secur/logout.jsp");
        })
    }
});