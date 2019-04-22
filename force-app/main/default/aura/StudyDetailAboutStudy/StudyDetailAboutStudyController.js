/**
 * Created by Leonid Bartenev
 */
({
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
    doChangePrimaryContact: function (component, event, helper) {
        var trialId = component.get('v.studyDetail').trial.Id;
        var primaryContactId = component.get('v.studyDetail').primaryContact;
        var spinner = component.find('mainSpinner');
        spinner.show();
        communityService.executeAction(component, 'setPrimaryContactForStudy', {
            trialId: trialId,
            primaryContactId: primaryContactId
        }, function (returnValue) {
            spinner.hide();
            communityService.showToast("success", "success", "Primary point of contact successfully updated for this study site.");
        });
    },


})