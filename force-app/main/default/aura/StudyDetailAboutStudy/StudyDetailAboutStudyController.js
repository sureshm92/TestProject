/**
 * Created by Leonid Bartenev
 */
({

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