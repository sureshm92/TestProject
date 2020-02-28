/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        component.set('v.mode', communityService.getUserMode());
    },

    doGoHome: function () {
        communityService.navigateToPage('');
    }
})