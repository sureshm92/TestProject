/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        if(!communityService.isInitialized()) return;
        communityService.executeAction(component, 'getBaselineSurveyURL', {
            userMode: communityService.getUserMode()
        }, function (ctpJSON) {
            var ctp = JSON.parse(ctpJSON);
            debugger;
            component.set('v.ctp', ctp);
        }, function () {
            communityService.navigateToHome();
            //component.find('spinner').hide();
        });
    },

    doFrameLoaded: function (component) {
        component.find('spinner').hide();
    }
})