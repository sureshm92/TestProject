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
                parent.find('shareModal').show(trial.Id, currentStudy.hcpe.HCP_Contact__c);
                break;
            case 'viewTermsAndConditions':
                communityService.navigateToPage("trial-terms-and-conditions?id=" + trialId + "&ret=" + communityService.createRetString());
                break;
            case 'findStudySites':
                //communityService.navigateToPage("study-workspace?id=" + trialId + "#studySitesAnchor");
                communityService.navigateToPage('sites-search?id=' + trialId);
                break;
            case 'myPatients':
                //communityService.navigateToPage("study-workspace?id=" + trialId + "#studySitesAnchor");
                communityService.navigateToPage('my-patients?id=' + trialId);
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
        var hcpeId = event.target.dataset.hcpeId;
        communityService.navigateToPage('referring?id=' + trialId +(hcpeId?'&hcpeid='+hcpeId:''));
    },

    doMyPatients: function(cmp, event, helper) {
        var currentStudy = cmp.get('v.currentStudy');
        var trial = currentStudy.trial;
        var trialId = trial.Id;
        debugger;
        var siteId = event.target.dataset.siteId;

        communityService.navigateToPage('my-patients?id='+trialId+(siteId?'&siteId='+siteId:''));
    },

    navigateToSitesSearch : function (component, event, helper) {
        var currentStudy = component.get('v.currentStudy');
        var trial = currentStudy.trial;
        var trialId = trial.Id;
        communityService.navigateToPage("sites-search?id=" + trialId);
    },

    onShareClick : function (component, event, helper) {
        var url = component.get('v.currentStudy').trial.Share_URL__c;
        console.log('URL: '+url);
        var id = event.target.dataset.id;
        console.log('Id share: '+id);
        switch (id) {
            case 'email':
                helper.onEmailClick(component);
                break;
            case 'facebook':
                helper.onFacebookClick(component, url);
                break;
            case 'twitter':
                helper.onTwitterClick(component, url);
                break;
            case 'linkedin':
                helper.onLinkedInClick(component, url);
                break;
        }
    }
})