({
    doAction: function (component, event) {
        var currentStudy = component.get('v.currentStudy');
        var trial = currentStudy.trial;
        var trialId = trial.Id;
        var parent = component.get('v.parent');
        var actionId = event.currentTarget.id;
        switch (actionId) {
            case 'medicalRecordReview':
                communityService.navigateToPage('medical-record-review?id=' + trialId);
                //communityService.navigateToPage('referring?id=' + trialId);
                break;
            case 'referToThisStudy':
            case 'refer':
                communityService.navigateToPage('referring?id=' + trialId);
                break;
            case 'share':
                //pass trial to 'Share' dialog:
                parent.find('shareModal').show(currentStudy.hcpe);
                break;
            case 'viewTermsAndConditions':
                communityService.navigateToPage("trial-terms-and-conditions?id=" + trialId + "&ret=" + communityService.createRetString());
                break;
            case 'findStudySites':
                //communityService.navigateToPage("study-workspace?id=" + trialId + "#studySitesAnchor");
                communityService.navigateToPage('sites-search?id=' + trialId);
                break;
            case 'noThanks':
                parent.showOpenNoTanksModal(trialId);
                break;
            case 'manageReferrals':
                communityService.navigateToPage("study-workspace?id=" + trialId + "&tab=tab-referrals");
                break;
            case 'manageReferringClinics':
                communityService.navigateToPage("study-workspace?id=" + trialId + "&tab=tab-referred-clinics");
                break;
            case 'openToReceiveReferrals':
                //pass trial to 'Iam open to receive...' dialog:
                parent.find('receiveReferralsModal').show(trial);
                break;
            case 'linkToStudySites':
                communityService.navigateToPage('sites-search?id=' + trialId);
                break;
        }
    },

    toggleStudySiteListView: function (cmp, event, helper) {
        let detailsExpanded = cmp.get("v.detailsExpanded");
        if (detailsExpanded) {
            cmp.set("v.detailsExpanded", false);
        } else {
            cmp.set("v.detailsExpanded", true);
        }
    },

    doReferPatient: function(cmp, event, helper) {
        var currentStudy = cmp.get('v.currentStudy');
        var trial = currentStudy.trial;
        var trialId = trial.Id;
        communityService.navigateToPage('referring?id=' + trialId);
    },

    doMyPatients: function(cmp, event, helper) {
        var currentStudy = cmp.get('v.currentStudy');
        var trial = currentStudy.trial;
        var trialId = trial.Id;
        communityService.navigateToPage('my-patients');
    },
    navigateToSitesSearch : function (component, event, helper) {
        var currentStudy = component.get('v.currentStudy');
        var trial = currentStudy.trial;
        var trialId = trial.Id;
        communityService.navigateToPage("sites-search?id=" + trialId);
    }
});