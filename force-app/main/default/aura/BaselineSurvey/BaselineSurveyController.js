/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        if(!communityService.isInitialized()) return;
        communityService.executeAction(component, 'getBaselineSurveyURL', {
            userMode: communityService.getUserMode(),
            invitationId : communityService.getUrlParameter('inv')
        }, function (response) {
            var sw = JSON.parse(response);
            component.set('v.codeName', sw.studyCodeName);
            component.set('v.link', sw.url);
            component.set('v.surveyName', sw.name);
        }, function () {
            communityService.navigateToHome();
            //component.find('spinner').hide();
        });
    },

    doFrameLoaded: function (component) {
        component.find('spinner').hide();
    }
})