/**
 * Created by user on 21-Aug-19.
 */

({
    onShareClick: function (component, event, helper) {
        let url = component.get('v.currentStudy').trial.Share_URL__c + 'none';
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

    doAction: function (component, event) {
        var currentStudy = component.get('v.currentStudy');
        var trial = currentStudy.trial;
        var trialId = trial.Id;
        var parent = component.get('v.parent');
        var actionId = event.currentTarget.id;
        if (!actionId) actionId = event.getSource().getLocalId();
        switch (actionId) {
            case 'medicalRecordReview':
                communityService.navigateToPage('referring?id=' + trialId);
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
                communityService.navigateToPage('sites-search?id=' + trialId);
                break;
            case 'myPatients':
                communityService.navigateToPage('my-patients?id=' + trialId);
                break;
            case 'noThanks':
                var studySiteId = component.get('v.currentStudy.ssList')[event.currentTarget.value].studySite.Id;
                parent.showOpenNoTanksModal(trialId,studySiteId);
                break;
            case 'manageReferrals':
                communityService.navigateToPage("my-referrals?id=" + trialId);
                break;
            case 'manageReferralsBySS':
                var studySiteId = component.get('v.currentStudy.ssList')[event.currentTarget.value].studySite.Id;
                communityService.navigateToPage("my-referrals?id=" +trialId+"&siteId="+studySiteId);
                break;
            case 'manageReferringClinics':
                communityService.navigateToPage("study-workspace?id=" + trialId + "&tab=tab-referred-clinics");
                break;
            case 'manageReferringClinicsBySS':
                var studySiteId = component.get('v.currentStudy.ssList')[event.currentTarget.value].studySite.Id;
                communityService.navigateToPage("my-referring-clinics?id=" + trialId + "&ssId="+studySiteId);
                break;
            case 'openToReceiveReferrals':
                //pass trial to 'Iam open to receive...' dialog:
                var studySiteId = component.get('v.currentStudy.ssList')[event.currentTarget.value].studySite.Id;
                console.log('studySiteId',studySiteId);
                parent.find('receiveReferralsModal').show(trial,studySiteId);
                break;
            case 'linkToStudySites':
                communityService.navigateToPage('sites-search?id=' + trialId);
                break;
            case 'addPatient':
                var studySiteId = component.get('v.currentStudy.ssList')[event.currentTarget.value].studySite.Id;
                communityService.navigateToPage('add-patient?id=' + trialId + "&ssId=" + studySiteId);
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

});