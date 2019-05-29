/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        if(!communityService.isInitialized()) return;
        communityService.executeAction(component, 'getBaselineSurveyURL', {
            userMode: communityService.getUserMode(),
            psId : communityService.getUrlParameter('ps')
        }, function (response) {
            var initData = JSON.parse(response);
            component.set('v.ctp', initData.ctp);
            component.set('v.link', initData.surveyLink);
            component.set('v.surveyName', initData.surveyName);
        }, function () {
            communityService.navigateToHome();
            //component.find('spinner').hide();
        });
    },

    doFrameLoaded: function (component) {
        component.find('spinner').hide();
    }
})