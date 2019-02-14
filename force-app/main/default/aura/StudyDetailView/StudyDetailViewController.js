({
    doInit: function (component, event, helper) {
        communityService.scrollToTop(true);
        var spinner = component.find('mainSpinner');
        spinner.show();
        var recId = communityService.getUrlParameter('id');
        var tabId = communityService.getUrlParameter('tab');
        if(tabId === undefined) tabId = 'tab-about-the-study'; //tab by default;

        if(communityService.isInitialized() && recId){
            component.set('v.userMode', communityService.getUserMode());
            component.set('v.multiMode', communityService.getCommunityTypes().length > 1);
            component.set('v.currentTab', tabId);
            helper.setTabInitialized(component);
            communityService.executeAction(component, 'getTrialDetail', {
                trialId: recId,
                userMode: communityService.getUserMode()
            }, function (returnValue) {
                var trialDetail = JSON.parse(returnValue);
                component.set('v.studyDetail', trialDetail);
                //get sticky bar position in browser window
                if(!component.get('v.isInitialized')) communityService.setStickyBarPosition();
                component.set('v.isInitialized', true);
                spinner.hide();
            });
        }
    },

     doAction: function (component, event) {
        var studyDetail = component.get('v.studyDetail');
        var trial = component.get('v.studyDetail').trial;
        var trialId = trial.Id;
        var actionId = event.currentTarget.id;
        switch (actionId){
            case 'medicalRecordReview':
                communityService.navigateToPage('medical-record-review?id=' + trialId);
                break;
            case 'referToThisStudy':
            case 'refer':
                communityService.navigateToPage('referring?id=' + trialId);
                break;
            case 'share':
                component.find('shareModal').show(studyDetail.hcpe);
                break;
            case 'viewTermsAndConditions':
                communityService.navigateToPage("trial-terms-and-conditions?id=" + trialId + "&ret=" + communityService.createRetString());
                break;
            case 'findStudySites':
                communityService.navigateToPage("study-workspace?id=" + trialId + "#studySitesAnchor");
                break;
            case 'noThanks':
                break;
            case 'manageReferrals':
                break;
            case 'manageReferringClinics':
                communityService.navigateToPage("study-workspace?id=" + trialId + "&tab=tab-referred-clinics");
                break;
            case 'openToReceiveReferrals':
        }
    },

    doScrollInto: function (component, event) {
        communityService.logError(function () {
            var tag = event.currentTarget.dataset.anchor;
            communityService.scrollInto(tag);
        });
    },

    doTabChanged: function(component, event, helper){
        helper.setTabInitialized(component);
    }

})