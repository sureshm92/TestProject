({
    doAction: function (component, event) {
        var currentStudy = component.get('v.currentStudy');
        var trial = currentStudy.trial;
        var trialId = trial.Id;
        var parent = component.get('v.parent');
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
                //pass trial to 'Share' dialog:
                parent.find('shareModal').show(currentStudy.hcpe);
                break;
            case 'viewTermsAndConditions':
                communityService.navigateToPage("trial-terms-and-conditions?id=" + trialId + "&ret=" + communityService.createRetString());
                break;
            case 'findStudySites':
                communityService.navigateToPage("study-workspace?id=" + trialId + "#studySitesAnchor");
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
        }
    },

    toggleStudySiteListView: function(cmp, event, helper) {
        let detailsExpanded = cmp.get("v.detailsExpanded");
        if (detailsExpanded) {
            cmp.set("v.detailsExpanded", false);
        } else {
            cmp.set("v.detailsExpanded", true);
        }

    },

    navigateToSitesSearch : function (component, event, helper) {
        var currentStudy = component.get('v.currentStudy');
        var trial = currentStudy.trial;
        var trialId = trial.Id;
        communityService.navigateToPage("sites-search?id=" + trialId);
    },

    onEmailClick : function (component, event, helper) {
        var hcpe = component.get('v.currentStudy').hcpEnrollments[0];
        component.find('emailModal').show(hcpe);
    },

    onFacebookClick: function (component, event, helper) {
        window.open('https://www.facebook.com/sharer/sharer.php?u=https://www.clinicalresearch.com&quote=some_text');
    },

    onTwitterClick: function (component, event, helper) {
        window.open('https://twitter.com/home?status=some_text:%20https://www.clinicalresearch.com');
    },

    onLinkedInClick: function (component, event, helper) {
        window.open('https://www.linkedin.com/shareArticle?mini=true&url=https://www.clinicalresearch.com');
    }
})