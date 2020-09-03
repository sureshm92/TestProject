/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        console.log(component.get('v.userMode'));
        console.log(component.get('v.studyDetail').trial.Id);
        component.set('v.communityName', communityService.getCurrentCommunityTemplateName())
        communityService.executeAction(component, 'getDocuments', {
            'role': component.get('v.userMode'),
            'ctpId': component.get('v.studyDetail').trial.Id,
        }, function (documents) {
            component.set('v.documents', documents);
        });
    },

    doChangeStudySite: function (component, event, helper) {
        communityService.logError(function () {
            var refreshSource = component.get('v.parent');
            var study = component.get('v.studyDetail').trial;
            var studySiteId = event.currentTarget.id;
            var hcpeId = component.get('v.studyDetail').hcpe.Id;
            component.find('sendSiteRequestAction').execute(study, studySiteId, hcpeId, refreshSource);
        });
    },


    doSelectNoSites: function(component){
        communityService.logError(function () {
            var refreshSource = component.get('v.parent');
            var study = component.get('v.studyDetail').trial;
            var hcpeId = component.get('v.studyDetail').hcpe.Id;
            component.find('sendSiteRequestAction').execute(study, null, hcpeId, refreshSource);
        });
    },

    doAction: function(component, event){
        var actionId = event.currentTarget.id;
        var trialId = component.get('v.studyDetail').trial.Id;
        switch (actionId){
            case 'noThanks':
                component.find('noTanksModal').show();
                break;
            case 'viewTermsAndConditions':
                communityService.navigateToPage("trial-terms-and-conditions?id=" + trialId + "&ret=" + communityService.createRetString());
                break;
            case 'findStudySites':
                component.find('mapAnchor').scrollInto();
                break;
            case 'openToReceiveReferrals':
                var trial = component.get('v.studyDetail').trial;
                component.find('openToReceiveReferralsModal').show(trial);
                break;
        }
    },

    onShareClick : function (component, event, helper) {
        let url = component.get('v.studyDetail').trial.Share_URL__c + 'none';
        let text = 'A clinical study of interest';
        let id = event.currentTarget.dataset.id;
        switch (id) {
            case 'email':
                helper.onEmailClick(component);
                break;
            case 'facebook':
                helper.onFacebookClick(component, url, text);
                break;
            case 'twitter':
                helper.onTwitterClick(component, url, text);
                break;
            case 'linkedin':
                helper.onLinkedInClick(component, url);
                break;
        }
    },

})