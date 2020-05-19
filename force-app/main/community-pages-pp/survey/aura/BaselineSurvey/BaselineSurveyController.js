/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if(!communityService.isInitialized()) return;

        if(!communityService.isDummy()) {
            component.find('spinner').show();
            communityService.executeAction(component, 'getBaselineSurveyURL', {
                userMode: communityService.getUserMode(),
                invitationId: communityService.getUrlParameter('inv')
            }, function (response) {
                if (response === 'expired') {
                    communityService.showInfoToast('', $A.get('$Label.c.Invitation_Expired'));
                    communityService.navigateToHome();
                } else {
                    let sw = JSON.parse(response);
                    component.set('v.codeName', sw.studyCodeName);
                    component.set('v.link', sw.url);
                    component.set('v.surveyName', sw.name);
                    component.set('v.initialized', true);
                }
            }, function () {
                communityService.navigateToHome();
            });
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    },

    doFrameLoaded: function (component) {
        component.find('spinner').hide();
    }
});