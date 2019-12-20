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
            if(response === 'expired') {
                communityService.showInfoToast('', $A.get('$Label.c.Invitation_Expired'));
                communityService.navigateToHome();
            } else {
                var sw = JSON.parse(response);
                component.set('v.codeName', sw.studyCodeName);
                component.set('v.link', sw.url);
                component.set('v.surveyName', sw.name);
            }
        }, function () {
            communityService.navigateToHome();
        });
    },

    doFrameLoaded: function (component) {
        component.find('spinner').hide();
    }
})